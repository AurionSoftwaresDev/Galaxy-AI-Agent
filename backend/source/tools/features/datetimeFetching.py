from datetime import datetime, timedelta
import json
from source.utils.logger import logger

def getCurrentDateTime() -> str:

    logger.info("AI Agent Feteching Date And Time Infos...")

    localDateTime = datetime.now().astimezone()

    data : list[dict] = [
        {
            "Full DateTime & Time " : localDateTime.strftime("%A, %B %d, %Y at %I-%M %p"),
            "Clean Date" : localDateTime.strftime("%Y-%m-%d"),
            "Clean Time" : localDateTime.strftime("%I-%M-%S %p"),
            "Friendly Date" : localDateTime.strftime("%d %b %Y"),
            "Time Zone" : localDateTime.tzname(),
            "UTC Offset" : localDateTime.utcoffset() 
        }
    ]

    logger.info("AI Agent Successfully Fetched Date Time Informations")

    return json.dumps(data, indent = 4)
