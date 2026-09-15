import json
import os
from zipfile import PyZipFile
import pyzipper
from pathlib import Path

def zipCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : Path
    ) -> str:

    useEncryption = ((True if len(passwordProtected["Password"]) > 1 else False) if passwordProtected["Protected"] == True else False)

    encryptionType = pyzipper.WZ_AES if useEncryption else pyzipper

    userArchivePassword = passwordProtected["Password"]

    outputPathNameIndex = len(outputPath.split("/")) - 1

    extractFileNameFromPath = outputPath.split("/")[outputPathNameIndex]

    if outputName.lower() == extractFileNameFromPath.lower() and outputPath == extractFileNameFromPath:

        fixedPrefixOutputPath : list = outputPath.split("/")

        fixedPrefixOutputPath[outputPathNameIndex] = outputName

        outputPath = Path("/".join(fixedPrefixOutputPath))

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
                "Status": "Arhived Created",
                "Archive Name": outputName,
                "Archive Created Path": str(object = outputPath),
                "Archive Sources": sources
            }
        ], indent = 4
    )

def gZipCompressor(
        sources : list[Path],
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : Path    
    ) -> str:

    return f" { outputName } GZip Compressing... "

def tarCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : Path    
    ) -> str:

    return f" { outputName } Tar Compressing... "


def ZzCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : Path    
    ) -> str:

    return f" { outputName } 7z Compressing... "

def rarCompressor(
        sources : list[Path], 
        passwordProtected : dict[str, bool],
        outputName : str,
        outputPath : Path    
    ) -> str:

    return f" { outputName } Rar Compressing..."

