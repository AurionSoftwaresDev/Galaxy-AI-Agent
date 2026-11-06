import os
import platform

from rich.console import Console

from source.controllers.keyboardThread.startKeyboardMapping import (
    startKeyboardMappingThread,
)
from source.utils.agentUtils.startupUtils.agentStartupTerminal import (
    galaxyAIAgentStartupTerminal,
)
from source.utils.agentUtils.startupUtils.typingAnimation import typingTextOnTerminal
from source.utils.helper import clearTerminalScreen, sleep
from source.utils.logger import logger

console : Console = Console()

with console.capture() as capture:

    console.print("You Are Pressed CTRL + C AI Agent Stopped.")

keyboardInterruptErrorMessage = capture.get()

def mainAgentHandler() -> None:

    try:
        
        logger.info("Staring Agent....")

        clearTerminalScreen(operatingSystem = platform.system())

        galaxyAIAgentStartupTerminal()

        logger.info("Starting Keyboard Mapping Shortcut Thread...")
                
        startKeyboardMappingThread()
        
        sleep(startRange = 1, endRange = 4)

    except KeyboardInterrupt:

        return mainAgentHandler()

    while True:

        try:

            sleep(startRange = 1, endRange = 2)

        except KeyboardInterrupt:

            typingTextOnTerminal(keyboardInterruptErrorMessage, speed = 0.05)

            os._exit(0)

if __name__ == "__main__":
     
    clearTerminalScreen(operatingSystem = platform.system())
    
    logger.info("Agent Application Starting...")

    sleep(1, 3)

    logger.info("Agent Application Successfully Started!")

    mainAgentHandler()