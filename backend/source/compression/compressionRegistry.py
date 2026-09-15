from source.compression.compressors.functions import (
    zipCompressor,
    tarCompressor,
    ZzCompressor,
    rarCompressor,
    gZipCompressor
)

ARCHIVE_HANDLERS = {
    ".zip": zipCompressor,
    ".tar": tarCompressor,
    ".7z": ZzCompressor,
    ".rar": rarCompressor,
    ".gz": gZipCompressor,
}

