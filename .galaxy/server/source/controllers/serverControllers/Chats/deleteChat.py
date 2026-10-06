import sqlite3
from fastapi import Response, status
from source.models.serverModels.Chats.deleteChatModel import DeleteChatModel
from source.memory.chatHistoryMemory import deleteChat
from source.utils.logger import logger

def deleteChatController(request : DeleteChatModel, response : Response) -> dict[str, str | int]:

    userGivenChatId : int = int(str(request.chatId).strip())

    logger.info(f"Deleting Chat... With ID : { userGivenChatId }")

    try:

        deleteChat(chatId = userGivenChatId)

        response.status_code = status.HTTP_200_OK

        logger.info("Chat Deleted!")

        return {
            "Status": response.status_code,
            "Message": "Successfully Chat Deleted!",
            "Chat ID": userGivenChatId
        }

    except sqlite3.Error:

        response.status_code = status.HTTP_404_NOT_FOUND

        logger.exception("Failed To Delete Chat. Wrong Chat ID")

        return {
            "Status": response.status_code,
            "Message": "Failed To Delete Chat. Wrong Chat ID!",
            "Chat ID": userGivenChatId
        }
