import multiprocessing, uvicorn
import shlex
import shutil
import subprocess
import sys
from pathlib import Path
from source.utils.logger import logger
from source.utils.helper import validateUserEnviromentVariables
from source.chat.memory.agentMemory import initializeAgentMemory

helpingMenu = """
        Galaxy AI Launcher
        ==================

        Usage:
            python startGalaxy.py
            python startGalaxy.py server=true
            python startGalaxy.py agent=true
            python startGalaxy.py server=true agent=true
            python startGalaxy.py server=false agent=false

        Options:
            server=true     Start the FastAPI server.
            server=false    Do not start the FastAPI server.

            agent=true      Start the interactive AI agent.
            agent=false     Do not start the interactive AI agent.

        Behavior:
            No arguments
                Starts both the server and agent.

            Only server/agent arguments
                Starts only the components enabled with true.

            -h, --help
                Show this usage menu.

        Examples:
            python startGalaxy.py
                Start server + agent.

            python startGalaxy.py server=true
                Start only the server.

            python startGalaxy.py agent=true
                Start only the agent.

            python startGalaxy.py server=true agent=true
                Start both.

            python startGalaxy.py server=false
                Start only the agent.

            python startGalaxy.py agent=false
                Start only the server.
"""


ROOT_PATH = Path(__file__).resolve().parent
BACKEND_PATH = ROOT_PATH

def getArguments():

    arguments = {
        "server": False,
        "agent": False
    }

    if "-h" in sys.argv[1:] or "--help" in sys.argv[1:]:

        print(helpingMenu)

        sys.exit(0)

    for argument in sys.argv[1:]:

        if "=" not in argument:

            continue

        key, value = argument.split("=", 1)

        if key in arguments:

            arguments[key] = value.lower() == "true"

    if len(sys.argv) == 1:

        arguments["server"] = True
        arguments["agent"] = True

    return arguments

def startWindowsTerminal(command, title):

    """
    Opens the command inside a new CMD window
    with a custom window title.
    """

    command = [str(part) for part in command]

    subprocess.Popen(
        [
            "cmd.exe",
            "/c",
            "start",
            title,
            "cmd.exe",
            "/k",
            f"title {title} && " +
            subprocess.list2cmdline(command)
        ],
        cwd=BACKEND_PATH
    )

def startLinuxTerminal(command, title):

    command = [str(part) for part in command]

    command_string = " ".join(
        shlex.quote(part)
        for part in command
    )

    shell_command = (
        f"cd {shlex.quote(str(BACKEND_PATH))} && "
        f"printf '\\033]0;{title}\\007' && "
        f"{command_string}; "
        f"echo; "
        f"echo 'Process finished. Press Enter to close...'; "
        f"read"
    )

    # GNOME Terminal
    if shutil.which("gnome-terminal"):

        subprocess.Popen(
            [
                "gnome-terminal",
                "--title",
                title,
                "--",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # KDE Konsole
    if shutil.which("konsole"):

        subprocess.Popen(
            [
                "konsole",
                "--title",
                title,
                "-e",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # XFCE Terminal
    if shutil.which("xfce4-terminal"):

        subprocess.Popen(
            [
                "xfce4-terminal",
                "--title",
                title,
                "--",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # Kitty
    if shutil.which("kitty"):

        subprocess.Popen(
            [
                "kitty",
                "--title",
                title,
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # Alacritty
    if shutil.which("alacritty"):

        subprocess.Popen(
            [
                "alacritty",
                "--title",
                title,
                "-e",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    # xterm
    if shutil.which("xterm"):

        subprocess.Popen(
            [
                "xterm",
                "-T",
                title,
                "-e",
                "bash",
                "-c",
                shell_command
            ]
        )

        return

    logger.exception("No Supported Linux Terminal Emulator Was Found")

    raise RuntimeError("No Supported Linux Terminal Emulator Was Found.")


def startNewTerminal(command, title):

    if sys.platform.startswith("win"):

        startWindowsTerminal(
            command,
            title
        )

        return

    if sys.platform.startswith("linux"):

        startLinuxTerminal(
            command,
            title
        )

        return

    logger.exception("Unsupprted Operating System to Run AI Agent")

    raise OSError(f"Unsupported Operating System : { sys.platform } ")

def runAgentServer() -> None:

    uvicorn.run("main:app", host="127.0.0.1", port=8000, log_level="info")

def mainHandler():

    arguments = getArguments()

    logger.info("Initializing Agent Memory...")

    initializeAgentMemory()

    logger.info("Memory Initialized Successfully")

    if arguments["server"]:

        logger.info("Starting Agent Server And Routers...")

        agentBackendServerProcess = multiprocessing.Process(target = runAgentServer, daemon = True)

        agentBackendServerProcess.start()
        
        logger.info("Uvicorn Galaxy AI Agent Server Started In The Background")


    if arguments["agent"]:

        logger.info("Starting Interactive AI Agent...")

        startNewTerminal(
            [
                sys.executable,
                "main.py"
            ],
            "Galaxy AI - Agent"
        )

if __name__ == "__main__":

    validateUserEnviromentVariables()

    mainHandler()