"""Account responses and the Site Figure calculation (used by several routers).

Site Figure of an account for a week = the sum (positive or negative) of the figures of every
capper CURRENTLY assigned to that account for that week. It is one value per account and week -
not per partner - so partners that share an account see the same number. It is recalculated
automatically whenever capper figures are imported or a capper is assigned/removed.
"""
from datetime import date
from decimal import Decimal
from typing import Iterable

from fastapi import HTTPException, status
from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session

from .models import Account, Figure, Party, PartyAccount, PartyKind, SiteFigure
from .schemas import AccountOut, PartyRef

Week = tuple[date, date]
CHUNK = 500  # keeps "IN (...)" lists small for every database


def _chunks(ids: Iterable[int]):
    ids = list(ids)
    for i in range(0, len(ids), CHUNK):
        yield ids[i:i + CHUNK]


def _links(db: Session, account_ids: list[int]):
    """(cappers, partners) per account id, each a list of PartyRef sorted by name."""
    cappers: dict[int, list[PartyRef]] = {}
    partners: dict[int, list[PartyRef]] = {}
    for chunk in _chunks(account_ids):
        rows = db.execute(
            select(PartyAccount.account_id, Party.id, Party.name, Party.kind)
            .select_from(PartyAccount).join(Party, Party.id == PartyAccount.party_id)
            .where(PartyAccount.account_id.in_(chunk)).order_by(Party.name_key)).all()
        for account_id, pid, name, kind in rows:
            (cappers if kind == PartyKind.capper else partners).setdefault(account_id, []).append(
                PartyRef(id=pid, name=name))
    return cappers, partners


def site_figures_for(db: Session, account_ids: list[int], week: Week | None = None) -> dict[int, SiteFigure]:
    """The stored Site Figure per account: for the given week, or else the latest week."""
    found: dict[int, SiteFigure] = {}
    for chunk in _chunks(account_ids):
        if week:
            q = select(SiteFigure).where(SiteFigure.account_id.in_(chunk),
                                         SiteFigure.start_date == week[0], SiteFigure.end_date == week[1])
        else:
            latest = (select(SiteFigure.account_id.label("aid"), func.max(SiteFigure.end_date).label("mx"))
                      .where(SiteFigure.account_id.in_(chunk)).group_by(SiteFigure.account_id).subquery())
            q = select(SiteFigure).join(latest, and_(SiteFigure.account_id == latest.c.aid,
                                                     SiteFigure.end_date == latest.c.mx))
        for row in db.scalars(q.order_by(SiteFigure.id)):
            found[row.account_id] = row
    return found


def accounts_out(db: Session, accounts: list[Account], week: Week | None = None) -> list[AccountOut]:
    """Account responses with cappers, partners and Site Figure (a handful of queries in total)."""
    ids = [a.id for a in accounts]
    cappers, partners = _links(db, ids)
    sites = site_figures_for(db, ids, week)
    out = []
    for a in accounts:
        s = sites.get(a.id)
        out.append(AccountOut(
            id=a.id, websites=a.websites, username=a.username, has_password=bool(a.password_enc),
            balance=a.balance if a.balance is not None else a.balance_text,
            max_win=a.max_win if a.max_win is not None else a.max_win_text, city=a.city,
            site_figure=s.site_figure if s else None,
            site_figure_start_date=s.start_date if s else None,
            site_figure_end_date=s.end_date if s else None,
            cappers=cappers.get(a.id, []), partners=partners.get(a.id, [])))
    return out


def recalc_site_figures(db: Session, account_ids: Iterable[int], week: Week, user_id: int | None = None) -> int:
    """Recalculate and store the Site Figure of these accounts for one week. Returns how many
    accounts now have a Site Figure for the week. Call db.flush() first if figures were just added.
    An account no cappers have a figure for (any more) loses its Site Figure for the week."""
    ids = sorted(set(account_ids))
    totals: dict[int, Decimal] = {}
    for chunk in _chunks(ids):
        rows = db.execute(
            select(Figure.account_id, Figure.party_id, Figure.figure)
            .join(PartyAccount, and_(PartyAccount.account_id == Figure.account_id,
                                     PartyAccount.party_id == Figure.party_id))
            .join(Party, Party.id == Figure.party_id)
            .where(Party.kind == PartyKind.capper, Figure.start_date == week[0],
                   Figure.end_date == week[1], Figure.account_id.in_(chunk))
            .order_by(Figure.id)).all()
        latest: dict[tuple[int, int], Decimal] = {}  # a capper may have several rows: the latest wins
        for account_id, capper_id, figure in rows:
            latest[(account_id, capper_id)] = figure
        for (account_id, _), figure in latest.items():
            totals[account_id] = totals.get(account_id, Decimal("0")) + figure

    existing: dict[int, SiteFigure] = {}
    for chunk in _chunks(ids):
        for row in db.scalars(select(SiteFigure).where(
                SiteFigure.account_id.in_(chunk), SiteFigure.start_date == week[0],
                SiteFigure.end_date == week[1])):
            existing[row.account_id] = row
    for account_id in ids:
        row = existing.get(account_id)
        if account_id in totals:
            if row:
                row.site_figure, row.calculated_by = totals[account_id], user_id
            else:
                db.add(SiteFigure(account_id=account_id, start_date=week[0], end_date=week[1],
                                  site_figure=totals[account_id], calculated_by=user_id))
        elif row:
            db.delete(row)
    return len(totals)


def recalc_all_weeks(db: Session, account_id: int, user_id: int | None = None) -> None:
    """Recalculate one account for every week it has capper figures or a stored Site Figure for
    (after its cappers changed)."""
    db.flush()
    weeks = set(db.execute(select(Figure.start_date, Figure.end_date)
                           .where(Figure.account_id == account_id, Figure.start_date.is_not(None))
                           .distinct()).all())
    weeks |= set(db.execute(select(SiteFigure.start_date, SiteFigure.end_date)
                            .where(SiteFigure.account_id == account_id)).all())
    for start, end in sorted(weeks):
        recalc_site_figures(db, [account_id], (start, end), user_id)


def week_param(start_date: date | None, end_date: date | None) -> Week | None:
    """Validates the optional ?start_date=&end_date= query pair (both or neither)."""
    if start_date is None and end_date is None:
        return None
    if start_date is None or end_date is None:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "Send both start_date and end_date")
    if end_date < start_date:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "end_date must not be before start_date")
    return start_date, end_date
