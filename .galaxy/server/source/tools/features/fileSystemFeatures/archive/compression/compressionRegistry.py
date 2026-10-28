from collections.abc import Callable

from source.tools.features.fileSystemFeatures.archive.compression.compressors.compressorsFunctions import (
    ZzCompressor,
    rarCompressor,
    tarCompressor,
    zipCompressor,
)

COMPRESSORS_HANDLERS : dict[str, Callable] = {
    ".zip": zipCompressor,
    ".tar": tarCompressor,
    ".7z": ZzCompressor,
    ".rar": rarCompressor,
}

