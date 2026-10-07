"""Partner and capper endpoints. Both are the same shape, so one router factory
builds /partners/... and /cappers/... ."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..crypto import decrypt, encrypt
from ..db import get_db
from ..models import Account, Figure, Party, PartyAccount, PartyKind, Admin
from ..schemas import (AccountCredentials, AccountOut, AssignIn, AssignmentOut, FigureCreate,
                       FigureOut, PartyCreate, PartyOut)
from ..security import READ, WRITE
from .accounts import to_out as account_out


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
                         account_id=pa.account_id, website=pa.account.website,
                         username=pa.account.username)


def build_router(kind: PartyKind, prefix: str) -> APIRouter:
    router = APIRouter(prefix=prefix, tags=[prefix.strip("/")])
    label = kind.value

    # --- create form + list / search dropdown ---
    @router.post("", response_model=PartyOut, status_code=201, dependencies=[Depends(WRITE)])
    def create(body: PartyCreate, db: Session = Depends(get_db)):
        key = body.name.lower()
        if db.scalar(select(Party.id).where(Party.kind == kind, Party.name_key == key)):
            raise HTTPException(status.HTTP_409_CONFLICT, f"{label.title()} name already exists")
        party = Party(kind=kind, name=body.name, name_key=key)
        db.add(party)
        try:
            db.commit()
        except IntegrityError:  # lost a race with a concurrent create
            db.rollback()
            raise HTTPException(status.HTTP_409_CONFLICT, f"{label.title()} name already exists")
        return party

    @router.get("", response_model=list[PartyOut], dependencies=[Depends(READ)])
    def list_parties(prefix: str | None = None, limit: int = 100, db: Session = Depends(get_db)):
        """All parties. With `prefix`, only names starting with it (case-insensitive) -
        use this for the type-ahead search fields."""
        q = select(Party).where(Party.kind == kind).order_by(Party.name_key).limit(min(limit, 1000))
        if prefix:
            q = q.where(Party.name_key.like(prefix.strip().lower().replace("%", r"\%")
                                            .replace("_", r"\_") + "%", escape="\\"))
        return db.scalars(q).all()

    # --- assign account ---
    @router.post("/{party_id}/accounts", response_model=AssignmentOut, status_code=201,
                 dependencies=[Depends(WRITE)])
    def assign(party_id: int, body: AssignIn, db: Session = Depends(get_db)):
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
            db.commit()
        except IntegrityError:
            db.rollback()
            raise HTTPException(status.HTTP_409_CONFLICT,
                                f"Account already assigned to this {label}")
        return _assignment_out(pa)

    @router.get("/{party_id}/accounts", response_model=list[AccountOut],
                dependencies=[Depends(READ)])
    def party_accounts(party_id: int, prefix: str | None = None, db: Session = Depends(get_db)):
        """Accounts under this party (second dropdown / account search). `prefix` filters
        by website name start."""
        _party(db, kind, party_id)
        q = (select(Account).join(PartyAccount, PartyAccount.account_id == Account.id)
             .where(PartyAccount.party_id == party_id).order_by(Account.website, Account.username))
        if prefix:
            q = q.where(Account.website.ilike(prefix.strip().replace("%", r"\%")
                                              .replace("_", r"\_") + "%", escape="\\"))
        return [account_out(a) for a in db.scalars(q)]

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
        return AccountCredentials(account_id=acct.id, website=acct.website,
                                  username=acct.username, password=decrypt(acct.password_enc))

    @router.post("/{party_id}/figures", response_model=FigureOut, status_code=201)
    def enter_figure(party_id: int, body: FigureCreate, db: Session = Depends(get_db),
                     user: Admin = Depends(WRITE)):
        party = _party(db, kind, party_id)
        acct = _assigned(db, party.id, body.account_id).account
        if body.username:
            acct.username = body.username.strip()
        if body.password:
            acct.password_enc = encrypt(body.password)
        fig = Figure(party_id=party.id, account_id=acct.id, amount=body.amount,
                     entered_by=user.id, **({"figure_date": body.figure_date}
                                            if body.figure_date else {}))
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
                     account_id=f.account_id, website=f.account.website,
                     username=f.account.username, amount=f.amount,
                     figure_date=f.figure_date, created_at=f.created_at)


partners = build_router(PartyKind.partner, "/partners")
cappers = build_router(PartyKind.capper, "/cappers")
