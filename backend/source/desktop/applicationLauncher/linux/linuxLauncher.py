import json
import subprocess, shutil
from pathlib import Path
from source.utils.logger import logger 
from source.desktop.core.baseLauncher import BaseApplicationLauncher
from source.desktop.core.utils.commonUtils import matchScore

# ============================================================
#  Linux Application Launcher
# ============================================================
class LinuxApplicationLauncher(BaseApplicationLauncher):
    """
        Linux application launcher.

        Discovery order:

            1. PATH
            2. .desktop application files
    """

    DESKTOP_LOCATIONS = [
        Path("/usr/share/applications"),
        Path("/usr/local/share/applications"),
    ]

    def __init__(self):

        self.DESKTOP_LOCATIONS.append(
            Path.home()
            / ".local"
            / "share"
            / "applications"
        )

    def _findFromPath(self, appName: str) -> Path | None:

        executable = shutil.which(cmd = appName)

        if executable:

            return Path(executable)

        return None

    def _readDesktopFile(self, desktopFile: Path) -> dict[str, str]:

        values = {}

        try:

            with desktopFile.open(mode = "r",encoding="utf-8",errors="ignore") as file:

                for line in file:

                    line = line.strip()

                    if (not line or line.startswith("#") or "=" not in line):

                        continue

                    key, value = line.split(sep = "=",maxsplit = 1)

                    values[key] = value

        except (OSError,PermissionError):

            pass

        return values

    def _findFromDesktopFiles(self, appName: str) -> Path | None:

        bestFile = None

        bestScore = 0.0

        for location in self.DESKTOP_LOCATIONS:

            if not location.exists():

                continue

            try:

                desktopFiles = location.glob(pattern = "*.desktop")

                for desktopFile in desktopFiles:

                    values = (
                        self._readDesktopFile(
                            desktopFile = desktopFile
                        )
                    )

                    displayName = values.get(
                        "Name",
                        desktopFile.stem
                    )

                    score = matchScore(
                        requestedName = appName,
                        candidateName = displayName
                    )

                    if score > bestScore:

                        bestScore = score

                        bestFile = desktopFile

            except (OSError, PermissionError):

                continue

        if (bestFile and bestScore >= self.MINIMUM_MATCH_SCORE):

            return bestFile

        return None

    def findApplication(self, appName: str) -> Path | None:

        result = self._findFromPath(appName = appName)

        if result:

            return result

        return self._findFromDesktopFiles(appName)

    def launch(self, application: Path | str, appName: str) -> str:

        application = Path(application)

        logger.info(f"AI Agent Launching \"{appName}\" Application On Linux At : \"{ application }\"")

        if application.suffix == ".desktop":

            if shutil.which("gtk-launch"):

                subprocess.Popen(
                    args = [
                        "gtk-launch",
                        application.stem
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )

            elif shutil.which("xdg-open"):

                subprocess.Popen(
                    args = [
                        "xdg-open",
                        str(application)
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )

                logger.info(f"AI Agent Successfully Launchedh Linux Appliation : \"{ appName }\"")

            else:

                logger.exception(f"AI Agent Failed To Launched Linux Appliation : \"{ appName }\", At \"{ application }\" ")

                return json.dumps(obj = [
                    {
                        "Status": "Could't Not Found Linux. Failed To Launched gtk-launch or xdg-open",
                        "Application Name": appName,
                        "Application Path": str(object = application),
                        "Operating System": "Linux"
                    }
                ], indent = 4)

        else:

            subprocess.Popen(
                [str(application)],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )

            logger.info(f"AI Agent Successfully Launched Linux Appliation : \"{ appName }\" At : \"{ application }\"")

        logger.exception(f"AI Agent Failed To Launch Linux Appliation : \"{ appName }\"")

        return json.dumps(obj = [
            {
                "Status": "Launched",
                "Application Name": appName,
                "Application Path": str(object = application),
                "Operating System": "Linux"
            }
        ], indent = 4)

