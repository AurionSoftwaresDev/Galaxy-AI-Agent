import platform
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

    clearTerminalScreen(operatingSystem = platform.system())
    
    startAgent()
    
if __name__ == "__main__":
     
    clearTerminalScreen(operatingSystem = platform.system())
    
    logger.info("Agent Applicaion Starting...")
    
    mainAgentHandler()
    
    logger.info("Agent Application Successfully Started!")