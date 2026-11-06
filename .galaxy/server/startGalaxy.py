import sys

from source.memory.agentMemory import initializeAgentMemory
from source.memory.chatHistoryMemory import initializeChatAgentMemory
from source.utils.helper import (
    getArguments,
    startServer,
    validateUserEnviromentVariables,
)
from source.utils.logger import logger
from source.utils.Terminal.OpenTerminal import startNewTerminal

serverPID : int

def mainHandler(arguments : dict[str, bool]):

    logger.info("Initializing Agent Memory...")

    initializeAgentMemory()

    logger.info("Memory Initialized Successfully")

    logger.info("Chat Memory Initializing...")

    initializeChatAgentMemory()

    logger.info("Chat Memory Initlized")

    if arguments["server"]:

        startServer()

    if arguments["agent"]:

        logger.info("Starting Interactive AI Agent...")

        startNewTerminal(
            command = [
                sys.executable,
                "main.py"
            ],
            title = "Galaxy AI - Agent"
        )

if __name__ == "__main__":

    validateUserEnviromentVariables()

    userArguments : dict[str, bool] = getArguments()

    mainHandler(arguments = userArguments)