import enum
from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import (CheckConstraint, Date, DateTime, Enum, ForeignKey, Index, Numeric, String, Text,
                        UniqueConstraint)
from sqlalchemy import text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .db import Base


def _now():
    return datetime.now(timezone.utc)


def _today():
    return date.today()


class PartyKind(str, enum.Enum):
    partner = "partner"
    capper = "capper"


class Admin(Base):
    """The single login for the system. The CHECK constraint on id keeps it to one row."""
    __tablename__ = "admin_credentials"
    __table_args__ = (CheckConstraint("id = 1", name="single_admin"),)
    id: Mapped[int] = mapped_column(primary_key=True, default=1)
    username: Mapped[str] = mapped_column(String(100), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))


class Party(Base):
    """A partner or a capper. Capper names are unique (case-insensitively, via name_key) because a
    capper is identified by its color; partner names are NOT unique - two partners can have the
    same name and are told apart by id."""
    __tablename__ = "parties"
    __table_args__ = (Index("uq_capper_name", "name_key", unique=True,
                            postgresql_where=text("kind = 'capper'"),
                            sqlite_where=text("kind = 'capper'")),)
    id: Mapped[int] = mapped_column(primary_key=True)
    kind: Mapped[PartyKind] = mapped_column(Enum(PartyKind), index=True)
    name: Mapped[str] = mapped_column(String(255))
    name_key: Mapped[str] = mapped_column(String(255), index=True)  # lower(strip(name))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class Account(Base):
    """A login on a website. Username/password are optional; password is stored encrypted."""
    __tablename__ = "accounts"
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str | None] = mapped_column(String(255), nullable=True)
    password_enc: Mapped[str | None] = mapped_column(Text, nullable=True)
    # Balance and max win are normally numbers. A value that is not a number ("Infinite",
    # "Unlimited", "No max", ...) is kept as written in the *_text column, and the number is NULL.
    balance: Mapped[Decimal | None] = mapped_column(Numeric(14, 2), nullable=True)
    balance_text: Mapped[str | None] = mapped_column(String(100), nullable=True)
    max_win: Mapped[Decimal | None] = mapped_column(Numeric(14, 2), nullable=True)
    max_win_text: Mapped[str | None] = mapped_column(String(100), nullable=True)
    city: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    website_rows: Mapped[list["AccountWebsite"]] = relationship(
        cascade="all, delete-orphan", order_by="AccountWebsite.id", lazy="selectin")

    @property
    def websites(self) -> list[str]:
        return [w.website for w in self.website_rows]


class AccountWebsite(Base):
    """One website an account is used on. An account has one or more."""
    __tablename__ = "account_websites"
    __table_args__ = (UniqueConstraint("account_id", "website"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    account_id: Mapped[int] = mapped_column(ForeignKey("accounts.id"), index=True)
    website: Mapped[str] = mapped_column(String(255), index=True)


class PartyAccount(Base):
    """Assignment of an account to a party. An account may belong to many parties,
    but a party cannot hold the same account twice."""
    __tablename__ = "party_accounts"
    __table_args__ = (UniqueConstraint("party_id", "account_id"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    party_id: Mapped[int] = mapped_column(ForeignKey("parties.id"), index=True)
    account_id: Mapped[int] = mapped_column(ForeignKey("accounts.id"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    party: Mapped[Party] = relationship()
    account: Mapped[Account] = relationship()


class Figure(Base):
    """A figure entered for an account under a party. Append-only history. For a capper it is
    that capper's figure for the account for one week (start_date..end_date)."""
    __tablename__ = "figures"
    __table_args__ = (Index("ix_figures_lookup", "party_id", "account_id", "start_date", "end_date"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    party_id: Mapped[int] = mapped_column(ForeignKey("parties.id"), index=True)
    account_id: Mapped[int] = mapped_column(ForeignKey("accounts.id"), index=True)
    figure: Mapped[Decimal] = mapped_column(Numeric(14, 2))
    figure_date: Mapped[date] = mapped_column(Date, default=_today, index=True)
    # Weekly range; only set for capper figures.
    start_date: Mapped[date | None] = mapped_column(Date, nullable=True, index=True)
    end_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    entered_by: Mapped[int | None] = mapped_column(ForeignKey("admin_credentials.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    party: Mapped[Party] = relationship()
    account: Mapped[Account] = relationship()


class UnregisteredFigure(Base):
    """A row of a capper sheet that could not be saved as a figure because its username is not one of
    the capper's accounts (no such account at all: "not registered account"; or an account the
    capper is not assigned to). Kept so those rows can be reviewed later. An import of the same
    capper and week replaces the rows of the previous import."""
    __tablename__ = "unregistered_figures"
    id: Mapped[int] = mapped_column(primary_key=True)
    capper_id: Mapped[int] = mapped_column(ForeignKey("parties.id"), index=True)
    username: Mapped[str] = mapped_column(String(255), index=True)
    website: Mapped[str | None] = mapped_column(String(255), nullable=True)
    figure: Mapped[Decimal] = mapped_column(Numeric(14, 2))
    start_date: Mapped[date] = mapped_column(Date, index=True)
    end_date: Mapped[date] = mapped_column(Date)
    notes: Mapped[str] = mapped_column(String(255))
    imported_by: Mapped[int | None] = mapped_column(ForeignKey("admin_credentials.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    capper: Mapped[Party] = relationship()


class SiteFigure(Base):
    """An account's Site Figure for one week: the sum (can be negative) of the figures of every
    capper assigned to the account for that week. One row per account and week, shared by all
    partners that have the account. Recalculated automatically (see app/accounts_view.py)."""
    __tablename__ = "site_figures"
    __table_args__ = (UniqueConstraint("account_id", "start_date", "end_date"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    account_id: Mapped[int] = mapped_column(ForeignKey("accounts.id"), index=True)
    start_date: Mapped[date] = mapped_column(Date, index=True)
    end_date: Mapped[date] = mapped_column(Date)
    site_figure: Mapped[Decimal] = mapped_column(Numeric(14, 2))
    calculated_by: Mapped[int | None] = mapped_column(ForeignKey("admin_credentials.id"), nullable=True)
    calculated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now, onupdate=_now)
    account: Mapped[Account] = relationship()
