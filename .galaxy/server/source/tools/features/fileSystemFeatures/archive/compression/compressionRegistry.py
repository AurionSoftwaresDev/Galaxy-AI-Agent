from typing import Callable
from source.tools.features.fileSystemFeatures.archive.compression.compressors.compressorsFunctions import (
    zipCompressor,
    tarCompressor,
    ZzCompressor,
    rarCompressor,
)

COMPRESSORS_HANDLERS : dict[str, Callable] = {
    ".zip": zipCompressor,
    ".tar": tarCompressor,
    ".7z": ZzCompressor,
    ".rar": rarCompressor,
}

