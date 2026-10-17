"""Partner and capper endpoints. Both are the same shape, so one router factory
builds /partners/... and /cappers/... ."""
from datetime import date
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import case, distinct, func, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..accounts_view import accounts_out, recalc_all_weeks, week_param
from ..crypto import decrypt, encrypt
from ..db import get_db
from ..listing import (Page, account_conditions, account_ids, account_search, contains, page_params,
                       paginate)
from ..models import (Account, AccountWebsite, Admin, Figure, Party, PartyAccount, PartyKind, SiteFigure,
                      UnregisteredFigure)
from ..schemas import (AccountCredentials, AccountOut, AssignIn, AssignmentOut, CapperFigureCreate,
                       ColorOut, FigureOut, PartnerFigureCreate, PartyCreate, PartyDetail, PartyListItem,
                       PartyOut, RelatedParty)
from ..security import READ, WRITE


def _party(db: Session, kind: PartyKind, party_id: int) -> Party:
    p = db.get(Party, party_id)
    if not p or p.kind != kind:
        raise HTTPException(status.HTTP_404_NOT_FOUND, f"{kind.value.title()} not found")
    return p


def _assigned(db: Session, party_id: int, account_id: int) -> PartyAccount:
    pa = db.scalar(select(PartyAccount).where(PartyAccount.party_id == party_id,
                                              PartyAccount.account_id == account_id))
    if not pa:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Account is not assigned to this party")
    return pa


def _assignment_out(pa: PartyAccount) -> AssignmentOut:
    return AssignmentOut(id=pa.id, party_id=pa.party_id, party_name=pa.party.name,
                         account_id=pa.account_id, websites=pa.account.websites,
                         username=pa.account.username)


CAPPER_COLORS = ["Green", "Lime Green", "Yellow", "Light Yellow", "Pink", "Light Pink", "Purple",
                 "Red", "Grey", "Black", "Orange", "Light Orange", "Blue", "Turquoise", "Teal",
                 "Maroon"]
_COLOR_BY_KEY = {c.lower(): c for c in CAPPER_COLORS}


