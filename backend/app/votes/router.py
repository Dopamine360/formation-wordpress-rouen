import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Header, HTTPException, status

from .schemas import VoteReceipt, VoteSubmitRequest, VoteVerifyResponse
from ..common.dependencies import SecureHeaders, SecureSignature, get_app_settings
from ..core.config import Settings

router = APIRouter()


@router.post("/submit", response_model=VoteReceipt, status_code=status.HTTP_202_ACCEPTED)
async def submit_vote(
    payload: VoteSubmitRequest,
    authorization: str = Header(..., alias="Authorization"),
    _: SecureHeaders = Depends(),
    __: SecureSignature = Depends(),
    settings: Settings = Depends(get_app_settings),
) -> VoteReceipt:
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    # TODO: validate JWT, signature, merkle leaf, and store ballot
    vote_id = str(uuid.uuid4())
    merkle_root = "BASE64_MERKLE_ROOT_PLACEHOLDER"
    return VoteReceipt(
        vote_id=vote_id,
        merkle_root=merkle_root,
        merkle_path=["BASE64_NODE_A", "BASE64_NODE_B"],
        server_timestamp=datetime.utcnow(),
        receipt_signature="BASE64_RECEIPT_SIGNATURE",
    )


@router.get("/verify", response_model=VoteVerifyResponse)
async def verify_vote(vote_id: str, merkle_root: str) -> VoteVerifyResponse:
    # TODO: lookup ballot status and provide proof path
    return VoteVerifyResponse(
        vote_id=vote_id,
        status="counted",
        merkle_root=merkle_root,
        merkle_path=["BASE64_NODE_A", "BASE64_NODE_B"],
        audit_log_reference="00000000-0000-0000-0000-000000000000",
        server_signature="BASE64_SERVER_SIGNATURE",
    )
