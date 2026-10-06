from fastapi import APIRouter
from source.controllers.serverControllers.Settings.getModels import getAvaliableLLMModels
from source.controllers.serverControllers.Settings.getProvidersController import getAvaliabeProviders
from source.controllers.serverControllers.Settings.changeAgentTemperature import changeAgentTemperature
from source.controllers.serverControllers.Settings.changeAgentProvider import changeAgentProvider

agentSettingsRouter = APIRouter()

agentSettingsRouter.get(path = "/avaliable-providers") (

    getAvaliabeProviders
)

agentSettingsRouter.get(path = "/avaliable-models") (
    
    getAvaliableLLMModels
)

agentSettingsRouter.patch(path = "/change-agent-temperature") (

    changeAgentTemperature
)

agentSettingsRouter.patch(path = "/change-agent-provider") (

    changeAgentProvider
)