from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.align import Align
from rich import box
from source.constants.agentInformations import agentVersion, agentName
from source.constants.cliConstants import COMMANDS_LIST, SHORTCUTS_LIST

def help() -> Panel:
    
    console: Console = Console()

    commandTable : Table = Table(
        title = "[bold cyan]Available CLI Slash Commands[/bold cyan]",
        title_justify = "center",
        box = box.ROUNDED,
        border_style = "cyan",
        header_style="bold magenta",
        expand = True,
        show_lines=True
    )

    shortcutsTable : Table = Table(
        box = box.SIMPLE_HEAD,
        border_style = "magenta",
        header_style = "bold magenta",
        expand = True,
        show_lines = False
    )

    dashboardGrid : Table = Table.grid(
        expand = True, 
        padding = (
            1, 
            1
        )
    )

    commandTable.add_column(
        header = "Command", 
        style = "bold green", 
        justify = "left", 
        min_width = 18
    )

    commandTable.add_column(
        header = "Category", 
        style = "yellow", 
        justify = "center", 
        min_width = 14
    )

    commandTable.add_column(
        header = "Description", 
        style = "white", 
        justify = "left", 
        ratio = 3
    )

    commandTable.add_column(
        header = "Syntax", 
        style = "bright_blue", 
        justify = "left", 
        min_width = 18
    )

    shortcutsTable.add_column(
        header = "Shortcut", 
        style = "bold bright_cyan", 
        min_width = 28
    )

    shortcutsTable.add_column(
        header = "Mode / Action", 
        style = "bright_white"
    )

    dashboardGrid.add_column(
        ratio = 1
    )

    for command, category, description, syntax in COMMANDS_LIST:

        commandTable.add_row(
            f"[bold green]{command}[/bold green]",
            f"[bold yellow]{category}[/bold yellow]",
            description,
            f"[dim]{syntax}[/dim]"
        )

    for shortcut, action in SHORTCUTS_LIST:

        shortcutsTable.add_row(shortcut, action)

    dashboardGrid.add_row(commandTable)

    dashboardGrid.add_row(
        Panel(
            renderable = shortcutsTable,
            title = "[bold magenta]⚡ System Hotkeys & Shortcuts[/bold magenta]",
            border_style = "magenta",
            box = box.ROUNDED
        )
    )

    infoText = (
        "[bold cyan]Tip:[/bold cyan] [italic white]Type slash commands anytime while interacting with the agent in chat mode.[/italic white]\n"
        "[dim]Multiple commands can also be executed together (e.g. [/dim][bold green]/status /tools[/bold green][dim]).[/dim]"
    )

    dashboardGrid.add_row(
        Panel(
            renderable = Align.center(
                renderable = infoText
            ),
            border_style = "bright_black",
            box = box.ROUNDED
        )
    )

    helpContainerPanel : Panel = Panel(
        renderable = dashboardGrid,
        title = f"[bold bright_cyan]✦ {agentName} — CLI Help & Commands Menu ({agentVersion}) ✦[/bold bright_cyan]",
        subtitle = "[bold dim cyan]Type any command preceded by / to execute[/bold dim cyan]",
        border_style = "bright_cyan",
        box = box.DOUBLE,
        padding = (
            1,
            2
        ),
        expand = True
    )

    console.print("")
    console.print(helpContainerPanel)
    console.print("")

    return helpContainerPanel