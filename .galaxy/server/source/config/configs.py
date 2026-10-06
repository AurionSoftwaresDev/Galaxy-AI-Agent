import os
from dotenv import load_dotenv

### Load Variables From The .env File In The System Variable ###
load_dotenv()

def getGeminiAPIKey() -> (str | None):
    
    return os.getenv(key = "GOOGLE_API_KEY") 

def getMistralAPIKey() -> (str | None):
    
    return os.getenv(key = "MISTRAL_API_KEY")

def getSMTPSenderEmail() -> (str | None):

    return os.getenv(key = "SMTP_SENDER_EMAIL")

def getSMTPPORT() -> (str | None):

    return os.getenv(key = "SMTP_PORT")

def getSMTPServerHost() -> (str | None):

    return os.getenv(key = "SMTP_SERVER_HOST")

def getSMTPSenderPassword() -> (str | None):

    return os.getenv(key = "SMTP_SENDER_PASSWORD")

def getAgentServerRunningPort() -> int:

    return int(os.getenv(key = "AGENT_SERVER_RUNNING_PORT")) if os.getenv(key = "AGENT_SERVER_RUNNING_PORT") != None else 8000

def getServerURL() -> str:

    return str(os.getenv(key = "SERVER_URL")) if os.getenv("SERVER_URL") != None else f"http://localhost:{ getAgentServerRunningPort() }"



