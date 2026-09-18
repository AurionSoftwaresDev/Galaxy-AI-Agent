import json
from pathlib import Path
from source.utils.logger import logger
from source.security.permissionManager import PermissionManager
from source.utils.TerminalUI import TerminalUI

def deleteFile(filePath : str, fileName : str) -> str:

    logger.info("AI Agent Called delete_file Tool..")

    terminalUI : TerminalUI = TerminalUI()

    permissionManager = PermissionManager(
        data = {
            "tool_name": "delete_file",
            "title": "Agent Wants To Delete A File :",
            "details": f"\"{ filePath }/{ fileName }\""
        },
        beforePrompt = terminalUI.pause,
        afterPrompt  = terminalUI.resume
    )

    userPermission : bool | dict[str, str | bool] = permissionManager.askPermission()

    if isinstance(userPermission, dict):

        if not userPermission["Success"]:

            return json.dumps(
                obj = userPermission,
                indent = 4
            )

    try:

        path = Path(f"{filePath}/{fileName}")

        path.unlink()
        
        logger.info(f"AI Agent Successfully Delete The File At : \"{ path }\"")

        return json.dumps(obj = [
            {
                "Status": "File Deleted",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except FileNotFoundError:

        logger.exception("AI Agent Not Found File To Delete")

        return json.dumps(obj = [
            {
                "Status": "File Not Found",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except PermissionError:

        logger.info("AI Agent Permission Deind To Delete File")

        return json.dumps(obj = [
            {
                "Status": "Permission Denied",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except IsADirectoryError:

        logger.info("AI Agent Can't Delete File Because It's Folder")

        return json.dumps(obj = [
            {
                "Status": "Its Directory. Not A File",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except OSError:

        logger.info("AI Agent Can't Delete File Operating System Issue")

        return json.dumps(obj = [
            {
                "Status": "OS Error To Delete File",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except Exception:

        logger.info("AI Agent Unexpected Error To Deleting File")

        return json.dumps(obj = [
            {
                "Status": "Unexpected Error",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)