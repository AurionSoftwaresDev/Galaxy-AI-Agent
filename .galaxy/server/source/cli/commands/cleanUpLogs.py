import time
import shutil, logging
import requests
from rich.console import Console
from rich.panel import Panel
from rich.console import Group
from rich.table import Table
from rich.align import Align
from rich.live import Live
from rich.progress_bar import ProgressBar
from source.utils.helper import startServer
from source.config.LogPaths import AGENT_LOGS_PATH, SERVER_LOGS_PATH
from source.utils.logger import logger, LOG_LOCK, configureLogger
from source.config.configs import getServerURL
from source.constants.animation.cli.commands.cleanupLogsAnimationData import CLEAN_UP_ANIMATION_QUEUE

def cleanUpLogs() -> None:
    
    serverTerminationEndpoint : str = "/server/disconnect"

    serverBaseURL : str = getServerURL()

    serverFullTargetURL : str = f"{ serverBaseURL }{ serverTerminationEndpoint }"

    shutil.rmtree(SERVER_LOGS_PATH)

    try:
    
        requests.get(url = serverFullTargetURL, timeout = 3.0)
    
    except requests.exceptions.ConnectionError:

        pass

    with LOG_LOCK:

        try:

            for handler in logger.handlers[:]:

                if isinstance(handler, logging.FileHandler):

                    logger.removeHandler(hdlr = handler)

                    handler.flush()

                    handler.close()

            lastError = None

            for attempt in range(5):

                try:

                    if AGENT_LOGS_PATH.exists():

                        shutil.rmtree(AGENT_LOGS_PATH)

                    lastError = None

                    break

                except PermissionError as error:

                    lastError = error

                    time.sleep(0.3)

            if lastError is not None:

                raise lastError

            AGENT_LOGS_PATH.mkdir(
                parents = True,
                exist_ok = True
            )

        finally:

            configureLogger()

    logger.info("Agent logs cleanup completed.")
    
    logger.info("Logs cleanup completed.")

    terminalConsole : Console = Console()

    logsWipeGridTable : Table = Table(
        show_header = False, 
        padding = (0, 1), 
        expand = True
    )

    totalAnimationFrames : int = len(CLEAN_UP_ANIMATION_QUEUE)

    progressIncrementSteps : float = 100 / totalAnimationFrames

    currentProgressTrackerPercentage : float = 0.0

    currentActiveProgressBar : ProgressBar = ProgressBar(
        total = 100, 
        completed = int(currentProgressTrackerPercentage), 
        width = 45
    )

    uiElementsGroupContainer : Group = Group(
        Align.center(
            renderable = currentActiveProgressBar
        ),
        "",
        logsWipeGridTable
    )

    logsCleaningStatusPanel = Panel(
        renderable = Align.center(renderable = uiElementsGroupContainer), 
        title = "[bold magenta]🧹 System Logs Maintenance (CLI)[/bold magenta]", 
        border_style = "magenta",
        width = 58
    )

    logsWipeGridTable.add_column(
        header = "Operation Phase", 
        justify = "left", 
        style = "cyan"
    )

    logsWipeGridTable.add_column(
        header = "Execution State", 
        justify = "right"
    )

    terminalConsole.print("")
    
    with Live(
        renderable = Align.center(renderable = logsCleaningStatusPanel), 
        console = terminalConsole, 
        refresh_per_second = 10
    ) as dashboardLiveRenderer:

        for maintenanceStepLabel, operationStatusText in CLEAN_UP_ANIMATION_QUEUE:

            time.sleep(0.45) 
            
            currentProgressTrackerPercentage += progressIncrementSteps
            
            logsWipeGridTable.add_row(maintenanceStepLabel, operationStatusText)
            
            updatedProgressBar = ProgressBar(
                total = 100, 
                completed = int(currentProgressTrackerPercentage), 
                width = 45
            )
            
            uiElementsGroupContainer.renderables[0] = Align.center(
                renderable = updatedProgressBar
            )
            
            dashboardLiveRenderer.update(
                renderable = Align.center(
                    renderable = logsCleaningStatusPanel
                )
            )

    startServer()
    
    terminalConsole.print("")