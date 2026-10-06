from fastapi import APIRouter
from source.controllers.serverControllers.terminateServer import terminateServer

agentServerTerminaterRouter = APIRouter()

agentServerTerminaterRouter.get("/disconnect")(
    terminateServer
)
