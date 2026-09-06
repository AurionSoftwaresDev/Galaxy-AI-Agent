from fastapi import APIRouter, WebSocket
from source.controllers.agentControllers.agentWebSocketController import agentWebSocketController

agentWebSocketRouter = APIRouter()

agentWebSocketRouter.WebSocket("/ws/assistant")(
    agentWebSocketController
)