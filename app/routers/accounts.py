from datetime import date
from decimal import Decimal

from cryptography.fernet import InvalidToken
from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from ..accounts_view import accounts_out, recalc_all_weeks, week_param
from ..crypto import decrypt, encrypt
from ..db import get_db
from ..listing import Page, account_conditions, page_params, paginate
from ..models import Account, AccountWebsite, Admin, Party, PartyAccount, PartyKind, SiteFigure
from ..schemas import AccountCreate, AccountOut, AccountSiteFigure, CapperIds
from ..security import READ, WRITE

router = APIRouter(prefix="/accounts", tags=["accounts"])


def _parties(db: Session, ids: list[int], kind: PartyKind, label: str) -> list[Party]:
    found = {p.id: p for p in db.scalars(select(Party).where(Party.id.in_(set(ids))))} if ids else {}
    for i in dict.fromkeys(ids):
        if i not in found or found[i].kind != kind:
            raise HTTPException(status.HTTP_404_NOT_FOUND, f"{label} {i} not found")
    return [found[i] for i in dict.fromkeys(ids)]


def _link(db: Session, account_id: int, parties: list[Party]) -> list[Party]:
    """Assign the account to these partners/cappers; returns the ones that were new."""
    if not parties:
        return []
    have = set(db.scalars(select(PartyAccount.party_id).where(
        PartyAccount.account_id == account_id, PartyAccount.party_id.in_([p.id for p in parties]))))
    new = [p for p in parties if p.id not in have]
    db.add_all(PartyAccount(party_id=p.id, account_id=account_id) for p in new)
    return new


def _split(v):
    """A parsed balance / max win as (number, text): exactly one of them is set (or neither)."""
    return (v, None) if isinstance(v, Decimal) else (None, v)


def _find_shared(db: Session, websites: list[str], username: str | None, password: str | None):
    """An existing account with exactly these credentials (same websites, username, password)."""
    if not username:
        return None
    sites = {w.lower() for w in websites}
    for a in db.scalars(select(Account).where(func.lower(Account.username) == username.lower())):
        if {w.lower() for w in a.websites} != sites:
            continue
        try:
            same_password = (decrypt(a.password_enc) or "") == (password or "")
        except InvalidToken:
            same_password = False
        if same_password:
            return a
    return None


@router.post("", response_model=AccountOut, status_code=201)
def create_account(body: AccountCreate, response: Response, db: Session = Depends(get_db),
                   user: Admin = Depends(WRITE)):
    """Creates an account (201). If an account with the same websites, username and password
    already exists, that account is shared instead of duplicated: it is returned with 200 and
    any `partner_ids` / `capper_ids` are added to it (fields it has not got yet are filled in)."""
    partners = _parties(db, body.partner_ids, PartyKind.partner, "Partner")
    cappers = _parties(db, body.capper_ids, PartyKind.capper, "Capper")
    username = (body.username or "").strip() or None
    city = (body.city or "").strip() or None
    balance, balance_text = _split(body.balance)
    max_win, max_win_text = _split(body.max_win)

    acct = _find_shared(db, body.websites, username, body.password)
    if acct:
        response.status_code = status.HTTP_200_OK
        if acct.balance is None and not acct.balance_text and body.balance is not None:
            acct.balance, acct.balance_text = balance, balance_text
        if acct.max_win is None and not acct.max_win_text and body.max_win is not None:
            acct.max_win, acct.max_win_text = max_win, max_win_text
        if not acct.city and city:
            acct.city = city
    else:
        acct = Account(username=username, password_enc=encrypt(body.password), balance=balance,
                       balance_text=balance_text, max_win=max_win, max_win_text=max_win_text, city=city,
                       website_rows=[AccountWebsite(website=w) for w in body.websites])
        db.add(acct)
    db.flush()
    _link(db, acct.id, partners)
    if _link(db, acct.id, cappers):
        recalc_all_weeks(db, acct.id, user.id)  # figures a newly added capper already has now count
    db.commit()
    return accounts_out(db, [acct])[0]


@router.get("", response_model=list[AccountOut], dependencies=[Depends(READ)])
def list_accounts(response: Response, website: str | None = None, username: str | None = None,
                  partner: str | None = None, capper: str | None = None, search: str | None = None,
                  start_date: date | None = None, end_date: date | None = None,
                  pg: Page = Depends(page_params), db: Session = Depends(get_db)):
    """Accounts, newest first, one page at a time (see app/listing.py), each with its cappers,
    partners and Site Figure. Filters (case-insensitive "contains", all must match): `website`
    (any of the account's websites), `username`, `partner` and `capper` (name), and `search`,
    one box over all four. The Site Figure is the latest week's unless `start_date` and
    `end_date` ask for a specific week."""
    week = week_param(start_date, end_date)
    q = (select(Account).where(*account_conditions(search=search, username=username, website=website,
                                                   partner=partner, capper=capper))
         .order_by(Account.id.desc()))
    return accounts_out(db, paginate(db, q, response, pg), week)


@router.get("/{account_id}", response_model=AccountOut, dependencies=[Depends(READ)])
def get_account(account_id: int, start_date: date | None = None, end_date: date | None = None,
                db: Session = Depends(get_db)):
    week = week_param(start_date, end_date)
    acct = db.get(Account, account_id)
    if not acct:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Account not found")
    return accounts_out(db, [acct], week)[0]


@router.put("/{account_id}/cappers", response_model=AccountOut)
def set_account_cappers(account_id: int, body: CapperIds, db: Session = Depends(get_db),
                        user: Admin = Depends(WRITE)):
    """Sets the account's list of cappers: adds the missing ones and removes the others. The
    Site Figure is recalculated for every week the account has figures for."""
    acct = db.get(Account, account_id)
    if not acct:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Account not found")
    wanted = _parties(db, body.capper_ids, PartyKind.capper, "Capper")
    keep = {p.id for p in wanted}
    for pa in db.scalars(select(PartyAccount).join(Party, Party.id == PartyAccount.party_id)
                         .where(PartyAccount.account_id == account_id, Party.kind == PartyKind.capper)):
        if pa.party_id not in keep:
            db.delete(pa)
    db.flush()
    _link(db, account_id, wanted)
    recalc_all_weeks(db, account_id, user.id)
    db.commit()
    return accounts_out(db, [acct])[0]


@router.get("/{account_id}/site-figures", response_model=list[AccountSiteFigure],
            dependencies=[Depends(READ)])
def account_site_figures(account_id: int, response: Response, pg: Page = Depends(page_params),
                         db: Session = Depends(get_db)):
    """The account's Site Figure for every week, newest first, one page at a time."""
    if not db.get(Account, account_id):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Account not found")
    rows = paginate(db, select(SiteFigure).where(SiteFigure.account_id == account_id)
                    .order_by(SiteFigure.start_date.desc(), SiteFigure.id.desc()), response, pg)
    return [AccountSiteFigure(start_date=r.start_date, end_date=r.end_date, site_figure=r.site_figure,
                              calculated_at=r.calculated_at) for r in rows]
