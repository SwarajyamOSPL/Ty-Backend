from fastapi import FastAPI

from .db import Base, SessionLocal, engine
from .routers import accounts, auth, dashboard, parties
from .security import seed_admin

app = FastAPI(title="Gaming CRM Backend")
app.include_router(auth.router)
app.include_router(dashboard.router)
app.include_router(parties.partners)
app.include_router(parties.cappers)
app.include_router(accounts.router)


@app.on_event("startup")
def create_tables():
    # Dev convenience; switch to Alembic migrations before production.
    Base.metadata.create_all(engine)
    with SessionLocal() as db:
        seed_admin(db)


@app.get("/health")
def health():
    return {"status": "ok"}
