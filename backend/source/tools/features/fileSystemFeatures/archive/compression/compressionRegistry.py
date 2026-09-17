from source.tools.features.fileSystemFeatures.archive.compression.compressors.compressorsFunctions import (
    zipCompressor,
    tarCompressor,
    ZzCompressor,
    rarCompressor,
)

COMPRESSORS_HANDLERS = {
    ".zip": zipCompressor,
    ".tar": tarCompressor,
    ".7z": ZzCompressor,
    ".rar": rarCompressor,
}

