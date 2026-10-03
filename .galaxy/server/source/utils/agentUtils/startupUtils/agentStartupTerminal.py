import pyfiglet, platform
from rich.console import Console
from source.constants.agentInformations import agentVersion, agentinformations, agentTerminalModeShorcuts
from source.utils.agentUtils.startupUtils.typingAnimation import typingTextOnTerminal
from source.utils.helper import clearTerminalScreen
from source.constants.styles.richFontColors import RICH_COLOR_PALETTE, RICH_COLORS

def galaxyAIAgentStartupTerminal(font: str = "slant", style: str = "bold bright_cyan", speed : float = 0.002):

    aiAgentStyledNameASCIIArt : str
    aiAgentStyledVersion : str
    aiAgentStyledShortcutLists : str

    clearTerminalScreen(platform.system())

    # Printing Galaxy AI Agent ASCII
    console = Console()

    agentNameInASCIIArt = pyfiglet.figlet_format( "Galaxy AI Agent", font = font)

    with console.capture() as capture:

        console.print(f"[{style}]{agentNameInASCIIArt}[/{style}]")

    aiAgentStyledNameASCIIArt = capture.get()

    with console.capture() as capture:
    
        console.print(f"[{RICH_COLOR_PALETTE["Reds & Browns"][0]}]Version {agentVersion}[/{RICH_COLOR_PALETTE["Reds & Browns"][0]}]")
    
    aiAgentStyledVersion = capture.get()

    with console.capture() as capture:

        console.print(f"[{RICH_COLORS["bright"][3]}]{agentinformations}[/{RICH_COLORS["bright"][3]}]")

    aiAgentStyledInformations = capture.get()

    with console.capture() as capture:

        console.print(f"[{RICH_COLORS["bright"][1]}]{agentTerminalModeShorcuts}[/{RICH_COLORS["bright"][1]}]")

    aiAgentStyledShortcutLists = capture.get()

    # Printing All Data And Information, Startup
    typingTextOnTerminal(text = aiAgentStyledNameASCIIArt, speed = speed)
    typingTextOnTerminal(text = f"\t\t\t\t\t\t\t\t{aiAgentStyledVersion}", speed = speed)
    typingTextOnTerminal(text = aiAgentStyledInformations,  speed = speed)
    typingTextOnTerminal(text = aiAgentStyledShortcutLists, speed = speed)
