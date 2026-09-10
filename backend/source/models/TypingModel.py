from pydantic import BaseModel, Field

class TypingModel(BaseModel):

    text : str = Field(description = "Text For Typing")