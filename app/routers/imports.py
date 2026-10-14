"""Excel import of weekly capper figures.

One workbook, one capper, many weeks: every worksheet is one week. The week is read from a
title cell above the table (e.g. "Baws - October Week 1 (September 28th - October 4th) 2026")
and, if there is none, from the worksheet's name (e.g. "10-6 - 10-12", "Oct 6 - Oct 12",
"106 1011") - see app/week_names.py.

The table can start anywhere: the header row is found by looking for a column called
"username" (or "account name" / "login") and a figure column in the first rows. The figure column is "figure" or, if there is
none, "fig", "total" or "PNL" (in that order of preference); failing that, a column whose header contains the
word PNL, such as "Gross PNL" (several of those are rejected as ambiguous). Other columns are ignored.

The file name must contain the capper's name (its color), e.g. "Turquoise.xlsx" or
"TB2 - Yellow.xlsx", and it must be the same capper that was selected.

Rows are matched, by username (ignoring case; numbers like 7261.0 become "7261"), to accounts
already assigned to the selected capper. If several of the capper's accounts have the same
username, a "Website" column in the sheet (when there is one) tells them apart. Every account
that gets a figure has its Site Figure for the week recalculated right away (the sum of all its
assigned cappers' figures, negative values included). Rows whose username is not one of the capper's accounts,
or whose figure cell is blank, are skipped and reported (the sheet may contain other partners'
accounts that are not in the database). Worksheets without a username (or account name / login)/figure header (notes,
totals...) are ignored and reported. All-or-nothing for real problems: an unreadable week, an
invalid figure, an ambiguous or repeated username rejects the whole file.
"""
import io
import re
from decimal import Decimal, InvalidOperation

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import StreamingResponse
from openpyxl import Workbook, load_workbook
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..accounts_view import recalc_site_figures
from ..db import get_db
from ..models import Account, Admin, Figure, Party, PartyAccount, PartyKind
from ..schemas import ImportResult, SheetResult
from ..security import WRITE
from ..week_names import parse_week
from .parties import CAPPER_COLORS

router = APIRouter(prefix="/cappers/figures/import", tags=["import"])

MAX_BYTES = 5 * 1024 * 1024
MAX_ROWS = 20000          # per worksheet
HEADER_SCAN_ROWS = 30     # the header row must be within the first rows of a worksheet
USERNAME_HEADERS = ("username", "user name", "login", "account name", "accountname")  # in order of preference
FIGURE_HEADERS = ("figure", "fig", "total", "pnl")  # in order of preference


def _norm(v) -> str:
    return str(v).strip().lower() if v is not None else ""


def _text(v) -> str:
    """Cell text for matching: whole numbers stored as floats (7261.0) become '7261'."""
    if isinstance(v, float) and v.is_integer():
        return str(int(v))
    return str(v).strip() if v is not None else ""


def _site(v) -> str:
    """A website for comparing: lowercase, no scheme, no 'www.', no path."""
    s = re.sub(r"^[a-z]+://", "", str(v).strip().lower())
    return re.sub(r"^www\.", "", s).split("/")[0]


def _header(v) -> str:
    """Header text for comparing: lowercase, "_" and runs of spaces become one space."""
    return re.sub(r"[\s_]+", " ", v.strip().lower()) if isinstance(v, str) else ""


def _find_columns(row) -> dict | None:
    """{'username': i, 'figure': j, 'figure_name': text} if this row is a header row.
    The figure column is one called exactly figure / fig / total / pnl (in that order) or, failing
    that, one whose header contains the word PNL ("Gross PNL", "Net PNL", "PNL (USD)"). If several
    headers contain PNL, {'username': i, 'ambiguous': [headers]} is returned instead."""
    cells = [_header(c) for c in row]
    user_col = next((cells.index(name) for name in USERNAME_HEADERS if name in cells), None)
    if user_col is None:
        return None
    for name in FIGURE_HEADERS:
        if name in cells:
            j = cells.index(name)
            return {"username": user_col, "figure": j, "figure_name": str(row[j]).strip(),
                    "website": cells.index("website") if "website" in cells else None}
    pnl = [j for j, c in enumerate(cells) if re.search(r"\bpnl\b", c)]
    if len(pnl) == 1:
        j = pnl[0]
        return {"username": user_col, "figure": j, "figure_name": str(row[j]).strip(),
                "website": cells.index("website") if "website" in cells else None}
    if len(pnl) > 1:
        return {"username": user_col, "ambiguous": [str(row[j]).strip() for j in pnl]}
    return None


def _slug(text: str) -> str:
    """Lowercase, with every run of non-alphanumeric characters turned into one space."""
    return re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()


