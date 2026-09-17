import io
import json
from pathlib import Path
from source.utils.logger import logger

def readFile(filePath: str, fileName: str) -> str:

    logger.info("AI Agent Called read_file Tool...")

    path = Path(filePath)
    
    fullPath = path / fileName

    try:

        logger.info(
            f'AI Agent Reading "{fileName}" File At: "{fullPath}"'
        )

        stringBuffer = io.StringIO()

        with open(fullPath, "r", encoding="utf-8") as file:

            while chunk := file.read(64 * 1024):

                stringBuffer.write(chunk)

        fileContent = stringBuffer.getvalue()

        stringBuffer.close()

        logger.info(f'AI Agent Successfully Read File At :  "{fullPath}"')

        return fileContent

    except FileNotFoundError:

        logger.info(f'AI Agent Can\'t Read File Because File Not Found At: "{fullPath}"')

        return json.dumps(
            [
                {
                    "Status": "File Not Found",
                    "Directory Path": str(path),
                    "File Path": str(fullPath),
                    "File Content": ""
                }
            ],
            indent = 4
        )

    except UnicodeDecodeError:

        logger.error(
            f'AI Agent Can\'t Read File Because The File Encoding '
            f'Is Not UTF-8: "{fullPath}"'
        )

        return json.dumps(
            [
                {
                    "Status": "Unsupported File Encoding",
                    "Directory Path": str(path),
                    "File Path": str(fullPath),
                    "File Content": ""
                }
            ],
            indent = 4
        )