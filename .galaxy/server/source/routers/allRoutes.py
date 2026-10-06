from fastapi import APIRouter
from source.routes.agentRoutes import agentRouter
from source.routes.healthCheckRoute import agentHealthChecker
from source.routes.webSocketRoute import agentWebSocketRouter
from source.routes.Settings.settingsRoutes import agentSettingsRouter
from source.routes.terminateServerRoute import agentServerTerminaterRouter
from source.routes.Chats.chatsRoutes import agentChatsRouter

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

rootRouter.include_router(
    prefix = "/server",
    router = agentServerTerminaterRouter
)

rootRouter.include_router(
    prefix = "/chats",
    router = agentChatsRouter
)