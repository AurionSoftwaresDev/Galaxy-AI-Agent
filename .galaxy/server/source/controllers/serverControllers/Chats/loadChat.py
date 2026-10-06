from fastapi import Response, status
from source.utils.logger import logger
from source.models.serverModels.Chats.loadChat import LoadChatModel
from source.memory.chatHistoryMemory import loadChat

def loadChatController(request : LoadChatModel, response : Response) -> dict | None:

    chatId : int = int(str(object = request.chatId).strip())

    chatTitle : str = str(object = request.chatId).strip()

    if not chatId and not chatTitle:

        response.status_code = status.HTTP_404

        return {
            "Status": response.status_code,
            "Message": "You Have To Give One Field Out Of Eid And Title But You Did Not Give Even One!"
        }

    logger.info(f"Fetching Chat With Details { f"Id : { chatId } " if chatId else f"Title : { chatTitle }"}")

    chatHistory = loadChat(
        chatId = chatId,
        title = chatTitle
    )

    response.status_code = status.HTTP_200_OK

    logger.info("Chat Successfully Feteched!")

    return {
        "Status": response.status_code,
        "Message": "Successfully Fetch Chat!" if chatHistory else "Failed To Fetch Completly!",
        "Chat History": chatHistory
    }
    