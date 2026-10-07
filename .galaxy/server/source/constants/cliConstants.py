import pandas

COMMANDS_LIST : list[tuple[str, str, str, str]] = [
    (
        "/help",
        "General",
        "Display this command reference menu with details and system shortcuts",
        "/help"
    ),
    (
        "/status",
        "Diagnostics",
        "Inspect system infrastructure, API gateway health & agent engine status",
        "/status"
    ),
    (
        "/tools",
        "Capabilities",
        "List all AI agent tools registered and active in the runtime engine",
        "/tools"
    ),
    (
        "/providers",
        "Configuration",
        "Display available LLM providers, models, and currently active engine",
        "/providers"
    ),
    (
        "/version",
        "General",
        "Display current release version tag and build details of the AI agent",
        "/version"
    ),
    (
        "/clear",
        "Utility",
        "Clear all previous content from the active terminal display screen",
        "/clear"
    ),
    (
        "/terminate-server",
        "Server",
        "Send shutdown sequence to stop the background FastAPI daemon server",
        "/terminateServer"
    ),
    (
        "/exit",
        "Session",
        "Safely terminate the interactive AI agent session and close application",
        "/exit"
    )
]

SHORTCUTS_LIST : list[tuple[str, str]] = [
    ("CTRL/CMD + ALT + SHIFT + C", "Switch to Chat Message Interactive Mode"),
    ("CTRL/CMD + ALT + R", "Activate Voice / Audio Recognition System"),
    ("CTRL/CMD + ALT + S", "Stop Voice / Audio Recognition System"),
    ("CTRL/CMD + ALT + Q", "Immediate Force Stop AI Agent Session"),
    ("CTRL/CMD + SHIFT + L", "Clear Active Terminal Screen")
]

_commandsListDataFrame : pandas.DataFrame = pandas.DataFrame(
    data = COMMANDS_LIST, 
    columns = [
        "Command", 
        "Category", 
        "Description", 
        "Endpoint/Shortcut"
    ]
)

_shortCutListsDataFrame : pandas.DataFrame = pandas.DataFrame(
    data = SHORTCUTS_LIST, 
    columns = [
        "Shortcut Key", 
        "Action Description"
    ]
)

COMMANDS_LIST_TABLE : str = _commandsListDataFrame.to_markdown(
    index = False, 
    tablefmt = "grid",
    colalign = (
        "center",
        "center",
        "center"
    )
)
SHORTCUTS_LIST_TABLE : str = _shortCutListsDataFrame.to_markdown(
    index = False, 
    tablefmt = "grid",
    colalign = (
        "center",
        "center",
        "center"
    )
)
