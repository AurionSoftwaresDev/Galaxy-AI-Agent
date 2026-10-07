from fastapi import Response, status
from source.utils.logger import logger
from source.models.serverModels.Chats.loadChat import LoadChatModel
from source.memory.chatHistoryMemory import loadChat

def loadChatController(
    request : LoadChatModel, 
    response : Response
) -> dict[str, str | int | dict[str, str | int | list[dict[str, str | int]]]]:

    chatId : int | None = (
        int(str(request.chatId).strip())
        if request.chatId is not None
        else None
    )

    chatTitle : str | None = (
        str(request.title).strip()
        if request.title is not None
        else None
    )

    if not chatId and not chatTitle:

        response.status_code = status.HTTP_404

        return {
            "Status": response.status_code,
            "Message": "You Have To Give One Field Out Of Eid And Title But You Did Not Give Even One!"
        }

    logger.info(f"Fetching Chat With Details { f"Id : { chatId } " if chatId else f"Title : { chatTitle }"}")

    chatHistory : dict[str, str | int | list[dict[str, str | int]]] | None = loadChat(
        chatId = chatId,
        title = chatTitle if (chatTitle != "" and chatTitle != None) else None
    )

    response.status_code = status.HTTP_200_OK

    logger.info("Chat Successfully Feteched!")

    return {
        "Status": response.status_code,
        "Message": "Successfully Fetchd Chat!" if chatHistory else "Failed To Fetching Chat Completly!",
        "Chat History": chatHistory if chatHistory else {}
    }
    