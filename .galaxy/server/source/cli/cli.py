import re
from source.utils.logger import logger
from source.cli.commandRegistry import COMMAND_REGISTRY

class CLI():

    def __init__(self):

        logger.info("Initialized CLI")

    def extractCommandFromUserPrompt(self, userPrompt : str) -> list[str]:

        extractCommandPattern = r"/[\w-]+"

        commands : list[str] = re.findall(pattern = extractCommandPattern, string = userPrompt)

        logger.info(f"Extracted CLI COMMANDs From User Prompt : { commands }")

        return commands
    
    def executeCLICommands(self, commands : list[str]) -> str | dict[str, str]:

        commandsOutput : dict[str, str] = {}

        for registryCommand in COMMAND_REGISTRY:

            for command in commands:

                if command.lower().strip() == registryCommand.lower().strip():

                    registryCommandExecuteFunction = COMMAND_REGISTRY[command.lower().strip()]              

                    if len(commands) > 1:

                        commandResponse = registryCommandExecuteFunction()      

                        commandsOutput[command] = commandResponse

                    else:

                        return registryCommandExecuteFunction()

        return commandsOutput