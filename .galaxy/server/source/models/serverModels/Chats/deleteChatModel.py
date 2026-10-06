from pydantic import BaseModel

class DeleteChatModel(BaseModel):

    chatId : int
    title : str