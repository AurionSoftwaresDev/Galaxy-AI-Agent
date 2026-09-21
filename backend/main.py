import platform, time, os
from rich.console import Console
from source.utils.agentUtils.startupUtils.typingAnimation import typingTextOnTerminal
from source.utils.logger import logger
from source.utils.helper import sleep, clearTerminalScreen
from source.controllers.keyboardThread.startKeyboardMapping import startKeyboardMappingThread
from source.utils.agentUtils.startupUtils.agentStartupTerminal import galaxyAIAgentStartupTerminal

console : Console = Console()

with console.capture() as capture:

    console.print(f"You Are Pressed CTRL + C AI Agent Stoped.")

keyboardInterruptErrorMessage = capture.get()

def mainAgentHandler() -> None:

    try:
        
        logger.info("Staring Agent....")

        clearTerminalScreen(operatingSystem = platform.system())

        galaxyAIAgentStartupTerminal()

        logger.info("Starting Keyboard Mapping Shortcut Thread...")
                
        startKeyboardMappingThread()
        
        sleep(1, 4)

    except KeyboardInterrupt:

        return mainAgentHandler()

    while True:

        try:

            time.sleep(1)

        except KeyboardInterrupt:

            typingTextOnTerminal(keyboardInterruptErrorMessage, speed = 0.05)

            os._exit(0)
    
if __name__ == "__main__":
     
    clearTerminalScreen(operatingSystem = platform.system())
    
    logger.info("Agent Applicaion Starting...")

    sleep(1, 3)

    logger.info("Agent Application Successfully Started!")

    mainAgentHandler()
