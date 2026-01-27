"""Utils."""

import base64
import hashlib
from datetime import UTC, datetime, timedelta
from pathlib import Path

import jwt
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric.types import (
    PrivateKeyTypes,
)
from cryptography.hazmat.primitives.serialization import (
    Encoding,
    PublicFormat,
    load_pem_private_key,
)

from dbtbnb.logger import get_logger

logger = get_logger(__name__)


def _load_private_key(private_key_file_path: Path) -> PrivateKeyTypes:
    with private_key_file_path.expanduser().open(mode="rb") as f:
        lines = f.read()
        private_key = load_pem_private_key(lines, password=None, backend=default_backend())

        return private_key


def get_fingerprint(private_key_file_path: Path):
    """Get fingerprint from private key."""
    private_key = _load_private_key(private_key_file_path)
    public_key = private_key.public_key().public_bytes(
        encoding=Encoding.DER, format=PublicFormat.SubjectPublicKeyInfo
    )

    hash = hashlib.sha256()
    hash.update(public_key)

    fingerprint = f"SHA256:{base64.b64encode(hash.digest()).decode()}"

    return fingerprint


def get_jwt(
    sf_org: str, sf_account: str, sf_user: str, sf_private_key_file_path: Path, fingerprint: str
):
    """Get JWT from private key."""
    now = datetime.now(tz=UTC)
    lifetime = timedelta(minutes=59)
    qualified_user = f"{sf_org.upper()}-{sf_account.upper()}.{sf_user.upper()}"
    payload = {
        "iss": f"{qualified_user}.{fingerprint}",
        "sub": qualified_user,
        "iat": now,
        "exp": now + lifetime,
    }
    logger.debug("Payload for JWT is: %s", payload)
    private_key = _load_private_key(sf_private_key_file_path)

    token = jwt.encode(payload, key=private_key, algorithm="RS256")  # type: ignore[invalid-argument-type]

    return token
