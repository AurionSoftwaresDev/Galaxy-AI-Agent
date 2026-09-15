import json
import os
from pathlib import Path
from source.utils.logger import logger
from source.constants.archiveCompressorAllowedFormats import ARCHIVE_SUPPORTED_FORMATS
from source.compression.compressionRegistry import ARCHIVE_HANDLERS

class ArchiveCompressor():

    def __init__(self) -> None:

        logger.info("AI Agent Created New Archive Compressor...")

    def validateArchiveGivenData(
            self,
            sources : list[Path],
            format : str,
            passwordProtected : dict[str, bool],
            outputName : str 
) -> str | bool:

        validFormatFouned : bool = False

        for allowedFormat in ARCHIVE_SUPPORTED_FORMATS:

            if allowedFormat == format:

                validFormatFouned = True

                break

        if validFormatFouned:

            # for sourcePath in sources:

            #     if not os.path.exists(sourcePath):

            #         return f"Path Doesn't Exsits '{ sourcePath }' Check Your Path"

            try:

                extractedPassoword = passwordProtected["Password"]
                usePassoword = passwordProtected["Protected"]

                if usePassoword:

                    if len(extractedPassoword) > 1:

                        if len(outputName) > 1:

                            return True

                        return "Output File Name Is Empty!"

                elif extractedPassoword == None or extractedPassoword == "":

                    if usePassoword:

                        return True

                    elif len(outputName) > 1:

                        return True

                return True
                
            except KeyError as keyException:   

                return f"Key Not Found In Your \"passwordProtected\" Object. Exception : {keyException}"

        return f"Your { format } Archive Format Doesn't Supported"

    def compresss(
            self, 
            sources : list[Path], 
            format: str = ".zip", 
            passwordProtected : dict[str, bool] = { "Password": None, "Protected": False },
            outputName : str = "archive.zip",
            outputPath : Path = None
        ) -> str:

        archiveValidationData = self.validateArchiveGivenData(
            sources     =       sources,
            format      =       format,
            outputName  =       outputName,
            passwordProtected = passwordProtected
        )

        if archiveValidationData == True and isinstance(archiveValidationData, str) != True:

            compressor = ARCHIVE_HANDLERS[format]

            return compressor(

                    sources           =   sources, 
                    passwordProtected =   passwordProtected, 
                    outputName        =   outputName,
                    outputPath        =   outputPath
            )

        return json.dumps(
            obj = [
                {   
                    "Status": f"Failed To Create {format} Archive",
                    "Source Paths To Create Archive": sources,
                    "Output Archive Name": outputName,
                    "Reason Why It's Failed": archiveValidationData
                }
            ],
            indent = 4
        )