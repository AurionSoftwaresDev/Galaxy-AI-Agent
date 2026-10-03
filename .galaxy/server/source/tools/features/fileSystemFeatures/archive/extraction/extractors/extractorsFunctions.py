from encodings import johab
import json
import os
from pathlib import Path
import pyzipper, py7zr, rarfile
import tarfile
from typing import Optional
from source.utils.logger import logger
from source.utils.archiveUtils import findExtractorRarEngine, extractNameOrPath

def zipExtractor(
        archiveSourceFullPath : str,
        archiveExtractOutputPath : str,
        archiveOutputNameFolder : Optional[str] = None,
        archivePassword : Optional[str] = None,
    ) -> str:

    archiveOutputNameFolder, archiveExtractOutputPath = extractNameOrPath(
        archiveSourceFullPath    = archiveSourceFullPath,
        archiveExtractOutputPath = archiveExtractOutputPath,
        archiveOutputNameFolder  = archiveOutputNameFolder
    )

    with pyzipper.AESZipFile(file = archiveSourceFullPath, mode = "r") as zipRef:

        isEncrypted = any(info.flag_bits & 0x1 for info in zipRef.infolist())
        
        if isEncrypted:

            if archivePassword == None or archivePassword == "":
                return json.dumps(
                    obj = [
                        {
                            "Status": "Faild To Extract Archive",
                            "Archive Type": ".zip",
                            "Reason": f"This Archive '{ archiveSourceFullPath }' Password Protected But You Are Not Provided Any Password."
                        }
                    ], indent = 4
                )

            try:

                byteConvertedPassword : bytes = archivePassword.encode("utf-8")

                zipRef.extractall(path = archiveExtractOutputPath, pwd = byteConvertedPassword)

                logger.info(f"AI Agent Successfully Extracted .zip \"{ archiveSourceFullPath }\" At : \"{ archiveExtractOutputPath }\"")

                return json.dumps(
                    obj = [
                        {
                            "Status": "Archive Extracted",
                            "Archive Type": ".zip",
                            "Password Protected": True,
                            "Archive Output Name": archiveOutputNameFolder,
                            "Archive Extracted Path": archiveExtractOutputPath,
                            "Archive Source Path": archiveSourceFullPath
                        }
                    ], indent = 4
                )

            except RuntimeError as runtimeException:

                logger.exception(f"AI Agent Failed To Extract .zip \"{ archiveSourceFullPath }\"")

                return json.dumps(
                    obj = [
                        {   
                            "Status": "Archive Password Wrong",
                            "Archive Type": ".zip",
                            "Archive Source Path": archiveSourceFullPath,
                            "Exception": str(object = runtimeException)
                        }
                    ], indent = 4
                )
        else:

            logger.info(f"Archive Is Without Password\"{ archiveSourceFullPath }\" Extracting....")

            zipRef.extractall(path = archiveExtractOutputPath)

            logger.info(f"\"{ archiveSourceFullPath }\" Archive Extracted! At : \"{ archiveExtractOutputPath }\"")

            return json.dumps(
                obj = [
                    {
                        "Status": "Archive Extracted",
                        "Archive Type": ".zip",
                        "Password Protected": False,
                        "Archive Output Name": archiveOutputNameFolder,
                        "Archive Extracted Path": archiveExtractOutputPath,
                        "Archive Source Path": archiveSourceFullPath
                    }
                ], indent = 4
            )

def tarExtractor(
        archiveSourceFullPath : str,
        archiveExtractOutputPath : str,
        archiveOutputNameFolder : Optional[str] = None,
        archivePassword : Optional[str] = None,
    ) -> str:

    archiveOutputNameFolder, archiveExtractOutputPath = extractNameOrPath(
        archiveSourceFullPath    = archiveSourceFullPath,
        archiveExtractOutputPath = archiveExtractOutputPath,
        archiveOutputNameFolder  = archiveOutputNameFolder
    )

    with tarfile.open(name = archiveSourceFullPath, mode = "r:*") as tarRef:

        try:

            tarRef.extractall(path = archiveExtractOutputPath, filter = "data")

        except TypeError:

            tarRef.extractall(path = archiveExtractOutputPath)
            
    return json.dumps(
        obj = [
            {
                "Status": "Archive Extracted",
                "Archive Type": ".tar",
                "Password Protected": False,
                "Archive Output Name": archiveOutputNameFolder,
                "Archive Extracted Path": archiveExtractOutputPath,
                "Archive Source Path": archiveSourceFullPath
            }   
        ], indent = 4
    )

