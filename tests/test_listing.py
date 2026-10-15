"""Pagination and search on the list endpoints."""
from tests.test_workflow import W1, Env


def ids(r):
    return [x["id"] for x in r.json()]


def seeded():
    e = Env()
    alpha, beta = e.partner("Alpha Bets"), e.partner("Beta")
    red, blue = e.capper("Red"), e.capper("Blue")
    a = e.account(["Foo.com"], "user_one", partner_ids=[alpha["id"]], capper_ids=[red["id"]])
    b = e.account(["bar.net", "foo.org"], "Other", partner_ids=[beta["id"]], capper_ids=[blue["id"]])
    c = e.account(["baz.com"], "100%_sure", partner_ids=[alpha["id"], beta["id"]], capper_ids=[red["id"], blue["id"]])
    e.upload(red, {W1: [["username", "figure"], ["user_one", 5], ["100%_sure", 7]]})
    return e, (alpha, beta, red, blue), (a, b, c)


def test_accounts_paging_and_headers():
    e, _, (a, b, c) = seeded()
    r = e.get("/accounts", params={"page_size": 2})
    assert ids(r) == [c["id"], b["id"]]                      # newest first
    assert (r.headers["X-Total-Count"], r.headers["X-Page"], r.headers["X-Page-Size"],
            r.headers["X-Total-Pages"]) == ("3", "1", "2", "2")
    assert ids(e.get("/accounts", params={"page_size": 2, "page": 2})) == [a["id"]]
    assert ids(e.get("/accounts", params={"page_size": 2, "page": 3})) == []
    assert e.get("/accounts", params={"page_size": 2, "page": 3}).headers["X-Total-Count"] == "3"


def test_accounts_search():
    e, _, (a, b, c) = seeded()
    q = lambda **p: sorted(ids(e.get("/accounts", params=p)))
    assert q(username="ONE") == [a["id"]]                       # contains, any case
    assert q(username="%") == [c["id"]]                         # % and _ are literal
    assert q(username="_") == sorted([a["id"], c["id"]])
    assert q(website="foo") == sorted([a["id"], b["id"]])       # any of an account's websites
    assert q(website=".com") == sorted([a["id"], c["id"]])
    assert q(partner="alpha") == sorted([a["id"], c["id"]])
    assert q(capper="blue") == sorted([b["id"], c["id"]])
    assert q(partner="beta", capper="red") == [c["id"]]         # filters combine (AND)
    assert q(partner="red") == []                               # a capper's name is not a partner
    assert q(search="beta") == sorted([b["id"], c["id"]])       # one box over everything
    assert q(search="bar.net") == [b["id"]] and q(search="red") == sorted([a["id"], c["id"]])
    assert q(search="zzz") == [] and q(search="  ") == sorted([a["id"], b["id"], c["id"]])  # blank ignored
    r = e.get("/accounts", params={"search": "alpha", "page_size": 1})
    assert len(r.json()) == 1 and r.headers["X-Total-Count"] == "2"       # the total follows the filters


def test_party_lists():
    e, (alpha, beta, red, blue), (a, b, c) = seeded()
    assert [p["name"] for p in e.get("/partners", params={"search": "bet"}).json()] == ["Alpha Bets", "Beta"]
    assert [p["name"] for p in e.get("/cappers", params={"search": "LU"}).json()] == ["Blue"]
    assert {p["name"]: p["account_count"] for p in e.get("/cappers").json()} == {"Blue": 2, "Red": 2}
    assert {p["name"]: p["account_count"] for p in e.get("/partners").json()} == {"Alpha Bets": 2, "Beta": 2}
    r = e.get(f"/partners/{alpha['id']}/accounts", params={"capper": "blue"})
    assert ids(r) == [c["id"]] and r.headers["X-Total-Count"] == "1"
    assert ids(e.get(f"/partners/{alpha['id']}/accounts", params={"website": "foo"})) == [a["id"]]
    assert ids(e.get(f"/cappers/{red['id']}/accounts", params={"partner": "beta"})) == [c["id"]]
    assert ids(e.get(f"/partners/{alpha['id']}/accounts", params={"search": "100%", "page_size": 1})) == [c["id"]]

    r = e.get("/partners/assignments/all", params={"page_size": 2})
    assert len(r.json()) == 2 and r.headers["X-Total-Count"] == "4"
    names = lambda **p: sorted((x["party_name"], x["username"]) for x in e.get("/partners/assignments/all", params=p).json())
    assert names(party="beta") == [("Beta", "100%_sure"), ("Beta", "Other")]
    assert names(username="other") == [("Beta", "Other")]
    assert names(website="foo.org") == [("Beta", "Other")]
    # search also looks at the account's other partners/cappers, so the shared account shows under Beta too
    assert names(search="alpha") == [("Alpha Bets", "100%_sure"), ("Alpha Bets", "user_one"), ("Beta", "100%_sure")]
    assert names(search="bar") == [("Beta", "Other")]
    assert len(e.get("/cappers/assignments/all", params={"party": "red"}).json()) == 2


def test_figures_and_site_figures():
    e, (alpha, beta, red, blue), (a, b, c) = seeded()
    r = e.get("/cappers/figures/all", params={"page_size": 1})
    assert len(r.json()) == 1 and r.headers["X-Total-Count"] == "2"
    users = lambda **p: sorted(x["username"] for x in e.get("/cappers/figures/all", params=p).json())
    assert users(username="one") == ["user_one"]
    assert users(party="red") == ["100%_sure", "user_one"] and users(party="blue") == []
    assert users(website="baz") == ["100%_sure"]
    assert users(search="RED") == ["100%_sure", "user_one"] and users(search="foo.com") == ["user_one"]

    r = e.get("/site-figures", params={"page_size": 1})
    assert len(r.json()) == 1 and r.headers["X-Total-Count"] == "2"
    sf = lambda **p: sorted(x["username"] for x in e.get("/site-figures", params=p).json())
    assert sf(partner="alpha") == ["100%_sure", "user_one"] and sf(partner="beta") == ["100%_sure"]
    assert sf(capper="red") == ["100%_sure", "user_one"] and sf(capper="blue") == ["100%_sure"]
    assert sf(username="one") == ["user_one"] and sf(website="baz") == ["100%_sure"]
    assert sf(search="beta") == ["100%_sure"] and sf(search="nothing") == []

    r = e.get(f"/accounts/{a['id']}/site-figures", params={"page_size": 1})
    assert len(r.json()) == 1 and r.headers["X-Total-Count"] == "1"
