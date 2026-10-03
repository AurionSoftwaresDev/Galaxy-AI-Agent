from fastapi import APIRouter, WebSocket
from source.routes.agentRoutes import agentRouter
from source.routes.healthCheck import agentHealthChecker
from source.routes.webSocketRoute import agentWebSocketRouter
from source.routes.Settings.settings import agentSettingsRouter

rootRouter = APIRouter()

rootRouter.include_router(
    prefix = "/agent",
    router = agentRouter
)

rootRouter.include_router(
    router = agentHealthChecker
)

rootRouter.include_router(
    router = agentWebSocketRouter
)

rootRouter.include_router(
    prefix = "/settings",
    router = agentSettingsRouter
)