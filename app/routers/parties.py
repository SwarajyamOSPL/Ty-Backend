"""Partner and capper endpoints. Both are the same shape, so one router factory
builds /partners/... and /cappers/... ."""
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import case, distinct, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..accounts_view import accounts_out, recalc_all_weeks, week_param
from ..crypto import decrypt, encrypt
from ..db import get_db
from ..models import Account, AccountWebsite, Figure, Party, PartyAccount, PartyKind, Admin, SiteFigure
from ..schemas import (AccountCredentials, AccountOut, AssignIn, AssignmentOut, CapperFigureCreate,
                       ColorOut, FigureOut, PartnerFigureCreate, PartyCreate, PartyDetail, PartyOut,
                       RelatedParty)
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

    @router.get("", response_model=list[PartyOut], dependencies=[Depends(READ)])
    def list_parties(prefix: str | None = None, limit: int | None = Query(None, ge=1),
                     db: Session = Depends(get_db)):
        """All parties, A-Z. With `prefix`, only names starting with it (case-insensitive) -
        use this for the type-ahead search fields. `limit` is optional; without it every
        party is returned."""
        q = select(Party).where(Party.kind == kind).order_by(Party.name_key, Party.id)
        if limit:
            q = q.limit(limit)
        if prefix:
            q = q.where(Party.name_key.like(prefix.strip().lower().replace("%", r"\%")
                                            .replace("_", r"\_") + "%", escape="\\"))
        return db.scalars(q).all()

    # --- details of one partner / capper ---
    @router.get("/{party_id:int}", response_model=PartyDetail, dependencies=[Depends(READ)])
    def party_detail(party_id: int, start_date: date | None = None, end_date: date | None = None,
                     db: Session = Depends(get_db)):
        """Summary of this partner (or capper): number of accounts, balances, who it is linked to
        and (partners) the Site Figure total for the latest week, or for `start_date`..`end_date`."""
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
        return PartyDetail(
            id=party.id, name=party.name, created_at=party.created_at, account_count=account_count,
            shared_account_count=shared, total_balance=total_balance,
            accounts_without_numeric_balance=int(no_balance),
            cappers=related if kind == PartyKind.partner else [],
            partners=related if kind == PartyKind.capper else [],
            site_figure_start_date=sf_start, site_figure_end_date=sf_end, site_figure_total=sf_total,
            accounts_with_site_figure=sf_count)

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
    def party_accounts(party_id: int, prefix: str | None = None, username: str | None = None,
                       start_date: date | None = None, end_date: date | None = None,
                       db: Session = Depends(get_db)):
        """Accounts under this party (second dropdown / account search), each with its cappers,
        partners and Site Figure (latest week, or the week given by `start_date` and `end_date`).
        `prefix` filters by website name start, `username` by the start of the username."""
        week = week_param(start_date, end_date)
        _party(db, kind, party_id)
        q = (select(Account).join(PartyAccount, PartyAccount.account_id == Account.id)
             .where(PartyAccount.party_id == party_id).order_by(Account.id))
        if prefix:
            like = prefix.strip().replace("%", r"\%").replace("_", r"\_") + "%"
            q = q.where(Account.id.in_(select(AccountWebsite.account_id).where(
                AccountWebsite.website.ilike(like, escape="\\"))))
        if username:
            ulike = username.strip().replace("%", r"\%").replace("_", r"\_") + "%"
            q = q.where(Account.username.ilike(ulike, escape="\\"))
        return accounts_out(db, db.scalars(q).all(), week)

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
    def all_assignments(db: Session = Depends(get_db)):
        q = (select(PartyAccount).join(Party).where(Party.kind == kind)
             .order_by(PartyAccount.id.desc()))
        return [_assignment_out(pa) for pa in db.scalars(q)]

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
    def list_figures(party_id: int | None = None, account_id: int | None = None,
                     limit: int = 200, db: Session = Depends(get_db)):
        q = (select(Figure).join(Party).where(Party.kind == kind)
             .order_by(Figure.figure_date.desc(), Figure.id.desc()).limit(min(limit, 2000)))
        if party_id:
            q = q.where(Figure.party_id == party_id)
        if account_id:
            q = q.where(Figure.account_id == account_id)
        return [_figure_out(f) for f in db.scalars(q)]

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
