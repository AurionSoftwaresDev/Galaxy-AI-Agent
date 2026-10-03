from source.provider.llmProviders import llmProviders
from source.agent.createNewAgent import createNewAgent

### LLM Provider Model ###
provider = llmProviders()

llmProviderModel = provider.createGeminiLLMProvider()

### Creating AI Agent Use Locally Ollama LLM Model 'llmProviderModel' Variable ###
agent = createNewAgent(llmProviderModel = llmProviderModel)

def setNewAgent(newAgent) -> None:

    global agent

    agent = newAgent

def setNewAgentProvider(newAgentProvider) -> None:

    global llmProviderModel

    llmProviderModel = newAgentProvider