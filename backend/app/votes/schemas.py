from datetime import datetime
from pydantic import BaseModel


class BallotCiphertext(BaseModel):
    c1: str
    c2: str


class VoteSubmitRequest(BaseModel):
    referendum_id: str
    ballot_ciphertext: BallotCiphertext
    proof_commitment: str
    merkle_leaf: str
    client_timestamp: datetime
    nonce: str
    signature: str


class VoteReceipt(BaseModel):
    vote_id: str
    merkle_root: str
    merkle_path: list[str]
    server_timestamp: datetime
    receipt_signature: str


class VoteVerifyResponse(BaseModel):
    vote_id: str
    status: str
    merkle_root: str
    merkle_path: list[str]
    audit_log_reference: str
    server_signature: str
