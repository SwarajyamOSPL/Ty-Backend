"""Import: headers anywhere, column aliases, numeric usernames, week from a title cell."""
import io
import os

os.environ["DATABASE_URL"] = "sqlite:///./test.db"

from datetime import date  # noqa: E402

from fastapi.testclient import TestClient  # noqa: E402
from openpyxl import Workbook  # noqa: E402

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.main import app  # noqa: E402
from app.security import seed_admin  # noqa: E402
from app.week_names import parse_week  # noqa: E402


def make_client():
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    with SessionLocal() as db:
        seed_admin(db)
    c = TestClient(app)
    tok = c.post("/auth/login", data={"username": "admin", "password": "admin"}).json()
    return c, {"Authorization": f"Bearer {tok['access_token']}"}


def sheet_file(sheets):
    """sheets: {sheet name: list of raw rows}; rows are written as given, starting at row 1."""
    wb = Workbook()
    wb.remove(wb.active)
    for name, rows in sheets.items():
        ws = wb.create_sheet(name)
        for r in rows:
            ws.append(list(r))
    buf = io.BytesIO()
    wb.save(buf)
    return buf.getvalue()


def test_title_with_week_number_and_year():
    t = "Baws - October Week 1 (September 28th - October 4th) 2026"
    assert parse_week(t, date(2026, 10, 13)) == (date(2026, 9, 28), date(2026, 10, 4))
    # the same text from a later year-less read still takes the year written in the title
    assert parse_week(t, date(2030, 1, 1)) == (date(2026, 9, 28), date(2026, 10, 4))


