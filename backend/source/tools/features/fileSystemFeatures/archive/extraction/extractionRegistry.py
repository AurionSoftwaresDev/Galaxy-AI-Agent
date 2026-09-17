from source.tools.features.fileSystemFeatures.archive.extraction.extractors.extractorsFunctions import (
    zipExtractor,
    tarExtractor,
    ZzExtractor,
    rarExtractor,
)

EXTRACTORS_HANDLERS = {
    ".zip": zipExtractor,
    ".tar": tarExtractor,
    ".7z": ZzExtractor,
    ".rar": rarExtractor,
}