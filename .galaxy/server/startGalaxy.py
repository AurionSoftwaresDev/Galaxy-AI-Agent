import os, sys, subprocess
from PyQt6.QtWidgets import QApplication
from PyQt6.QtCore import QLoggingCategory
from source.utils.logger import logger
from source.utils.helper import validateUserEnviromentVariables
from source.memory.agentMemory import initializeAgentMemory
from source.memory.chatHistoryMemory import initializeChatAgentMemory
from source.config.LogPaths import ( 
    EXECUTABLE_PATH
)
from source.utils.Terminal.OpenTerminal import startNewTerminal
from source.utils.helper import getArguments, getExecutableExtension
from source.gui.widgets.DialogBox import NeonPremiumDialog
from source.utils.helper import startServer

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

 