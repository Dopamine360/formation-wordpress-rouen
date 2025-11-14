from datetime import datetime, timedelta
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from jose import jwt

from .schemas import (
    LoginRequest,
    LoginResponse,
    RegisterVoterRequest,
    RegisterVoterResponse,
    TokenPair,
    VerifyOtpRequest,
)
from ..common.dependencies import get_app_settings
from ..core.config import Settings

router = APIRouter()


@router.post("/login", response_model=LoginResponse)
async def login(payload: LoginRequest, settings: Settings = Depends(get_app_settings)) -> LoginResponse:
    # TODO: lookup voter eligibility, validate signature and nonce
    challenge_id = str(uuid.uuid4())
    # Persist challenge with expiry in Redis
    return LoginResponse(challenge_id=challenge_id, otp_channel="email", expires_in=settings.otp_expire_seconds)


@router.post("/verify-otp", response_model=TokenPair)
async def verify_otp(payload: VerifyOtpRequest, settings: Settings = Depends(get_app_settings)) -> TokenPair:
    # TODO: verify challenge exists and OTP is valid
    voter_id = "00000000-0000-0000-0000-000000000000"
    referendum_id = "00000000-0000-0000-0000-000000000000"
    issued_at = datetime.utcnow()
    access_expires = issued_at + timedelta(minutes=settings.access_token_expire_minutes)
    refresh_expires = issued_at + timedelta(days=settings.refresh_token_expire_days)

    access_token = jwt.encode(
        {"sub": voter_id, "ref": referendum_id, "iat": int(issued_at.timestamp()), "exp": int(access_expires.timestamp())},
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
    )
    refresh_token = jwt.encode(
        {"sub": voter_id, "type": "refresh", "iat": int(issued_at.timestamp()), "exp": int(refresh_expires.timestamp())},
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
    )

    # TODO: persist refresh token hash
    return TokenPair(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.access_token_expire_minutes * 60,
        refresh_expires_in=settings.refresh_token_expire_days * 24 * 3600,
        requires_mfa=False,
    )


@router.post("/refresh", response_model=TokenPair)
async def refresh_token(*, settings: Settings = Depends(get_app_settings)) -> TokenPair:
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail="Refresh flow not implemented")


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(*, settings: Settings = Depends(get_app_settings)) -> None:
    # TODO: revoke refresh token
    return None


@router.post("/register", response_model=RegisterVoterResponse, status_code=status.HTTP_201_CREATED)
async def register_voter(payload: RegisterVoterRequest, settings: Settings = Depends(get_app_settings)) -> RegisterVoterResponse:
    # TODO: create voter in DB, hash eligibility token, store OTP secret
    voter_id = str(uuid.uuid4())
    return RegisterVoterResponse(voter_id=voter_id, temporary_password=None, invitation_sent=True)
