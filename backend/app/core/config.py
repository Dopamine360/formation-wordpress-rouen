from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    project_name: str = "CivicVote API"
    environment: str = "development"
    database_url: str = "postgresql+asyncpg://user:password@db:5432/civicvote"
    redis_url: str = "redis://redis:6379/0"
    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 14
    otp_expire_seconds: int = 300
    signature_required_drift_seconds: int = 30


@lru_cache
def get_settings() -> Settings:
    return Settings()
