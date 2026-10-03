from source.models.toolModels.launchDesktopApplicationModel import LaunchApplicationInputModel
from source.tools.features.applicationLauncher import launchApplication
from langchain_core.tools import StructuredTool

launchApplicationTool = StructuredTool.from_function(
    args_schema = LaunchApplicationInputModel,
    func = launchApplication,
    name = "launch_application",
    description = """
        Launch an installed desktop application on the user's computer.

        Use this tool when the user wants to open or launch a desktop
        application.

        The input must be the application's normal human-readable name,
        such as:
            - Visual Studio Code
            - Google Chrome
            - Mozilla Firefox
            - IntelliJ IDEA
            - Spotify
            - Notepad

        Do not provide an executable path, file path, .exe file, .app
        bundle, .desktop file, or shortcut path unless the user explicitly
        provides one.

        The tool automatically handles application discovery and launching
        for Windows, macOS, and Linux.

        Do not use this tool for opening websites, URLs, or ordinary files.
    """

)