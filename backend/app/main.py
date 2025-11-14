from fastapi import FastAPI

from .auth.router import router as auth_router
from .referendums.router import router as referendum_router
from .votes.router import router as vote_router


def create_app() -> FastAPI:
    app = FastAPI(
        title="CivicVote API",
        version="0.1.0",
        description="API sécurisée pour le vote citoyen",
    )

    app.include_router(auth_router, prefix="/v1/auth", tags=["auth"])
    app.include_router(referendum_router, prefix="/v1/referendum", tags=["referendum"])
    app.include_router(vote_router, prefix="/v1/vote", tags=["vote"])

    return app


app = create_app()
