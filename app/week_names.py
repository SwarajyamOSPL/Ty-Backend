"""Reads a week (start date, end date) from a worksheet name.

Excel does not allow "/" in sheet names, so weeks are written in many other ways. Understood:
  "10-6 - 10-12", "10.6-10.12", "10 6 - 10 12", "Oct 6 - Oct 12", "October 6-12", "6 Oct - 12 Oct",
  "2026-10-06 to 2026-10-12", "10-06-2026 - 10-12-2026", "106 1011", "106-1011", "1006 1011",
  "10-6" (start date only: the week is then 7 days, start + 6; but a Sunday such as "104" = Oct 4 2026
  is the LAST day of a Monday-Sunday week: Sep 28 - Oct 4).
  "April w2", "Apr week 2", "week 2 of April", "April W2 2025" (week N of a month, see below).
Week N of a month: weeks run Monday to Sunday and week 1 is the one that contains the 1st of the
month (as in "October Week 1 (September 28th - October 4th)"), so April 2026 w2 = Apr 6 - Apr 12.
Month comes first (US style). Other words in the name (a capper name, "week", ...) are ignored.
When the year is not in the name (the usual case) it is worked out from a reference date
(default: today): the latest year in which the week does not start more than 7 days after it.
Real weekly data is never in the future, so "12 29 - 1 4" read in October means last December,
and "11 24 - 11 30" read in October means last November.
"""
import re
from datetime import date, timedelta

_MONTHS = ["january", "february", "march", "april", "may", "june", "july", "august",
           "september", "october", "november", "december"]
_NAME_TO_NUM = {}
for _i, _m in enumerate(_MONTHS, start=1):
    _NAME_TO_NUM[_m] = _i
    _NAME_TO_NUM[_m[:3]] = _i
_NAME_TO_NUM["sept"] = 9
_MONTH_RE = (r"(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|aug(?:ust)?|"
             r"sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)")
_MONTH_FIRST = re.compile(rf"\b({_MONTH_RE})\.?\s*(\d{{1,2}})(?:st|nd|rd|th)?(?!\d)(?:,?\s*(20\d\d))?")
_DAY_FIRST = re.compile(rf"\b(\d{{1,2}})(?:st|nd|rd|th)?\s*({_MONTH_RE})\b(?:,?\s*(20\d\d))?")
_TOKEN = re.compile(r"""
    (?P<ymd_y>\d{4})[-/._](?P<ymd_m>\d{1,2})[-/._](?P<ymd_d>\d{1,2})(?!\d)
  | (?P<mdy_m>\d{1,2})[-/._](?P<mdy_d>\d{1,2})[-/._](?P<mdy_y>20\d\d|2\d)(?!\d)
  | (?P<md_m>\d{1,2})[-/._](?P<md_d>\d{1,2})(?!\d)
  | (?P<blob>\d{3,4})(?!\d)
  | (?P<bare>\d{1,2})(?!\d)
""", re.X)

_WEEK_OF_MONTH = [
    re.compile(rf"\b({_MONTH_RE})\.?[\s_-]*(?:w|wk|week)\s*\.?\s*(\d)(?!\d)(?:\D*?(20\d\d))?", re.I),
    re.compile(rf"\b(?:w|wk|week)\s*\.?\s*(\d)(?!\d)\s*(?:of\s+)?({_MONTH_RE})\b(?:\D*?(20\d\d))?", re.I),
]

MAX_SPAN_DAYS = 31
FUTURE_TOLERANCE_DAYS = 7  # a week may start at most this many days after as_of


def _month_number(word: str) -> int:
    return _NAME_TO_NUM[word.lower().rstrip(".")[:4] if word.lower().startswith("sept") else word.lower().rstrip(".")[:3]]


def _names_to_numbers(text: str) -> str:
    def month_first(m):
        year = f"/{m.group(3)}" if m.group(3) else ""
        return f" {_month_number(m.group(1))}/{m.group(2)}{year} "

    def day_first(m):
        year = f"/{m.group(3)}" if m.group(3) else ""
        return f" {_month_number(m.group(2))}/{m.group(1)}{year} "

    return _DAY_FIRST.sub(day_first, _MONTH_FIRST.sub(month_first, text))


def _valid(m: int, d: int) -> bool:
    return 1 <= m <= 12 and 1 <= d <= 31


def _blob_options(s: str) -> list[tuple[int, int]]:
    opts = []
    if len(s) == 3:
        opts = [(int(s[0]), int(s[1:])), (int(s[:2]), int(s[2]))]
    elif len(s) == 4:
        opts = [(int(s[:2]), int(s[2:]))]
    return [o for o in opts if _valid(*o)]


