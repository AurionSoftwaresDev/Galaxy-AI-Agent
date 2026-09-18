import platform, time
from source.utils.logger import logger
from source.utils.helper import sleep, clearTerminalScreen
from source.controllers.keyboardThread.startKeyboardMapping import startKeyboardMappingThread
from source.utils.agentUtils.startupUtils.agentStartupTerminal import galaxyAIAgentStartupTerminal

def mainAgentHandler() -> None:

    try:
    
        logger.info("Starting Keyboard Mapping Shortcut Thread...")
        
        startKeyboardMappingThread()
        
        sleep(1, 4)
        
        logger.info("Staring Agent....")

        clearTerminalScreen(operatingSystem = platform.system())

        galaxyAIAgentStartupTerminal()

    except KeyboardInterrupt:

        return mainAgentHandler()

    while True:

        time.sleep(1)
    
if __name__ == "__main__":
     
    clearTerminalScreen(operatingSystem = platform.system())
    
    logger.info("Agent Applicaion Starting...")

    sleep(1, 3)

    logger.info("Agent Application Successfully Started!")

    mainAgentHandler()
