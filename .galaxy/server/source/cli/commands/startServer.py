import time
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.align import Align
from rich.live import Live
from source.utils.helper import startServer
from source.constants.animation.cli.commands.startServerAnimationData import ANIMATION_STEPS_QUEUE

def startAgentServer() -> Table:

    terminalConsole: Console = Console()

    serverActivationGridTable : Table = Table(
        show_header = False, 
        padding = (
            0, 
            1
        ), 
        expand = True
    )

    activationStatusPanel = Panel(
        renderable = Align.center(
            renderable = serverActivationGridTable
        ), 
        title = "[bold green]🚀 System Activation Sequence[/bold green]", 
        border_style = "green",
        width = 55
    )

    serverActivationGridTable.add_column(
        header = "Initialization Step", 
        justify = "left", 
        style = "cyan"
    )

    serverActivationGridTable.add_column(
        header = "Status Metric", 
        justify = "right"
    )

    startServer()

    terminalConsole.print("")

    with Live(
        renderable = Align.center(
            renderable = activationStatusPanel
        ), 
        console = terminalConsole, 
        refresh_per_second = 10
    ) as liveRenderer:
        
        for systemInitializationLabel, operationStatusText in ANIMATION_STEPS_QUEUE:

            time.sleep(0.45) 
            
            serverActivationGridTable.add_row(systemInitializationLabel, operationStatusText)
            
            liveRenderer.update(
                renderable = Align.center(
                    renderable = activationStatusPanel
                )
            )

    terminalConsole.print("")

    return serverActivationGridTable
