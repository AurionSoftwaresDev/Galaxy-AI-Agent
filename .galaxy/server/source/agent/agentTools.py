from langchain_core.tools import BaseTool, StructuredTool

from source.tools.BrowserTool import (
    close_own_galaxy_custom_browser,
    open_own_galaxy_custom_browser,
    openDefaultBrower,
)
from source.tools.commandsExecutorTool import commandsExecutorTool
from source.tools.datetimeFetchingTool import fetchCurrentDateTimeTool
from source.tools.fileSystem.archive.archiveCompressorTool import archiveCompressorTool
from source.tools.fileSystem.archive.archiveExtractorTool import archiveExtractorTool
from source.tools.fileSystem.buildFileSystemTreeTool import buildFileSystemTreeTool
from source.tools.fileSystem.createFileTool import createFileTool
from source.tools.fileSystem.createFolderTool import createFolderTool
from source.tools.fileSystem.deleteFileTool import deleteFileTool
from source.tools.fileSystem.deleteFolderTool import deleteFolderTool
from source.tools.fileSystem.readFileTool import readFileTool
from source.tools.inspectUserSystemTool import inspectUserSystemTool
from source.tools.launchDesktopApplicationTool import launchApplicationTool
from source.tools.mapTools import (
    addMarkerOnCoordinateTool,
    calculateCoordinateDistanceTool,
    flyToLocationTool,
    openMapTool,
)
from source.tools.sendEmaillTool import sendEmailTool
from source.tools.TypingTool import typingTool
from source.tools.webSearchTool import webSearchTool

AGENT_TOOLS : list[BaseTool | StructuredTool] = [
    fetchCurrentDateTimeTool,
    webSearchTool,
    sendEmailTool,
    typingTool,
    inspectUserSystemTool,

    createFolderTool,
    deleteFolderTool,
    createFileTool,
    readFileTool,
    deleteFileTool,
    buildFileSystemTreeTool,
    archiveCompressorTool,
    archiveExtractorTool,
    
    launchApplicationTool,
    commandsExecutorTool,

    openMapTool,
    flyToLocationTool,
    addMarkerOnCoordinateTool,
    calculateCoordinateDistanceTool,

    open_own_galaxy_custom_browser,
    close_own_galaxy_custom_browser,
    openDefaultBrower
]