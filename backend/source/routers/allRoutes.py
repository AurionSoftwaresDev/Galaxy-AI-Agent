from fastapi import APIRouter
from source.routes.agentRoutes import agentRouter
from source.routes.healthCheck import agentHealthChecker

rootRouter = APIRouter()

rootRouter.include_router(
    prefix = "/agent",
    router = agentRouter
)

rootRouter.include_router(
    router = agentHealthChecker
)