import asyncio, warnings, logging
from source.chat.agentChat import chat

warnings.filterwarnings("ignore")
    
logging.disable(logging.WARNING)

async def main() -> None:
    
    agent_running : bool = True

    while agent_running:
        
        agent_running = await chat()
    
def startAgent() -> bool:
    
    try:
        
        asyncio.run(main())
        
        return True
        
    except Exception as exception:
        
        print("[!] Error Exception: " , exception)
        
        return False
        