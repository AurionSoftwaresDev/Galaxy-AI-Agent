import webbrowser

from langchain_core.tools import StructuredTool, tool

from source.models.toolModels.openBrowserModel import OpenBrowserModel
from source.tools.features.browser.browser import start_browser, stop_browser
from source.utils.logger import logger


@tool(
        name_or_callable = "open_default_browser",
        args_schema = OpenBrowserModel,
        description = """
            Open a website/browser if URL is None or URL using the user's default system browser.

            This tool launches the browser configured as the default web browser on the user's operating system. It relies on the operating system's browser association to determine which browser application should handle the requested URL.

            Primary Responsibilities:
            - Open the requested URL in the user's default browser.
            - Allow the operating system to select the appropriate browser application.
            - Support normal website navigation through the user's existing browser environment.
            - Use the user's configured browser rather than launching the custom Galaxy AI Agent Browser.

            Usage Guidelines:
            - Use this tool when the user explicitly requests opening a website in their default browser.
            - Use it for ordinary browsing tasks when the user has not requested the custom Galaxy AI Agent Browser and no advanced agent-specific browser control is required.
            - Pass the requested URL accurately without unnecessarily modifying its destination.
            - Do not substitute the custom Galaxy AI Agent Browser for the system browser.

            Important:
            This tool only launches the requested URL in the default browser. It does not provide direct control over browser tabs, page content, JavaScript execution, or other browser interactions unless separately supported by the underlying system.
        """
)
def openDefaultBrowserTool(url : str):

    logger.info("AI Agent Called open_browser Tool...")

    webbrowser.open(url)

    logger.info(f"AI Agent Opening In Browser : { url }")

open_own_galaxy_custom_browser : StructuredTool = StructuredTool.from_function(
    func = start_browser,
    name = "open_own_galaxy_custom_browser",
    description = """
        Launch the custom Galaxy AI Agent Browser, a dedicated Python-based desktop browser developed specifically for Galaxy AI Agent.

        This browser provides an agent-integrated browsing environment with greater control over browser behavior, application lifecycle, and custom browser functionality compared to launching the user's default system browser.

        Primary Responsibilities:
        - Start the Galaxy AI Agent Browser application.
        - Open the requested URL or initialize the browser with the supplied starting URLs, if supported.
        - Provide the agent with access to its dedicated browser environment.
        - Enable agent-oriented browsing workflows through the custom browser's available control interfaces.
        - Keep the custom browser independent of the user's default browser.

        Usage Guidelines:
        - Use this tool when the user explicitly requests Galaxy AI Agent Browser.
        - Prefer this browser when a task requires custom browser integration or browser-specific automation capabilities.
        - Use it when the agent needs to interact with the browser through its dedicated control system.
        - Avoid launching unnecessary duplicate browser instances.
        - Do not use this tool to open the user's default system browser.

        Important:
        Launching the browser does not guarantee that a requested website has loaded successfully. Only report successful navigation when confirmed by the underlying operation.
    """
)

close_own_galaxy_custom_browser : StructuredTool = StructuredTool.from_function(
    func = stop_browser,
    name = "close_own_galaxy_custom_browser",
    description = """
        Close the currently running Galaxy AI Agent Browser application.

        This tool specifically manages the lifecycle of the custom Python-based browser developed for Galaxy AI Agent. It is intended to terminate the dedicated Galaxy browser application without intentionally affecting other browser applications installed on the user's system.

        Primary Responsibilities:
        - Request the Galaxy AI Agent Browser application to shut down.
        - Terminate its active GUI session through the application's supported shutdown mechanism.
        - Release the browser application's resources when it exits.
        - Keep the user's default browser and other unrelated applications unaffected.

        Usage Guidelines:
        - Use this tool when the user requests closing, stopping, or terminating Galaxy AI Agent Browser.
        - Use it when the agent needs to shut down its dedicated browser after completing a browsing task.
        - Do not use this tool to close Chrome, Edge, Firefox, or any other default system browser.
        - Do not attempt to terminate unrelated browser processes.
        - If the custom browser is already closed, report its current state accurately.

        Important:
        This tool only targets Galaxy AI Agent Browser. It must never be interpreted as a general-purpose system browser termination tool.
    """
)