def ZzExtractor(
        archiveSourceFullPath : str,
        archiveExtractOutputPath : str,
        archiveOutputNameFolder : Optional[str] = None,
        archivePassword : Optional[str] = None,
    ) -> str:

    archiveOutputNameFolder, archiveExtractOutputPath = extractNameOrPath(
        archiveSourceFullPath    = archiveSourceFullPath,
        archiveExtractOutputPath = archiveExtractOutputPath,
        archiveOutputNameFolder  = archiveOutputNameFolder
    )

    passwordString = archivePassword if archivePassword else None

    try:

        with py7zr.SevenZipFile(file = archiveSourceFullPath, mode = "r", password = passwordString) as archiveRef:

            archiveRef.extractall(path=archiveExtractOutputPath)
            
        return json.dumps(
            obj = [
                {
                    "Status": "Archive Extracted",
                    "Archive Type": ".7z",
                    "Password Protected": archiveRef.needs_password(),
                    "Archive Output Name": archiveOutputNameFolder,
                    "Archive Extracted Path": archiveExtractOutputPath,
                    "Archive Source Path": archiveSourceFullPath               
                }
            ], indent = 4
        )

    except py7zr.exceptions.PasswordRequired:

        return json.dumps(
            obj = [
                {
                    "Status": "Failed To Extract Archive",
                    "Archive Type": ".7z",
                    "Password Protected": True,
                    "Archive Source Path": archiveSourceFullPath, 
                    "Error": "Password Required"
                }
            ], indent = 4
        ) 
        
    except py7zr.exceptions.Bad7zFile:

        return json.dumps(
            obj = [
                {
                    "Status": "Failed To Extract Archive",
                    "Archive Type": ".7z",
                    "Password Protected": True,
                    "Archive Source Path": archiveSourceFullPath, 
                    "Error": "Bad Request. Wrong Password OR Corrupted .7z File."
                }
            ], indent = 4
        ) 
                
def rarExtractor(
        archiveSourceFullPath : str,
        archiveExtractOutputPath : str,
        archiveOutputNameFolder : Optional[str] = None,
        archivePassword : Optional[str] = None,
    ) -> str:


    rarEngine = findExtractorRarEngine()

    if not rarEngine:

        return json.dumps(
            obj = [
                {
                    "Status": "Failed To Extract Archive",
                    "Archive Type": ".rar",
                    "Archive Source Path": archiveSourceFullPath, 
                    "Error": "UnRar, WinRar Engine Not Found."
                }
            ], indent = 4
        )

    rarfile.UNRAR_TOOL = rarEngine

    try:

        with rarfile.RarFile(file = archiveSourceFullPath, mode = "r") as archiveRef:

            if archiveRef.needs_password():

                if not archivePassword:
                    
                    return json.dumps(
                        obj = [
                            {
                                "Status": "Faild To Extract Archive",
                                "Archive Type": ".rar",
                                'Password Protected': True,
                                "Reason": f"This Archive '{ archiveSourceFullPath }' Password Protected But You Are Not Provided Any Password."
                            }
                        ], indent = 4
                    )
                    
                archiveRef.setpassword(pwd = archivePassword)
                
            archiveRef.extractall(path = archiveExtractOutputPath)

        return json.dumps(
            obj= [
                {
                    "Status": "Archive Extracted",
                    "Archive Type": ".rar",
                    "Password Protected": archiveRef.needs_password(),
                    "Archive Output Name": archiveOutputNameFolder,
                    "Archive Extracted Path": archiveExtractOutputPath,
                    "Archive Source Path": archiveSourceFullPath   
                }
            ], indent = 4
        )
        
    except Exception as unexpectedException:

        return json.dumps(
            obj = [
                {
                    "Status": "Failed To Extract Archive",
                    "Archive Source Path": archiveSourceFullPath,
                    "Exception": str(object = unexpectedException)
                }
            ]
        )