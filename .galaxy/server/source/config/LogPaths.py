from pathlib import Path

AGENT_LOGS_PATH : Path = (Path(__file__).resolve().parents[2] / "storage" / "logs" / "agentLogs" )
SERVER_LOGS_PATH : Path = (Path(__file__).resolve().parents[2] / "storage" / "logs" / "serverLogs" )