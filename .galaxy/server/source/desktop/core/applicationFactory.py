import sys
from source.desktop.core.baseLauncher import BaseApplicationLauncher
from source.desktop.applicationLauncher.linux.linuxLauncher import LinuxApplicationLauncher
from source.desktop.applicationLauncher.windows.windowsLauncher import WindowsApplicationLauncher
from source.desktop.applicationLauncher.macOS.macOSLauncher import MacOSApplicationLauncher

# ============================================================
# FACTORY
# ============================================================

class ApplicationLauncherFactory:
    """
    Creates the correct application launcher
    for the current operating system.
    """

    @staticmethod
    def create() -> BaseApplicationLauncher:

        if sys.platform.startswith("win"):

            return WindowsApplicationLauncher()

        if sys.platform == "darwin":

            return MacOSApplicationLauncher()

        if sys.platform.startswith("linux"):

            return LinuxApplicationLauncher()

        raise RuntimeError(
            f"Unsupported operating system: "
            f"{sys.platform}"
        )
