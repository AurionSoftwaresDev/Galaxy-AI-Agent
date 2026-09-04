import time, random, os, datetime, shutil, subprocess

def sleep(startRange : int, endRange : int) -> int:
    
    try:
        
        sleepDelay : int = random.randint(startRange, endRange)
            
        time.sleep(sleepDelay)
        
        return (-1 if sleepDelay == -1 else sleepDelay) 
    
    except KeyboardInterrupt as exception:
        
        print("[!] Error: Program Closed You Are Press CTRL + C")
        
        return int(os._exit(0))

def clearTerminalScreen(operatingSystem : str):
    
    if operatingSystem == "Windows":
        
        os.system("cls")
        
    elif operatingSystem == "Linux" or operatingSystem == "Darwin":
        
        os.system("clear")
        
    else:
        
        os._exit(1)
    
def getCurrentDate() -> str:
    
    return datetime.datetime.now().strftime("%d-%m-%Y")

