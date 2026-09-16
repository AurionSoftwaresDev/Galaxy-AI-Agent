import sys, os, shutil, subprocess
from pathlib import Path
from source.utils.logger import logger

def validateRarEngine():

    if shutil.which(cmd = "rar"): 

        return "rar"

    currentPlatform = sys.platform
    backendDirectory = os.path.dirname(os.path.abspath(__file__))
    localRarPath = os.path.join(backendDirectory, "rar_engine")

    if currentPlatform == "win32":

        commonWindowsPath = r"C:\Program Files\WinRAR\rar.exe"

        if os.path.exists(path = commonWindowsPath):

            return commonWindowsPath

    localBin = os.path.join(localRarPath, "rar.exe" if currentPlatform == "win32" else "rar")

    if os.path.exists(localBin):

        return localBin

    logger.info("AI Agent Rar Configuring Background Compression Binaries... Please wait.")

    os.makedirs(name = localRarPath, exist_ok = True)

    try:
        if currentPlatform == "linux" or currentPlatform == "linux2":

            subprocess.run(
                args = ["sudo", "apt-get", "-y", "update"], 
                stdout = subprocess.DEVNULL, 
                stderr = subprocess.DEVNULL
            )
            subprocess.run(
                args = ["sudo", "apt-get", "-y", "install", "rar"], 
                check = True, 
                stdout = subprocess.DEVNULL
            )

            return "rar"
            
        elif currentPlatform == "darwin": 

            if shutil.which("brew"):

                subprocess.run(
                    args = ["brew", "install", "cask", "rar"], 
                    check = True, 
                    stdout = subprocess.DEVNULL
                )

                return "rar"
                
        
    except Exception:
        
        return None  

def validatePathLastName(outputPath : str, outputName : str) -> str:

    outputPathNameIndex = len(outputPath.split("/")) - 1
    
    extractFileNameFromPath = outputPath.split("/")[outputPathNameIndex]

    if outputName.lower() == extractFileNameFromPath.lower() and outputPath == extractFileNameFromPath:

        fixedPrefixOutputPath : list = outputPath.split("/")

        fixedPrefixOutputPath[outputPathNameIndex] = outputName

        fixedPath = Path("/".join(fixedPrefixOutputPath))

        return str(fixedPath)

    return outputPath

def extractPasswordData(passwordProtectedObject : dict[str, bool]) -> list[str | bool]:

    useEncryption = ((True if len(passwordProtectedObject["Password"]) > 1 else False) if passwordProtectedObject["Protected"] == True else False)

    userArchivePassword = passwordProtectedObject["Password"]

    return [
        useEncryption,
        userArchivePassword
    ]
