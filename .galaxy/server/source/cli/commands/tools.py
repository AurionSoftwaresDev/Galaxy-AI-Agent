import random
import time   
from rich.console import Console
from rich.table import Table
from rich.align import Align
from rich.live import Live      
from source.agent.agentTools import AGENT_TOOLS
from source.constants.styles.richFontColors import RICH_COLORS

def tools() -> Table:

    printingOnConsole : Console = Console()

    styleBrightColors = RICH_COLORS["bright"]

    brightRed = styleBrightColors[1]
    brightYellow = styleBrightColors[3]

    toolsTable : Table = Table(
        title = "[bold cyan]AI Agent Avaliable Tools List[/bold cyan]", 
        padding = (0, 2, 0, 2), 
        collapse_padding = True,
        show_lines = True 
    )

    toolsTable.add_column("[bold magenta]Tools Name[/bold magenta]", justify = "center")

    with Live(
        renderable = Align.center(toolsTable), 
        console = printingOnConsole, 
        refresh_per_second = 5
    ) as live:
        
        for tool in AGENT_TOOLS:

            time.sleep(0.2)
        
            toolName = tool.name

            chosen_color = random.choice([brightRed, brightYellow])
            
            formattedRow = f"[bold green]●[/bold green] [{chosen_color}]{toolName}[/{chosen_color}]"
            
            toolsTable.add_row(formattedRow)
            
            live.update(renderable = Align.center(renderable = toolsTable))
            
    return toolsTable