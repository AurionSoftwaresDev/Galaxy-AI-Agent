from pydantic import BaseModel

class ChangeAgentProviderModel(BaseModel):
    
    provider : str