import os
from dotenv import load_dotenv

### Load Variables From The .env File In The System Variable ###
load_dotenv()

def getGeminiAPIKey() -> (str | None):
    
    return os.getenv("GOOGLE_API_KEY") 

def getMistralAPIKey() -> (str | None):
    
    return os.getenv("MISTRAL_API_KEY")

def getSMTPSenderEmail() -> (str | None):

    return os.getenv("SMTP_SENDER_EMAIL")

def getSMTPPORT() -> (str | None):

    return os.getenv("SMTP_PORT")

def getSMTPServerHost() -> (str | None):

    return os.getenv("SMTP_SERVER_HOST")

def getSMTPSenderPassword() -> (str | None):

    return os.getenv("SMTP_SENDER_PASSWORD")