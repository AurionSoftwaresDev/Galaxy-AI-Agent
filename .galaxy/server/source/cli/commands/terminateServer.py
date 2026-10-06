import time
import requests
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.align import Align
from rich.live import Live
from source.config.configs import getServerURL

def terminateServer() -> Table:
    
    serverTerminationEndpoint : str = "/server/disconnect"

    serverBaseURL : str = getServerURL()

    serverFullTargetURL : str = f"{serverBaseURL}{serverTerminationEndpoint}"

    terminalConsole : Console = Console()

    serverStatusGridTable : Table = Table(
        show_header = False, 
        padding = (
            0, 
            1
        ), 
        expand = True
    )

    serverStatusGridTable.add_column(
        header = "Property", 
        justify = "left", 
        style = "cyan"
    )

    serverStatusGridTable.add_column(
        header = "Status", 
        justify = "right"
    )

    terminationStatusPanel = Panel(
        renderable = Align.center(
            renderable = serverStatusGridTable
        ), 
        title = "[bold red]⚠️ System Deactivation sequence[/bold red]", 
        border_style = "red",
        width = 55
    )

    animationStepsQueue = [
        ("Target Host Base", f"[white]{serverBaseURL}[/white]"),
        ("Termination Request", "[bold yellow]SENT ➔[/bold yellow]"),
        ("Active Process State", "[bold red]TERMINATED ✖[/bold red]"),
        ("System Gateway Pipeline", "[bold red]OFFLINE ○[/bold red]")
    ]

    try:

        requests.get(url = serverFullTargetURL, timeout = 3.0)

    except requests.exceptions.ConnectionError:

        terminalConsole.print("")
        
        with Live(Align.center(terminationStatusPanel), console = terminalConsole, refresh_per_second = 10) as liveRenderer:
            
            for systemPropertyLabel, executionStatusText in animationStepsQueue:

                time.sleep(0.40) 
                
                serverStatusGridTable.add_row(systemPropertyLabel, executionStatusText)
                
                liveRenderer.update(Align.center(terminationStatusPanel))
                
        terminalConsole.print("")

        return serverStatusGridTable
    
    except Exception:

        return serverStatusGridTable

    return serverStatusGridTable