def _capper_in_filename(filename: str, known_names: list[str]) -> str | None:
    """The capper name found in the file name, or None. Whole words only; if several names
    match (e.g. 'Blue' and 'Light Blue') the longest wins."""
    stem = re.sub(r"\.xlsx$", "", filename.replace("\\", "/").rsplit("/", 1)[-1], flags=re.I)
    padded = f" {_slug(stem)} "
    found = [n for n in known_names if _slug(n) and f" {_slug(n)} " in padded]
    return max(found, key=lambda n: len(_slug(n))) if found else None


def _fail(errors: list[str], status_code=status.HTTP_422_UNPROCESSABLE_ENTITY):
    raise HTTPException(status_code, {"message": "Import rejected, nothing was saved",
                                      "errors": errors[:200]})


@router.get("/template")
def template(_: Admin = Depends(WRITE)):
    """Download an empty .xlsx: one worksheet per week, the sheet name is the week. Add a
    worksheet for each week, name it like "10-6 - 10-12", and name the file after the capper
    (e.g. "Red.xlsx") before uploading."""
    wb = Workbook()
    ws = wb.active
    ws.title = "10-6 - 10-12"
    ws.append(["username", "figure"])
    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)
    return StreamingResponse(
        buf, media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": 'attachment; filename="capper_figures_template.xlsx"'})


@router.post("", response_model=ImportResult)
async def import_figures(capper_id: int = Form(...), file: UploadFile = File(...),
                         db: Session = Depends(get_db), user: Admin = Depends(WRITE)):
    """Each worksheet is one week. The dates come from a title cell above the table, or from the
    worksheet's name. When the dates have no year it is the latest year in which the week does
    not start more than 7 days after today."""
    capper = db.get(Party, capper_id)
    if not capper or capper.kind != PartyKind.capper:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Capper not found")
    if not (file.filename or "").lower().endswith(".xlsx"):
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "Upload an .xlsx file")

    known = list({*CAPPER_COLORS, *db.scalars(select(Party.name).where(Party.kind == PartyKind.capper))})
    in_name = _capper_in_filename(file.filename, known)
    if not in_name:
        _fail([f"No capper name found in the file name '{file.filename}'. Name the file after "
               f"the selected capper, e.g. '{capper.name}.xlsx'"])
    if _slug(in_name) != _slug(capper.name):
        _fail([f"File name is for capper '{in_name}' but the selected capper is '{capper.name}'"])

    data = await file.read()
    if len(data) > MAX_BYTES:
        raise HTTPException(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "File larger than 5 MB")
    try:
        wb = load_workbook(io.BytesIO(data), read_only=True, data_only=True)
        sheets = list(wb.worksheets)
    except Exception:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "Not a valid .xlsx file")

    # accounts assigned to this capper, indexed by username
    assigned = db.scalars(select(Account).join(PartyAccount, PartyAccount.account_id == Account.id)
                          .where(PartyAccount.party_id == capper.id)).all()
    by_user: dict[str, list[Account]] = {}
    for a in assigned:
        if _norm(a.username):
            by_user.setdefault(_norm(a.username), []).append(a)

    errors: list[str] = []
    ignored: list[str] = []
    weeks: dict[tuple, dict] = {}  # (start, end) -> data collected from that worksheet
    for ws in sheets:
        # find the header row (within the first rows) and remember the text above it
        try:
            rows = ws.iter_rows(values_only=True)
            above: list[str] = []
            cols = None
            header_row_no = 0
            for header_row_no, row in enumerate(rows, start=1):
                cols = _find_columns(row)
                if cols or header_row_no >= HEADER_SCAN_ROWS:
                    break
                above.extend(c.strip() for c in row if isinstance(c, str) and c.strip())
        except Exception:
            errors.append(f"[{ws.title}] can't be read")
            continue
        if not cols:
            ignored.append(ws.title)  # not a data sheet (notes, totals, ...)
            continue
        if cols.get("ambiguous"):
            errors.append(f"[{ws.title}] has several PNL columns ({', '.join(cols['ambiguous'])}) and "
                          f"I can't tell which one is the figure. Keep one of them, or name it exactly 'PNL'")
            continue

        # the week: a title cell above the table first, then the worksheet's name
        week, week_from = None, ""
        for text in above:
            try:
                week, week_from = parse_week(text), "sheet title"
                break
            except ValueError:
                continue
        if week is None:
            try:
                week, week_from = parse_week(ws.title), "sheet name"
            except ValueError as e:
                errors.append(f"{e}. Name each sheet by its week, e.g. '10-6 - 10-12' or "
                              f"'Oct 6 - Oct 12', or put the week in a title cell above the table")
                continue
        if week in weeks:
            errors.append(f"[{ws.title}] is the same week ({week[0]} to {week[1]}) as "
                          f"[{weeks[week]['sheet']}]")
            continue

        entries: dict[int, Decimal] = {}  # account_id -> figure
        skipped_rows = 0
        skipped_users: dict[str, None] = {}  # distinct usernames that were skipped (ordered)
        n_rows = 0
        for n, row in enumerate(rows, start=header_row_no + 1):
            u_raw = row[cols["username"]] if cols["username"] < len(row) else None
            raw = row[cols["figure"]] if cols["figure"] < len(row) else None
            site_raw = row[cols["website"]] if cols["website"] is not None and cols["website"] < len(row) else None
            if (u_raw is None or str(u_raw).strip() == "") and (raw is None or str(raw).strip() == ""):
                continue  # blank line
            n_rows += 1
            if n_rows > MAX_ROWS:
                errors.append(f"[{ws.title}] more than {MAX_ROWS} rows")
                break
            user_ = _norm(_text(u_raw))
            matches = by_user.get(user_, []) if user_ else []
            blank_figure = raw is None or str(raw).strip() == ""
            if not matches or blank_figure:
                # Not one of this capper's accounts (e.g. another partner's account that is not
                # in the database), or no figure given: ignore the row, but report it.
                skipped_rows += 1
                if user_ and user_ not in skipped_users:
                    skipped_users[user_] = None
                continue
            try:
                if isinstance(raw, bool):
                    raise InvalidOperation
                figure = Decimal(str(raw).strip().replace(",", ""))
                if not figure.is_finite() or abs(figure) >= Decimal("1e12"):
                    raise InvalidOperation
            except InvalidOperation:
                errors.append(f"[{ws.title}] row {n}: figure '{raw}' is not a valid number")
                continue
            if len(matches) > 1 and site_raw is not None and str(site_raw).strip():
                narrowed = [a for a in matches if _site(site_raw) in {_site(w) for w in a.websites}]
                if len(narrowed) == 1:  # same username on several sites: the sheet's website decides
                    matches = narrowed
            if len(matches) > 1:
                errors.append(f"[{ws.title}] row {n}: {len(matches)} accounts of capper "
                              f"{capper.name} have username '{user_}'"
                              + ("" if site_raw is not None else " (add a Website column to tell them apart)"))
                continue
            acct = matches[0]
            if acct.id in entries:
                errors.append(f"[{ws.title}] row {n}: username '{user_}' appears more than once")
                continue
            entries[acct.id] = figure
        weeks[week] = {"sheet": ws.title, "entries": entries, "skipped_rows": skipped_rows,
                       "skipped_users": skipped_users, "week_from": week_from,
                       "figure_column": cols["figure_name"], "header_row": header_row_no}

    if not weeks and not errors:
        _fail(["No worksheet has a header row with a 'username' (or 'account name' / 'login') column and a figure column "
               "('figure', 'fig', 'total' or 'PNL', e.g. 'Gross PNL')"
               + (f" (ignored sheets: {', '.join(ignored)})" if ignored else "")])
    if errors:
        _fail(errors)
    if not any(w["entries"] for w in weeks.values()):
        total_skipped = sum(w["skipped_rows"] for w in weeks.values())
        _fail([f"No row matched an account assigned to capper {capper.name} "
               f"({total_skipped} row(s) skipped). Check that this is the right capper's file "
               f"and that the accounts are assigned to the capper"])

    # Re-importing the same week overwrites instead of duplicating.
    results: list[SheetResult] = []
    for (start, end), w in weeks.items():
        entries = w["entries"]
        existing = {f.account_id: f for f in db.scalars(select(Figure).where(
            Figure.party_id == capper.id, Figure.start_date == start,
            Figure.end_date == end, Figure.account_id.in_(entries)))} if entries else {}
        created = updated = 0
        for account_id, figure in entries.items():
            fig = existing.get(account_id)
            if fig:
                fig.figure, fig.entered_by = figure, user.id
                updated += 1
            else:
                db.add(Figure(party_id=capper.id, account_id=account_id, figure=figure,
                              start_date=start, end_date=end, entered_by=user.id))
                created += 1
        db.flush()
        site_figures = recalc_site_figures(db, list(entries), (start, end), user.id)
        results.append(SheetResult(sheet_name=w["sheet"], start_date=start, end_date=end,
                                   week_from=w["week_from"], header_row=w["header_row"],
                                   figure_column=w["figure_column"],
                                   created=created, updated=updated, site_figures_updated=site_figures,
                                   skipped=w["skipped_rows"],
                                   skipped_usernames=list(w["skipped_users"])[:200]))
    db.commit()
    return ImportResult(capper_id=capper.id, capper_name=capper.name,
                        created=sum(r.created for r in results), updated=sum(r.updated for r in results),
                        skipped=sum(r.skipped for r in results),
                        site_figures_updated=sum(r.site_figures_updated for r in results),
                        sheets=results, ignored_sheets=ignored)
