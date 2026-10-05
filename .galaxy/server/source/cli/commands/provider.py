import time
from rich.console import Console
from rich.table import Table
from rich.align import Align
from rich.live import Live
from source.agent.agent import agent, llmProviderModel
from source.utils.extractProvider import extractProvider
from source.provider.models import models
from source.provider.providers import providers

def provider() -> Align:

    currentProvider, currentModelName = extractProvider(agent = agent, llmProviderModel = llmProviderModel)

    maximumListLength = max(len(providers), len(models))

    activeProvidersSequence = [currentProvider] + [""] * (maximumListLength - 1)
    activeModelsSequence = [currentModelName] + [""] * (maximumListLength - 1)
    
    providersConfigurationGridTable: Table = Table(
        title = "[bold cyan]AI Agent LLM Providers and Models Configurations List[/bold cyan]", 
        padding = (0, 2, 0, 2), 
        collapse_padding = True,
        show_lines = True 
    )

    # Columns configuration definitions
    providersConfigurationGridTable.add_column(
        header = "Available Providers", 
        style = "green", 
        justify = "center"
    )

    providersConfigurationGridTable.add_column(
        header = "Available Models", 
        style = "blue", 
        justify = "center"
    )

    providersConfigurationGridTable.add_column(
        header = "Current Active Provider", 
        style = "magenta bold", 
        justify = "center"
    )

    providersConfigurationGridTable.add_column(
        header = "Current Active Model", 
        style = "yellow bold", 
        justify = "center"
    )

    terminalConsole: Console = Console()
    terminalConsole.print("")

    with Live(Align.center(providersConfigurationGridTable), console = terminalConsole, refresh_per_second = 10) as liveRenderer:
        
        for index in range(maximumListLength):
            time.sleep(0.3)  
            
            providerValue = providers[index] if index < len(providers) else ""
            modelValue = models[index] if index < len(models) else ""
            activeProviderValue = activeProvidersSequence[index] if index < len(activeProvidersSequence) else ""
            activeModelValue = activeModelsSequence[index] if index < len(activeModelsSequence) else ""

            providersConfigurationGridTable.add_row(
                providerValue,
                modelValue,
                activeProviderValue,
                activeModelValue
            )
            
            liveRenderer.update(Align.center(providersConfigurationGridTable))

    centeredAlignedProvidersGridTable = Align.center(providersConfigurationGridTable)

    return centeredAlignedProvidersGridTable
