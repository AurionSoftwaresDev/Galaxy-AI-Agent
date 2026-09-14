from pydantic import BaseModel, Field

class LaunchApplicationInputModel(BaseModel):
    """
        Input model for launching a desktop application.
    """

    appName : str = Field(
        ...,
        description = """
            The human-readable name of the desktop application to launch.
            
                Provide the normal application name, for example:
                - Visual Studio Code
                - Google Chrome
                - Mozilla Firefox
                - IntelliJ IDEA
                - Spotify
                - Notepad

                Do not provide an executable path, file path, .exe file,
                .app bundle, .desktop file, or shortcut path unless the user
                explicitly provides a path.
        """
    )