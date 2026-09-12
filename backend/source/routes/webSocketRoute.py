from fastapi import APIRouter
from source.controllers.agentControllers.agentWebSocketController import agentWebSocketController

agentWebSocketRouter = APIRouter()

agentWebSocketRouter.websocket("/ws/assistant")(
    agentWebSocketController
)