import platform
from fastapi import FastAPI
from source.utils.logger import logger
from source.utils.helper import sleep, clearTerminalScreen
from source.chat.memory.agentMemory import initializeAgentMemory 
from source.controllers.keyboardThread.startKeyboardMapping import startKeyboardMappingThread
from source.agent.runAgent import startAgent
from source.routers.allRoutes import rootRouter

def mainAgentHandler() -> None:
    
    logger.info("Initializing Agent Memory...")
    
    initializeAgentMemory()
    
    logger.info("Starting Keyboard Mapping Shortcut Thread...")
    
    startKeyboardMappingThread()
    
    sleep(1, 5)
    
    logger.info("Staring Agent....")
    
    startAgent()
    

logger.info("Starting Agent Server And Routers...")

agentServer = FastAPI()

agentServer.include_router(
    router = rootRouter
)

logger.info("Server Started All Routers/Routes Set-up Successfully")

if __name__ == "__main__":
    
    logger.info("Agent Applicaion Starting...")
    
    clearTerminalScreen(platform.system())
    
    mainAgentHandler()
    
    logger.info("Agent Application Successfully Started!")