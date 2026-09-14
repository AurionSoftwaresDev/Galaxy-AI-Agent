import io
import json
from pathlib import Path
from source.utils.logger import logger

def readFile(filePath : str, fileName : str) -> str:

    logger.info("AI Agent Called read_file Tool...")

    path = Path(filePath)

    fullPath = path / fileName

    fileContent : str

    try:

        logger.info(f"AI Agent Reading \"{ fileName } \"File At : \"{ fullPath }\"")

        stringBuffer = io.StringIO()

        with open(fullPath, "r") as file:

            while chunk := file.read(64 * 1024):

                stringBuffer.write(chunk)

            fileContent = stringBuffer.getvalue()

            stringBuffer.close()

        logger.info(f"AI Agent Successfully Readed File At : \"{ fullPath } \"")

        return fileContent

    except FileNotFoundError:

        logger.info(f"AI Agent Can't Read File Becase File Not Found The File At : \"{ fullPath }\"")

        return json.dumps(obj = [
            {
                "Status": "File Not Found",
                "Directory Path" : str(path),
                "File Path": str(fullPath),
                "File Content": ""
            }
        ], indent = 4)
