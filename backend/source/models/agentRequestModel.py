from pydantic import BaseModel

class AgentRequestModel(BaseModel):
    
    prompt : str