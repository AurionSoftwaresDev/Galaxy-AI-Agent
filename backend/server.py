from fastapi import FastAPI
from source.routers.allRoutes import rootRouter

agentServer = FastAPI()

agentServer.include_router(
    router = rootRouter
)

