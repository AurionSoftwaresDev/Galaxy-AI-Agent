from typing import Callable
from source.agent.agent import agent
from source.utils.extractProvider import extractProvider
from source.provider.llmProviders import llmProviders

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