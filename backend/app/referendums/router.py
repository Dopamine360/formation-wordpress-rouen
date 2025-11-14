import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status

from .schemas import ReferendumCreateRequest, ReferendumListResponse, ReferendumSummary
from ..common.dependencies import SecureHeaders, SecureSignature
from ..core.config import Settings
from ..common.dependencies import get_app_settings

router = APIRouter()


@router.post("/create", response_model=ReferendumSummary, status_code=status.HTTP_201_CREATED)
async def create_referendum(
    payload: ReferendumCreateRequest,
    _: SecureHeaders,
    __: SecureSignature,
    settings: Settings = Depends(get_app_settings),
) -> ReferendumSummary:
    if payload.start_at >= payload.end_at:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La date de début doit précéder la date de fin")

    # TODO: persist in database and generate per-referendum public key
    referendum_id = str(uuid.uuid4())
    public_key = "BASE64_PUBLIC_KEY_PLACEHOLDER"
    return ReferendumSummary(
        id=referendum_id,
        title=payload.title,
        status="draft",
        start_at=payload.start_at,
        end_at=payload.end_at,
        result_mode=payload.result_mode,
        public_key=public_key,
    )


@router.get("/list", response_model=ReferendumListResponse)
async def list_referendums() -> ReferendumListResponse:
    # TODO: fetch from database with filters
    now = datetime.utcnow()
    return ReferendumListResponse(
        items=[
            ReferendumSummary(
                id="00000000-0000-0000-0000-000000000000",
                title="Scrutin test",
                status="ongoing",
                start_at=now,
                end_at=now,
                result_mode="hidden_until_close",
                public_key="BASE64_PUBLIC_KEY_PLACEHOLDER",
            )
        ]
    )
