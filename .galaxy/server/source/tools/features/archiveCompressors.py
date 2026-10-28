from pathlib import Path

from source.tools.features.fileSystemFeatures.archive.compression.compressor import (
    ArchiveCompressor,
)
from source.utils.logger import logger


def archiveCompressor(
        sources : list[Path], 
        format : str = ".zip", 
        passwordProtected : dict[str, bool] | None = None,
        outputName : str = "archive.zip",
        outputPath : Path | None = None
    ) -> str:

    if passwordProtected is None:
        passwordProtected = {"Password": None, "Protected": False}
    logger.info("AI Agent Called archive_compressor Tool...")

    archiveCompressor = ArchiveCompressor()

    compressorJSONResponse = archiveCompressor.compresss(
        sources             =        sources,
        format              =        format,
        outputPath          =        outputPath,
        outputName          =        outputName,
        passwordProtected   =        passwordProtected,
    )

    logger.info(f"AI Agent Successfully Created \"{ format }\" Archive At \"{ outputPath }\"")

    return compressorJSONResponse