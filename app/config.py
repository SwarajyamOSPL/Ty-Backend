from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env")

    database_url: str = "sqlite:///./crm.db"
    secret_key: str = "dev-secret-change-me"
    # Used to encrypt stored account passwords. Changing it makes old passwords unreadable.
    encryption_key: str = "dev-encryption-key-change-me"
    access_token_expire_minutes: int = 480


settings = Settings()
