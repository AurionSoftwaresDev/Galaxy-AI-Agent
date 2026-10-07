from typing import Optional
from pydantic import BaseModel

class LoadChatModel(BaseModel):

    title : Optional[str] = None
    chatId : int