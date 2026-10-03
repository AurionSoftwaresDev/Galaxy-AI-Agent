from fastapi import Response, status
from source.provider.llmTemperatures import llmTemperature
from source.provider.llmProviders import llmProviders
from source.models.serverModels.Settings.changeAgentTemperatureModel import ChangeAgentTemperatureRequestModel
from source.agent.agent import createNewAgent, llmProviderModel, setNewAgent

def changeAgentTemperature(request : ChangeAgentTemperatureRequestModel, response : Response) -> dict:

    newTemperature : float = request.temperature

    oldTemperature : float = llmTemperature

    llmProvider : llmProviders = llmProviders()    

    llmProvider.updateLLMProviderTemperature(llmProvider = llmProviderModel, newTemperature = newTemperature)

    newAgent = createNewAgent(llmProviderModel = llmProviderModel)

    setNewAgent(agent = newAgent)

    response.status_code = status.HTTP_201_CREATED

    return {
        "Old Temperature" : oldTemperature,
        "New Temperature" : newTemperature
    }