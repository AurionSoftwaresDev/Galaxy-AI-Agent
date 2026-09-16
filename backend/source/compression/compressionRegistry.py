from source.compression.compressors.functions import (
    zipCompressor,
    tarCompressor,
    ZzCompressor,
    rarCompressor,
)

ARCHIVE_HANDLERS = {
    ".zip": zipCompressor,
    ".tar": tarCompressor,
    ".7z": ZzCompressor,
    ".rar": rarCompressor,
}

