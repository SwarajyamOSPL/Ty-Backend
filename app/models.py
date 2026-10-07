import enum
from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import (CheckConstraint, Date, DateTime, Enum, ForeignKey, Numeric, String, Text,
                        UniqueConstraint)
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
    """A partner or a capper. Name is unique per kind, case-insensitively (via name_key)."""
    __tablename__ = "parties"
    __table_args__ = (UniqueConstraint("kind", "name_key"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    kind: Mapped[PartyKind] = mapped_column(Enum(PartyKind), index=True)
    name: Mapped[str] = mapped_column(String(255))
    name_key: Mapped[str] = mapped_column(String(255), index=True)  # lower(strip(name))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class Account(Base):
    """A login on a website. Username/password are optional; password is stored encrypted."""
    __tablename__ = "accounts"
    id: Mapped[int] = mapped_column(primary_key=True)
    website: Mapped[str] = mapped_column(String(255), index=True)
    username: Mapped[str | None] = mapped_column(String(255), nullable=True)
    password_enc: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


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
    """A figure entered for an account under a party. Append-only history."""
    __tablename__ = "figures"
    id: Mapped[int] = mapped_column(primary_key=True)
    party_id: Mapped[int] = mapped_column(ForeignKey("parties.id"), index=True)
    account_id: Mapped[int] = mapped_column(ForeignKey("accounts.id"), index=True)
    amount: Mapped[Decimal] = mapped_column(Numeric(14, 2))
    figure_date: Mapped[date] = mapped_column(Date, default=_today, index=True)
    entered_by: Mapped[int | None] = mapped_column(ForeignKey("admin_credentials.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    party: Mapped[Party] = relationship()
    account: Mapped[Account] = relationship()
