from typing import Optional
from source.utils.logger import logger
from source.tools.features.fileSystemFeatures.archive.extraction.extractor import ArchiveExtractor

def archiveExtractor(
        format : str,
        archiveSourceFullPath : str,
        archiveExtractOutputPath : str,
        archiveOutputNameFolder : Optional[str] = None,
        archivePassword : Optional[str] = None,
    ) -> str:

    logger.info("AI Agent Called archive_extractor Tool...")

    archiveExtractor = ArchiveExtractor()

    extractorJSONResponse = archiveExtractor.extract(
        format                            =     format,
        archiveSourceFullPath             =     archiveSourceFullPath,
        archiveExtractOutputPath          =     archiveExtractOutputPath,
        archiveOutputNameFolder           =     archiveOutputNameFolder,
        archivePassword                   =     archivePassword,
    )

    logger.info(f"AI Agent Successfully Extracted \"{ archiveSourceFullPath }\" At : \"{ archiveExtractOutputPath }\"")

    return extractorJSONResponse


print(archiveExtractor(
    format                      =      ".zip",
    archiveSourceFullPath       =      "C:/Users/dell/desktop/Arr.zip",
    archiveExtractOutputPath    =      "C:/Users/dell/desktop",
    archivePassword             =      "Password"
))