import sqlite3
from source.utils.logger import logger
from source.config.databasePaths import MEMORY_STORE_PATH


def checkMemoryIsNoCorrupted(connection: sqlite3.Connection) -> bool:

    if not MEMORY_STORE_PATH.exists():

        logger.info("AI Agent Memory Is Not Initialized.")

        return False

    cursor : sqlite3.Cursor = connection.cursor()

    cursor.execute("""
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
        AND name = 'messages'
    """)

    table = cursor.fetchone()

    if table is None:

        logger.warning("AI Agent Memory Exists But 'messages' Table Is Missing.")

        logger.info("Creating Missing AI Agent Memory 'messages' Table...")

        cursor.execute("""
            CREATE TABLE messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        connection.commit()

        logger.info("Fixed AI Agent Memory Dependency.")

        return True

    logger.info("AI Agent Memory Is Clean And Successfully Validated.")

    return True


def initializeAgentMemory() -> None:

    MEMORY_STORE_PATH.parent.mkdir(
        parents = True,
        exist_ok = True
    )

    if not MEMORY_STORE_PATH.exists():

        logger.info(f"Creating AI Agent Memory File At: {MEMORY_STORE_PATH}")

        with sqlite3.connect(MEMORY_STORE_PATH) as connection:

            connection.execute("""
                CREATE TABLE messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    role TEXT NOT NULL,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)

            connection.commit()

        logger.info("AI Agent Memory Created Successfully.")

        return

    with sqlite3.connect(MEMORY_STORE_PATH) as connection:

        checkMemoryIsNoCorrupted(connection)


def loadMessagesFromAgentMemory() -> list[dict[str, str]]:

    if not MEMORY_STORE_PATH.exists():

        initializeAgentMemory()

    logger.info("Loading AI Agent Memory...")

    with sqlite3.connect(MEMORY_STORE_PATH) as memory:

        rows = memory.execute("""
            SELECT role, content
            FROM messages
            ORDER BY id ASC
        """).fetchall()

    messages : list[dict[str, str]] = [
        {
            "role": role,
            "content": content
        }
        for role, content in rows
    ]

    logger.info("AI Agent Memory Loaded.")

    return messages


def saveMessagesInAgentMemory(role : str, content : str) -> None:

    if not MEMORY_STORE_PATH.exists():

        initializeAgentMemory()

    if role == "user":

        logger.info("AI Agent Saving User Message In Galaxy AI Agent Memory")

    else:

        logger.info("AI Agent Memory Saving...")

    with sqlite3.connect(MEMORY_STORE_PATH) as memory:

        memory.execute("""
            INSERT INTO messages (
                role,
                content
            )
            VALUES (?, ?)
        """, (
            role,
            content
        ))

        memory.commit()

    logger.info("AI Agent Memory Saved.")