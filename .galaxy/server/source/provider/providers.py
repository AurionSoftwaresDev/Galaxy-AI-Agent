from collections.abc import Callable

from source.agent.agent import agent
from source.provider.llmProviders import llmProviders
from source.utils.extractProvider import extractProvider

providers : list[str] = []

functionsProvider = llmProviders()

providerFunctions : dict[str, Callable] = {}

provider, _ = extractProvider(agent = agent, llmProviderModel = llmProviders.TemplateLLMs.geminiLLMProvider)
providers.append(provider)
providerFunctions[provider] = functionsProvider.createGeminiLLMProvider

provider, _ = extractProvider(agent = agent, llmProviderModel = llmProviders.TemplateLLMs.ollamaLLMProvider)
providers.append(provider)
providerFunctions[provider] = functionsProvider.createOllamaLLMProvider

provider, _ = extractProvider(agent = agent, llmProviderModel = llmProviders.TemplateLLMs.mistralLLMProvider)
providers.append(provider)
providerFunctions[provider] = functionsProvider.createMistralLLMProvider