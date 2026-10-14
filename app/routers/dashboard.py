from decimal import Decimal

from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Account, Figure, Party, PartyAccount, PartyKind
from ..schemas import DashboardOut
from ..security import READ

router = APIRouter(prefix="/dashboard", tags=["dashboard"], dependencies=[Depends(READ)])


@router.get("", response_model=DashboardOut)
def dashboard(db: Session = Depends(get_db)):
    def count_parties(kind):
        return db.scalar(select(func.count()).select_from(Party).where(Party.kind == kind))

    def figure_total(kind):
        return db.scalar(select(func.coalesce(func.sum(Figure.figure), 0))
                         .join(Party, Party.id == Figure.party_id).where(Party.kind == kind))

    return DashboardOut(
        partners=count_parties(PartyKind.partner),
        cappers=count_parties(PartyKind.capper),
        accounts=db.scalar(select(func.count()).select_from(Account)),
        assignments=db.scalar(select(func.count()).select_from(PartyAccount)),
        partner_figure_total=Decimal(figure_total(PartyKind.partner)),
        capper_figure_total=Decimal(figure_total(PartyKind.capper)),
    )
