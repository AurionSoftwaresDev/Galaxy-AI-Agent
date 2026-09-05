from fastapi import APIRouter
from source.controllers.agentControllers.agentResponse import agentRequestResponse

agentRouter = APIRouter()

agentRouter.post("/generate")(
    agentRequestResponse
)
