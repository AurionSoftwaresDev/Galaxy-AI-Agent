from langchain_core.tools import tool
import webbrowser
from source.models.openBrowserModel import OpenBrowserModel
from source.utils.logger import logger

@tool(
        name_or_callable = "open_browser",
        args_schema = OpenBrowserModel,
        description = """
            Open a website in the user's web browser.

            Use this tool when the user asks to open, visit, or go to a website or URL.
            Do not use this tool when the user only wants information about a website Without asking to open it.
        """,
)
def openBrowserTool(url : str):

    logger.info("AI Agent Called open_browser Tool...")

    webbrowser.open(url)

    logger.info(f"AI Agent Opening In Browser : { url }")