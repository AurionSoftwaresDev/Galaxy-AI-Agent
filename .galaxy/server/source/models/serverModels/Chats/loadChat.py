from pydantic import BaseModel

class LoadChatModel(BaseModel):

    title : str
    chatId : int