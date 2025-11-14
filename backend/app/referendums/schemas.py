from datetime import datetime
from typing import List

from pydantic import BaseModel, Field


class ReferendumOption(BaseModel):
    label: str
    order: int | None = None


class ReferendumCreateRequest(BaseModel):
    title: str
    description: str
    start_at: datetime
    end_at: datetime
    options: List[ReferendumOption]
    result_mode: str = Field(default="hidden_until_close", pattern="^(public|hidden_until_close)$")


class ReferendumSummary(BaseModel):
    id: str
    title: str
    status: str
    start_at: datetime
    end_at: datetime
    result_mode: str
    public_key: str


class ReferendumListResponse(BaseModel):
    items: list[ReferendumSummary]
