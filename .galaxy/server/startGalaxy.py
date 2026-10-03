import sys, subprocess
from source.config.configs import getAgentServerRunningPort
from source.utils.logger import logger
from source.utils.helper import validateUserEnviromentVariables
from source.chat.memory.agentMemory import initializeAgentMemory
from source.config.LogPaths import SERVER_LOGS_PATH
from source.config.RootPaths import BACKEND_PATH
from source.constants.agentHelpingMenu import HELPING_MENU
from source.utils.getCurrentDateTime import getCurrentDate
from source.utils.Terminal.OpenTerminal import startNewTerminal
from source.utils.helper import getArguments

def mainHandler():

    arguments = getArguments()

    logger.info("Initializing Agent Memory...")

    initializeAgentMemory()

    logger.info("Memory Initialized Successfully")

    if arguments["server"]:

        logger.info("Starting Agent Server And Routers...")

        logger.info("Creating Server Logs File And Folder Or Configure...")

        SERVER_LOGS_PATH.mkdir(parents = True, exist_ok = True)

        serverLogsFile = open(
            file = SERVER_LOGS_PATH / f"Server_{getCurrentDate()}.log",
            encoding = "utf-8",
            mode = "a"
        )

        serverErrorLogsFile = open(
            file = SERVER_LOGS_PATH / f"ServerErrors_{getCurrentDate()}.log",
            encoding = "utf-8",
            mode = "a"
        )

        agentServerProcess = subprocess.Popen(
            args = [
                sys.executable,
                "-m",
                "uvicorn",
                "server:agentServer",
                "--host",
                "127.0.0.1",
                "--port",
                f"{ getAgentServerRunningPort() }",
                "--log-level",
                "info"
            ],
            cwd = BACKEND_PATH,
            stdin = subprocess.DEVNULL,
            stdout = serverLogsFile,
            stderr = serverErrorLogsFile,
            creationflags = subprocess.CREATE_NO_WINDOW
        )

        logger.debug(f"AI Agent Server Run At PID : { agentServerProcess.pid }")

        logger.info("Uvicorn Galaxy AI Agent Server Started In The Background")

    if arguments["agent"]:

        logger.info("Starting Interactive AI Agent...")

        startNewTerminal(
            [
                sys.executable,
                "main.py"
            ],
            "Galaxy AI - Agent"
        )

if __name__ == "__main__":

    validateUserEnviromentVariables()

    mainHandler()
