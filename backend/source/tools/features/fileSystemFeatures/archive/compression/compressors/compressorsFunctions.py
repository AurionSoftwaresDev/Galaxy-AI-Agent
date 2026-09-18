import base64
import json
import os, subprocess
import pyzipper, py7zr 
import tarfile
from pathlib import Path
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt
from cryptography.fernet import Fernet
from source.utils.logger import logger
from backend.source.utils.archiveUtils import (
    extractPasswordData,
    validatePathLastName,
    findCompressorRarEngine
)

def zipCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : str
    ) -> str:

    if not outputPath.endswith(".zip"):

        outputPath += ".zip"

    useEncryption, userArchivePassword = extractPasswordData(
        passwordProtectedObject = passwordProtected
    )

    encryptionType = pyzipper.r.WZ_AES if useEncryption else pyzipper.WZ_NONE

    outputPath = validatePathLastName(outputPath = outputPath, outputName = outputName)

    with pyzipper.AESZipFile(outputPath, "w", compression = pyzipper.ZIP_DEFLATED, encryption = encryptionType) as archiveFolder:

        if useEncryption:

            archiveFolder.pwd = userArchivePassword.encode("utf-8")

        for source in sources:

            sourcePath = os.path.abspath(source)

            if os.path.isdir(sourcePath):

                baseDirectory = os.path.dirname(sourcePath)

                for root, _, files in os.walk(sourcePath):

                    for file in files:

                        fullPath = os.path.join(root, file)

                        archiveFolder.write(fullPath, arcname=os.path.relpath(fullPath, baseDirectory))

            elif os.path.isfile(sourcePath):

                archiveFolder.write(sourcePath, arcname=os.path.basename(sourcePath))

    return json.dumps(
        obj = [
            {
                "Status": "Archived Created",
                "Format": ".zip",
                "Archive Name": outputName,
                "Archive Created Path": str(object = outputPath),
                "Archive Sources": sources
            }
        ], indent = 4
    )

def tarCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : str    
    ) -> str:

     if not outputPath.endswith('.tar'):

        outputPath += '.tar'

     useEncryption, userArchivePassword = extractPasswordData(
         passwordProtectedObject = passwordProtected  
     )

     outputPath = validatePathLastName(outputPath = outputPath, outputName = outputName)
    
     with tarfile.open(name = outputPath, mode = "w") as tarArchiveFolder:
    
        for source in sources:
    
            sourcePath = os.path.abspath(source)
    
            if os.path.isdir(sourcePath):
    
                tarArchiveFolder.add(sourcePath, arcname=os.path.basename(sourcePath))

            elif os.path.isfile(sourcePath):

                tarArchiveFolder.add(sourcePath, arcname=os.path.basename(sourcePath))

     if useEncryption:
        
            salt : bytes = os.urandom(16)

            kdf = Scrypt(salt = salt, length = 32, n = 2**14, r = 8, p = 1)

            key : bytes = base64.urlsafe_b64encode(kdf.derive(key_material = userArchivePassword.encode('utf-8')))

            fernet = Fernet(key)
            
            # Read the raw tar data, encrypt it, and overwrite the file
            with open(outputPath, 'rb') as originalFile:

                raw_data = originalFile.read()
                
            encrypted_data = fernet.encrypt(raw_data)
            
            with open(outputPath, 'wb') as encryptedFile:

                encryptedFile.write(encrypted_data)

     return json.dumps(
         obj = [
             {
                "Status": "Archive Created",
                "Archive Path": str(object = outputPath),
                "Archive Name": outputName,
                "Format": ".tar",
                "Source Path To Create Archive": sources,
             }
         ], indent = 4
     )

def ZzCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : str    
    ) -> str:

    if not outputPath.endswith('.7z'):

        outputPath += '.7z'

    useEncryption, userArchivePassword = extractPasswordData(
        passwordProtectedObject = passwordProtected
    )

    archivePassword = userArchivePassword if useEncryption else None

    outputPath = validatePathLastName(outputPath = outputPath, outputName = outputName)

    with py7zr.SevenZipFile(file = outputPath, mode = "w", password = archivePassword) as py7zArchiveFile:

        for sourcePath in sources:

             if os.path.isdir(sourcePath):

                baseDirectory = os.path.dirname(sourcePath)

                for root, _, files in os.walk(sourcePath):

                    for file in files:

                        fullPath = os.path.join(root, file)

                        relative_path = os.path.relpath(path = fullPath, start = baseDirectory)

                        py7zArchiveFile.write(file = fullPath, arcname=relative_path)
                        
             elif os.path.isfile(sourcePath):

                py7zArchiveFile.write(file = sourcePath, arcname = os.path.basename(p = sourcePath))

    return json.dumps(
        obj = [
            {
                "Status": "Archive Created",
                "Archive Path": str(object = outputPath),
                "Archive Name": outputName,
                "Format": ".7z",
                "Source Path To Create Archive": sources,
            }
        ], indent = 4
    )

def rarCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : str    
    ) -> str:

    if not outputPath.endswith(".rar"):

        outputPath += ".rar"

    useEncryption, userArchivePassword = extractPasswordData(
        passwordProtectedObject = passwordProtected
    )

    rarExecutable = findCompressorRarEngine()

    if rarExecutable:

        absoluteSources = [os.path.abspath(path = sourcePath) for sourcePath in sources]

        cmd = [rarExecutable, "a", "-ep1"]

        if useEncryption and userArchivePassword:
            cmd.append(f"-hp{userArchivePassword}")
            
        cmd.append(outputPath)
        cmd.extend(absoluteSources)

        process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        if process.returncode != 0:

            logger.exception(f"RAR Generation failure: {process.stderr}")

            return json.dumps(
                obj = [
                    {
                        "Status": "Failed To Create Archive",
                        "Reason Why It's Failed": f"Exception: { process.stderr }",
                        "Archive Path": str(object = outputPath),
                        "Archive Name": outputName,
                        "Format": ".rar",
                        "Source Path To Create Archive": sources,
                    }
                ], indent = 4
            )

        return json.dumps(
            obj = [
                {
                    "Status": "Archive Created",
                    "Archive Path": str(object = outputPath),
                    "Archive Name": outputName,
                    "Format": ".rar",
                    "Source Path To Create Archive": sources,
                }
            ], indent = 4
        )            
    
    else:

        logger.exception("AI Agent Failed To Create .rar")

        logger.info("AI Agent Create .zip Because He Is Failed To Create .rar")

        zipCompressor(
            sources                 =       sources,
            outputName              =       outputName,
            outputPath              =       outputPath,
            passwordProtected       =       passwordProtected
        )

        return json.dumps(
            obj = [
                {
                    "Status": "Archive Created",
                    "Archive Path": str(object = outputPath),
                    "Archive Name": outputName,
                    "Format": ".7z",
                    "Source Path To Create Archive": sources,
                    "Note": ".rar Archive Created Is Failed But Tool Use Save Way And Create The .zip Archive"
                }
            ], indent = 4
        )
    