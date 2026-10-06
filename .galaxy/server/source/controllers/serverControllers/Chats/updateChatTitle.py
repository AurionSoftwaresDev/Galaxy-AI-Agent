from fastapi import Response, status
from source.models.serverModels.Chats.updateChatTitleModel import UpdateChatTitleModel

def updateChatTitleController(request : UpdateChatTitleModel, response : Response) -> dict[str, str | int]:

    pass