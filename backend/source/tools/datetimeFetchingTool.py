from source.tools.features.datetimeFetching import getCurrentDateTime
from langchain_core.tools import tool

@tool(
    description = (
        "Get the current date and time."
        "Use this tool whenever the user asks for the current time, "
        "or any time-sensitive date information."
    )
)
def fetchCurrentDateTimeTool():
    
    return getCurrentDateTime()
    