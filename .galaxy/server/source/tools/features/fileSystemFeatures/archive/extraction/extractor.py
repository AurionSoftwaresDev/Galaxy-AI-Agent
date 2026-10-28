
from source.tools.features.fileSystemFeatures.archive.extraction.extractionRegistry import (
    EXTRACTORS_HANDLERS,
)
from source.utils.logger import logger


class ArchiveExtractor:

    def __init__(self):

        logger.info("AI Agent Created New Archive Extractor")

    def extract(
            self,
            format : str,
            archiveSourceFullPath : str,
            archiveExtractOutputPath : str,
            archiveOutputNameFolder : str | None = None,
            archivePassword : str | None = None,
    ) -> str:

        archiveExtractor = EXTRACTORS_HANDLERS[format]

        return archiveExtractor(
            archiveSourceFullPath        =      archiveSourceFullPath,
            archiveExtractOutputPath     =      archiveExtractOutputPath,
            archiveOutputNameFolder      =      archiveOutputNameFolder,
            archivePassword              =      archivePassword,
        )