import os
from rich.console import Console

def exit():

    console : Console = Console()

    console.print(
        "[bold red] Exited [bold red]"
    )

    os._exit(0)