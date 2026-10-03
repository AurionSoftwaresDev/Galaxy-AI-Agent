import json
import subprocess, shutil
from pathlib import Path
from venv import logger
from source.desktop.core.baseLauncher import BaseApplicationLauncher
from source.desktop.core.utils.commonUtils import matchScore

# ============================================================
# MacOS Application Launcher
# ============================================================
class MacOSApplicationLauncher(BaseApplicationLauncher):
    """
        macOS application launcher.

        macOS already provides a native application
        launcher through the `open` command.
    """

    def findApplication(self, appName: str) -> Path | None:

        # First check PATH.
        executable = shutil.which(cmd = appName)

        if executable:

            return Path(executable)

        # Check common .app locations.
        locations = [
            Path("/Applications"),
            Path.home() / "Applications"
        ]

        bestMatch = None
        
        bestScore = 0.0

        for location in locations:

            if not location.exists():

                continue

            try:

                for application in location.glob(
                    pattern = "*.app"
                ):

                    score = matchScore(
                        requestedName = appName,
                        candidateName = application.stem
                    )

                    if score > bestScore:

                        bestScore = score

                        bestMatch = application

            except OSError:

                logger.info(f"AI Agent Failed To Launched MacOS Application \"{ appName }\" At : \"{ application }\"")

                continue

        if (bestMatch and bestScore >= self.MINIMUM_MATCH_SCORE):

            return bestMatch

        return None
    
    def launch(self, application: Path | str, appName: str) -> str:

        applicationPath = Path(application)

        subprocess.Popen(
            [
                "open",
                str(applicationPath)
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

        logger.info(
            f'AI Agent Launched The MacOS Application "{appName}" '
            f'At: "{applicationPath}"'
        )

        return json.dumps(
            obj=[
                {
                    "Status": "Launched",
                    "Application Name": appName,
                    "Application Path": str(applicationPath),
                    "Operating System": "MacOS"
                }
            ],
            indent=4
        )