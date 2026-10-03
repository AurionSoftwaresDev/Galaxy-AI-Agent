import re
from source.utils.logger import logger
from source.cli.commandRegistry import COMMAND_REGISTRY

class CLI():

    def __init__(self):

        logger.info("Initialized CLI")

    def extractCommandFromUserPrompt(self, userPrompt : str) -> list[str]:

        extractCommandPattern = r"/\w+"

        commands : list[str] = re.findall(pattern = extractCommandPattern, string = userPrompt)

        return commands
    
    def executeCLICommands(self, commands : list[str]) -> str | dict[str, str]:

        commandsOutput : dict[str, str] = {}

        for registryCommand in COMMAND_REGISTRY:

            for command in commands:

                if command.lower() == registryCommand.lower():

                    registryCommandExecuteFunction = COMMAND_REGISTRY[command]              

                    if len(commands) > 1:

                        commandResponse = registryCommandExecuteFunction()      

                        commandsOutput[command] = commandResponse

                    else:

                        return registryCommandExecuteFunction()

        return commandsOutput