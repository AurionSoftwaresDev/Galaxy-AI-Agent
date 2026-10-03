from fastapi import APIRouter
from source.controllers.agentControllers.agentServerHealth import agentHealth

agentHealthChecker = APIRouter()

agentHealthChecker.get("/health")(
    agentHealth
)
