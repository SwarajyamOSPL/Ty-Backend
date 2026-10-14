"""The workflow: partners -> website accounts -> cappers; capper sheets -> Site Figure."""
import io
import os

os.environ["DATABASE_URL"] = "sqlite:///./test.db"

from fastapi.testclient import TestClient  # noqa: E402
from openpyxl import Workbook  # noqa: E402

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.main import app  # noqa: E402
from app.security import seed_admin  # noqa: E402

W1 = "2026-10-06 to 2026-10-12"   # sheet names with a year, so the tests do not depend on today
W2 = "2026-10-13 to 2026-10-19"


def make_client():
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    with SessionLocal() as db:
        seed_admin(db)
    c = TestClient(app)
    tok = c.post("/auth/login", data={"username": "admin", "password": "admin"}).json()
    return c, {"Authorization": f"Bearer {tok['access_token']}"}


def workbook(sheets):
    """{sheet name: [header row, *rows]}"""
    wb = Workbook()
    wb.remove(wb.active)
    for name, rows in sheets.items():
        ws = wb.create_sheet(name)
        for r in rows:
            ws.append(list(r))
    buf = io.BytesIO()
    wb.save(buf)
    return buf.getvalue()


class Env:
    def __init__(self):
        self.c, self.h = make_client()

    def post(self, url, **kw):
        return self.c.post(url, headers=self.h, **kw)

    def get(self, url, **kw):
        return self.c.get(url, headers=self.h, **kw)

    def partner(self, name):
        return self.post("/partners", json={"name": name}).json()

    def capper(self, name):
        return self.post("/cappers", json={"name": name}).json()

    def account(self, websites, username, password="pw", **kw):
        r = self.post("/accounts", json={"websites": websites, "username": username, "password": password, **kw})
        assert r.status_code in (200, 201), r.text
        return r.json()

    def upload(self, capper, sheets, name=None):
        return self.c.post("/cappers/figures/import", headers=self.h, data={"capper_id": capper["id"]},
                           files={"file": (name or f"{capper['name']}.xlsx", workbook(sheets))})

    def site_figure(self, account_id, **params):
        return self.get(f"/accounts/{account_id}", params=params).json()["site_figure"]


def test_shared_credentials_and_same_site_accounts():
    e = Env()
    a, b = e.partner("Alpha"), e.partner("Beta")
    red = e.capper("Red")
    # first partner creates the account
    r = e.post("/accounts", json={"websites": ["Site.com"], "username": "User1", "password": "pw",
                                  "balance": "100", "partner_ids": [a["id"]]})
    assert r.status_code == 201
    acct = r.json()
    assert [p["name"] for p in acct["partners"]] == ["Alpha"] and acct["cappers"] == [] and acct["site_figure"] is None
    # the second partner enters the SAME credentials: the account is shared, not duplicated
    r = e.post("/accounts", json={"websites": ["site.com"], "username": "user1", "password": "pw",
                                  "city": "Dallas", "partner_ids": [b["id"]], "capper_ids": [red["id"]]})
    assert r.status_code == 200 and r.json()["id"] == acct["id"]
    assert sorted(p["name"] for p in r.json()["partners"]) == ["Alpha", "Beta"]
    assert [x["name"] for x in r.json()["cappers"]] == ["Red"]
    assert r.json()["balance"] == "100.00" and r.json()["city"] == "Dallas"  # kept / filled in
    assert len(e.get("/accounts").json()) == 1
    # both partners list the shared account
    for p in (a, b):
        assert [x["id"] for x in e.get(f"/partners/{p['id']}/accounts").json()] == [acct["id"]]
    # repeating it changes nothing
    r = e.post("/accounts", json={"websites": ["Site.com"], "username": "User1", "password": "pw",
                                  "partner_ids": [a["id"], b["id"]]})
    assert r.status_code == 200 and len(e.get("/accounts").json()) == 1

    # a partner can have several accounts on the same website with different credentials
    other = e.account(["Site.com"], "User2", "pw")                       # other username
    other_pw = e.account(["Site.com"], "User1", "different")            # same username, other password
    assert len({acct["id"], other["id"], other_pw["id"]}) == 3
    for x in (other, other_pw):
        assert e.post(f"/partners/{a['id']}/accounts", json={"account_id": x["id"]}).status_code == 201
    assert len(e.get(f"/partners/{a['id']}/accounts").json()) == 3
    # a missing partner/capper is rejected before anything is created
    n = len(e.get("/accounts").json())
    assert e.post("/accounts", json={"websites": ["x.com"], "username": "zz", "partner_ids": [99999]}).status_code == 404
    assert e.post("/accounts", json={"websites": ["x.com"], "username": "zz", "capper_ids": [a["id"]]}).status_code == 404  # a partner is not a capper
    assert len(e.get("/accounts").json()) == n


