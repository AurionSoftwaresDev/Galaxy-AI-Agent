import json
from pathlib import Path
from source.utils.logger import logger

def createFolder(path : str, folderName : str, parents : bool = True):

    logger.info("AI Agent Called create_folder Tool.")

    path = Path(f"{path}/{folderName}")

    if path.exists():

        return json.dumps(obj = [
            {
                "Status": "Already Exits",
                "Path": str(path),
                "Folder Name": folderName
            }
        ], indent = 4)

    path.mkdir(parents = parents, exists_ok = True)
    
    return json.dumps(obj = [
        {
            "Status": "Created",
            "Path": str(path),
            "Folder Name": folderName
        }
    ], indent = 4)