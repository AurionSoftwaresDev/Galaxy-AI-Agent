from fastapi import (
    Response,
    status
)
from langchain.messages import HumanMessage
from source.memory.agentMemory import (
    loadMessagesFromAgentMemory,
    saveMessagesInAgentMemory
)
from source.models.serverModels.agentRequestModel import AgentRequestModel
from source.agent.agent import agent

async def agentRequestResponse(userRequest : AgentRequestModel, response : Response):
    
    userPrompt = userRequest.prompt
    
    if len(userPrompt.strip()) < 1 or userPrompt == None:
        
        response.status_code = status.HTTP_400_BAD_REQUEST
        
        return {
            "Status": 400,
            "Error": "Prompt Is Empty"
        }
        
    oldHistory : list[dict[str, str]] = loadMessagesFromAgentMemory()
    
    messages = [
        {
            "role": message["role"],
            "content": message["content"],
        }
        for message in oldHistory
    ]
    
    messages.append(
        HumanMessage(
            content = userPrompt
        )
    )
        
    agentResponse = await agent.ainvoke({
        "messages" : messages
    })
    
    finalAgentResponse = agentResponse["messages"][-1].content
    
    saveMessagesInAgentMemory("user", userPrompt)        
    saveMessagesInAgentMemory("assistant", finalAgentResponse)        
    
    response.status_code = status.HTTP_201_CREATED
    
    return {
        "status": 201,
        "response": finalAgentResponse
    }
    