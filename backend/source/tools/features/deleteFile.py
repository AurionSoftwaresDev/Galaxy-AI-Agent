import json
from pathlib import Path

def deleteFile(filePath : str, fileName : str) -> str:

    try:

        path = Path(f"{filePath}/{fileName}")

        path.unlink()

        return json.dumps(obj = [
            {
                "Status": "File Deleted",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except FileNotFoundError:

        return json.dumps(obj = [
            {
                "Status": "File Not Found",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except PermissionError:

        return json.dumps(obj = [
            {
                "Status": "Permission Denied",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except IsADirectoryError:

        return json.dumps(obj = [
            {
                "Status": "Its Directory. Not A File",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except OSError:

        return json.dumps(obj = [
            {
                "Status": "OS Error To Delete File",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)

    except Exception:

        return json.dumps(obj = [
            {
                "Status": "Unexpected Error",
                "Path": str(path),
                "File Name": fileName
            }
        ], indent = 4)