def test_site_figure_from_imports():
    e = Env()
    p1, p2 = e.partner("P1"), e.partner("P2")
    red, blue, green = e.capper("Red"), e.capper("Blue"), e.capper("Green")
    a = e.account(["s.com"], "U1", partner_ids=[p1["id"], p2["id"]], capper_ids=[red["id"], blue["id"]])  # 2 cappers, 2 partners
    b = e.account(["t.com"], "U2", partner_ids=[p1["id"]], capper_ids=[red["id"]])
    c3 = e.account(["u.com"], "U3", partner_ids=[p2["id"]], capper_ids=[blue["id"], green["id"]])  # cappers shared between accounts
    assert e.site_figure(a["id"]) is None

    # Red imports week 1: U1 -50.5 (negative), U2 20, someone else's account is skipped
    r = e.upload(red, {W1: [["Website", "Username", "TOTAL"], ["s.com", "u1", -50.5], ["t.com", "U2", 20], ["z.com", "nobody", 5]]})
    assert r.status_code == 200, r.text
    assert (r.json()["created"], r.json()["skipped"], r.json()["site_figures_updated"]) == (2, 1, 2)
    assert e.site_figure(a["id"]) == "-50.50" and e.site_figure(b["id"]) == "20.00"   # Site Figure set by the import itself
    # Blue imports the same week: the Site Figure of the shared accounts adds up (negative included)
    r = e.upload(blue, {W1: [["username", "pnl"], ["U1", 30], ["u3", -100]]})
    assert r.status_code == 200 and r.json()["site_figures_updated"] == 2
    assert e.site_figure(a["id"]) == "-20.50"        # -50.5 + 30
    assert e.site_figure(c3["id"]) == "-100.00"      # Green has nothing yet
    r = e.upload(green, {W1: [["username", "fig"], ["U3", 40.25]]})
    assert e.site_figure(c3["id"]) == "-59.75"       # -100 + 40.25
    # re-importing a corrected sheet updates the Site Figure, it does not add to it
    e.upload(red, {W1: [["username", "figure"], ["U1", 10], ["U2", 20]]})
    assert e.site_figure(a["id"]) == "40.00" and e.site_figure(b["id"]) == "20.00"

    # a later week is kept separately; the account shows the latest week unless one is asked for
    e.upload(red, {W2: [["username", "total"], ["U1", 7]]})
    acct = e.get(f"/accounts/{a['id']}").json()
    assert (acct["site_figure"], acct["site_figure_start_date"], acct["site_figure_end_date"]) == ("7.00", "2026-10-13", "2026-10-19")
    assert e.site_figure(a["id"], start_date="2026-10-06", end_date="2026-10-12") == "40.00"
    assert e.site_figure(a["id"], start_date="2026-01-01", end_date="2026-01-07") is None
    assert [(x["start_date"], x["site_figure"]) for x in e.get(f"/accounts/{a['id']}/site-figures").json()] == [
        ("2026-10-13", "7.00"), ("2026-10-06", "40.00")]
    assert e.get(f"/accounts/{a['id']}", params={"start_date": "2026-10-06"}).status_code == 422  # both dates or none

    # the same Site Figure shows under every partner that has the account
    for p in (p1, p2):
        mine = {x["id"]: x for x in e.get(f"/partners/{p['id']}/accounts").json()}
        assert mine[a["id"]]["site_figure"] == "7.00"
    assert e.get(f"/partners/{p1['id']}/accounts", params={"start_date": "2026-10-06", "end_date": "2026-10-12"}).json()[0]["site_figure"] == "40.00"
    assert len(e.get("/site-figures").json()) == 4   # one per account and week: a has 2 weeks, b 1, c3 1
    assert len(e.get("/site-figures", params={"partner_id": p2["id"]}).json()) == 3


