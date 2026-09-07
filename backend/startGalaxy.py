import subprocess, sys
from pathlib import Path
from source.utils.logger import logger

ROOT_PATH = Path(__file__).resolve().parents[1]
BACKEND_PATH = ROOT_PATH / "backend"

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
