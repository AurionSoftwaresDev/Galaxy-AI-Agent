from pathlib import Path
from source.utils.logger import logger
from source.tools.features.fileSystemFeatures.archive.compression.compressor import ArchiveCompressor

def archiveCompressor(
        sources : list[Path], 
        format : str = ".zip", 
        passwordProtected : dict[str, bool] = { "Password": None, "Protected": False },
        outputName : str = "archive.zip",
        outputPath : Path = None
    ) -> str:

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