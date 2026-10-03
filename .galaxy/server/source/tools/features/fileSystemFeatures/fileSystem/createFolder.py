import json
from pathlib import Path
from source.utils.logger import logger

def createFolder(path : str, folderName : str, parents : bool = True):

    logger.info("AI Agent Called create_folder Tool.")

    rootPath = Path(f"{path}/{folderName}")

    if rootPath.exists():

        logger.info(f"AI Agent Can't Create Folder At \"{ rootPath }\" Because It's Already Exists")

        return json.dumps(obj = [
            {
                "Status": "Already Exits",
                "Path": str(rootPath),
                "Folder Name": folderName
            }
        ], indent = 4)

    rootPath.mkdir(parents = parents, exist_ok = True)

    logger.info(f"AI Agent Successfully Created Folder At : \" { rootPath }\"")
    
    return json.dumps(obj = [
        {
            "Status": "Created",
            "Path": str(object = rootPath),
            "Folder Name": folderName
        }
    ], indent = 4)