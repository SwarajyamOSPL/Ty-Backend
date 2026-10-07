import base64
import hashlib

from cryptography.fernet import Fernet

from .config import settings

_fernet = Fernet(base64.urlsafe_b64encode(hashlib.sha256(settings.encryption_key.encode()).digest()))


def encrypt(value: str | None) -> str | None:
    return _fernet.encrypt(value.encode()).decode() if value else None


def decrypt(token: str | None) -> str | None:
    return _fernet.decrypt(token.encode()).decode() if token else None
