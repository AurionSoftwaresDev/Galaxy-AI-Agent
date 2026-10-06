from fastapi import APIRouter
from source.controllers.serverControllers.agentResponse import agentRequestResponse

agentRouter = APIRouter()

agentRouter.post("/generate") (

    agentRequestResponse
)
