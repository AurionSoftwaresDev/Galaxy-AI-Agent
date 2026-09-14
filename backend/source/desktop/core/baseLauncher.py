from abc import ABC, abstractmethod
import json
from pathlib import Path

class BaseApplicationLauncher(ABC):
    """
    Base class for operating-system-specific
    application launchers.
    """

    MINIMUM_MATCH_SCORE = 0.75

    @abstractmethod
    def findApplication(self, appName : str) -> Path | None:
        """
            Finds an application and returns its path.

            Returns:
                Path if application was found.
                None otherwise.
        """
        raise NotImplementedError

    @abstractmethod
    def launch(self, application : Path | str, appName : str) -> str:
        """
            Launches the discovered application.
        """
        raise NotImplementedError

    def launchApplication(self, appName : str) -> str:
        """
            Common application-launch workflow.

            1. Validate name.
            2. Find application.
            3. Launch application.
        """

        appName = appName.strip()

        if not appName:

            return json.dumps(obj = [
                {

                }
            ], indent = 4)

        try:

            application = self.findApplication(
                appName = appName
            )

            if application is None:

                return (
                    f"Could not find an installed "
                    f"application named '{appName}'."
                )

            return self.launch(
                application,
                appName = appName
            )

        except Exception as exception:

            return (
                f"Failed to launch "
                f"'{ appName }': { exception }"
            )
