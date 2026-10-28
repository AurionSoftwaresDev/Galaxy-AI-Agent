from collections.abc import Callable

from source.tools.features.fileSystemFeatures.archive.extraction.extractors.extractorsFunctions import (
    ZzExtractor,
    rarExtractor,
    tarExtractor,
    zipExtractor,
)

EXTRACTORS_HANDLERS : dict[str, Callable]= {
    ".zip": zipExtractor,
    ".tar": tarExtractor,
    ".7z": ZzExtractor,
    ".rar": rarExtractor,
}