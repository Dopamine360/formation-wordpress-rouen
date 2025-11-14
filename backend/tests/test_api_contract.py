from datetime import datetime

from fastapi.testclient import TestClient

from app.main import create_app


client = TestClient(create_app())


def test_login_returns_challenge_response():
    payload = {
        "email": "voter@example.com",
        "referendum_id": "00000000-0000-0000-0000-000000000000",
        "client_nonce": "BASE64_NONCE",
        "signature": "BASE64_SIGNATURE",
    }

    response = client.post("/v1/auth/login", json=payload)

    assert response.status_code == 200
    data = response.json()
    assert "challenge_id" in data
    assert data["otp_channel"] == "email"
    assert data["expires_in"] > 0


def test_create_referendum_requires_valid_dates():
    now = datetime.utcnow()
    payload = {
        "title": "Budget participatif",
        "description": "Vote sur les projets 2024",
        "start_at": now.isoformat(),
        "end_at": now.isoformat(),
        "options": [
            {"label": "Pour"},
            {"label": "Contre"},
        ],
        "result_mode": "hidden_until_close",
    }

    response = client.post(
        "/v1/referendum/create",
        json=payload,
        headers={"X-Timestamp": now.isoformat(), "X-Signature": "dummy"},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "La date de début doit précéder la date de fin"


def _build_valid_vote_payload() -> dict:
    timestamp = datetime.utcnow()
    return {
        "referendum_id": "00000000-0000-0000-0000-000000000000",
        "ballot_ciphertext": {
            "c1": "BASE64_C1",
            "c2": "BASE64_C2",
        },
        "proof_commitment": "BASE64_COMMITMENT",
        "merkle_leaf": "BASE64_LEAF",
        "client_timestamp": timestamp.isoformat(),
        "nonce": "BASE64_NONCE",
        "signature": "BASE64_SIGNATURE",
    }


def test_vote_submit_requires_bearer_token():
    payload = _build_valid_vote_payload()
    headers = {
        "X-Timestamp": datetime.utcnow().isoformat(),
        "X-Signature": "dummy",
    }

    response = client.post("/v1/vote/submit", json=payload, headers=headers)

    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid token"


def test_vote_submit_accepts_well_formed_request():
    payload = _build_valid_vote_payload()
    timestamp = datetime.utcnow().isoformat()
    headers = {
        "Authorization": "Bearer ACCESS_TOKEN",
        "X-Timestamp": timestamp,
        "X-Signature": "dummy",
    }

    response = client.post("/v1/vote/submit", json=payload, headers=headers)

    assert response.status_code == 202
    data = response.json()
    assert "vote_id" in data
    assert data["merkle_root"].startswith("BASE64_")


def test_vote_verify_returns_receipt_details():
    response = client.get(
        "/v1/vote/verify",
        params={
            "vote_id": "00000000-0000-0000-0000-000000000000",
            "merkle_root": "BASE64_MERKLE_ROOT_PLACEHOLDER",
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "counted"
    assert data["merkle_root"] == "BASE64_MERKLE_ROOT_PLACEHOLDER"
    assert "audit_log_reference" in data
