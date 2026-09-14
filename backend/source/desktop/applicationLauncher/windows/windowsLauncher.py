import json
import os
import shutil
import subprocess
from pathlib import Path
from source.utils.logger import logger
from source.desktop.core.baseLauncher import BaseApplicationLauncher
from source.desktop.applicationLauncher.windows.windowsPaths import (
    REGISTRY_LOCATIONS,
    PROGRAM_DATA,
    APP_DATA,
    PUBLIC,
    USER_PROFILE
)
from source.desktop.applicationLauncher.windows.windowsShortcuts import (
    WINDOWS_SHORTCUTS
)
from source.desktop.core.utils.commonUtils import matchScore

# ============================================================
# Windows Application Launcher
# ============================================================
class WindowsApplicationLauncher(BaseApplicationLauncher):
    """
        Windows application launcher.

        Discovery order:

            1. PATH
            2. Start Menu / Desktop shortcuts
            3. Windows Registry

        The launcher searches for an application using multiple
        Windows-specific discovery mechanisms and then launches
        the discovered application.
    """

    def _findFromPath(self, appName: str) -> Path | None:
        """
            Finds an application executable from the system PATH.

            Args:
                appName: Human-readable application name.

            Returns:
                Path to the executable if found, otherwise None.
        """

        try:
            executable = shutil.which(appName)

            if executable:
                logger.debug(
                    f'Found Windows application "{appName}" '
                    f'in PATH: "{executable}"'
                )

                return Path(executable)

            executable = shutil.which(f"{appName}.exe")

            if executable:
                logger.debug(
                    f'Found Windows application "{appName}" '
                    f'in PATH: "{executable}"'
                )

                return Path(executable)

        except OSError as error:
            logger.warning(
                f'Failed to search PATH for Windows application '
                f'"{appName}": {error}'
            )

        return None

    def _getSearchLocations(self) -> list[Path]:
        """
            Builds the Windows locations used for application
            shortcut discovery.

            Returns:
                Existing Windows application search directories.
        """

        locations: list[Path] = []

        try:
            # System-wide Start Menu.
            if PROGRAM_DATA:
                locations.append(
                    Path(PROGRAM_DATA)
                    / "Microsoft"
                    / "Windows"
                    / "Start Menu"
                    / "Programs"
                )

            # Current-user Start Menu.
            if APP_DATA:
                locations.append(
                    Path(APP_DATA)
                    / "Microsoft"
                    / "Windows"
                    / "Start Menu"
                    / "Programs"
                )

            # Current-user Desktop.
            if USER_PROFILE:
                locations.append(
                    Path(USER_PROFILE) / "Desktop"
                )

            # Public Desktop.
            if PUBLIC:
                locations.append(
                    Path(PUBLIC) / "Desktop"
                )

        except (OSError, TypeError) as error:
            logger.error(
                f"Failed to build Windows application search "
                f"locations: {error}"
            )

            return []

        existingLocations = [
            path
            for path in locations
            if path.exists() and path.is_dir()
        ]

        logger.debug(
            f"Windows application search locations: "
            f"{len(existingLocations)}"
        )

        return existingLocations

    def _findFromShortcuts(self, appName: str) -> Path | None:
        """
            Searches Windows Start Menu and Desktop for application
            shortcuts or executable files.

            Args:
                appName: Human-readable application name.

            Returns:
                Best matching application path if found.
        """

        bestPath: Path | None = None
        bestScore = 0.0

        for location in self._getSearchLocations():

            logger.debug(
                f'Searching Windows shortcuts in: "{location}"'
            )

            try:

                for file in location.rglob("*"):

                    if not file.is_file():
                        continue

                    if file.suffix.lower() not in WINDOWS_SHORTCUTS:
                        continue

                    score = matchScore(
                        requestedName=appName,
                        candidateName=file.stem
                    )

                    if score > bestScore:
                        bestScore = score
                        bestPath = file

            except (OSError, PermissionError) as error:

                logger.warning(
                    f'Unable to search Windows shortcut location '
                    f'"{location}": {error}'
                )

                continue

        if bestPath and bestScore >= self.MINIMUM_MATCH_SCORE:

            logger.debug(
                f'Found Windows shortcut match for "{appName}": '
                f'"{bestPath}" with score {bestScore:.2f}'
            )

            return bestPath

        logger.debug(
            f'No suitable Windows shortcut found for "{appName}".'
        )

        return None

    def _findFromRegistry(self, appName: str) -> Path | None:
        """
            Searches Windows Registry uninstall entries for an
            installed application.

            Args:
                appName: Human-readable application name.

            Returns:
                Path to the discovered executable if found.
        """

        try:
            # Import only on Windows.
            #
            # This prevents winreg from being required when
            # the project runs on macOS or Linux.
            import winreg

        except ImportError as error:

            logger.error(
                f"Windows Registry module is unavailable: {error}"
            )

            return None

        bestMatch = None
        bestScore = 0.0

        for root, registryPath in REGISTRY_LOCATIONS:

            try:

                uninstallKey = winreg.OpenKey(
                    root,
                    registryPath
                )

            except OSError as error:

                logger.debug(
                    f'Unable to open Windows Registry location '
                    f'"{registryPath}": {error}'
                )

                continue

            try:

                subkeyCount = winreg.QueryInfoKey(
                    uninstallKey
                )[0]

                for index in range(subkeyCount):

                    try:

                        subkeyName = winreg.EnumKey(
                            uninstallKey,
                            index
                        )

                        subkey = winreg.OpenKey(
                            uninstallKey,
                            subkeyName
                        )

                    except OSError:

                        continue

                    try:

                        displayName = self._readRegistryValue(
                            winreg,
                            key=subkey,
                            value_name="DisplayName"
                        )

                        if not displayName:
                            continue

                        score = matchScore(
                            requestedName=appName,
                            candidateName=displayName
                        )

                        if score <= bestScore:
                            continue

                        displayIcon = self._readRegistryValue(
                            winreg,
                            key=subkey,
                            value_name="DisplayIcon"
                        )

                        installLocation = self._readRegistryValue(
                            winreg,
                            key=subkey,
                            value_name="InstallLocation"
                        )

                        bestMatch = (
                            score,
                            displayIcon,
                            installLocation,
                            displayName
                        )

                        bestScore = score

                    finally:

                        try:
                            winreg.CloseKey(subkey)

                        except OSError as error:
                            logger.debug(
                                f"Failed to close Registry subkey: "
                                f"{error}"
                            )

            except OSError as error:

                logger.warning(
                    f'Failed while reading Windows Registry '
                    f'location "{registryPath}": {error}'
                )

            finally:

                try:
                    winreg.CloseKey(uninstallKey)

                except OSError as error:
                    logger.debug(
                        f"Failed to close Registry key "
                        f'"{registryPath}": {error}'
                    )

        if not bestMatch:
            logger.debug(
                f'No Windows Registry application matched '
                f'"{appName}".'
            )

            return None

        if bestScore < self.MINIMUM_MATCH_SCORE:

            logger.debug(
                f'Windows Registry match for "{appName}" '
                f'was below the required score: '
                f'{bestScore:.2f}'
            )

            return None

        _, displayIcon, installLocation, displayName = bestMatch

        logger.debug(
            f'Best Windows Registry match for "{appName}": '
            f'"{displayName}" with score {bestScore:.2f}'
        )

        # Try DisplayIcon
        if displayIcon:

            try:

                displayIcon = (
                    displayIcon
                    .split(",")[0]
                    .strip('"')
                )

                iconPath = Path(displayIcon)

                if iconPath.is_file():

                    logger.debug(
                        f'Using Windows Registry DisplayIcon '
                        f'for "{appName}": "{iconPath}"'
                    )

                    return iconPath

            except (OSError, ValueError) as error:

                logger.warning(
                    f'Failed to process Registry DisplayIcon '
                    f'for "{appName}": {error}'
                )

        # Try InstallLocation
        if installLocation:

            try:

                directory = Path(
                    installLocation
                )

                if directory.is_dir():

                    executable = self._findExecutable(
                        directory,
                        appName
                    )

                    if executable:
                        return executable

            except (OSError, ValueError) as error:

                logger.warning(
                    f'Failed to search Registry installation '
                    f'location for "{appName}": {error}'
                )

        return None

    @staticmethod
    def _readRegistryValue(
        winreg,
        key,
        value_name: str
    ) -> str | None:
        """
        Reads a string value from a Windows Registry key.
        """

        try:

            value, _ = winreg.QueryValueEx(
                key,
                value_name
            )

            if isinstance(value, str):
                return value

        except (
            FileNotFoundError,
            OSError
        ):

            return None

        return None

    def _findExecutable(
        self,
        directory: Path,
        appName: str
    ) -> Path | None:
        """
            Recursively searches an installation directory for
            the best matching executable.

            Args:
                directory: Application installation directory.
                appName: Requested application name.

            Returns:
                Best matching executable or None.
        """

        if not directory.exists() or not directory.is_dir():

            logger.debug(
                f'Windows application directory does not exist: '
                f'"{directory}"'
            )

            return None

        bestPath: Path | None = None
        bestScore = 0.0

        try:

            for executable in directory.rglob("*.exe"):

                score = matchScore(
                    requestedName=appName,
                    candidateName=executable.stem
                )

                if score > bestScore:

                    bestScore = score
                    bestPath = executable

        except (
            OSError,
            PermissionError
        ) as error:

            logger.warning(
                f'Failed to search executable directory '
                f'"{directory}": {error}'
            )

            return None

        if bestPath and bestScore >= 0.70:

            logger.debug(
                f'Found executable for "{appName}": '
                f'"{bestPath}" with score {bestScore:.2f}'
            )

            return bestPath

        return None

    def findApplication(
        self,
        appName: str
    ) -> Path | None:
        """
            Finds a Windows application using multiple
            discovery mechanisms.

            Discovery order:

                1. PATH
                2. Shortcuts
                3. Registry
        """

        if not appName or not appName.strip():

            logger.warning(
                "Windows application search received "
                "an empty application name."
            )

            return None

        appName = appName.strip()

        logger.info(
            f'AI Agent Searching For Windows Application '
            f'"{appName}"'
        )

        # 1. PATH
        result = self._findFromPath(appName)

        if result:

            logger.info(
                f'Found Windows application "{appName}" '
                f'using PATH: "{result}"'
            )

            return result

        # 2. Start Menu / Desktop shortcuts
        result = self._findFromShortcuts(appName)

        if result:

            logger.info(
                f'Found Windows application "{appName}" '
                f'using shortcuts: "{result}"'
            )

            return result

        # 3. Windows Registry
        result = self._findFromRegistry(appName)

        if result:

            logger.info(
                f'Found Windows application "{appName}" '
                f'using Registry: "{result}"'
            )

            return result

        logger.warning(
            f'Could not find installed Windows application '
            f'"{appName}".'
        )

        return None

    def launch(
        self,
        application: Path | str,
        appName: str
    ) -> str:
        """
            Launches a discovered Windows application.

            Args:
                application: Path to the discovered application.
                appName: Human-readable application name.

            Returns:
                JSON-formatted launch result.
        """

        if not appName or not appName.strip():

            logger.warning(
                "Windows application launch received "
                "an empty application name."
            )

            return json.dumps(
                [
                    {
                        "Status": "Failed",
                        "Application Name": appName,
                        "Reason": "Application name is empty.",
                        "Operating System": "Windows"
                    }
                ],
                indent=4
            )

        application = Path(application)

        if not application.exists():

            logger.error(
                f'Windows application path does not exist: '
                f'"{application}"'
            )

            return json.dumps(
                [
                    {
                        "Status": "Failed",
                        "Application Name": appName,
                        "Application Location": str(application),
                        "Reason": "Application path does not exist.",
                        "Operating System": "Windows"
                    }
                ],
                indent=4
            )

        try:

            # Windows shortcuts should be opened through
            # the Windows Shell.
            if application.suffix.lower() == ".lnk":

                os.startfile(
                    str(application)
                )

            else:

                subprocess.Popen(
                    [
                        str(application)
                    ],
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )

            logger.info(
                f'AI Agent Successfully Launched Windows '
                f'Application "{appName}"'
            )

            return json.dumps(
                [
                    {
                        "Status": "Launched",
                        "Application Name": appName,
                        "Application Location": str(application),
                        "Operating System": "Windows"
                    }
                ],
                indent=4
            )

        except (
            FileNotFoundError,
            PermissionError,
            OSError,
            subprocess.SubprocessError
        ) as error:

            logger.error(
                f'AI Agent Failed To Launch Windows '
                f'Application "{appName}" '
                f'At: "{application}". Error: {error}'
            )

            return json.dumps(
                [
                    {
                        "Status": "Failed",
                        "Application Name": appName,
                        "Application Location": str(application),
                        "Reason": str(error),
                        "Operating System": "Windows"
                    }
                ],
                indent=4
            )