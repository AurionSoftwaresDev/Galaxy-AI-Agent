from fastapi import APIRouter
from source.controllers.serverControllers.agentServerHealth import agentHealth

agentHealthChecker = APIRouter()

agentHealthChecker.get("/health")(
    agentHealth
)
