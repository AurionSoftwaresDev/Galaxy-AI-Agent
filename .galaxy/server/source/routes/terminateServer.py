from fastapi import APIRouter
from source.controllers.terminateServer import terminateServer

agentServerTerminaterRouter = APIRouter()

agentServerTerminaterRouter.get("/desktop/disconnect")(
    terminateServer
)
