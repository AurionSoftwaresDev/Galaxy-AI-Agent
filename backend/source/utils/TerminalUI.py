from rich.console import Console
from rich.live import Live
from rich.spinner import Spinner
from rich.text import Text
from rich.table import Table

class TerminalUI:

    def __init__(self) -> None:

        self.console : Console = Console()

        self.currentState     =     "idle"
        self.currentTool      =     None
        self.currentMessage   =     ""
        self.responseStarted  =     False

        self.live             =     None
        self.spinner          =     None

    # Internal Rendering
    def _buildStatus(self) -> Text:

        if self.currentState == "thinking":

            return Text(
                text  = "Thinking...",
                style = "cyan"
            )

        if self.currentState == "tool":

            return Text(
                text  = f"AI Agent Using {self.currentTool}...",
                style = "yellow"
            )

        if self.currentState == "completed":

            return Text(
                text  = "Completed",
                style = "green"
            )

        if self.currentState == "error":

            return Text(
                text  = "Something went wrong",
                style = "red"
            )

        return Text(text = "")

    # UI Lifecycle
    def start(self) -> None:
        self.live = Live(
            renderable = Spinner(
                name = "dots",
                text = self._buildStatus()
            ),
            console = self.console,
            refresh_per_second = 12,
            transient = True
        )

        self.live.start()

    def stop(self) -> None:
        if self.live is not None:

            self.live.stop()

            self.live = None

    def _refresh(self) -> None:

        if self.live is None:

            return

        self.live.update(
            renderable = Spinner(
                name = "dots",
                text = self._buildStatus()
            )
        )

    
    # Agent States
    def thinking(self) -> None:

        self.currentState = "thinking"

        self.currentTool = None

        self._refresh()

    def toolStarted(self, toolName : str) -> None:

        self.currentState = "tool"

        self.currentTool = toolName

        self._refresh()

    def toolCompleted(self) -> None:

        self.currentState = "thinking"

        self.currentTool = None

        self._refresh()

    def completed(self) -> None:

        self.currentState = "completed"

        self.currentTool = None

        self._refresh()

    def error(self) -> None:

        self.currentState = "error"

        self.currentTool = None

        self._refresh()

    # Permission
    def pauseForPermission(self) -> None:

        self.stop()

    def resumeAfterPermission(self) -> None:

        self.start()

    # Response
    def startResponse(self) -> None:

        self.stop()

        self.console.print(
            "\nAI Agent : ",
            end = "",
            style = "bold green"
        )

    def printResponseChunk(self, text : str) -> None:

        if not self.responseStarted:

            self.stop()
            self.console.print(
                "\nAI Agent: ",
                end = "",
                style = "bold"
            )

            self.responseStarted = True

        self.console.print(
            text,
            end = "",
            style = "white"
        )

    def finishResponse(self) -> None:

        self.console.print()

    def pause(self) -> None:

        self.stop()

    def resume(self) -> None:

        self.start()

    # Complete request
    def finish(self) -> None:

        self.stop()
        
        self.currentState = "idle"

