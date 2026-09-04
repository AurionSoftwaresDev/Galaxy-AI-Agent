from source.agent.agent import agent
from source.chat.memory.agentMemory import (
    loadMessagesFromAgentMemory,
    saveMessagesInAgentMemory
)
from source.utils.logger import logger
from langchain.messages import HumanMessage, AIMessageChunk, ToolMessage

async def chat() -> bool:
    
    userPrompt : str = input("You : ")
        
    if userPrompt.strip() == "quit-agent":
        
        print("[+] Agent Shutdown...")
        
        logger.info("User Shutdown The AI Agent")
        
        return False
    
    oldHistory : list[dict[str, str]] = loadMessagesFromAgentMemory()
    
    messages = [
        {
            "role": message["role"],
            "content": message["content"]
        }
        for message in oldHistory
    ]
    
    messages.append(
        HumanMessage(
            content=userPrompt
        )
    )
    
    finalAgentResponse : str = ""
    
    print("\nAI : ", end = "", flush = True)
    
    try:
        
        async for token, metadata in agent.astream({ "messages" : messages }, stream_mode = "messages"):
            
           if isinstance(token, ToolMessage):
               
               continue
            
           if isinstance(token, AIMessageChunk):
               content = token.content
                       
               logger.info(f"AI Response Metadata : {metadata}")
                
               if isinstance(content, str):
                    
                    print(content, end = "", flush = True)
                    
                    finalAgentResponse += content
                    
               elif isinstance(content, list):
                    
                   for block in content:
                        
                       if isinstance(block, dict) and block.get("type") == "text":
                            
                            text = block.get("text", "")
                            
                            if text:
                                
                                print(content, end = "", flush = True)
                            
                                finalAgentResponse += text
                
                                                
    except Exception as Error:
        
        logger.exception(f"AI Agent Streaming Failed. Exception: {Error}")    
    
    print()
    
    saveMessagesInAgentMemory("user", userPrompt)
    saveMessagesInAgentMemory("assistant", finalAgentResponse)
    
    return True
        