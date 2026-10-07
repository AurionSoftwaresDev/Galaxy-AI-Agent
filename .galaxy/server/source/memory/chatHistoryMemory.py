import sqlite3

from source.config.databasePaths import CHAT_STORE_PATH
from source.utils.logger import logger

def initializeChatAgentMemory() -> None:

    logger.info("Initializing Agent Chat History")


    CHAT_STORE_PATH.parent.mkdir(
            parents = True,
            exist_ok = True
    )

    if not CHAT_STORE_PATH.exists():

        logger.info(f"Creating AI Agent Memory File At: { CHAT_STORE_PATH }")
   

        with sqlite3.connect(database = CHAT_STORE_PATH) as connection:

            connection.execute("""
                CREATE TABLE IF NOT EXISTS chats (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL UNIQUE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
                )
            """)

            connection.execute("""
                CREATE TABLE IF NOT EXISTS messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    chat_id INTEGER NOT NULL,
                    role TEXT NOT NULL,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

                    FOREIGN KEY (chat_id)
                        REFERENCES chats(id)
                        ON DELETE CASCADE
                )
            """)

            connection.execute("""
                CREATE INDEX IF NOT EXISTS idx_messages_chat_id
                ON messages(chat_id)
            """)

            connection.commit()

        logger.info("Agent Chat History Initialized.")

def createNewChat(title : str) -> int | None:

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

        cursor = connection.execute("""
            INSERT INTO chats (title)
            VALUES (?)
        """, (title,))

        connection.commit()

        chatId : int | None = cursor.lastrowid

    logger.info(f"Created New Chat : { chatId }")

    return chatId

def saveMessage(chatId : int, role : str, content : str) -> None:

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

        connection.execute("""
            INSERT INTO messages (
                chat_id,
                role,
                content
            )
            VALUES (?, ?, ?)
        """, (
            chatId,
            role,
            content
        ))

        connection.execute("""
            UPDATE chats
            SET updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        """, (chatId,))

        connection.commit()

    logger.info(f"Saved Message In Chat: {chatId}")

def loadChats() -> list[dict]:

    with sqlite3.connect(database = CHAT_STORE_PATH) as connection:

        rows = connection.execute("""
            SELECT id, title, created_at, updated_at
            FROM chats
            ORDER BY updated_at DESC
        """).fetchall()

    return [
        {
            "id" : chatId,
            "title" : title,
            "created_at" : createdAt,
            "updated_at" : updatedAt
        }
        for chatId, title, createdAt, updatedAt in rows
    ]

def updateChatTitle(chatId : int, title : str) -> None:

    with sqlite3.connect(database = CHAT_STORE_PATH) as connection:

        connection.execute("""
            UPDATE chats
            SET title = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        """, (
            title,
            chatId
        ))

        connection.commit()

def deleteChat(chatId : int | None = None, title : str | None = None) -> bool:

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

        connection.execute("PRAGMA foreign_keys = ON")

        if chatId is not None:

            cursor = connection.execute("""
                DELETE FROM chats
                WHERE id = ?
            """, (chatId,))

            if cursor.rowcount == 0 and title is not None:

                cursor = connection.execute("""
                    DELETE FROM chats
                    WHERE title = ?
                """, (title,))

        elif title is not None:

            cursor = connection.execute("""
                DELETE FROM chats
                WHERE title = ?
            """, (title,))

        else:

            return False

        connection.commit()

    if cursor.rowcount > 0:

        logger.info(f"Deleted Chat : { chatId or title }")

        return True

    logger.warning("Chat Not Found.")

    return False

def validateChatMemory() -> None:

    if not CHAT_STORE_PATH.exists():

        logger.info("Chat Memory Does Not Exist. Creating New Chat Memory.")

        initializeChatAgentMemory()

        return

    try:

        with sqlite3.connect(database = CHAT_STORE_PATH) as connection:

            connection.execute("""
                SELECT id FROM chats LIMIT 1
            """)

            connection.execute("""
                SELECT id FROM messages LIMIT 1
            """)

        logger.info("Chat Memory Validated Successfully.")

    except sqlite3.Error:

        logger.warning("Chat Memory Is Invalid. Removing And Recreating...")

        CHAT_STORE_PATH.unlink(missing_ok = True)

        initializeChatAgentMemory()

def loadChat(chatId : int = None, title : str = None) -> dict[str, str | int | list[dict[str, str | int]]] | None:

    with sqlite3.connect(database = CHAT_STORE_PATH) as connection:
    
        if chatId is not None:

            chat = connection.execute("""
                SELECT id, title, created_at, updated_at
                FROM chats
                WHERE id = ?
            """, (chatId,)).fetchone()

            if chat is None and title is not None:

                chat = connection.execute("""
                    SELECT id, title, created_at, updated_at
                    FROM chats
                    WHERE title = ?
                """, (title,)).fetchone()

        elif title is not None:

            chat = connection.execute("""
                SELECT id, title, created_at, updated_at
                FROM chats
                WHERE title = ?
            """, (title,)).fetchone()

        else:

            logger.warning("Unable To Load Chat: No Chat ID Or Title Provided.")

            return None

        if chat is None:

            logger.warning(f"Chat Not Found : { chatId or title }")

            return None

        messages = connection.execute("""
            SELECT id, role, content, created_at
            FROM messages
            WHERE chat_id = ?
            ORDER BY id ASC
        """, (chat[0],)).fetchall()

    result : dict[str, str | int | list[dict[str, str | int]]] | None = {
        "id": chat[0],
        "title": chat[1],
        "created_at": chat[2],
        "updated_at": chat[3],
        "messages": [
            {
                "id": messageId,
                "role": role,
                "content": content,
                "created_at": createdAt
            }
            for (
                messageId,
                role,
                content,
                createdAt
            ) in messages
        ]
    }

    logger.info(
        f"Loaded Chat: {result['id']} | "
        f"Title: {result['title']} | "
        f"Messages: {len(result['messages'])}"
    )

    return result    