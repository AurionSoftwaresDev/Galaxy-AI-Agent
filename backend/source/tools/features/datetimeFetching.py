from datetime import datetime, timedelta
from source.utils.logger import logger

def getCurrentDateTime() -> list[dict[str, (str | timedelta | None)]]:

    logger.info("AI Agent Feteching Date And Time Infos...")

    localDateTime = datetime.now().astimezone()

    data : list[dict[str, (str | timedelta | None)]] = [
        {
            "Full DateTime & Time " : localDateTime.strftime("%A, %B %d, %Y at %I:%M %p"),
            "Clean Date" : localDateTime.strftime("%Y-%m-%d"),
            "Clean Time" : localDateTime.strftime("%I:%M:%S %p"),
            "Friendly Date" : localDateTime.strftime("%d %b %Y"),
            "Time Zone" : localDateTime.tzname(),
            "UTC Offset" : localDateTime.utcoffset() 
        }
    ]

    logger.info("AI Agent Successfully Fetched Date Time Informations")

    return data
