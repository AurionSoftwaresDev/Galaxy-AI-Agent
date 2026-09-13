import json
import shutil
from pathlib import Path

def deleteFolder(
    folderPath: str,
    folderName: str,
    recursive: bool = False
) -> str:

    path = Path(folderPath) / folderName

    try:

        if not path.exists():

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

        return json.dumps(
            obj=[
                {
                    "Status": "OS Error To Delete Folder",
                    "Path": str(path),
                    "Folder Name": folderName,
                    "Recursive": recursive,
                    "Error": str(exception)
                }
            ],
            indent=4
        )

    except Exception as exception:

        return json.dumps(
            obj=[
                {
                    "Status": "Unexpected Error",
                    "Path": str(path),
                    "Folder Name": folderName,
                    "Recursive": recursive,
                    "Error": str(exception)
                }
            ],
            indent=4
        )
