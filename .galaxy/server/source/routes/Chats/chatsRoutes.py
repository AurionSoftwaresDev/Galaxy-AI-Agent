from fastapi import APIRouter

from source.controllers.serverControllers.Chats.createNewChat import createNewChatController
from source.controllers.serverControllers.Chats.deleteChat import deleteChatController
from source.controllers.serverControllers.Chats.loadAllChats import loadAllChatsController
from source.controllers.serverControllers.Chats.updateChatTitle import updateChatTitleController
from source.controllers.serverControllers.Chats.saveMessage import saveMessageController
from source.controllers.serverControllers.Chats.loadChat import loadChatController

agentChatsRouter = APIRouter()

agentChatsRouter.post(path = "/create") (
    createNewChatController
)

agentChatsRouter.post(path = "/delete") (
    deleteChatController
)

agentChatsRouter.post(path = "/save-message") (
    saveMessageController
)

agentChatsRouter.post(path = "/load-chat") (
    loadChatController
)

agentChatsRouter.get(path = "/load-all") (
    loadAllChatsController
)

agentChatsRouter.patch(path = "/update-title") (
    updateChatTitleController
) 

