import platform
from fastapi import FastAPI
from source.utils.logger import logger
from source.utils.helper import sleep, clearTerminalScreen
from source.chat.memory.agentMemory import initializeAgentMemory 
from source.controllers.keyboardThread.startKeyboardMapping import startKeyboardMappingThread
from source.agent.runAgent import startAgent

def mainAgentHandler() -> None:
    
    logger.info("Initializing Agent Memory...")
    
    initializeAgentMemory()
    
    logger.info("Starting Keyboard Mapping Shortcut Thread...")
    
    startKeyboardMappingThread()
    
    sleep(1, 5)
    
    logger.info("Staring Agent....")
    
    startAgent()
    
if __name__ == "__main__":
     
    clearTerminalScreen(platform.system())
    
    logger.info("Agent Applicaion Starting...")
    
    mainAgentHandler()
    
    logger.info("Agent Application Successfully Started!")