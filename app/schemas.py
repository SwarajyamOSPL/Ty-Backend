from datetime import date, datetime
import re
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

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
    username: str


# ---- parties (partner / capper) ----
class PartyCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)

    @field_validator("name")
    @classmethod
    def strip(cls, v: str) -> str:
        v = " ".join(v.split())  # trim and collapse inner spaces so "A  B" and "A B" are the same name
        if not v:
            raise ValueError("name must not be blank")
        return v


class ColorOut(BaseModel):
    name: str
    created: bool


class PartyOut(ORM):
    id: int
    name: str
    created_at: datetime


class PartyListItem(PartyOut):
    account_count: int              # accounts assigned to this partner/capper


class RelatedParty(BaseModel):
    id: int
    name: str
    account_count: int              # how many of this partner's/capper's accounts it is linked to


class PartyDetail(BaseModel):
    """Summary of one partner (or capper)."""
    id: int
    name: str
    created_at: datetime
    account_count: int
    shared_account_count: int       # accounts that other partners (cappers) also have
    total_balance: Decimal          # sum of the accounts whose balance is a number
    accounts_without_numeric_balance: int   # no balance, or text such as "Infinite"
    cappers: list[RelatedParty]     # (partners only) the cappers its accounts have, most accounts first
    partners: list[RelatedParty]    # (cappers only) the partners that have accounts with this capper
    # Site Figure total of the partner's accounts for one week (partners only): the week asked for,
    # or else the latest week any of its accounts has a Site Figure for.
    site_figure_start_date: date | None = None
    site_figure_end_date: date | None = None
    site_figure_total: Decimal | None = None
    accounts_with_site_figure: int = 0
    # Figure total of the capper (cappers only): the sum of its figures over all weeks, or over the
    # one week asked for (figure_start_date / figure_end_date are then set). Where an account has
    # several entries for the same week only the latest counts.
    figure_total: Decimal | None = None
    figure_count: int = 0           # how many figures (account-weeks) the total adds up
    figure_weeks: int = 0           # how many different weeks they cover
    figure_start_date: date | None = None
    figure_end_date: date | None = None
    # The same for the rows of imported sheets that were not saved as figures (accounts that are not
    # registered, or not this capper's; see /cappers/figures/unregistered), and both added together.
    unregistered_figure_total: Decimal | None = None
    unregistered_figure_count: int = 0
    figure_total_all: Decimal | None = None   # figure_total + unregistered_figure_total


# ---- accounts ----
_NUMBER = re.compile(r"^[+-]?(\d[\d,]*(\.\d+)?|\.\d+)$")


def parse_amount(v, *, negative_ok: bool, name: str):
    """A number (Decimal) or, when it is not a number, the text as written (trimmed, spaces
    collapsed): "Infinite", "No max"... "Unlimited" is normalised to that spelling. None / blank -> None."""
    if v is None:
        return None
    if isinstance(v, bool):
        raise ValueError(f"{name} must be a number or text")
    if isinstance(v, (int, float, Decimal)):
        n = Decimal(str(v))
    else:
        s = " ".join(str(v).split())
        if not s:
            return None
        if not _NUMBER.match(s):
            if len(s) > 100:
                raise ValueError(f"{name} text is longer than 100 characters")
            return "Unlimited" if s.lower() == "unlimited" else s
        n = Decimal(s.replace(",", ""))
    if not n.is_finite():
        raise ValueError(f"{name} must be a number or text")
    if n < 0 and not negative_ok:
        raise ValueError(f"{name} must not be negative")
    return n


class PartyRef(BaseModel):
    id: int
    name: str


class AccountCreate(BaseModel):
    """One account (one set of credentials) that can be used on several websites.
    If an account with the same websites, username and password already exists, that account is
    reused (shared) instead of creating a duplicate. `partner_ids` / `capper_ids` assign the
    account to those partners / cappers (existing assignments are kept)."""
    websites: list[str] = Field(min_length=1, max_length=50)
    username: str | None = None
    password: str | None = None
    balance: Decimal | str | None = None   # a number (can be negative) or text such as "Infinite"
    max_win: Decimal | str | None = None   # a number >= 0 or text such as "Unlimited" / "No max"
    city: str | None = Field(default=None, max_length=255)
    partner_ids: list[int] = Field(default_factory=list, max_length=200)
    capper_ids: list[int] = Field(default_factory=list, max_length=50)

    @field_validator("balance", mode="before")
    @classmethod
    def parse_balance(cls, v):
        return parse_amount(v, negative_ok=True, name="balance")

    @field_validator("max_win", mode="before")
    @classmethod
    def parse_max_win(cls, v):
        return parse_amount(v, negative_ok=False, name="max_win")

    @field_validator("websites")
    @classmethod
    def clean_websites(cls, v: list[str]) -> list[str]:
        out: dict[str, str] = {}
        for w in v:
            w = w.strip()
            if not w or len(w) > 255:
                raise ValueError("each website must be 1-255 characters and not blank")
            out.setdefault(w.lower(), w)  # drop case-insensitive duplicates in the same request
        return list(out.values())


