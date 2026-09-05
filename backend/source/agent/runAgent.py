import asyncio, platform
from source.chat.agentChat import chat
from source.utils.logger import logger
from source.utils.helper import clearTerminalScreen

async def main() -> None:
    
    clearTerminalScreen(platform.system())
    
    agent_running : bool = True

    while agent_running:
        
        agent_running = await chat()
    
def startAgent() -> bool:
    
    try:
        
        asyncio.run(main())
        
        return True
        
    except Exception as exception:
        
        if type(exception) is KeyboardInterrupt:
            
            print("[+] Agent Shutdown...")
                    
            logger.info("User Shutdown The AI Agent With Press CTRL + C")
        
        
        print("[!] Error Exception: " , exception)
        
        return False
        