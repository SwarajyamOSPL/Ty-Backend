import os

os.environ["DATABASE_URL"] = "sqlite:///./test.db"

from fastapi.testclient import TestClient  # noqa: E402

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.main import app  # noqa: E402
from app.security import seed_admin  # noqa: E402


def test_full_flow():
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    with SessionLocal() as db:
        seed_admin(db)
        seed_admin(db)  # idempotent: still exactly one row
    c = TestClient(app)
    assert c.post("/auth/login", data={"username": "admin", "password": "nope"}).status_code == 401
    assert c.get("/partners").status_code == 401
    tok = c.post("/auth/login", data={"username": "admin", "password": "admin"}).json()
    h = {"Authorization": f"Bearer {tok['access_token']}"}

    # partner: unique name (case-insensitive)
    p1 = c.post("/partners", json={"name": "Alpha"}, headers=h).json()
    assert c.post("/partners", json={"name": " alpha "}, headers=h).status_code == 409
    p2 = c.post("/partners", json={"name": "Bravo"}, headers=h).json()
    # same name allowed as a capper
    cap = c.post("/cappers", json={"name": "Alpha"}, headers=h)
    assert cap.status_code == 201
    assert [p["name"] for p in c.get("/partners?prefix=a", headers=h).json()] == ["Alpha"]

    # accounts: password never listed
    a1 = c.post("/accounts", json={"website": "site1.com", "username": "u1", "password": "pw1"},
                headers=h).json()
    a2 = c.post("/accounts", json={"website": "site2.com"}, headers=h).json()
    listed = c.get("/accounts", headers=h).json()
    assert all("password" not in a for a in listed)

    # assign: no duplicate per partner, but same account under another partner is fine
    assert c.post(f"/partners/{p1['id']}/accounts", json={"account_id": a1["id"]},
                  headers=h).status_code == 201
    assert c.post(f"/partners/{p1['id']}/accounts", json={"account_id": a1["id"]},
                  headers=h).status_code == 409
    assert c.post(f"/partners/{p2['id']}/accounts", json={"account_id": a1["id"]},
                  headers=h).status_code == 201
    c.post(f"/partners/{p1['id']}/accounts", json={"account_id": a2["id"]}, headers=h)
    assert len(c.get(f"/partners/{p1['id']}/accounts", headers=h).json()) == 2
    assert len(c.get(f"/partners/{p2['id']}/accounts?prefix=site2", headers=h).json()) == 0

    # enter figure: credentials pre-fill, missing ones come back null
    cred = c.get(f"/partners/{p1['id']}/accounts/{a1['id']}/credentials", headers=h).json()
    assert cred["username"] == "u1" and cred["password"] == "pw1"
    cred2 = c.get(f"/partners/{p1['id']}/accounts/{a2['id']}/credentials", headers=h).json()
    assert cred2["username"] is None and cred2["password"] is None

    r = c.post(f"/partners/{p1['id']}/figures",
               json={"account_id": a2["id"], "amount": "150.50", "username": "new", "password": "np"},
               headers=h)
    assert r.status_code == 201 and r.json()["username"] == "new"
    cred2 = c.get(f"/partners/{p1['id']}/accounts/{a2['id']}/credentials", headers=h).json()
    assert cred2["password"] == "np"
    # figure on an unassigned account is rejected
    assert c.post(f"/partners/{p2['id']}/figures", json={"account_id": a2["id"], "amount": "1"},
                  headers=h).status_code == 404

    d = c.get("/dashboard", headers=h).json()
    assert d["partners"] == 2 and d["cappers"] == 1 and d["partner_figure_total"] == "150.50"
