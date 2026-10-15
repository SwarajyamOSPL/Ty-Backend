"""Site Figures.

An account's Site Figure for a week is the sum (can be negative) of the figures of every capper
assigned to the account for that week. It is saved per account and week (shared by all partners
that have the account) and is recalculated automatically when capper sheets are imported or a
capper is assigned/removed (see app/accounts_view.py). The endpoints here show how a Site Figure
is made up and let it be recalculated by hand, and list the saved values.
"""
from datetime import date
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..accounts_view import _links, recalc_site_figures
from ..db import get_db
from ..listing import Page, account_conditions, account_ids, page_params, paginate
from ..models import Admin, Figure, Party, PartyAccount, PartyKind, SiteFigure
from ..schemas import (AssignedCapper, CapperContribution, SavedSiteFigure, SiteFigureOut,
                       SiteFigureView, WeekRange)
from ..security import READ, WRITE
from .parties import _assigned, _party

router = APIRouter(prefix="/partners", tags=["site-figures"])
all_router = APIRouter(prefix="/site-figures", tags=["site-figures"])


def _cappers_of_account(db: Session, account_id: int) -> list[Party]:
    return db.scalars(select(Party).join(PartyAccount, PartyAccount.party_id == Party.id)
                      .where(Party.kind == PartyKind.capper, PartyAccount.account_id == account_id)
                      .order_by(Party.name_key)).all()


def _saved_row(db: Session, account_id: int, week: WeekRange):
    return db.scalar(select(SiteFigure).where(
        SiteFigure.account_id == account_id, SiteFigure.start_date == week.start_date,
        SiteFigure.end_date == week.end_date))


def _view(db: Session, partner: Party, account, week: WeekRange) -> SiteFigureView:
    cappers = _cappers_of_account(db, account.id)
    # a capper may have several rows for the same week (manual entries); the latest one wins
    latest: dict[int, Decimal] = {}
    if cappers:
        rows = db.scalars(select(Figure).where(
            Figure.account_id == account.id, Figure.party_id.in_([c.id for c in cappers]),
            Figure.start_date == week.start_date, Figure.end_date == week.end_date
        ).order_by(Figure.id))
        latest = {f.party_id: f.figure for f in rows}
    contributions = [CapperContribution(capper_id=c.id, capper_name=c.name, figure=latest.get(c.id))
                     for c in cappers]
    saved = _saved_row(db, account.id, week)
    return SiteFigureView(
        partner_id=partner.id, partner_name=partner.name, account_id=account.id,
        username=account.username, websites=account.websites, start_date=week.start_date,
        end_date=week.end_date, cappers=contributions,
        total=sum((c.figure for c in contributions if c.figure is not None), Decimal("0")),
        missing_cappers=[c.capper_name for c in contributions if c.figure is None],
        saved=SavedSiteFigure(id=saved.id, site_figure=saved.site_figure,
                              calculated_at=saved.calculated_at) if saved else None)


@router.get("/{party_id}/accounts/{account_id}/cappers", response_model=list[AssignedCapper],
            dependencies=[Depends(READ)])
def account_cappers(party_id: int, account_id: int, db: Session = Depends(get_db)):
    """The cappers assigned to this account (shown after picking a username)."""
    _party(db, PartyKind.partner, party_id)
    acct = _assigned(db, party_id, account_id).account
    return [AssignedCapper(capper_id=c.id, capper_name=c.name)
            for c in _cappers_of_account(db, acct.id)]


@router.get("/{party_id}/accounts/{account_id}/site-figure", response_model=SiteFigureView,
            dependencies=[Depends(READ)])
def preview_site_figure(party_id: int, account_id: int, start_date: date = Query(...),
                        end_date: date = Query(...), db: Session = Depends(get_db)):
    """How the account's Site Figure for the week is made up: each assigned capper's figure and
    their sum, and the stored Site Figure. Saves nothing."""
    if end_date < start_date:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY,
                            "end_date must not be before start_date")
    partner = _party(db, PartyKind.partner, party_id)
    acct = _assigned(db, party_id, account_id).account
    return _view(db, partner, acct, WeekRange(start_date=start_date, end_date=end_date))


@router.post("/{party_id}/accounts/{account_id}/site-figure", response_model=SiteFigureView)
def save_site_figure(party_id: int, account_id: int, week: WeekRange,
                     db: Session = Depends(get_db), user: Admin = Depends(WRITE)):
    """Recalculates the account's Site Figure for the week by hand (imports already do this
    automatically). Overwrites the stored value for that account and week."""
    partner = _party(db, PartyKind.partner, party_id)
    acct = _assigned(db, party_id, account_id).account
    view = _view(db, partner, acct, week)
    if not view.cappers:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY,
                            "No capper is assigned to this account")
    if len(view.missing_cappers) == len(view.cappers):
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY,
                            f"No capper has a figure for this account for "
                            f"{week.start_date} to {week.end_date}. Import the capper sheets first")
    recalc_site_figures(db, [acct.id], (week.start_date, week.end_date), user.id)
    db.commit()
    return _view(db, partner, acct, week)


@all_router.get("", response_model=list[SiteFigureOut], dependencies=[Depends(READ)])
def list_site_figures(response: Response, partner_id: int | None = None, account_id: int | None = None,
                      start_date: date | None = None, end_date: date | None = None,
                      username: str | None = None, website: str | None = None,
                      partner: str | None = None, capper: str | None = None,
                      search: str | None = None, pg: Page = Depends(page_params),
                      db: Session = Depends(get_db)):
    """Saved Site Figures (one per account and week), newest week first, one page at a time (see
    app/listing.py). `partner_id` limits them to that partner's accounts. Case-insensitive
    "contains" filters on the account: `username`, `website`, `partner` and `capper` (name), and
    `search`, one box over all four."""
    q = select(SiteFigure).order_by(SiteFigure.start_date.desc(), SiteFigure.id.desc())
    if partner_id:
        q = q.where(SiteFigure.account_id.in_(
            select(PartyAccount.account_id).where(PartyAccount.party_id == partner_id)))
    if account_id:
        q = q.where(SiteFigure.account_id == account_id)
    if start_date:
        q = q.where(SiteFigure.start_date >= start_date)
    if end_date:
        q = q.where(SiteFigure.end_date <= end_date)
    conds = account_conditions(search=search, username=username, website=website,
                               partner=partner, capper=capper)
    if conds:
        q = q.where(SiteFigure.account_id.in_(account_ids(conds)))
    rows = paginate(db, q, response, pg)
    _, partners = _links(db, sorted({r.account_id for r in rows}))
    return [SiteFigureOut(id=s.id, account_id=s.account_id, username=s.account.username,
                          websites=s.account.websites, partners=partners.get(s.account_id, []),
                          start_date=s.start_date, end_date=s.end_date, site_figure=s.site_figure,
                          calculated_at=s.calculated_at) for s in rows]
