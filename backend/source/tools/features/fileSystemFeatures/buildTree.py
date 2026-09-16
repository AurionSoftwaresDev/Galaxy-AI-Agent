import json
from pathlib import Path
import sys, os, subprocess
from typing import Literal
from source.utils.logger import logger

def _createDictTree(
        path: Path,
        depth: int = 0,
        counter: list[int] | None = None,
    ) -> dict[str, str | bool | list[str]]:

    MAX_ENTRIES = 200

    if counter is None:
        counter = [0]

    if counter[0] >= MAX_ENTRIES:
        return {
            "truncated": True
        }

    counter[0] += 1

    if path.is_file():
        return {
            "name": path.name,
            "path": str(path),
            "type": "file"
        }

    if path.is_dir():
        children = []

        try:
            for item in path.iterdir():

                if counter[0] >= MAX_ENTRIES:
                    break

                children.append(
                    buildTree(
                        item,
                        depth + 1,
                        counter
                    )
                )

        except PermissionError:
            return {
                "name": path.name,
                "path": str(path),
                "type": "directory",
                "children": [],
                "error": "Permission denied"
            }

        return {
            "name": path.name,
            "path": str(path),
            "type": "directory",
            "children": children
        }

    return {
        "name": path.name,
        "path": str(path),
        "type": "unknown"
    }


def _createRealTree(rootPath : str):

    if sys.platform == "win32":

        cmd = f'tree "{os.path.abspath(rootPath)}" /F /Ap'

        useShell = True
        
    else:

        cmd = ["tree", os.path.abspath(target_dir)]
        useShell = False

    try:

        process = subprocess.run(
            args = cmd, 
            stdout = subprocess.PIPE, 
            stderr = subprocess.PIPE, 
            text = True, 
            shell = useShell,
            check = True,
            encoding = "utf-8",      
            errors = "ignore",       
            timeout = 30             
        )
        
        tree = process.stdout

    except subprocess.TimeoutExpired:

        tree = "Warning: Execution Stopped: Folder structure too heavy (Timeout expired)."

    except subprocess.CalledProcessError as e:

        tree = f"Error executing tree command:\n{e.stderr}"

    except FileNotFoundError:

        tree = "Environment Error: 'tree' utility package not installed on this host OS."

    except Exception as unexpectedException:

        tree = f"Unexpected automation error: {str(unexpectedException)}"

    return tree

def buildTree(
        depth: int = 0,
        counter: list[int] | None = None,
        path: str = Path.home(),
        type : Literal["COMMAND", "JSON"] = "JSON"
    ) -> str:

    logger.info("AI Agent Called build_file_system_tree Tool...")

    if not os.path.exists(path = path):

        return json.dumps(
            obj = [
                {
                    "Status": "Faild To Create File System Tree",
                    "Reason": f"Your \"{ path }\" Doen't Exists"
                }
            ]
        )

    if type.lower() == "json":

        dictTreeResponse : dict[str, str | bool | list[str]] = _createDictTree(
            path         = path,
            depth        = depth,
            counter      = counter,
        )

        JSONConvertedTreeResponse : str = json.dumps(obj = dictTreeResponse, indent = 4)

        return JSONConvertedTreeResponse

    elif type.lower() == "command":

        commandRealTreeResponse : str = _createRealTree(rootPath = path)

        return commandRealTreeResponse

    return json.dumps(
        obj = [
            {
                f"Error": "You Are Choose Wrong Mode!",
                "Modes": [
                    "COMMAND",
                    "JSON(Default Selected)"
                ]
            }
        ], indent = 4
    )
