import subprocess, sys, os
from pathlib import Path
from source.utils.logger import logger
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

ROOT_PATH = Path(__file__).resolve().parents[1]
BACKEND_PATH = ROOT_PATH / "backend"

def getArguments():

    arguments = {
        "server": False,
        "agent": False
    }

    if "-h" in sys.argv[1:] or "--help" in sys.argv[1:]:

        print(helpingMenu)

        sys.exit(0)

    for argument in sys.argv[:1]:

        if "=" not in argument:

            continue

        key, value = argument.split("=", 1)

        if key in arguments:

            arguments[key] = value.lower() == "true"

    if len(sys.argv) == 1:

        arguments["server"] = True
        arguments["agent"] = True

    return arguments

if len(sys.argv) > 1:

    initializeAgentMemory()

    arguments = getArguments()

    if arguments["server"]:

        logger.info("Starting Agent Server And Routers...")

        serverProcess = subprocess.Popen(
            [
                "cmd",
                "/k",
                sys.executable,
                "-m",
                "uvicorn",
                "server:agentServer",
                "--reload",
                "--port",
                "8000"
            ],
            cwd = BACKEND_PATH
        )

    if arguments["agent"]:

        logger.info("Server Started All Routers/Routes Set-up Successfully")
        agentProcess = subprocess.Popen(
            [
                "cmd",
                "/k",
                sys.executable,
                "main.py"
            ],
            cwd = BACKEND_PATH
        )

else:

    logger.exception("AI Agent Arguments Not Found What You Start? Start OR Agent OR AGENT + Server?")

    print(helpingMenu)

    os._exit(404)