import os
from dotenv import load_dotenv

### Load Variables From The .env File In The System Variable ###
load_dotenv()

def getProviderAPIKey() -> (str | None):
    
    return os.getenv("GOOGLE_AI_API_KEY") 

def getMistralAPIKey() -> (str | None):
    
    return os.getenv("MISTRAL_API_KEY")

def getResendAPIKey() -> (str | None):

    return os.getenv("RESEND_API_KEY")

def getResendFromAgentEmail() -> (str | None):

    return os.getenv("RESEND_FROM_AGENT_EMAIL")