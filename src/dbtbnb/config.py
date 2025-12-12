"""Configuration."""

from pathlib import Path
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Config(BaseSettings):
    """Configuration."""

    model_config = SettingsConfigDict(env_file=".env")

    sf_org: str = "test"
    sf_account: str = "test"
    sf_user: str = "test"
    sf_authenticator: str = "SNOWFLAKE_JWT"
    sf_private_key_file_path: Path = Path("~/.ssh/id_rsa.p8")
    sf_role: str = "test"
    sf_warehouse: str = "COMPUTE_WH"
    sf_database: str = "test"
    sf_schema: str = "test"
    sf_semantic_model: str = "test"

    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = "INFO"


def get_config() -> Config:
    """Get config."""
    return Config()
