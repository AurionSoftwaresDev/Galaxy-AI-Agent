from datetime import datetime
from source.utils.logger import logger

def getCurrentDateTime():

    data = []
 	
    logger.info("Fetching Current Time")
      
    dataEntry = {
        "currentDate": datetime.now().strftime("%B %d-%m-%Y"),
        "currentTime": datetime.now().strftime("%S:%M:%I %p")
    }
    
    data.append(dataEntry)

    logger.info("Time Fetched")    

    return data