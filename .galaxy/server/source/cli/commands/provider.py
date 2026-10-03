from rich.console import Console
from rich.table import Table
from source.agent.agent import agent, llmProviderModel
from source.utils.extractProvider import extractProvider
from source.provider.models import models
from source.provider.providers import providers

def provider():

    provider, modelName = extractProvider(agent = agent, llmProviderModel = llmProviderModel)

    maxLength = max(len(providers), len(models))

    activeProviderList = [provider] + [""] * (maxLength - 1)
    activeModelList = [modelName] + [""] * (maxLength - 1)
    
    gridTable : Table = Table(
        title = "[bold cyan]AI Agent LLM Providers and Models Configurations List[/bold cyan]", 
        padding = (0, 2, 0, 2), 
        collapse_padding = True,
        show_lines = True 
    )

    gridTable.add_column(
        header = "Available Providers", 
        style = "green", 
        justify = "center"
    )

    gridTable.add_column(
        header = "Available Models", 
        style = "blue", 
        justify = "center"
    )

    gridTable.add_column(
        header = "Current Active Provider", 
        style = "magenta bold", 
        justify = "center"
    )

    gridTable.add_column(
        header = "Current Active Model", 
        style = "yellow bold", 
        justify = "center"
    )

    for i in range(maxLength):

        gridTable.add_row(
            providers[i],
            models[i],
            activeProviderList[i],
            activeModelList[i]
        )

    console : Console = Console()

    console.print("")

    console.print(gridTable)
