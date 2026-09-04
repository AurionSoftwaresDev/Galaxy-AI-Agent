from fastapi import APIRouter
from source.routes.agentRoutes import agentRouter

rootRouter = APIRouter()

rootRouter.include_router(
    prefix = "/agent",
    router = agentRouter
)