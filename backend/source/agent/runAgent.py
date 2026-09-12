import asyncio, threading
from rich.console import Console
from typing import Literal
from source.chat.agentChat import chat
from source.utils.logger import logger
from source.constants.styles.richFontColors import RICH_COLORS
from source.utils.agentUtils.startupUtils.typingAnimation import typingTextOnTerminal

async def main(mode : Literal["chatMode", "speakMode"]) -> None:

    console = Console()
    
    agent_running : bool = True

    if mode == "chatMode":

        logger.info("User Choose Chat Message Mode!")

        with console.capture() as capture:
        
            console.print(f"[{RICH_COLORS["bright"][2]}][Success][/{RICH_COLORS["bright"][2]}]")
        
        successMessage = capture.get().replace("\n", "\0")

        typingTextOnTerminal(text = f"{successMessage} You Are Switch To Chat Mode!\n", )

        while agent_running:
            
            agent_running = await chat()

    elif mode == "speakMode":

        logger.info("User Choose Speak Mode!")

        with console.capture() as capture:
                
            console.print(f"[{RICH_COLORS["bright"][3]}][Unregistered Request][/{RICH_COLORS["bright"][3]}]")
                
        warningMessage = capture.get().replace("\n", "\0")

        typingTextOnTerminal(text = f"\n{warningMessage} This Is Not Implement!\n")
    
def startAgentAsChatMode() -> bool:
    
    try:
        
        chatThread = threading.Thread(
            target = asyncio.run,
            args = (main(mode = "chatMode"),),
            name = "AgentChatModeThread",
            daemon = True
        )

        chatThread.start()
        
        return True
        
    except Exception as exception:
        
        if type(exception) is KeyboardInterrupt:
            
            print("[+] Agent Shutdown...")
                    
            logger.info("User Shutdown The AI Agent With Press CTRL + C")
        
        
        print("[!] Error Exception: " , exception)
        
        return False

def startAgentAsSpeakMode() -> bool:
    
    try:
        
        speakThread = threading.Thread(
            target = asyncio.run, 
            args = (main(mode = "speakMode"),),
            name = "AgentSpeakModeThread",
            daemon = True,
        )
        
        speakThread.start()
        
        return True
        
    except Exception as exception:
        
        if type(exception) is KeyboardInterrupt:
            
            print("[+] Agent Shutdown...")
                    
            logger.info("User Shutdown The AI Agent With Press CTRL + C")
        
        
        print("[!] Error Exception: " , exception)
        
        return False