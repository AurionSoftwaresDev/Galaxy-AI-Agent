from fastapi import Response, status
from source.memory.chatHistoryMemory import loadChats

def loadAllChatsController(response : Response) -> list[dict[str, str | int]]:

    response.status_code = status.HTTP_200_OK

    return loadChats()