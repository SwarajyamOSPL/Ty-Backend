from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, field_validator

from .models import PartyKind


class ORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# ---- auth ----
class AdminOut(ORM):
    username: str


class ChangePassword(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


# ---- parties (partner / capper) ----
class PartyCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)

    @field_validator("name")
    @classmethod
    def strip(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("name must not be blank")
        return v


class PartyOut(ORM):
    id: int
    name: str
    created_at: datetime


# ---- accounts ----
class AccountCreate(BaseModel):
    website: str = Field(min_length=1, max_length=255)
    username: str | None = None
    password: str | None = None

    @field_validator("website")
    @classmethod
    def strip(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("website must not be blank")
        return v


class AccountOut(ORM):
    """List view: never includes the password."""
    id: int
    website: str
    username: str | None
    has_password: bool


# ---- assignment ----
class AssignIn(BaseModel):
    account_id: int


class AssignmentOut(BaseModel):
    id: int
    party_id: int
    party_name: str
    account_id: int
    website: str
    username: str | None


# ---- enter figure ----
class AccountCredentials(BaseModel):
    """Pre-fills the enter-figure form. Fields are null when missing."""
    account_id: int
    website: str
    username: str | None
    password: str | None


class FigureCreate(BaseModel):
    account_id: int
    amount: Decimal
    figure_date: date | None = None  # defaults to today
    # Optional: fill in / correct missing credentials from the same form.
    username: str | None = None
    password: str | None = None


class FigureOut(BaseModel):
    id: int
    party_id: int
    party_name: str
    account_id: int
    website: str
    username: str | None
    amount: Decimal
    figure_date: date
    created_at: datetime


class DashboardOut(BaseModel):
    partners: int
    cappers: int
    accounts: int
    assignments: int
    partner_figure_total: Decimal
    capper_figure_total: Decimal
