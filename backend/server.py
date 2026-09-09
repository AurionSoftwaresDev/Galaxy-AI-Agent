from fastapi import FastAPI
from source.routers.allRoutes import rootRouter
from source.chat.memory.agentMemory import initializeAgentMemory

initializeAgentMemory()

agentServer = FastAPI()

agentServer.include_router(
    router = rootRouter
)

