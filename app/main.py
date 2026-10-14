from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .db import Base, SessionLocal, engine
from .routers import accounts, auth, dashboard, imports, parties, site_figures
from .security import seed_admin

app = FastAPI(title="Gaming CRM Backend")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in settings.cors_origins.split(",") if o.strip()],
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(auth.router)
app.include_router(dashboard.router)
app.include_router(imports.router)
app.include_router(parties.partners)
app.include_router(parties.cappers)
app.include_router(site_figures.router)
app.include_router(site_figures.all_router)
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