def build_router(kind: PartyKind, prefix: str) -> APIRouter:
    router = APIRouter(prefix=prefix, tags=[prefix.strip("/")])
    label = kind.value
    body_model = PartnerFigureCreate if kind == PartyKind.partner else CapperFigureCreate

    # --- create form + list / search dropdown ---
    @router.post("", response_model=PartyOut, status_code=201, dependencies=[Depends(WRITE)])
    def create(body: PartyCreate, db: Session = Depends(get_db)):
        name = body.name
        if kind == PartyKind.capper:  # any name is allowed; known colors get their standard spelling
            name = " ".join(body.name.split())
            name = _COLOR_BY_KEY.get(name.lower(), name)
        key = name.lower()
        # capper names are unique (a capper is a color); partner names may repeat
        if kind == PartyKind.capper and db.scalar(
                select(Party.id).where(Party.kind == kind, Party.name_key == key)):
            raise HTTPException(status.HTTP_409_CONFLICT, f"{label.title()} name already exists")
        party = Party(kind=kind, name=name, name_key=key)
        db.add(party)
        try:
            db.commit()
        except IntegrityError:  # lost a race with a concurrent create
            db.rollback()
            raise HTTPException(status.HTTP_409_CONFLICT, f"{label.title()} name already exists")
        return party

    @router.get("", response_model=list[PartyListItem], dependencies=[Depends(READ)])
    def list_parties(response: Response, prefix: str | None = None, search: str | None = None,
                     pg: Page = Depends(page_params), db: Session = Depends(get_db)):
        """Parties A-Z, one page at a time (see app/listing.py). With `prefix`, only names
        starting with it (case-insensitive) - use this for the type-ahead search fields. With
        `search`, only names containing it."""
        q = select(Party).where(Party.kind == kind).order_by(Party.name_key, Party.id)
        if prefix:
            q = q.where(Party.name_key.like(prefix.strip().lower().replace("%", r"\%")
                                            .replace("_", r"\_") + "%", escape="\\"))
        if search and search.strip():
            q = q.where(contains(Party.name, search))
        rows = paginate(db, q, response, pg)
        counts = dict(db.execute(
            select(PartyAccount.party_id, func.count()).where(PartyAccount.party_id.in_([p.id for p in rows]))
            .group_by(PartyAccount.party_id)).all()) if rows else {}
        return [PartyListItem(id=p.id, name=p.name, created_at=p.created_at,
                              account_count=counts.get(p.id, 0)) for p in rows]

    # --- details of one partner / capper ---
    @router.get("/{party_id:int}", response_model=PartyDetail, dependencies=[Depends(READ)])
    def party_detail(party_id: int, start_date: date | None = None, end_date: date | None = None,
                     db: Session = Depends(get_db)):
        """Summary of this partner (or capper): number of accounts, balances, who it is linked to
        and (partners) the Site Figure total for the latest week, or for `start_date`..`end_date`.
        For a capper: `figure_total`, the sum of all its figures (all weeks), or only of the week
        `start_date`..`end_date` when given. `unregistered_figure_total` is the same sum over the sheet
        rows kept as unregistered, and `figure_total_all` is both added together."""
        week = week_param(start_date, end_date)
        party = _party(db, kind, party_id)
        mine = select(PartyAccount.account_id).where(PartyAccount.party_id == party_id)

        account_count = db.scalar(select(func.count()).select_from(mine.subquery())) or 0
        shared = db.scalar(
            select(func.count(distinct(PartyAccount.account_id)))
            .join(Party, Party.id == PartyAccount.party_id)
            .where(PartyAccount.account_id.in_(mine), Party.kind == kind,
                   PartyAccount.party_id != party_id)) or 0
        total_balance, no_balance = db.execute(
            select(func.coalesce(func.sum(Account.balance), 0),
                   func.coalesce(func.sum(case((Account.balance.is_(None), 1), else_=0)), 0))
            .where(Account.id.in_(mine))).one()

        other = PartyKind.capper if kind == PartyKind.partner else PartyKind.partner
        related = [RelatedParty(id=i, name=n, account_count=k) for i, n, k in db.execute(
            select(Party.id, Party.name, func.count(distinct(PartyAccount.account_id)))
            .join(PartyAccount, PartyAccount.party_id == Party.id)
            .where(PartyAccount.account_id.in_(mine), Party.kind == other)
            .group_by(Party.id, Party.name, Party.name_key)
            .order_by(func.count(distinct(PartyAccount.account_id)).desc(), Party.name_key, Party.id))]

        sf_start = sf_end = sf_total = None
        sf_count = 0
        if kind == PartyKind.partner:
            if week is None:
                latest = db.execute(select(SiteFigure.start_date, SiteFigure.end_date)
                                    .where(SiteFigure.account_id.in_(mine))
                                    .order_by(SiteFigure.end_date.desc(), SiteFigure.start_date.desc())
                                    .limit(1)).first()
                week = (latest[0], latest[1]) if latest else None
            if week:
                sf_start, sf_end = week
                sf_total, sf_count = db.execute(
                    select(func.coalesce(func.sum(SiteFigure.site_figure), 0), func.count())
                    .where(SiteFigure.account_id.in_(mine), SiteFigure.start_date == week[0],
                           SiteFigure.end_date == week[1])).one()
        fig_total = unr_total = all_total = None
        fig_count = fig_weeks = unr_count = 0
        if kind == PartyKind.capper:
            q = select(Figure.account_id, Figure.start_date, Figure.end_date, Figure.figure).where(
                Figure.party_id == party_id).order_by(Figure.id)
            if week:
                q = q.where(Figure.start_date == week[0], Figure.end_date == week[1])
            latest: dict[tuple, Decimal] = {}  # one figure per account and week: the latest entry wins
            for account_id, f_start, f_end, figure in db.execute(q):
                latest[(account_id, f_start, f_end)] = figure
            fig_total = sum(latest.values(), Decimal("0"))
            fig_count = len(latest)
            fig_weeks = len({(k[1], k[2]) for k in latest})
            uq = select(func.coalesce(func.sum(UnregisteredFigure.figure), 0), func.count()).where(
                UnregisteredFigure.capper_id == party_id)
            if week:
                uq = uq.where(UnregisteredFigure.start_date == week[0], UnregisteredFigure.end_date == week[1])
            unr_total, unr_count = db.execute(uq).one()
            unr_total = Decimal(unr_total)
            all_total = fig_total + unr_total
        return PartyDetail(
            id=party.id, name=party.name, created_at=party.created_at, account_count=account_count,
            shared_account_count=shared, total_balance=total_balance,
            accounts_without_numeric_balance=int(no_balance),
            cappers=related if kind == PartyKind.partner else [],
            partners=related if kind == PartyKind.capper else [],
            site_figure_start_date=sf_start, site_figure_end_date=sf_end, site_figure_total=sf_total,
            accounts_with_site_figure=sf_count, figure_total=fig_total, figure_count=fig_count,
            figure_weeks=fig_weeks, unregistered_figure_total=unr_total, unregistered_figure_count=unr_count,
            figure_total_all=all_total,
            figure_start_date=week[0] if kind == PartyKind.capper and week else None,
            figure_end_date=week[1] if kind == PartyKind.capper and week else None)

    # --- assign account ---
    @router.post("/{party_id}/accounts", response_model=AssignmentOut, status_code=201,
                 dependencies=[Depends(WRITE)])
    def assign(party_id: int, body: AssignIn, db: Session = Depends(get_db),
               user: Admin = Depends(WRITE)):
        party = _party(db, kind, party_id)
        if not db.get(Account, body.account_id):
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Account not found")
        if db.scalar(select(PartyAccount.id).where(PartyAccount.party_id == party.id,
                                                   PartyAccount.account_id == body.account_id)):
            raise HTTPException(status.HTTP_409_CONFLICT,
                                f"Account already assigned to this {label}")
        pa = PartyAccount(party_id=party.id, account_id=body.account_id)
        db.add(pa)
        try:
            if kind == PartyKind.capper:  # figures this capper already has for the account now count
                recalc_all_weeks(db, body.account_id, user.id)
            db.commit()
        except IntegrityError:
            db.rollback()
            raise HTTPException(status.HTTP_409_CONFLICT,
                                f"Account already assigned to this {label}")
        return _assignment_out(pa)

    @router.get("/{party_id}/accounts", response_model=list[AccountOut],
                dependencies=[Depends(READ)])
    def party_accounts(response: Response, party_id: int, prefix: str | None = None,
                       username: str | None = None, website: str | None = None,
                       partner: str | None = None, capper: str | None = None,
                       search: str | None = None, start_date: date | None = None,
                       end_date: date | None = None, pg: Page = Depends(page_params),
                       db: Session = Depends(get_db)):
        """Accounts under this party (second dropdown / account search), one page at a time (see
        app/listing.py), each with its cappers, partners and Site Figure (latest week, or the
        week given by `start_date` and `end_date`). `prefix` filters by website name start; the
        other filters are case-insensitive "contains": `username`, `website`, `partner` and
        `capper` (name), and `search`, one box over all four."""
        week = week_param(start_date, end_date)
        _party(db, kind, party_id)
        q = (select(Account).join(PartyAccount, PartyAccount.account_id == Account.id)
             .where(PartyAccount.party_id == party_id,
                    *account_conditions(search=search, username=username, website=website,
                                        partner=partner, capper=capper))
             .order_by(Account.id))
        if prefix:
            like = prefix.strip().replace("%", r"\%").replace("_", r"\_") + "%"
            q = q.where(Account.id.in_(select(AccountWebsite.account_id).where(
                AccountWebsite.website.ilike(like, escape="\\"))))
        return accounts_out(db, paginate(db, q, response, pg), week)

    @router.delete("/{party_id}/accounts/{account_id}", status_code=204)
    def unassign(party_id: int, account_id: int, db: Session = Depends(get_db),
                 user: Admin = Depends(WRITE)):
        """Removes the account from this partner/capper. The account itself stays. Removing a
        capper recalculates the account's Site Figure without that capper."""
        _party(db, kind, party_id)
        db.delete(_assigned(db, party_id, account_id))
        if kind == PartyKind.capper:
            recalc_all_weeks(db, account_id, user.id)
        db.commit()

    @router.get("/assignments/all", response_model=list[AssignmentOut],
                dependencies=[Depends(READ)])
    def all_assignments(response: Response, party: str | None = None, username: str | None = None,
                        website: str | None = None, search: str | None = None,
                        pg: Page = Depends(page_params), db: Session = Depends(get_db)):
        """Assignments, newest first, one page at a time (see app/listing.py). Case-insensitive
        "contains" filters: `party` (the partner/capper name), `username`, `website`, and
        `search`, one box over all three."""
        q = (select(PartyAccount).join(Party, Party.id == PartyAccount.party_id)
             .where(Party.kind == kind).order_by(PartyAccount.id.desc()))
        if party and party.strip():
            q = q.where(contains(Party.name, party))
        conds = account_conditions(username=username, website=website)
        if conds:
            q = q.where(PartyAccount.account_id.in_(account_ids(conds)))
        if search and search.strip():
            q = q.where(or_(contains(Party.name, search),
                            PartyAccount.account_id.in_(account_ids([account_search(search)]))))
        return [_assignment_out(pa) for pa in paginate(db, q, response, pg)]

    # --- enter figure ---
    @router.get("/{party_id}/accounts/{account_id}/credentials",
                response_model=AccountCredentials, dependencies=[Depends(WRITE)])
    def credentials(party_id: int, account_id: int, db: Session = Depends(get_db)):
        """Pre-fills the enter-figure form once an account is selected."""
        _party(db, kind, party_id)
        acct = _assigned(db, party_id, account_id).account
        return AccountCredentials(account_id=acct.id, websites=acct.websites,
                                  username=acct.username, password=decrypt(acct.password_enc))

    @router.post("/figures", response_model=FigureOut, status_code=201)
    def enter_figure(body: body_model, db: Session = Depends(get_db),
                     user: Admin = Depends(WRITE)):
        party = _party(db, kind, getattr(body, f"{label}_id"))
        acct = _assigned(db, party.id, body.account_id).account
        if body.username:
            acct.username = body.username.strip()
        if body.password:
            acct.password_enc = encrypt(body.password)
        fig = Figure(party_id=party.id, account_id=acct.id, figure=body.figure,
                     start_date=getattr(body, "start_date", None),
                     end_date=getattr(body, "end_date", None), entered_by=user.id)
        db.add(fig)
        db.commit()
        return _figure_out(fig)

    @router.get("/figures/all", response_model=list[FigureOut], dependencies=[Depends(READ)])
    def list_figures(response: Response, party_id: int | None = None, account_id: int | None = None,
                     party: str | None = None, username: str | None = None,
                     website: str | None = None, search: str | None = None,
                     pg: Page = Depends(page_params), db: Session = Depends(get_db)):
        """Entered figures, newest first, one page at a time (see app/listing.py). Case-insensitive
        "contains" filters: `party` (the partner/capper name), `username`, `website`, and
        `search`, one box over all three."""
        q = (select(Figure).join(Party, Party.id == Figure.party_id).where(Party.kind == kind)
             .order_by(Figure.figure_date.desc(), Figure.id.desc()))
        if party_id:
            q = q.where(Figure.party_id == party_id)
        if account_id:
            q = q.where(Figure.account_id == account_id)
        if party and party.strip():
            q = q.where(contains(Party.name, party))
        conds = account_conditions(username=username, website=website)
        if conds:
            q = q.where(Figure.account_id.in_(account_ids(conds)))
        if search and search.strip():
            q = q.where(or_(contains(Party.name, search),
                            Figure.account_id.in_(account_ids([account_search(search)]))))
        return [_figure_out(f) for f in paginate(db, q, response, pg)]

    return router


def _figure_out(f: Figure) -> FigureOut:
    return FigureOut(id=f.id, party_id=f.party_id, party_name=f.party.name,
                     account_id=f.account_id, websites=f.account.websites,
                     username=f.account.username, figure=f.figure,
                     figure_date=f.figure_date, start_date=f.start_date, end_date=f.end_date,
                     created_at=f.created_at)


partners = build_router(PartyKind.partner, "/partners")
cappers = build_router(PartyKind.capper, "/cappers")


@cappers.get("/colors", response_model=list[ColorOut], dependencies=[Depends(READ)])
def capper_colors(db: Session = Depends(get_db)):
    """Suggested capper names (colors), flagged with whether that capper already exists.
    Suggestions only: POST /cappers accepts any unique name."""
    existing = set(db.scalars(select(Party.name_key).where(Party.kind == PartyKind.capper)))
    return [ColorOut(name=c, created=c.lower() in existing) for c in CAPPER_COLORS]
