import json
from abc import ABC, abstractmethod
from pathlib import Path
from source.utils.logger import logger


class BaseApplicationLauncher(ABC):
    """
        Base class for operating-system-specific
        application launchers.
    """

    MINIMUM_MATCH_SCORE = 0.75

    @abstractmethod
    def findApplication(self, appName: str) -> Path | None:
        """
            Finds an application and returns its path.

            Returns:
                Path: Application path if found.
                None: If the application was not found.
        """
        raise NotImplementedError

    @abstractmethod
    def launch(
        self,
        application: Path | str,
        appName: str
    ) -> str:
        """
        Launches the discovered application.
        """
        raise NotImplementedError

    def launchApplication(self, appName: str) -> str:
        """
            Common application-launch workflow.

            Workflow:
                1. Validate application name.
                2. Find the application.
                3. Launch the application.
                4. Return a JSON response.
        """

        appName = appName.strip()

        logger.info(f"Application Launch Requested : \"{ appName }\"")

        # Validate Application Name.
        if not appName:

            logger.warning("Application launch failed: empty application name.")

            return json.dumps(
                obj=[
                    {
                        "Status": "Failed",
                        "Message": "Application Name Cannot Be Empty.",
                    }
                ],
                indent = 4
            )

        try:

            logger.debug(f"Searching For Application: '{appName}'")

            application = self.findApplication(appName = appName)

            if application is None:

                logger.warning(f"Application Not Found: '{appName}'")

                return json.dumps(
                    obj = [
                        {
                            "Status": "Not Found",
                            "Application Name": appName,
                            "Message": (
                                f"Could not find an installed "
                                f"application named '{appName}'."
                            ),
                        }
                    ],
                    indent=4
                )

            logger.info(f"Application found: \"'{ appName }\" at \"{ application }\"")

            logger.debug(f"Launching application: '{ appName }'")

            return self.launch(
                application,
                appName = appName
            )

        except Exception as exception:

            logger.exception(
                f"Unexpected error while launching "
                f"application '{appName}'."
            )

            return json.dumps(
                obj = [
                    {
                        "Status": "Failed",
                        "Application Name": appName,
                        "Application Path": str(object = application),
                        "Message": (
                            f"Failed to launch "
                            f"'{appName}'."
                        ),
                        "Error": str(object = exception),
                    }
                ],
                indent = 4
            )