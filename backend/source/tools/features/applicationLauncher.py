from source.desktop.core.applicationFactory import ApplicationLauncherFactory

# ============================================================
# SINGLE LAUNCHER INSTANCE
# ============================================================

applicationLauncher = (
    ApplicationLauncherFactory.create()
)

# ============================================================
# LANGCHAIN TOOL
# ============================================================

def launchApplication(appName: str) -> str:
    """
        Finds and launches a desktop application
        using the current operating system.

        The tool accepts a human-readable application name.

        Examples:
            Visual Studio Code
            IntelliJ IDEA
            Google Chrome
            Spotify
            Firefox
            Notepad
    """

    return applicationLauncher.launchApplication(appName)