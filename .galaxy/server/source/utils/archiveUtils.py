import sys, os, shutil, subprocess
from pathlib import Path
from source.utils.logger import logger

def findCompressorRarEngine():

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


def findExtractorRarEngine():

    if shutil.which("unrar"): 

        return "unrar"
        
    if sys.platform != "win32" and shutil.which("rar"):

        return "rar"

    currentPlatform = sys.platform

    backendDirectory = os.path.dirname(os.path.abspath(__file__))

    localRarPath = os.path.join(backendDirectory, "rar_engine")

    if currentPlatform == "win32":

        commonWindowsPaths = [
            r"C:\Program Files\WinRAR\UnRAR.exe",
            r"C:\Program Files (x86)\WinRAR\UnRAR.exe"
        ]

        for path in commonWindowsPaths:

            if os.path.exists(path):

                return path

    localBinName = "UnRAR.exe" if currentPlatform == "win32" else "unrar"

    localBin = os.path.join(localRarPath, localBinName)

    if os.path.exists(localBin):

        return localBin

    logger.info("AI Agent Configuring Background Unrar Binaries... Please wait.")

    os.makedirs(name = localRarPath, exist_ok = True)

    try:

        if currentPlatform in ["linux", "linux2"]:

            subprocess.run(
                args = ["sudo", "apt-get", "-y", "update"], 
                stdout = subprocess.DEVNULL, 
                stderr = subprocess.DEVNULL)
            
            process = subprocess.run(
                args = ["sudo", "apt-get", "-y", "install", "unrar"], 
                stdout = subprocess.DEVNULL, 
                stderr = subprocess.DEVNULL
            )

            if process.returncode != 0:

                subprocess.run(
                    args = ["sudo", "apt-get", "-y", "install", "unrar-free"], 
                    check = True, 
                    stdout = subprocess.DEVNULL
                )
            
            return "unrar"
            
        elif currentPlatform == "darwin":
            
            if shutil.which("brew"):

                subprocess.run(
                    args = ["brew", "install", "unrar"], 
                    check = True, 
                    stdout = 
                    subprocess.DEVNULL
                )

                return "unrar"
            
    except Exception as exception:

        logger.exception(f"Failed To Auto-Configure Unrar Engine : { exception }")
        
    return None

def extractNameOrPath(
        archiveOutputNameFolder : str, 
        archiveSourceFullPath : str, 
        archiveExtractOutputPath : str
    ):

    if archiveOutputNameFolder == None or archiveOutputNameFolder == "":

        archiveOutputNameFolder = Path(archiveSourceFullPath).stem

    archiveExtractOutputPath = os.path.join(archiveExtractOutputPath, archiveOutputNameFolder)

    return [
        archiveOutputNameFolder,
        archiveExtractOutputPath
    ]