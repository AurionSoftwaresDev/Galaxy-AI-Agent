import json
import shutil
from pathlib import Path
from source.utils.logger import logger
from source.security.permissionManager import PermissionManager
from source.utils.Terminal.TerminalContextShared import terminalUI

def deleteFolder(
    folderPath: str,
    folderName: str,
    recursive: bool = False
) -> str:

    logger.info("AI Agent Called delete_folder Tool...")

    permissionManager = PermissionManager(
        data = {
            "tool_name": "delete_file",
            "title": "Agent Wants To Delete A Folder :",
            "details": f"\"{ folderPath }/{ folderName }\""
        },
        beforePrompt = terminalUI.pause,
        afterPrompt  = terminalUI.resume
    )

    userPermission : bool | dict[str, str | bool] = permissionManager.askPermission()

    if isinstance(userPermission, dict):

        return json.dumps(
            obj = userPermission,
            indent = 4
        )

    path = Path(folderPath) / folderName

    try:

        if not path.exists():

            logger.info(f"AI Agent Say The Folder \"{ path }\" Already Exists At : \"{ path }\"")

            return json.dumps(
                obj=[
                    {
                        "Status": "Folder Not Found",
                        "Path": str(path),
                        "Folder Name": folderName
                    }
                ],
                indent=4
            )

        if not path.is_dir():

            logger.info(f"AI Agent Say The Folder \"{ path }\" Is Not A Folder It's File")

            return json.dumps(
                obj=[
                    {
                        "Status": "Not A Folder",
                        "Path": str(path),
                        "Folder Name": folderName
                    }
                ],
                indent=4
            )

        if recursive:

            shutil.rmtree(path)

        else:

            path.rmdir()

        logger.info(f"AI Agent Successfully Deleted The Folder At : \"{ path }\"")

        return json.dumps(
            obj=[
                {
                    "Status": "Folder Deleted",
                    "Path": str(path),
                    "Folder Name": folderName,
                    "Recursive": recursive
                }
            ],
            indent=4
        )

    except OSError as exception:

        logger.info(f"AI Agent Failed To Delete Folder Because Operating System Issue. Exception : { exception }")

        return json.dumps(
            obj = [
                {
                    "Status": "OS Error To Delete Folder",
                    "Path": str(path),
                    "Folder Name": folderName,
                    "Recursive": recursive,
                    "Error": str(exception)
                }
            ],
            indent = 4
        )

    except Exception as exception:

        logger.info(f"AI Agent Unexpected Exception To Deleting Folder. Exception : { exception }")

        return json.dumps(
            obj = [
                {
                    "Status": "Unexpected Error",
                    "Path": str(path),
                    "Folder Name": folderName,
                    "Recursive": recursive,
                    "Error": str(exception)
                }
            ],
            indent = 4
        )