class AccountOut(ORM):
    """List view: never includes the password."""
    id: int
    websites: list[str]
    username: str | None
    has_password: bool
    balance: Decimal | str | None   # a number, text as written ("Infinite") or null
    max_win: Decimal | str | None   # a number, text as written ("Unlimited", "No max") or null
    city: str | None
    # Site Figure: sum of the assigned cappers' figures for a week; latest week unless a week
    # was asked for. null when no sheet has been imported for the account yet.
    site_figure: Decimal | None = None
    site_figure_start_date: date | None = None
    site_figure_end_date: date | None = None
    cappers: list[PartyRef] = []
    partners: list[PartyRef] = []


class CapperIds(BaseModel):
    capper_ids: list[int] = Field(max_length=50)


class AccountSiteFigure(BaseModel):
    start_date: date
    end_date: date
    site_figure: Decimal
    calculated_at: datetime


# ---- assignment ----
class AssignIn(BaseModel):
    account_id: int


class AssignmentOut(BaseModel):
    id: int
    party_id: int
    party_name: str
    account_id: int
    websites: list[str]
    username: str | None


# ---- enter figure ----
class AccountCredentials(BaseModel):
    """Pre-fills the enter-figure form. Fields are null when missing."""
    account_id: int
    websites: list[str]
    username: str | None
    password: str | None


class FigureCreate(BaseModel):
    account_id: int
    figure: Decimal
    # Optional: fill in / correct missing credentials from the same form.
    username: str | None = None
    password: str | None = None


class PartnerFigureCreate(FigureCreate):
    partner_id: int


class CapperFigureCreate(FigureCreate):
    capper_id: int
    start_date: date
    end_date: date

    @model_validator(mode="after")
    def check_range(self):
        if self.end_date < self.start_date:
            raise ValueError("end_date must not be before start_date")
        return self


class FigureOut(BaseModel):
    id: int
    party_id: int
    party_name: str
    account_id: int
    websites: list[str]
    username: str | None
    figure: Decimal
    figure_date: date
    start_date: date | None = None
    end_date: date | None = None
    created_at: datetime


class SheetResult(BaseModel):
    """What one worksheet (= one week) of the file did."""
    sheet_name: str
    start_date: date
    end_date: date
    week_from: str                  # where the week was read from: "sheet title", "date cell" or "sheet name"
    header_row: int                 # row of the header (username / figure columns)
    figure_column: str              # the column used as the figure, e.g. "TOTAL"
    created: int
    updated: int
    site_figures_updated: int       # accounts whose Site Figure for this week was recalculated
    unregistered_rows: int          # rows whose username is not one of the capper's accounts (kept with a note)
    ignored_rows: int = 0           # rows with no username, no figure, or a figure that is not a number
    repeated_ignored: int = 0       # rows ignored: the same account with the same figure appeared again
    summed_rows: int = 0            # rows added to an earlier row of the same account (a different figure)


class ImportResult(BaseModel):
    capper_id: int
    capper_name: str
    created: int                    # totals over all worksheets
    updated: int
    unregistered_rows: int          # kept with a note: GET /cappers/figures/unregistered (or /imported)
    ignored_rows: int = 0
    site_figures_updated: int       # accounts whose Site Figure was recalculated
    sheets: list[SheetResult]
    ignored_sheets: list[str]       # worksheets without username/figure columns


class ImportedRowOut(BaseModel):
    """One row of imported capper sheets: a saved figure of a registered account, or a row that was
    kept because the account is not registered (see `notes`)."""
    source: str                     # "registered" (saved as a figure) or "unregistered" (kept with a note)
    id: int                         # id in /cappers/figures/all (registered) or /cappers/figures/unregistered
    capper_id: int
    capper_name: str
    account_id: int | None          # null when the username is not an account in the database
    username: str
    websites: list[str]
    partners: list[PartyRef]
    figure: Decimal
    start_date: date | None
    end_date: date | None
    notes: str | None               # "not registered account" / "account not assigned to this capper"; null when saved
    created_at: datetime


class UnregisteredFigureOut(BaseModel):
    id: int
    capper_id: int
    capper_name: str
    username: str
    website: str | None
    figure: Decimal
    start_date: date
    end_date: date
    notes: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class DashboardOut(BaseModel):
    partners: int
    cappers: int
    accounts: int
    assignments: int
    partner_figure_total: Decimal
    capper_figure_total: Decimal


# ---- site figure: a partner's weekly total of its account's capper figures ----
class WeekRange(BaseModel):
    start_date: date
    end_date: date

    @model_validator(mode="after")
    def check_range(self):
        if self.end_date < self.start_date:
            raise ValueError("end_date must not be before start_date")
        return self


class CapperContribution(BaseModel):
    capper_id: int
    capper_name: str
    figure: Decimal | None  # null = this capper has no figure for the week


class AssignedCapper(BaseModel):
    capper_id: int
    capper_name: str


class SavedSiteFigure(BaseModel):
    id: int
    site_figure: Decimal
    calculated_at: datetime


class SiteFigureView(BaseModel):
    partner_id: int
    partner_name: str
    account_id: int
    username: str | None
    websites: list[str]
    start_date: date
    end_date: date
    cappers: list[CapperContribution]
    total: Decimal                   # sum of the cappers' figures that exist
    missing_cappers: list[str]       # assigned cappers with no figure for the week
    saved: SavedSiteFigure | None    # the stored site figure, if one was saved


class SiteFigureOut(BaseModel):
    id: int
    account_id: int
    username: str | None
    websites: list[str]
    partners: list[PartyRef]
    start_date: date
    end_date: date
    site_figure: Decimal
    calculated_at: datetime
