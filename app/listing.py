"""Pagination and search shared by the list endpoints.

Every list endpoint takes `page` (1-based) and `page_size` (default 50, at most 500) and still
returns a plain JSON array, so existing clients keep working. The paging details are in the
response headers: X-Total-Count (rows matching the filters), X-Page, X-Page-Size, X-Total-Pages.
`limit` is the old name of `page_size` and is still accepted.

Text filters are case-insensitive "contains" matches; blank values are ignored.
"""
from dataclasses import dataclass
from math import ceil

from fastapi import Query, Response
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from .models import Account, AccountWebsite, Party, PartyAccount, PartyKind

DEFAULT_PAGE_SIZE = 50
MAX_PAGE_SIZE = 500


@dataclass(frozen=True)
class Page:
    page: int
    size: int


def page_params(page: int = Query(1, ge=1, description="Page number, starting at 1"),
                page_size: int = Query(DEFAULT_PAGE_SIZE, ge=1, le=MAX_PAGE_SIZE,
                                       description="Rows per page"),
                limit: int | None = Query(None, ge=1, deprecated=True,
                                          description="Old name of page_size")) -> Page:
    return Page(page, min(limit, MAX_PAGE_SIZE) if limit else page_size)


def paginate(db: Session, stmt, response: Response, pg: Page) -> list:
    """The rows of one page of `stmt` (a select of one entity, already ordered); the totals go
    into the response headers."""
    total = db.scalar(select(func.count()).select_from(stmt.order_by(None).subquery())) or 0
    response.headers["X-Total-Count"] = str(total)
    response.headers["X-Page"] = str(pg.page)
    response.headers["X-Page-Size"] = str(pg.size)
    response.headers["X-Total-Pages"] = str(ceil(total / pg.size))
    return list(db.scalars(stmt.offset((pg.page - 1) * pg.size).limit(pg.size)))


def contains(column, text: str):
    """column ILIKE '%text%', with %, _ and \\ in the text taken literally."""
    esc = text.strip().replace("\\", "\\\\").replace("%", r"\%").replace("_", r"\_")
    return column.ilike(f"%{esc}%", escape="\\")


def _blank(text: str | None) -> bool:
    return text is None or not text.strip()


def _has_website(text: str):
    return Account.id.in_(select(AccountWebsite.account_id).where(contains(AccountWebsite.website, text)))


def _has_party(text: str, kind: PartyKind | None = None):
    sub = (select(PartyAccount.account_id).join(Party, Party.id == PartyAccount.party_id)
           .where(contains(Party.name, text)))
    if kind:
        sub = sub.where(Party.kind == kind)
    return Account.id.in_(sub)


def account_search(text: str):
    """One search box over an account's username, websites and the names of its partners and cappers."""
    return or_(contains(Account.username, text), _has_website(text), _has_party(text))


def account_conditions(*, search: str | None = None, username: str | None = None,
                       website: str | None = None, partner: str | None = None,
                       capper: str | None = None) -> list:
    """WHERE conditions on Account for the usual search fields (all must match)."""
    conds = []
    if not _blank(username):
        conds.append(contains(Account.username, username))
    if not _blank(website):
        conds.append(_has_website(website))
    if not _blank(partner):
        conds.append(_has_party(partner, PartyKind.partner))
    if not _blank(capper):
        conds.append(_has_party(capper, PartyKind.capper))
    if not _blank(search):
        conds.append(account_search(search))
    return conds


def account_ids(conds: list):
    """Subquery of the ids of the accounts matching `conds`, for `Table.account_id.in_(...)`."""
    return select(Account.id).where(*conds)
