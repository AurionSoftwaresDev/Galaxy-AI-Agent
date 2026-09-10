import datetime

def getCurrentDate() -> str:
    
    return datetime.datetime.now().strftime("%d-%m-%Y")