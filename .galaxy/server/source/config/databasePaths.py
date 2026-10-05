from pathlib import Path

MEMORY_STORE_PATH : Path = Path(__file__).resolve().parents[2] / "databases" / "memory" / "memory.db"
CHAT_STORE_PATH : Path = Path(__file__).resolve().parents[2] / "databases" / "memory" / "chats.db"