def test_real_layout(monkeypatch):
    import app.routers.imports as imports_module

    monkeypatch.setattr(imports_module, "parse_week", lambda name: parse_week(name, as_of=date(2026, 10, 13)))
    c, h = make_client()
    yellow = c.post("/cappers", json={"name": "Yellow"}, headers=h).json()
    accts = {}
    for site, user in (("trylnk.com", "lnk98213"), ("empire.ag", "Ccm166"), ("sports411.ag", "8548"),
                       ("dup.com", "twin"), ("dup2.com", "TWIN")):
        a = c.post("/accounts", json={"websites": [site], "username": user}, headers=h).json()
        accts[user] = a
        c.post(f"/cappers/{yellow['id']}/accounts", json={"account_id": a["id"]}, headers=h)

    def upload(content, name="TB2 - Yellow.xlsx"):
        return c.post("/cappers/figures/import", data={"capper_id": yellow["id"]},
                      files={"file": (name, content)}, headers=h)

    def sheet_info(r):
        return r.json()["sheets"][0]

    title = "Baws - October Week 1 (September 28th - October 4th) 2026"
    body = [("legacy365.net", 7261.0, 0.0, "x"), ("sports411.ag", 8548.0, 150.5, "x"),
            ("empire.ag", "CCM166", -20.25, "x"), ("trylnk.com", "LNK98213", None, "x")]
    # header on row 7 in column C..F, a title above it, week number in the title, sheet named "104"
    rows = [[], [], [], [], [], [None, None, title], [None, None, "Website", "Username", "TOTAL", 32360.83]]
    rows += [[None, None, *r] for r in body]
    r = upload(sheet_file({"104": rows}))
    assert r.status_code == 200, r.text
    s = sheet_info(r)
    assert (s["week_from"], s["header_row"], s["figure_column"]) == ("sheet title", 7, "TOTAL")
    assert (s["start_date"], s["end_date"]) == ("2026-09-28", "2026-10-04")  # not the sheet name "104" (Oct 4 + 6)
    assert (s["created"], s["skipped"]) == (2, 2)  # numeric username 8548.0 matches; blank figure and unknown skipped
    assert set(s["skipped_usernames"]) == {"7261", "lnk98213"}
    saved = {f["username"]: f["figure"] for f in c.get("/cappers/figures/all", headers=h).json()}
    assert saved == {"8548": "150.50", "Ccm166": "-20.25"}

    # the title wins over the sheet name; with no title the sheet name is used
    plain = [["Username", "Total"], ["lnk98213", 9]]
    r = upload(sheet_file({"10-13 - 10-19": [[title], *plain]}))
    assert sheet_info(r)["start_date"] == "2026-09-28" and sheet_info(r)["week_from"] == "sheet title"
    r = upload(sheet_file({"10-13 - 10-19": plain}))
    assert (sheet_info(r)["start_date"], sheet_info(r)["week_from"]) == ("2026-10-13", "sheet name")

    # figure column names: figure > fig > total > pnl; any column position; any case
    wk = "10-13 - 10-19"
    for header, want in ((["x", "PNL", "Username"], "PNL"), (["Username", "TOTAL", "Fig"], "Fig"),
                         (["Username", "total", "PNL", "FIGURE"], "FIGURE"), (["USERNAME", "pnl"], "pnl"),
                         ([" User Name ", "  Fig  "], "Fig")):
        u_i = [i for i, x in enumerate(header) if x.strip().lower() in ("username", "user name")][0]
        want_i = [i for i, x in enumerate(header) if x.strip() == want][0]
        row = [None] * len(header)
        row[u_i] = "lnk98213"
        row[want_i] = 5
        for i, x in enumerate(header):  # other candidate columns get a different number
            if i not in (u_i, want_i) and x.strip().lower() in ("fig", "total", "pnl", "figure"):
                row[i] = 999
        r = upload(sheet_file({wk: [header, row]}))
        assert r.status_code == 200 and sheet_info(r)["figure_column"] == want, (header, r.text)
        assert c.get("/cappers/figures/all", headers=h).json()[0]["figure"] == "5.00", header

    # the username column may also be called "Account Name" (any case; "_" or spaces)
    for header in (["Account Name", "PNL"], ["ACCOUNT NAME", "Total"], ["account_name", "fig"],
                   ["Website", " Account   Name ", "Figure"], ["AccountName", "Total"]):
        u_i = next(i for i, x in enumerate(header) if "account" in x.lower())
        f_i = next(i for i, x in enumerate(header) if x.strip().lower() in ("pnl", "total", "fig", "figure"))
        row = [None] * len(header)
        row[u_i], row[f_i] = "lnk98213", 7
        r = upload(sheet_file({wk: [header, row]}))
        assert r.status_code == 200 and r.json()["created"] + r.json()["updated"] == 1, (header, r.text)
        assert c.get("/cappers/figures/all", headers=h).json()[0]["figure"] == "7.00", header
    # "Login" also works as the username column (exact header only)
    for header in (["Login", "PNL"], ["LOGIN", "Total"], ["Website", " login ", "Figure"]):
        u_i = next(i for i, x in enumerate(header) if x.strip().lower() == "login")
        f_i = next(i for i, x in enumerate(header) if x.strip().lower() in ("pnl", "total", "figure"))
        row = [None] * len(header)
        row[u_i], row[f_i] = "lnk98213", 4
        r = upload(sheet_file({wk: [header, row]}))
        assert r.status_code == 200 and r.json()["created"] + r.json()["updated"] == 1, (header, r.text)
        assert c.get("/cappers/figures/all", headers=h).json()[0]["figure"] == "4.00", header
    assert upload(sheet_file({wk: [["Login Date", "Total"], ["lnk98213", 1]]})).status_code == 422
    r = upload(sheet_file({wk: [["Login", "Username", "Total"], ["no_such_account", "lnk98213", 6]]}))  # "username" wins
    assert r.status_code == 200 and c.get("/cappers/figures/all", headers=h).json()[0]["figure"] == "6.00"
    # a plain "Account" column is not a username column (it is a colour/status column in other sheets)
    assert upload(sheet_file({wk: [["Account", "Total"], ["lnk98213", 1]]})).status_code == 422
    # if both exist, "username" wins and the account-name column is ignored
    r = upload(sheet_file({wk: [["Account Name", "Username", "Total"], ["no_such_account", "lnk98213", 11]]}))
    assert r.status_code == 200 and c.get("/cappers/figures/all", headers=h).json()[0]["figure"] == "11.00"

    # a header that merely CONTAINS the word PNL counts as the figure column
    for header, want in ((["Username", "Gross PNL"], "Gross PNL"), (["Gross_PNL", "Account Name"], "Gross_PNL"),
                         (["Username", "Net PNL (USD)"], "Net PNL (USD)"), (["Username", "weekly pnl", "Website"], "weekly pnl"),
                         (["Username", "Gross PNL", "PNL"], "PNL"),          # an exact name beats a "contains PNL" header
                         (["Username", "Gross PNL", "Total"], "Total")):
        u_i = next(i for i, x in enumerate(header) if x.lower() in ("username", "account name"))
        f_i = header.index(want)
        row = [None] * len(header)
        row[u_i], row[f_i] = "lnk98213", 9
        for i, x in enumerate(header):  # the other candidate columns hold a different number
            if i not in (u_i, f_i) and "pnl" in x.lower():
                row[i] = 999
        r = upload(sheet_file({wk: [header, row]}))
        assert r.status_code == 200 and sheet_info(r)["figure_column"] == want, (header, r.text)
        assert c.get("/cappers/figures/all", headers=h).json()[0]["figure"] == "9.00", header
    # but not just any header with part of a word: "Site Fig", "Total Players", "Pnlx"
    for header in (["Username", "Site Fig"], ["Username", "Total Players"], ["Username", "Pnlx"], ["Username", "Unpnl"]):
        assert upload(sheet_file({wk: [header, ["lnk98213", 1]]})).status_code == 422, header
    # several PNL-like columns and nothing exact: refuse to guess
    r = upload(sheet_file({wk: [["Username", "Gross PNL", "Net PNL"], ["lnk98213", 1, 2]]}))
    assert r.status_code == 422 and "Gross PNL" in r.json()["detail"]["errors"][0] and "Net PNL" in r.json()["detail"]["errors"][0]

    # no figure-like column, or no username column: the sheet is not a data sheet
    assert upload(sheet_file({wk: [["Username", "Amount"], ["a", 1]]})).status_code == 422
    assert upload(sheet_file({wk: [["Website", "Total"], ["a", 1]]})).status_code == 422
    # header too far down is not found
    assert upload(sheet_file({wk: [[]] * 40 + [["Username", "Total"], ["lnk98213", 1]]})).status_code == 422

    # a username shared by two of the capper's accounts is ambiguous, in any case
    r = upload(sheet_file({wk: [["Username", "Total"], ["Twin", 1]]}))
    assert r.status_code == 422 and "twin" in r.json()["detail"]["errors"][0]
