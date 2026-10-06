from pydantic import BaseModel

class UpdateChatTitleModel(BaseModel):

    chatId : int

    title : str