
from pydantic import BaseModel


class LoadChatModel(BaseModel):

    title : str | None = None
    chatId : int