def test_changing_cappers_recalculates():
    e = Env()
    p = e.partner("P")
    red, blue = e.capper("Red"), e.capper("Blue")
    a = e.account(["s.com"], "U1", partner_ids=[p["id"]], capper_ids=[red["id"], blue["id"]])
    e.upload(red, {W1: [["username", "figure"], ["U1", 100]]})
    e.upload(blue, {W1: [["username", "figure"], ["U1", -30]]})
    assert e.site_figure(a["id"]) == "70.00"

    # remove one capper from the account: its figure no longer counts
    assert e.c.delete(f"/cappers/{blue['id']}/accounts/{a['id']}", headers=e.h).status_code == 204
    assert e.site_figure(a["id"]) == "100.00"
    assert [x["name"] for x in e.get(f"/accounts/{a['id']}").json()["cappers"]] == ["Red"]
    # its figures are kept, so adding it back counts them again
    assert e.post(f"/cappers/{blue['id']}/accounts", json={"account_id": a["id"]}).status_code == 201
    assert e.site_figure(a["id"]) == "70.00"
    # replace the whole list of cappers
    r = e.c.put(f"/accounts/{a['id']}/cappers", json={"capper_ids": [blue["id"]]}, headers=e.h)
    assert r.status_code == 200 and [x["name"] for x in r.json()["cappers"]] == ["Blue"] and r.json()["site_figure"] == "-30.00"
    r = e.c.put(f"/accounts/{a['id']}/cappers", json={"capper_ids": []}, headers=e.h)
    assert r.json()["cappers"] == [] and r.json()["site_figure"] is None          # nobody left: no Site Figure
    assert e.get(f"/accounts/{a['id']}/site-figures").json() == []
    r = e.c.put(f"/accounts/{a['id']}/cappers", json={"capper_ids": [red["id"], red["id"], blue["id"]]}, headers=e.h)
    assert r.json()["site_figure"] == "70.00" and len(r.json()["cappers"]) == 2      # duplicates in the list are ignored
    assert e.c.put(f"/accounts/{a['id']}/cappers", json={"capper_ids": [p["id"]]}, headers=e.h).status_code == 404  # a partner is not a capper
    assert e.c.put("/accounts/99999/cappers", json={"capper_ids": []}, headers=e.h).status_code == 404

    # removing a partner keeps the account and its Site Figure; unknown links are 404
    assert e.c.delete(f"/partners/{p['id']}/accounts/{a['id']}", headers=e.h).status_code == 204
    assert e.get(f"/accounts/{a['id']}").json()["partners"] == [] and e.site_figure(a["id"]) == "70.00"
    assert e.c.delete(f"/partners/{p['id']}/accounts/{a['id']}", headers=e.h).status_code == 404
    assert e.c.delete(f"/cappers/{p['id']}/accounts/{a['id']}", headers=e.h).status_code == 404  # wrong kind
    assert e.c.delete(f"/cappers/{red['id']}/accounts/{a['id']}").status_code == 401


def test_same_username_on_different_websites():
    e = Env()
    red = e.capper("Red")
    x = e.account(["one.com"], "Pw20", capper_ids=[red["id"]])
    y = e.account(["two.com"], "Pw20", capper_ids=[red["id"]])
    # without a Website column the username alone is ambiguous
    r = e.upload(red, {W1: [["Username", "Total"], ["pw20", 1]]})
    assert r.status_code == 422 and "Website column" in r.json()["detail"]["errors"][0]
    # with one, the website decides (www./scheme/case do not matter)
    r = e.upload(red, {W1: [["Website", "Username", "Total"], ["https://WWW.One.com/x", "PW20", 5], ["two.com", "Pw20", -8]]})
    assert r.status_code == 200 and r.json()["created"] == 2
    assert (e.site_figure(x["id"]), e.site_figure(y["id"])) == ("5.00", "-8.00")
    # a website that matches neither is still ambiguous
    assert e.upload(red, {W2: [["Website", "Username", "Total"], ["three.com", "Pw20", 1]]}).status_code == 422


