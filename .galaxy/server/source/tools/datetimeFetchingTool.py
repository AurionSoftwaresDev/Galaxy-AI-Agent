from source.tools.features.datetimeFetching import getCurrentDateTime
from langchain_core.tools import tool

@tool(
    name_or_callable = "fetch_datetime",
    description = """
        Get current date and time.

        Use this tool whenever the user asks for current date, curren time, day of the week,
        today's date, or the current date and time together.

        Do not guess the current date time from your own knowledge.
        Always use this tool when acuurate current date/time information is requied.

        The tool returns the current system date and time, timezone, and related time information from the system clock.
    """
)
def fetchCurrentDateTimeTool() -> str:
    
    return getCurrentDateTime()
    