from pathlib import Path

AGENT_LOGS_PATH : Path = (Path(__file__).resolve().parents[2] / "logs" / "agentLogs" )
SERVER_LOGS_PATH : Path = (Path(__file__).resolve().parents[2] / "logs" / "serverLogs" )
SERVER_PID_STORE_FILE_NAME : str = "server.pid"
