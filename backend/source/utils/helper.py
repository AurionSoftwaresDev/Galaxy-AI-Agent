import time, random, os, datetime
import source.config.configs as Configs

def sleep(startRange : int, endRange : int) -> int:
    
    try:
        
        sleepDelay : int = random.randint(startRange, endRange)
            
        time.sleep(sleepDelay)
        
        return (-1 if sleepDelay == -1 else sleepDelay) 
    
    except KeyboardInterrupt as exception:
        
        print("[!] Error: Program Closed You Are Press CTRL + C")
        
        return int(os._exit(0))

def clearTerminalScreen(operatingSystem : str):
    
    if operatingSystem == "Windows":
        
        os.system("cls")
        
    elif operatingSystem == "Linux" or operatingSystem == "Darwin":
        
        os.system("clear")
        
    else:
        
        os._exit(1)

def validateUserEnviromentVariables():

    from source.utils.logger import logger

    logger.info("AI Agent Checking Enviroment Variables Key...")

    keys = {

        "geminiAPIKey": Configs.getGeminiAPIKey(),
        "mistralAPIKey": Configs.getMistralAPIKey(),
        "smtpPort" : Configs.getSMTPPORT(),
        "smtpSenderEmail": Configs.getSMTPSenderEmail(),
        "smtpSenderPassword": Configs.getSMTPSenderPassword(),
        "smtpHost": Configs.getSMTPServerHost()
    }

    foundedEmptyKeys : dict[str, bool] = {}  
    avaliableAPIKeys : dict[str, bool] = {}

    for key, keyValue in keys.items():

        if keyValue == "" or keyValue == None:

            foundedEmptyKeys[key] = True

        if keyValue != "" and keyValue != None:

            avaliableAPIKeys[key] = True

    if keys["geminiAPIKey"] in foundedEmptyKeys:

        logger.exception(
            "AI Agent Provider Keys Not Found 1 Key Is IMPORTANT Your Choose In This Keys \"GOOGLE_API_KEY\" OR \"MISTRAL_API_KEY\" " \
        ) 

        os._exit(404)

    logger.info(f"Empty OR Not Added API Keys : { foundedEmptyKeys } ")
    logger.info(f"Avaliable API Keys : { avaliableAPIKeys } ")