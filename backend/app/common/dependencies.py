from typing import Annotated
from fastapi import Depends, Header, HTTPException, status

from ..core.config import get_settings, Settings


async def verify_timestamp(x_timestamp: Annotated[str | None, Header(alias="X-Timestamp")]) -> str:
    if x_timestamp is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Missing X-Timestamp header")
    # TODO: validate drift using settings.signature_required_drift_seconds
    return x_timestamp


async def verify_signature(x_signature: Annotated[str | None, Header(alias="X-Signature")]) -> str:
    if x_signature is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Missing X-Signature header")
    # TODO: verify Ed25519 signature against registered key
    return x_signature


def get_app_settings() -> Settings:
    return get_settings()


SecureHeaders = Annotated[str, Depends(verify_timestamp)]
SecureSignature = Annotated[str, Depends(verify_signature)]
