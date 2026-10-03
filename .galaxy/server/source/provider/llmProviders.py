from source.config.configs import getGeminiAPIKey, getMistralAPIKey
from langchain_ollama import ChatOllama
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_mistralai import ChatMistralAI
from source.provider.models import models
from source.provider.llmTemperatures import llmTemperature

# All LLM Providers
class llmProviders:

    # Gemini Provider IMPORTANT NOTE: Please Add Your "GOOGLE_API_KEY" In Enviorment
    def createGeminiLLMProvider(self, temperature : float = llmTemperature):

        geminiLLMProvider = ChatGoogleGenerativeAI(
            model = models[0],
            api_key = getGeminiAPIKey(),
            temperature = temperature
        )

        return geminiLLMProvider
        
    # Ollama Provider
    def createOllamaLLMProvider(self, temperature : float = llmTemperature):

        ollamaLLMProvider = ChatOllama(
            model = models[1],
            temperature = temperature
        )  

        return ollamaLLMProvider

    # Mistral Provider IMPORTANT NOTE: Please Add Your "MISTRAL_API_KEY" In Enviorment
    def createMistralLLMProvider(self, temperature : float = llmTemperature):
        mistralLLMProvider = ChatMistralAI(
            name = models[2],
            api_key = getMistralAPIKey(),
            temperature = temperature
        )

        return mistralLLMProvider

    def updateLLMProviderTemperature(self, llmProvider, newTemperature : float = llmTemperature) -> dict[str, str | bool]:

        if hasattr(llmProvider, "temperature"):

            llmProvider.temperature = newTemperature

            return {
                "Success" : True,
                "Message": "Successfully Updated The LLM Provider Temperature"
            }

        else:

            return {
                "Success": False,
                "Error": "Failed To Update New Temperature",
                "Message" : "LLM Provider Doen't Supported!"
            }

    class TemplateLLMs:
        
        geminiLLMProvider = ChatGoogleGenerativeAI(
            model = models[0],
            api_key = getGeminiAPIKey(),
            temperature = llmTemperature
        )
                
        # Ollama Provider
        ollamaLLMProvider = ChatOllama(
            model = models[1],
            temperature = llmTemperature
        )  
    
        # Mistral Provider IMPORTANT NOTE: Please Add Your "MISTRAL_API_KEY" In Enviorment
        
        mistralLLMProvider = ChatMistralAI(
            name = models[2],
            api_key = getMistralAPIKey(),
            temperature = llmTemperature
        )