from fastapi import Response, status

from source.provider.providers import providers
from source.agent.agent import setNewAgentProvider, llmProviderModel, agent
from source.utils.extractProvider import extractProvider
from source.models.serverModels.Settings.changeAgentProviderModel import ChangeAgentProviderModel
from source.provider.providers import providerFunctions

def changeAgentProvider(request : ChangeAgentProviderModel, response : Response):

    oldProvider, _ = extractProvider(agent = agent, llmProviderModel = llmProviderModel)

    newProvider = request.provider

    if newProvider not in providers:

        response.status_code = status.HTTP_404_NOT_FOUND

        return {
            "Success": False,
            "Error": f"Your '{ newProvider }' Provider Does Not Supported",
            "Supported Providers": providers
        }

    newCreatedProvider : object = providerFunctions[newProvider]()

    setNewAgentProvider(newAgentProvider = newCreatedProvider)

    response.status_code = status.HTTP_200_OK

    return {
        "Success": True,
        "Old Provider" : oldProvider,
        "New Provider": newProvider
    }