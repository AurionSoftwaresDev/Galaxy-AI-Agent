from rich.console import Console
from source.constants.agentInformations import agentVersion

def version() -> None:

    console : Console = Console()

    console.print(
        f"[bold cyan]AI Agent[/bold cyan] "
        f"[bold white]Version :[/bold white] "
        f"[bold green]v{agentVersion}[/bold green]"
    )