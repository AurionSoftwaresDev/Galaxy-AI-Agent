from source.config.configs import getGeminiAPIKey, getMistralAPIKey
from langchain_ollama import ChatOllama
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_mistralai import ChatMistralAI

# All LLM Providers
class llmProviders:
    
    # Gemini Model 
    # geminiModel = "gemini-3.5-flash" # My Debugging Model
    geminiModel = "gemini-3.6-flash"
    
    # Ollama Model
    ollamaModel = "qwen3:8b"
    
    # Mistral Model
    mistralModel = "mistral-small-latest" 

    # Gemini Provider IMPORTANT NOTE: Please Add Your "GOOGLE_API_KEY" In Enviorment
    geminiProvider = ChatGoogleGenerativeAI(
        model = geminiModel,
        api_key = getGeminiAPIKey()
    )
    
    # Ollama Provider
    ollamaProvider = ChatOllama(
        model = ollamaModel
    )  
    
    # Mistral Provider IMPORTANT NOTE: Please Add Your "MISTRAL_API_KEY" In Enviorment
    mistralProvider = ChatMistralAI(
        name = mistralModel,
        api_key = getMistralAPIKey()
    )