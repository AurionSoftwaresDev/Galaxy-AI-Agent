from typing import Optional
from source.utils.logger import logger
from source.tools.features.fileSystemFeatures.archive.extraction.extractionRegistry import EXTRACTORS_HANDLERS

class ArchiveExtractor():

    def __init__(self):

        logger.info("AI Agent Created New Archive Extractor")

    def extract(
            self,
            format : str,
            archiveSourceFullPath : str,
            archiveExtractOutputPath : str,
            archiveOutputNameFolder : Optional[str] = None,
            archivePassword : Optional[str] = None,
    ) -> str:

        archiveExtractor = EXTRACTORS_HANDLERS[format]

        return archiveExtractor(
            archiveSourceFullPath        =      archiveSourceFullPath,
            archiveExtractOutputPath     =      archiveExtractOutputPath,
            archiveOutputNameFolder      =      archiveOutputNameFolder,
            archivePassword              =      archivePassword,
        )