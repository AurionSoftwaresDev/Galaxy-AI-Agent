import json
from pathlib import Path
from typing import Literal
from source.utils.logger import logger

def createFile(
        path : str, 
        fileName : str, 
        content : str,
        mode : Literal[
            "w", 
            "a", 
            "x", 
            "r+", 
            "x+", 
            "w+"
        ]
    ):

    logger.info("AI Agent Called create_file Tool...")

    dirPath = Path(path)

    fullPath = dirPath / fileName

    if fullPath.is_file():

        return json.dumps(obj =[
            {
                "Status": "Already Exits",
                "Path": str(fullPath),
                "Write Mode": mode,
                "File Name": fileName
            }
        ], indent = 4)

    fullPath.parent.mkdir(parents = True, exist_ok = True)

    with open(file = fullPath, mode = mode, encoding = "utf-8") as file:

        file.write(content)

    logger.info("AI Agent Successfully Created! File")

    return json.dumps(obj = [
        {
            "Status": "Created",
            "Path": str(fullPath),
            "Write Mode": mode,
            "File Name": fileName
        }
    ], indent = 4)

