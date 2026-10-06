from typing import Literal
from pydantic import BaseModel

class SaveMessageModel(BaseModel):

    chatId : int
    role : Literal["user", "assistant"]
    content : str