from fastapi import APIRouter
from source.controllers.serverControllers.agentWebSocketController import agentWebSocketController

agentWebSocketRouter = APIRouter()

agentWebSocketRouter.websocket("/ws/assistant")(
    agentWebSocketController
)