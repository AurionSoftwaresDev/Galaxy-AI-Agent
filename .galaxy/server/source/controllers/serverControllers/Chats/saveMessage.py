from fastapi import Response, status
from source.models.serverModels.Chats.saveMessageModel import SaveMessageModel
from source.memory.chatHistoryMemory import saveMessage, loadChat

def saveMessageController(
    request : SaveMessageModel, 
    response : Response
) -> dict[str, str | int | list[str]]:

    messageRole : str = request.role.strip()
    
    messageContent : str = request.content

    chatId : int = request.chatId

    if not messageRole in ["user", "assistant"]:

        response.status_code = status.HTTP_200_OK

        return {
            "Status": response.status_code,
            "Success": False,
            "Process": "Failed",
            "Your Role": messageRole,
            "Chat ID": chatId,
            "Your Message": messageContent,
            "Message": "Failed To Save Message Because Role Is Invalid!",
            "Avaliable Role": [
                "user",
                "assistant"
            ]
        }

    if messageContent.strip() == "":

        response.status_code = status.HTTP_400_BAD_REQUEST
        
        return {
            "Status": response.status_code,
            "Success": False,
            "Process": "Failed",
            "Chat ID": chatId,
            "Your Role": messageRole,
            "Your Message": messageContent,
            "Message": "Failed To Save Message Because Your Message Is Empty!"
        }

    chatIsExists : dict[str, str | int] | None = loadChat(chatId = chatId)

    if not chatIsExists:

        response.status_code = status.HTTP_404_NOT_FOUND

        return {
            "Status": response.status_code,
            "Success": False,
            "Process": "Failed",
            "Your Role": messageRole,
            "Chat ID": chatId,
            "Your Message": messageContent,
            "Message": "Failed To Save Message Because chatId Is Invalid!",
        }

    try:

        saveMessage(
            chatId = chatId,
            role = messageRole,
            content = messageContent
        )

        response.status_code = status.HTTP_202_ACCEPTED

        return {
            "Status": response.status_code,
            "Your Role": messageRole,
            "Your Message": messageContent,
            "Message": "Successfully Message Saved!",
        }

    except Exception as unexpectedException:

        response.status_code = status.HTTP_500_INTERNAL_SERVER_ERROR

        return {
            "Status": response.status_code,
            "Success": False,
            "Process": "Failed",
            "Your Role": messageRole,
            "Your Message": messageContent,
            "Message": "Failed To Save Message Because Unexpected Exception! In Server!",
            "Exception": str(object = unexpectedException)
        }