def _tokens(name: str):
    """Returns (items, bares, year_hint). Each item is a list of (year|None, month, day) options."""
    text = _names_to_numbers(name.lower())
    items: list[list[tuple[int | None, int, int]]] = []
    bares: list[int] = []
    year_hint = None
    for m in _TOKEN.finditer(text):
        if m.group("ymd_y"):
            y, mo, d = int(m.group("ymd_y")), int(m.group("ymd_m")), int(m.group("ymd_d"))
            items.append([(y, mo, d)] if _valid(mo, d) else [])
        elif m.group("mdy_y"):
            y = int(m.group("mdy_y"))
            y = y + 2000 if y < 100 else y
            mo, d = int(m.group("mdy_m")), int(m.group("mdy_d"))
            items.append([(y, mo, d)] if _valid(mo, d) else [])
        elif m.group("md_m"):
            mo, d = int(m.group("md_m")), int(m.group("md_d"))
            items.append([(None, mo, d)] if _valid(mo, d) else [])
        elif m.group("blob"):
            b = m.group("blob")
            if len(b) == 4 and b.startswith("20") and not _blob_options(b):
                year_hint = int(b)  # a stray year such as "2026"
            else:
                items.append([(None, mo, d) for mo, d in _blob_options(b)])
        else:
            bares.append(int(m.group("bare")))
    return items, bares, year_hint


def _make_date(y: int, m: int, d: int) -> date | None:
    try:
        return date(y, m, d)
    except ValueError:
        return None


def _resolve(start_opt, end_opt, year_hint: int | None, today: date):
    """One (start, end) pair for a combination of options, or None if impossible."""
    sy, sm, sd = start_opt
    if sy is None:
        years = [year_hint] if year_hint else [today.year + 1, today.year, today.year - 1]
        chosen = None
        for y in years:
            s = _make_date(y, sm, sd)
            if s and (year_hint or s <= today + timedelta(days=FUTURE_TOLERANCE_DAYS)):
                chosen = s
                break
        if chosen is None:
            chosen = _make_date(years[-1], sm, sd)
        start = chosen
    else:
        start = _make_date(sy, sm, sd)
    if start is None:
        return None
    ey, em, ed = end_opt
    if ey is None:
        end = _make_date(start.year, em, ed)
        if end is not None and end < start:
            end = _make_date(start.year + 1, em, ed)
    else:
        end = _make_date(ey, em, ed)
    if end is None or end < start or (end - start).days > MAX_SPAN_DAYS:
        return None
    return start, end


def _week_of_month(name: str, today: date):
    """(start, end) for "April w2" style names, None if the name is not of that kind or the week
    does not exist (e.g. a 6th week in a month that only has five)."""
    for n, pattern in enumerate(_WEEK_OF_MONTH):
        m = pattern.search(name)
        if not m:
            continue
        month_word, week_no, year = (m.group(1), m.group(2), m.group(3)) if n == 0 else (m.group(2), m.group(1), m.group(3))
        month, week_no = _month_number(month_word), int(week_no)
        if not 1 <= week_no <= 6:
            return None
        years = [int(year)] if year else [today.year + 1, today.year, today.year - 1]
        for y in years:
            first = date(y, month, 1)
            start = first - timedelta(days=first.weekday()) + timedelta(days=7 * (week_no - 1))
            if (start.month, start.year) > (month, y) and start > first:
                continue  # that week is already in the next month: this month has no such week that year
            if year or start <= today + timedelta(days=FUTURE_TOLERANCE_DAYS):
                return start, start + timedelta(days=6)
        return None
    return None


def parse_week(name: str, as_of: date | None = None) -> tuple[date, date]:
    """Returns (start, end) for a sheet name, or raises ValueError. `as_of` is the reference
    date used to pick the year when the name has none (default: today)."""
    today = as_of or date.today()
    items, bares, year_hint = _tokens(name)
    if len(items) != 2:  # two dates are the week itself; otherwise "April w2" means week 2 of April
        by_month = _week_of_month(name, today)
        if by_month:
            return by_month
    combos: list[tuple] = []  # (start option, end option)

    if len(items) == 2:                                # (stray numbers like "Week 1" are ignored)
        combos = [(s, e) for s in items[0] for e in items[1]]
    elif len(items) == 1 and len(bares) == 1:          # "Oct 6 - 12": end day in the same month
        combos = [(s, (s[0], s[1], bares[0])) for s in items[0] if _valid(s[1], bares[0])]
    elif len(items) == 1 and not bares:                # start date only: 7-day week
        for s in items[0]:
            start = _resolve(s, s, year_hint, today)
            if start:
                first = start[0]
                if first.weekday() == 6:      # a Sunday: the week is Monday-Sunday and ends on that day ("104")
                    first -= timedelta(days=6)
                end = first + timedelta(days=6)
                combos.append(((first.year, first.month, first.day),
                               (end.year, end.month, end.day)))
    elif not items and len(bares) == 4:                # "10 6 - 10 12"
        combos = [((None, bares[0], bares[1]), (None, bares[2], bares[3]))]

    resolved = [r for r in (_resolve(s, e, year_hint, today) for s, e in combos) if r]
    if not resolved:
        raise ValueError(f"can't read a week from the sheet name '{name}'")
    # several readings possible (e.g. "106" = 1/6 or 10/6): take the one closest to as_of
    return min(resolved, key=lambda r: (abs((r[0] - today).days), (r[1] - r[0]).days))
