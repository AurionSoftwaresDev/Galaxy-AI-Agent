from fastapi import Response, status
from source.models.serverModels.Chats.saveMessageModel import SaveMessageModel

def saveMessageController(request : SaveMessageModel, response : Response) -> dict[str, str | int]:

    pass