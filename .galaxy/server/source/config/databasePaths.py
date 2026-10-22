from pathlib import Path

DATABASES_ROOT_PATH : Path = Path(__file__).resolve().parents[2] / "databases" 

MEMORY_STORE_PATH : Path = DATABASES_ROOT_PATH / "memory.db"
CHAT_STORE_PATH : Path = DATABASES_ROOT_PATH / "chats.db"