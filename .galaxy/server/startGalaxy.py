import os, sys, subprocess
from PyQt6.QtWidgets import QApplication
from PyQt6.QtCore import QLoggingCategory
from source.config.configs import getAgentServerRunningPort
from source.utils.logger import logger
from source.utils.helper import validateUserEnviromentVariables
from source.memory.agentMemory import initializeAgentMemory
from source.memory.chatHistoryMemory import initializeChatAgentMemory
from source.config.LogPaths import ( 
    SERVER_LOGS_PATH,
    SERVER_PID_STORE_FILE_NAME,
    EXECUTABLE_PATH
)
from source.config.RootPaths import BACKEND_PATH
from source.utils.getCurrentDateTime import getCurrentDate
from source.utils.Terminal.OpenTerminal import startNewTerminal
from source.utils.helper import getArguments, getExecutableExtension
from source.gui.widgets.DialogBox import NeonPremiumDialog

serverPID : int

def mainHandler(arguments : dict[str, bool]):

    logger.info("Initializing Agent Memory...")

    initializeAgentMemory()

    logger.info("Memory Initialized Successfully")

    logger.info("Chat Memory Initializing...")

    initializeChatAgentMemory()

    logger.info("Chat Memory Initlized")

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

        serverPID = agentServerProcess.pid

        logger.debug(f"AI Agent Server Run At PID : { serverPID }")

        SERVER_LOGS_PATH.mkdir(exist_ok = True, parents = True)

        with open(file = f"{ SERVER_LOGS_PATH }/{ SERVER_PID_STORE_FILE_NAME }", mode = "w") as serverPIDFile:

            serverPIDFile.write(str(serverPID))

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

def mainExecutableHandler(arguments : dict[str, bool]) -> bool:

    QLoggingCategory.setFilterRules("*debug=false\n*.info=false\n*.warning=false")
    
    initializeDialogApp = QApplication(sys.argv)

    if not EXECUTABLE_PATH.exists():

        logger.warning(f"Executable Directory Not Found: { EXECUTABLE_PATH }. Continue As Normal Python Mode")

        return False

    try:

        if arguments["server"]:

            serverExecutable = getExecutableExtension(executable = "server")

            if not serverExecutable.exists():

                errorDilaog = NeonPremiumDialog(
                    error_text = "Server Executable Does't Found! Build Galaxy Agent",
                    title_text = "CIRTICAL Server Error"
                )
                
                errorDilaog.show()
                
                errorDilaog.exec()
    
                os._exit(status = 404)

            logger.info("Starting Galaxy AI Agent Server...")

            serverProcess = subprocess.Popen(
                args = [
                    str(
                        object = serverExecutable
                    )
                ],
                cwd = EXECUTABLE_PATH,
                stdin = subprocess.DEVNULL,
                stdout = subprocess.DEVNULL,
                stderr = subprocess.DEVNULL,
                creationflags = (
                    subprocess.CREATE_NO_WINDOW
                    if sys.platform == "win32"
                    else 0
                )
            )

            logger.info(f"Galaxy AI Agent Server Started. PID : { serverProcess.pid }")

        if arguments["agent"]:

            agentExecutable = getExecutableExtension(executable = "main")

            if not agentExecutable.exists():

                errorDilaog = NeonPremiumDialog(
                    error_text = "Agent CLI Mode Executable Does't Found! Build Galaxy Agent",                
                    title_text = "CIRTICAL Agent Error"
                )

                errorDilaog.show()
                
                errorDilaog.exec()

                os._exit(status = 404)

            logger.info("Starting Interactive AI Agent...")

            startNewTerminal(
                command = [
                    str(
                        object = agentExecutable
                    )
                ],
                title = "Galaxy AI - Agent"
            )

            logger.info("Interactive AI Agent Terminal Started Successfully")

        return True

    except FileNotFoundError as error:

        logger.exception(f"Executable Not Found While Starting Galaxy : { error }")

        return False

    except OSError as error:

        logger.exception(f"Failed To Start Galaxy Process : { error }")

        return False

if __name__ == "__main__":

    validateUserEnviromentVariables()

    userArguments : dict[str, bool] = getArguments()

    if not mainExecutableHandler(arguments = userArguments):

        mainHandler(arguments = userArguments)

 