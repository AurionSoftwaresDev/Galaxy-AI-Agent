import os, psutil
from fastapi import Response, status
from source.utils.logger import logger
from source.utils.helper import findServerPID
from source.config.configs import getAgentServerRunningPort 

def terminateServer(response : Response) -> None:

    serverPID : int = findServerPID()

    serverPort : int = getAgentServerRunningPort()

    serverPort = serverPort if serverPort and serverPort != -1 else 8000

    response.status_code = status.HTTP_204_NO_CONTENT

    if serverPID and serverPID != -1:

        try:

            if psutil.pid_exists(pid = serverPID):

                serverProcess = psutil.Process(pid = serverPID)

                if "python" in serverProcess.name().lower() or "uvicorn" in serverProcess.name().lower():

                    serverProcess.terminate()

        except Exception:

            logger.exception("Failed To Terminate Agent Server(It-Self)")

            logger.exception("Try Again To Terminating Using PORT PID Process Already Failed")

    else:

        logger.exception("PID Was Wrong!")

    logger.info("Killing Server In Hardcore Mode All Process Killing...")

    for serverProcess in psutil.process_iter(attrs = ["name", "pid"]):

        try:

            for serverConnection in serverProcess.net_connections():

                if serverConnection.laddr.port == serverPort:

                    serverProcess.terminate()

        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):

            continue

    logger.exception("Failed To Terminate Server With PORT OR PID")

    logger.exception("Kill All Python Servers!")

    currentPID = os.getpid() 
    
    pythonKillCounts = 0
    
    for proc in psutil.process_iter(['pid', 'name']):

        try:

            if "python" in proc.info['name'].lower() and proc.info['pid'] != currentPID:

                proc.kill() 

                pythonKillCounts += 1

                logger.info(f"Killed { proc.name() }. Current Kills : { pythonKillCounts }")    
                
        except (psutil.NoSuchProcess, psutil.AccessDenied):

            continue