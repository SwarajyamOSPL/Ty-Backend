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
    ("104", (2026, 9, 28), (2026, 10, 4)),               # a lone Sunday ends a Monday-Sunday week
    ("10-4", (2026, 9, 28), (2026, 10, 4)),
    ("Light Pink 10-11", (2026, 10, 5), (2026, 10, 11)),
    ("105", (2026, 10, 5), (2026, 10, 11)),               # a lone Monday starts it
    ("106", (2026, 10, 6), (2026, 10, 12)),             # 1/6 or 10/6: the one closest to today
    ("Sept 29 - Oct 5", (2026, 9, 29), (2026, 10, 5)),
    ("929 105", (2026, 9, 29), (2026, 10, 5)),
    ("1229 104", (2025, 12, 29), (2026, 1, 4)),          # over New Year: last December
    ("Feb 24 - Mar 2", (2026, 2, 24), (2026, 3, 2)),
    # week N of a month: Monday-Sunday weeks, week 1 contains the 1st (Apr 1 2026 is a Wednesday)
    ("April w2", (2026, 4, 6), (2026, 4, 12)),
    ("April W2", (2026, 4, 6), (2026, 4, 12)),
    ("april week 2", (2026, 4, 6), (2026, 4, 12)),
    ("Apr Week 1", (2026, 3, 30), (2026, 4, 5)),
    ("Week 3 April", (2026, 4, 13), (2026, 4, 19)),
    ("w2 of April", (2026, 4, 6), (2026, 4, 12)),
    ("Green April w3", (2026, 4, 13), (2026, 4, 19)),
    ("April w2 2025", (2025, 4, 7), (2025, 4, 13)),
    ("March w1", (2026, 2, 23), (2026, 3, 1)),
    ("Feb w5", (2026, 2, 23), (2026, 3, 1)),                # Feb 2027 has no 5th week: last year's
    ("Oct w2", (2026, 10, 5), (2026, 10, 11)),
    ("Oct w5", (2025, 10, 27), (2025, 11, 2)),              # this year's w5 starts 13 days ahead: last year's
    ("October Week 1 (September 28th - October 4th) 2026", (2026, 9, 28), (2026, 10, 4)),  # explicit dates win
])
def test_readable(name, start, end):
    assert parse_week(name, TODAY) == (date(*start), date(*end))


@pytest.mark.parametrize("name", ["Sheet1", "Week 41", "Summary", "", "10-12 - 10-6", "13-40 - 14-50",
                                  "Total", "10-6 - 12-25", "Green", "2", "Feb w6", "April w7", "April w0", "Feb w5 2027"])
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
