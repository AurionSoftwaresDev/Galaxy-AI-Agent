from source.provider.models import models
from source.agent.agent import agent
from source.utils.extractProvider import extractProvider
from source.provider.llmProviders import llmProviders

providers : list[str] = []

provider, _ = extractProvider(agent = agent, llmProviderModel = llmProviders.geminiProvider)
providers.append(provider)

provider, _ = extractProvider(agent = agent, llmProviderModel = llmProviders.ollamaProvider)
providers.append(provider)

provider, _ = extractProvider(agent = agent, llmProviderModel = llmProviders.mistralProvider)
providers.append(provider)

