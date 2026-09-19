from source.config.configs import getGeminiAPIKey, getMistralAPIKey
from langchain_ollama import ChatOllama
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_mistralai import ChatMistralAI
from source.provider.models import models

# All LLM Providers
class llmProviders:

    # Gemini Provider IMPORTANT NOTE: Please Add Your "GOOGLE_API_KEY" In Enviorment
    geminiProvider = ChatGoogleGenerativeAI(
        model = models[0],
        api_key = getGeminiAPIKey()
    )
    
    # Ollama Provider
    ollamaProvider = ChatOllama(
        model = models[1]
    )  
    
    # Mistral Provider IMPORTANT NOTE: Please Add Your "MISTRAL_API_KEY" In Enviorment
    mistralProvider = ChatMistralAI(
        name = models[2],
        api_key = getMistralAPIKey()
    )