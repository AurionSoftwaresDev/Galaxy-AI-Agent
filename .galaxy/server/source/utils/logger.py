import logging
import threading
from pathlib import Path

from source.config.LogPaths import AGENT_LOGS_PATH, SERVER_LOGS_PATH
from source.utils.getCurrentDateTime import getCurrentDate

logger : logging.Logger = logging.getLogger(name = "Galaxy")

logger.setLevel(level = logging.DEBUG)

logger.propagate = False

server_logger : logging.Logger = logging.getLogger(name = "Galaxy Server")

server_logger.setLevel(level = logging.DEBUG)

server_logger.propagate = False

LOG_LOCK = threading.RLock()

def configureLogger() -> None:

    with LOG_LOCK:

        AGENT_LOGS_PATH.mkdir(parents=True, exist_ok=True)

        logsFile = AGENT_LOGS_PATH / f"agent_{getCurrentDate()}.log"

        for handler in logger.handlers[:]:

            if isinstance(handler, logging.FileHandler):

                if Path(handler.baseFilename) == logsFile.resolve():

                    return

                logger.removeHandler(hdlr = handler)

                handler.close()

        file_handler = logging.FileHandler(
            filename = logsFile,
            mode = "a",
            encoding = "utf-8",
        )

        file_handler.setLevel(level = logging.DEBUG)

        formatter : logging.Formatter = logging.Formatter(
            fmt = "%(asctime)s | %(levelname)s | %(name)s | %(message)s",
            datefmt = "%d-%m-%Y %H:%M:%S",
        )

        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)


def cleanUpAgentLogs() -> None:

    with LOG_LOCK:

        try:

            for handler in logger.handlers[:]:

                if isinstance(handler, logging.FileHandler):

                    logger.removeHandler(hdlr = handler)

                    handler.flush()

                    handler.close()

            if AGENT_LOGS_PATH.exists():

                import shutil

                shutil.rmtree(AGENT_LOGS_PATH)

            AGENT_LOGS_PATH.mkdir(parents=True, exist_ok=True)

        finally:

            configureLogger()

def configureServerLogger():

    with LOG_LOCK:
    
            SERVER_LOGS_PATH.mkdir(parents = True, exist_ok = True)
    
            logsFile = SERVER_LOGS_PATH / f"server{getCurrentDate()}.log"
    
            for handler in server_logger.handlers[:]:
    
                if isinstance(handler, logging.FileHandler):
    
                    if Path(handler.baseFilename) == logsFile.resolve():
    
                        return
    
                    server_logger.removeHandler(hdlr = handler)
    
                    handler.close()
    
            file_handler = logging.FileHandler(
                filename = logsFile,
                mode = "a",
                encoding = "utf-8",
            )
    
            file_handler.setLevel(level = logging.DEBUG)
    
            formatter : logging.Formatter = logging.Formatter(
                fmt = "%(asctime)s | %(levelname)s | %(name)s | %(message)s",
                datefmt = "%d-%m-%Y %H:%M:%S",
            )
    
            file_handler.setFormatter(formatter)
            server_logger.addHandler(file_handler)

configureLogger()
configureServerLogger()