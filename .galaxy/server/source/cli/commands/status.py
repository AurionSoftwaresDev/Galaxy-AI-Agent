import time
import requests
from rich.console import Console
from rich.table import Table
from rich.align import Align
from rich.live import Live
from rich.panel import Panel
from source.config.configs import getServerURL, getAgentServerRunningPort

def status() -> Table:

    terminalConsole : Console = Console()
    
    serverHealthCheckEndpoint : str = "/health"

    serverBaseURL : str = getServerURL()

    serverFullTargetURL : str = f"{ serverBaseURL }{ serverHealthCheckEndpoint }"

    serverRunningPort : int = getAgentServerRunningPort()
    
    serverStatusCode : int = 503

    serverResponseMessage : str = "Host Unreachable / Connection Refused"

    isServerActive : bool = False
    
    try:

        networkResponse : requests.Response = requests.get(url = serverFullTargetURL, timeout = 3.0)

        if networkResponse.status_code == 200:

            jsonPayloadData = networkResponse.json()

            if isinstance(jsonPayloadData, list) and len(jsonPayloadData) > 0:

                serverStatusCode = jsonPayloadData[0].get("Status", 200)

                serverResponseMessage = jsonPayloadData[0].get("Message", "Operational")

            elif isinstance(jsonPayloadData, dict):

                serverStatusCode = jsonPayloadData.get("Status", 200)

                serverResponseMessage = jsonPayloadData.get("Message", "Operational")

            else:

                serverStatusCode = 200

                serverResponseMessage = "Operational"

            isServerActive = True

    except Exception:
        
        isServerActive = False

    agentChatModuleProperties = {
        "Status" : "Running",
        "Modes" : {
            "Chat" : "Running",
            "Speak" : "Not Implemented"
        }
    }

    systemInfrastructureGridTable : Table = Table(
        show_header = True, 
        header_style = "bold magenta", 
        expand = True
    )

    backendGatewayHealthGridTable : Table = Table(
            show_header = True, 
            header_style = "bold yellow", 
            expand = True
    )

    agentRuntimeEngineGridTable : Table = Table(
            show_header = True, 
            header_style = "bold green", 
            expand = True
    )

    masterDashboardLayoutGrid : Table = Table.grid(
        expand = True, 
        padding = (
            1,
            2
        )
    )

    infrastructurePanelContainer = Panel(
            renderable = systemInfrastructureGridTable, 
            title = "[bold magenta]Network & Infrastructure[/bold magenta]", 
            border_style = "magenta", 
            expand = True
        )
    
    gatewayHealthPanelContainer = Panel(
        renderable = backendGatewayHealthGridTable, 
        title = "[bold yellow]API Gateway Health[/bold yellow]", 
        border_style = "yellow", 
        expand = True
    )
    
    agentEnginePanelContainer = Panel(
        renderable = Align.center(
            renderable = agentRuntimeEngineGridTable
        ), 
        title = "[bold green]Agent Engine Matrix[/bold green]", 
        border_style = "green", 
        width = 60
    )
    
    systemInfrastructureGridTable.add_column(
        header = "Parameter Metrics", 
        justify = "left", style = 
        "cyan"
    )
    
    systemInfrastructureGridTable.add_column(
        header = "Current Runtime Value", 
        justify = "right"
    )

    backendGatewayHealthGridTable.add_column(
        header = "Service Properties", 
        justify = "left", 
        style = "cyan"
    )

    backendGatewayHealthGridTable.add_column(
        header = "Diagnostics Log", 
        justify = "right"
    )

    agentRuntimeEngineGridTable.add_column(
        header = "Submodule Core", 
        justify = "center", 
        style = "cyan"
    )

    agentRuntimeEngineGridTable.add_column(
        header = "Implementation Flag", 
        justify = "center"
    )


    masterDashboardLayoutGrid.add_column(
        justify = "center", 
        ratio = 1
    )

    masterDashboardLayoutGrid.add_column(
        justify = "center", 
        ratio = 1
    )

    masterDashboardLayoutGrid.add_row(
        infrastructurePanelContainer, 
        gatewayHealthPanelContainer
    )

    masterDashboardLayoutGrid.add_row(
        Align.center(
            renderable = agentEnginePanelContainer
        ), 
        None
    )

    animationProcessingStepsQueue = [

        # System parameters configurations array mapping
        (
            "system", 
            "Target Base Server", 
            f"{serverBaseURL}"
        ),
        (
            "system", 
            "Active Daemon Port", 
            f"[bold white]{serverRunningPort}[/bold white]"
        ),
        (
            "system", 
            "Network Pipeline", 
            "[bold green]ONLINE ●[/bold green]" if isServerActive else "[bold red]OFFLINE ○[/bold red]"
        ),
        
        # Backend health analytics parameter mapping definitions 
        (
            "backend", 
            "API Gateway Status", 
            f"[bold green]{ serverStatusCode } OK[/bold green]" if isServerActive else f"[bold red]{ serverStatusCode } CRITICAL[/bold red]"
        ),
        (
            "backend", 
            "Response Message", 
            f"[italic white]{ serverResponseMessage }[/italic white]"
        ),
        
        # Core internal system status engine parameters structures mapping setup 
        (
            "agent", 
            "Agent Core Engine", 
            f"[bold green]{ agentChatModuleProperties['Status'] } ●[/bold green]"
        ),
        (
            "agent", ""
            "Chat Engine Interface", 
            f"[bold green]{ agentChatModuleProperties['Modes']['Chat'] } ●[/bold green]"
        ),
        (
            "agent", 
            "Audio Synthesis Engine", 
            f"[bold yellow]{ agentChatModuleProperties['Modes']['Speak'] }[/bold yellow]"
        )
    ]

    terminalConsole.print("")
    
    with Live(
        renderable = Align.center(
            renderable = masterDashboardLayoutGrid
        ), 
        console = terminalConsole, 
        refresh_per_second = 12
    ) as dashboardLiveRenderer:
        
        for classificationTag, metricLabel, compiledOutputString in animationProcessingStepsQueue:

            time.sleep(0.35)
            
            if classificationTag == "system":

                systemInfrastructureGridTable.add_row(metricLabel, compiledOutputString)

            elif classificationTag == "backend":

                backendGatewayHealthGridTable.add_row(metricLabel, compiledOutputString)
                
            elif classificationTag == "agent":

                agentRuntimeEngineGridTable.add_row(metricLabel, compiledOutputString)
                
            dashboardLiveRenderer.update(Align.center(masterDashboardLayoutGrid))
            
    terminalConsole.print("")

    return masterDashboardLayoutGrid
    