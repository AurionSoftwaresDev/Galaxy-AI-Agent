from pydantic import BaseModel

class ChangeAgentTemperatureRequestModel(BaseModel):
    
    temperature : float 