def test_partner_and_capper_details():
    e = Env()
    p1, p2 = e.partner("P1"), e.partner("P2")
    red, blue = e.capper("Red"), e.capper("Blue")
    a = e.account(["s.com"], "U1", balance="100", partner_ids=[p1["id"], p2["id"]], capper_ids=[red["id"], blue["id"]])
    b = e.account(["t.com"], "U2", balance="-30.5", partner_ids=[p1["id"]], capper_ids=[red["id"]])
    e.account(["u.com"], "U3", balance="Infinite", partner_ids=[p1["id"]])
    e.account(["v.com"], "U4", partner_ids=[p1["id"]])
    e.account(["w.com"], "U5", balance="7", partner_ids=[p2["id"]], capper_ids=[blue["id"]])

    d = e.get(f"/partners/{p1['id']}").json()
    assert (d["id"], d["name"], d["account_count"], d["shared_account_count"]) == (p1["id"], "P1", 4, 1)
    assert (d["total_balance"], d["accounts_without_numeric_balance"]) == ("69.50", 2)   # 100 - 30.5; "Infinite" and none excluded
    assert [(x["name"], x["account_count"]) for x in d["cappers"]] == [("Red", 2), ("Blue", 1)] and d["partners"] == []
    assert d["site_figure_total"] is None and d["accounts_with_site_figure"] == 0
    d2 = e.get(f"/partners/{p2['id']}").json()
    assert (d2["account_count"], d2["shared_account_count"], d2["total_balance"]) == (2, 1, "107.00")

    # Site Figure total for the latest week (or the week asked for), over the partner's accounts
    e.upload(red, {W1: [["username", "figure"], ["U1", 50], ["U2", -20]]})
    e.upload(blue, {W1: [["username", "figure"], ["U1", 5], ["U5", 3]]})
    e.upload(red, {W2: [["username", "figure"], ["U1", 11]]})
    d = e.get(f"/partners/{p1['id']}").json()   # latest week = W2: only U1 has one
    assert (d["site_figure_start_date"], d["site_figure_end_date"], d["site_figure_total"], d["accounts_with_site_figure"]) == (
        "2026-10-13", "2026-10-19", "11.00", 1)
    d = e.get(f"/partners/{p1['id']}", params={"start_date": "2026-10-06", "end_date": "2026-10-12"}).json()
    assert (d["site_figure_total"], d["accounts_with_site_figure"]) == ("35.00", 2)       # U1 55 + U2 -20
    d = e.get(f"/partners/{p2['id']}", params={"start_date": "2026-10-06", "end_date": "2026-10-12"}).json()
    assert (d["site_figure_total"], d["accounts_with_site_figure"]) == ("58.00", 2)       # U1 55 + U5 3
    d = e.get(f"/partners/{p1['id']}", params={"start_date": "2026-01-01", "end_date": "2026-01-07"}).json()
    assert d["site_figure_total"] == "0" or d["site_figure_total"] == "0.00"
    assert d["accounts_with_site_figure"] == 0
    assert e.get(f"/partners/{p1['id']}", params={"start_date": "2026-01-01"}).status_code == 422

    # a capper's details: which partners its accounts belong to
    dc = e.get(f"/cappers/{red['id']}").json()
    assert (dc["name"], dc["account_count"], dc["shared_account_count"], dc["total_balance"]) == ("Red", 2, 1, "69.50")   # U1 also has Blue
    assert [(x["name"], x["account_count"]) for x in dc["partners"]] == [("P1", 2), ("P2", 1)] and dc["cappers"] == []
    assert dc["site_figure_total"] is None

    # errors and routing
    assert e.get("/partners/99999").status_code == 404
    assert e.get(f"/partners/{red['id']}").status_code == 404 and e.get(f"/cappers/{p1['id']}").status_code == 404  # wrong kind
    assert e.c.get(f"/partners/{p1['id']}").status_code == 401
    assert len(e.get("/cappers/colors").json()) == 16                       # still reachable next to /cappers/{id}
    assert len(e.get(f"/partners/{p1['id']}/accounts").json()) == 4
