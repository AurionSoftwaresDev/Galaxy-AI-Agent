import sqlite3

from fastapi import Response, status

from source.memory.chatHistoryMemory import loadChat, updateChatTitle
from source.models.serverModels.Chats.updateChatTitleModel import UpdateChatTitleModel


def updateChatTitleController(
    request : UpdateChatTitleModel, 
    response : Response
) -> dict[str, str | int | bool | list]:

    newChatTitle : str = request.title.strip()

    chatId : int = request.chatId

    chatIsExists : (dict[str, str | int | list[dict[str, str | int]]] | None) = loadChat(
        chatId = chatId, 
        title = newChatTitle if newChatTitle != "" else None
    )

    if not chatIsExists:

        response.status_code = status.HTTP_404_NOT_FOUND

        return {
            "Status": response.status_code,
            "Success": False,
            "Process": "Failed",
            "Chat ID": chatId,
            "New Title": newChatTitle if newChatTitle != "" else "Untitled Chat",
            "Message": "Failed To Update Chat Title Because He Chat Not Exists!",
        }

    oldChatTitle = chatIsExists["title"]

    if oldChatTitle == newChatTitle:

        response.status_code = status.HTTP_306_RESERVED
        
        return {
            "Status": response.status_code,
            "Success": False,
            "Process": "Failed",
            "Old Chat Title": oldChatTitle,
            "New Title": newChatTitle if newChatTitle else oldChatTitle,
            "Message": "Failed To Rename Chat Because This Title Is Already Exists!"
        }

    try:

        updateChatTitle(
            chatId = chatId,
            title = newChatTitle if (newChatTitle != "" and newChatTitle != None) else oldChatTitle
        )

        response.status_code = status.HTTP_202_ACCEPTED

        return {
            "Status": response.status_code,
            "Old Title": oldChatTitle,
            "New Title": newChatTitle if newChatTitle else oldChatTitle,
            "Message": "Successfully Chat Renamed Saved!",
        }

    except (
        sqlite3.DataError,
        sqlite3.InternalError,
        sqlite3.DatabaseError
    ) as unexpectedException:

        response.status_code = status.HTTP_500_INTERNAL_SERVER_ERROR

        return {
            "Status": response.status_code,
            "Success": False,
            "Process": "Failed",
            "Old Title": oldChatTitle,
            "New Title": newChatTitle if newChatTitle else oldChatTitle,
            "Message": "Failed To Rename Chat Because Unexpected Exception! In Server!",
            "Exception": str(object = unexpectedException)
        }