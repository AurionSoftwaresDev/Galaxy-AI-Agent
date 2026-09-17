import json
from pathlib import Path
from source.utils.logger import logger

def createFolder(path : str, folderName : str, parents : bool = True):

    logger.info("AI Agent Called create_folder Tool.")

    path = Path(f"{path}/{folderName}")

    if path.exists():

        logger.info(f"AI Agent Can't Create Folder At \"{ path }\" Because It's Already Exists")

        return json.dumps(obj = [
            {
                "Status": "Already Exits",
                "Path": str(path),
                "Folder Name": folderName
            }
        ], indent = 4)

    path.mkdir(parents = parents, exist_ok = True)

    logger.info(f"AI Agent Successfully Created Folder At : \" { path }\"")
    
    return json.dumps(obj = [
        {
            "Status": "Created",
            "Path": str(path),
            "Folder Name": folderName
        }
    ], indent = 4)