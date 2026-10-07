from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..crypto import encrypt
from ..db import get_db
from ..models import Account
from ..schemas import AccountCreate, AccountOut
from ..security import READ, WRITE

router = APIRouter(prefix="/accounts", tags=["accounts"])


def to_out(a: Account) -> AccountOut:
    return AccountOut(id=a.id, website=a.website, username=a.username,
                      has_password=bool(a.password_enc))


@router.post("", response_model=AccountOut, status_code=201, dependencies=[Depends(WRITE)])
def create_account(body: AccountCreate, db: Session = Depends(get_db)):
    acct = Account(website=body.website, username=(body.username or None),
                   password_enc=encrypt(body.password))
    db.add(acct)
    db.commit()
    return to_out(acct)


@router.get("", response_model=list[AccountOut], dependencies=[Depends(READ)])
def list_accounts(website: str | None = None, db: Session = Depends(get_db)):
    """All accounts, newest first. Optional `website` prefix filter."""
    q = select(Account).order_by(Account.id.desc())
    if website:
        q = q.where(Account.website.ilike(f"{website}%"))
    return [to_out(a) for a in db.scalars(q)]
