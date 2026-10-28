
from source.tools.features.fileSystemFeatures.archive.extraction.extractor import (
    ArchiveExtractor,
)
from source.utils.logger import logger


def archiveExtractor(
        format : str,
        archiveSourceFullPath : str,
        archiveExtractOutputPath : str,
        archiveOutputNameFolder : str | None = None,
        archivePassword : str | None = None,
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