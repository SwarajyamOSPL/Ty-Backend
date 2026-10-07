from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Admin
from ..schemas import AdminOut, ChangePassword, Token
from ..security import create_token, current_user, hash_password, verify_password

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=Token)
def login(form: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    admin = db.scalar(select(Admin).where(Admin.username == form.username))
    if not admin or not verify_password(form.password, admin.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Bad credentials")
    return Token(access_token=create_token(admin))


@router.get("/me", response_model=AdminOut)
def me(admin: Admin = Depends(current_user)):
    return admin


@router.post("/change-password", status_code=204)
def change_password(body: ChangePassword, admin: Admin = Depends(current_user),
                    db: Session = Depends(get_db)):
    if not verify_password(body.current_password, admin.password_hash):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Current password is wrong")
    admin.password_hash = hash_password(body.new_password)
    db.commit()
