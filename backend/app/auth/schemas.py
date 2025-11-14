from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    email: EmailStr
    referendum_id: str
    client_nonce: str
    signature: str


class LoginResponse(BaseModel):
    challenge_id: str
    otp_channel: str
    expires_in: int = Field(default=300, description="Seconds before the OTP expires")


class VerifyOtpRequest(BaseModel):
    challenge_id: str
    otp_code: str
    device_info: dict | None = None


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int
    refresh_expires_in: int
    requires_mfa: bool = False


class RegisterVoterRequest(BaseModel):
    referendum_id: str
    email: EmailStr
    display_name: Optional[str] = None
    public_signing_key: str
    eligibility_token: str
    otp_delivery: str = "email"


class RegisterVoterResponse(BaseModel):
    voter_id: str
    temporary_password: Optional[str] = None
    invitation_sent: bool = True


class JwtSubject(BaseModel):
    voter_id: str
    referendum_id: str
    issued_at: datetime
