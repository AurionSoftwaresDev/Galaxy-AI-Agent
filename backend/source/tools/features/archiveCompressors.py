from pathlib import Path
from source.utils.logger import logger
from source.compression.compressor import ArchiveCompressor

def archiveCompressor(
            sources : list[Path], 
            format : str = ".zip", 
            passwordProtected : dict[str, bool] = { "Password": None, "Protected": False },
            outputName : str = "archive.zip",
            outputPath : Path = None
    ):

    logger.info("AI Agent Called archive_compressor Tool...")

    compressor = ArchiveCompressor()

    JSONResponse = compressor.compresss(
        sources             =        sources,
        format              =        format,
        outputPath          =        outputPath,
        outputName          =        outputName,
        passwordProtected   =        passwordProtected,
    )

    logger.info(f"AI Agent Successfully Created \"{ format }\" Archive At \"{ outputPath }\"")

    return JSONResponse