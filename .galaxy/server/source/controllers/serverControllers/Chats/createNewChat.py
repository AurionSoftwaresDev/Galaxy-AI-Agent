import sqlite3
from fastapi import Response, status
from source.models.serverModels.Chats.createNewChatModel import CreateNewChatModel
from source.memory.chatHistoryMemory import createNewChat
from source.utils.logger import logger

def createNewChatController(
    request : CreateNewChatModel, 
    response : Response
) -> dict[str, str | int]:

    inputTitle : str = request.title.strip()
    
    baseTitle : str = "Untitled Chat" if inputTitle == "" else inputTitle
    
    currentTitle : str = baseTitle

    counter : int = 1

    logger.info(f"Creating Chat \"{ currentTitle }\"")
 
    while True:

        try:
            
            chatId : int | None = createNewChat(title = currentTitle)           

            response.status_code = status.HTTP_201_CREATED

            logger.info("Chat Created!")

            return {
                "Status": response.status_code,
                "Message": "Chat Successfully Created",
                "Chat Id": chatId if chatId else counter, 
                "Chat Title": currentTitle
            }

        except sqlite3.IntegrityError:

            logger.exception(f"Chat Already Exists With \"{ currentTitle }\" Title")

            logger.info("Chaning Title With Number Count!")
            
            currentTitle = f"{ baseTitle } { counter }"

            counter += 1
            
            continue

        