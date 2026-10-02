import logging
from pathlib import Path
from source.utils.getCurrentDateTime import getCurrentDate
from source.config.LogPaths import AGENT_LOGS_PATH

AGENT_LOGS_PATH.mkdir(parents = True, exist_ok = True)

LOGS_FILE : Path = AGENT_LOGS_PATH / f"agent_{getCurrentDate()}.log"

logger = logging.getLogger("agent")

logger.setLevel(logging.DEBUG)

logger.propagate = False

if not logger.handlers:
    
    fileHandler = logging.FileHandler(LOGS_FILE, encoding="utf-8")
    
fileHandler.setLevel(logging.DEBUG)

formatter : logging.Formatter = logging.Formatter(
    "%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    datefmt="%d-%m-%Y %H:%M:%S"
)

fileHandler.setFormatter(formatter)

logger.addHandler(fileHandler)