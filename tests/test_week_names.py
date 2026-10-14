from datetime import date

import pytest

from app.week_names import parse_week

TODAY = date(2026, 10, 13)


@pytest.mark.parametrize("name,start,end", [
    ("106 1011", (2026, 10, 6), (2026, 10, 11)),
    ("106-1011", (2026, 10, 6), (2026, 10, 11)),
    ("1006 1011", (2026, 10, 6), (2026, 10, 11)),
    ("10-6 - 10-12", (2026, 10, 6), (2026, 10, 12)),
    ("10.6-10.12", (2026, 10, 6), (2026, 10, 12)),
    ("10 6 - 10 12", (2026, 10, 6), (2026, 10, 12)),
    ("Oct 6 - Oct 12", (2026, 10, 6), (2026, 10, 12)),
    ("OCT 6-12", (2026, 10, 6), (2026, 10, 12)),
    ("October 6th to 12th", (2026, 10, 6), (2026, 10, 12)),
    ("6 Oct - 12 Oct", (2026, 10, 6), (2026, 10, 12)),
    ("Oct 6, 2026 - Oct 12, 2026", (2026, 10, 6), (2026, 10, 12)),
    ("2026-10-06 to 2026-10-12", (2026, 10, 6), (2026, 10, 12)),
    ("10-06-2026 - 10-12-2026", (2026, 10, 6), (2026, 10, 12)),
    ("Green 10-6 - 10-12", (2026, 10, 6), (2026, 10, 12)),
    ("10-6", (2026, 10, 6), (2026, 10, 12)),            # start date only: 7-day week
    ("106", (2026, 10, 6), (2026, 10, 12)),             # 1/6 or 10/6: the one closest to today
    ("Sept 29 - Oct 5", (2026, 9, 29), (2026, 10, 5)),
    ("929 105", (2026, 9, 29), (2026, 10, 5)),
    ("1229 104", (2025, 12, 29), (2026, 1, 4)),          # over New Year: last December
    ("Feb 24 - Mar 2", (2026, 2, 24), (2026, 3, 2)),
])
def test_readable(name, start, end):
    assert parse_week(name, TODAY) == (date(*start), date(*end))


@pytest.mark.parametrize("name", ["Sheet1", "Week 41", "Summary", "", "10-12 - 10-6", "13-40 - 14-50",
                                  "Total", "10-6 - 12-25", "Green", "2"])
def test_unreadable(name):
    with pytest.raises(ValueError):
        parse_week(name, TODAY)


def test_year_rules():
    # no year in the name: the latest year that is not in the future (7 days of slack)
    assert parse_week("10-6 - 10-12", date(2025, 12, 31)) == (date(2025, 10, 6), date(2025, 10, 12))
    assert parse_week("11-24 - 11-30", TODAY) == (date(2025, 11, 24), date(2025, 11, 30))  # not next month
    assert parse_week("10-20 - 10-26", TODAY) == (date(2026, 10, 20), date(2026, 10, 26))  # next week: ok
    assert parse_week("10-21 - 10-27", TODAY) == (date(2025, 10, 21), date(2025, 10, 27))  # 8 days ahead: no
    assert parse_week("12-29 - 1-4", date(2027, 1, 3)) == (date(2026, 12, 29), date(2027, 1, 4))
    assert parse_week("Dec 29 - Jan 4", date(2027, 1, 8)) == (date(2026, 12, 29), date(2027, 1, 4))
