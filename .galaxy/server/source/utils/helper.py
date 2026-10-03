import platform
import time, random, os, sys
from source.utils.logger import logger
from source.config.EnviromentKeys import ENVRIOMENTAL_KEYS
from PyQt6.QtWidgets import QApplication
from PyQt6.QtCore import QLoggingCategory
from source.gui.widgets.DialogBox import NeonPremiumDialog
from source.constants.agentHelpingMenu import HELPING_MENU

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

    QLoggingCategory.setFilterRules("*debug=false\n*.info=false\n*.warning=false")

    app = QApplication(sys.argv)

    logger.info("AI Agent Checking Enviroment Variables Key...")

    foundedEmptyKeys : dict[str, bool] = {}  
    avaliableAPIKeys : dict[str, bool] = {}

    for key, keyValue in ENVRIOMENTAL_KEYS.items():

        if keyValue == "" or keyValue == None:

            foundedEmptyKeys[key] = True

        if keyValue != "" and keyValue != None:

            avaliableAPIKeys[key] = True

    try:
    
        if foundedEmptyKeys["geminiAPIKey"] and foundedEmptyKeys["mistralAPIKey"]:

            logger.exception("AI Agent Provider Keys Not Found 1 Key Is IMPORTANT Your Choose In This Keys \"GOOGLE_API_KEY\" OR \"MISTRAL_API_KEY\" ") 

            print("[Exception] Providers Keys Not Found Check Logs.")

            dialog = NeonPremiumDialog(
                title_text="CRTICAL AI Agent Error", 
                error_text="Your Environment Variables Are Missing Both \"GOOGLE_API_KEY\" And \"MISTRAL_API_KEY\". At Least One Of These API Keys Must Be Configured To Continue"
            )

            dialog.show()
            
            dialog.exec()

            os._exit(404)

    except KeyError:

        clearTerminalScreen(operatingSystem = platform.system())

        logger.info(f"Empty OR Not Added API Keys : { foundedEmptyKeys } ")
        logger.info(f"Avaliable API Keys : { avaliableAPIKeys } ")


def getArguments():

    arguments = {
        "server": False,
        "agent": False
    }

    if "-h" in sys.argv[1:] or "--help" in sys.argv[1:]:

        print(HELPING_MENU)

        sys.exit(0)

    for argument in sys.argv[1:]:

        if "=" not in argument:

            continue

        key, value = argument.split("=", 1)

        if key in arguments:

            arguments[key] = value.lower() == "true"

    if len(sys.argv) == 1:

        arguments["server"] = True
        arguments["agent"] = True

    return arguments