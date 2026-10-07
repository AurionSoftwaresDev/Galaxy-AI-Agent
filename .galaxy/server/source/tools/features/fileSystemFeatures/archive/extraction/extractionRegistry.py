from typing import Callable
from source.tools.features.fileSystemFeatures.archive.extraction.extractors.extractorsFunctions import (
    zipExtractor,
    tarExtractor,
    ZzExtractor,
    rarExtractor,
)

EXTRACTORS_HANDLERS : dict[str, Callable]= {
    ".zip": zipExtractor,
    ".tar": tarExtractor,
    ".7z": ZzExtractor,
    ".rar": rarExtractor,
}