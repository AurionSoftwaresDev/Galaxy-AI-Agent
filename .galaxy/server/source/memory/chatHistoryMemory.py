import sqlite3

from source.config.databasePaths import CHAT_STORE_PATH
from source.utils.logger import logger


def initializeChatHistory() -> None:

    logger.info("Initializing Agent Chat History")

    CHAT_STORE_PATH.parent.mkdir(
        parents = True,
        exist_ok = True
    )

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

        connection.execute("""
            CREATE TABLE IF NOT EXISTS chats (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
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

    logger.info(f"Created New Chat: {chatId}")

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


def loadMessages(chatId : int) -> list[dict[str, str]]:

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

        rows = connection.execute("""
            SELECT id, role, content, created_at
            FROM messages
            WHERE chat_id = ?
            ORDER BY id ASC
        """, (chatId,)).fetchall()

    return [
        {
            "id": messageId,
            "role": role,
            "content": content,
            "created_at": createdAt
        }
        for messageId, role, content, createdAt in rows
    ]


def loadChats() -> list[dict]:

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

        rows = connection.execute("""
            SELECT id, title, created_at, updated_at
            FROM chats
            ORDER BY updated_at DESC
        """).fetchall()

    return [
        {
            "id": chatId,
            "title": title,
            "created_at": createdAt,
            "updated_at": updatedAt
        }
        for chatId, title, createdAt, updatedAt in rows
    ]


def updateChatTitle(
    chatId: int,
    title: str
) -> None:

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

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


def deleteChat(chatId: int) -> None:

    with sqlite3.connect(CHAT_STORE_PATH) as connection:

        connection.execute("""
            DELETE FROM chats
            WHERE id = ?
        """, (chatId,))

        connection.commit()

    logger.info(f"Deleted Chat : {chatId}")