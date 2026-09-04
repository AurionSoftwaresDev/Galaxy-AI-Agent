import sqlite3
from pathlib import Path
from source.utils.logger import logger

MEMORY_STORE_PATH : Path = Path(__file__).resolve().parents[3] / "storage" / "memory" / "memory.db"

def checkMemoryIsNoCorrupted(connection : sqlite3.Connection) -> bool:
    
    if MEMORY_STORE_PATH.exists():
    
        cursor = connection.cursor()
        
        cursor.execute("""
            SELECT name 
            FROM sqlite_master                
            WHERE type = 'table'
            AND name = 'messages'
        """)
        
        table = cursor.fetchone()
        
        if table is None:
            
            logger.warning("AI Agent Memory Is Exists But 'messages' Data Is Missing.")
            logger.info("Creating AI Agent Missing Memory'messages' Data Is Missing Table Dependency...")

            cursor.execute("""
                CREATE TABLE messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    role TEXT NOT NULL,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )          
            """)
            
            connection.commit()
            
            logger.info("Fixed Memory Dependency.")
            
            return True
        
        else:
            
            logger.info("AI Agent Memory Is Clean And Fine Successfully Validated.")
            
            return True
    else:
        
        logger.info("AI Agent Memory Is Not Initialize")
        
        return False

def initializeAgentMemory() -> None:

    MEMORY_STORE_PATH.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    if not MEMORY_STORE_PATH.exists():

        logger.info(
            f"Creating AI Agent Memory File At: {MEMORY_STORE_PATH}"
        )

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
    
def loadMessagesFromAgentMemory() -> list[dict]:
    
    connection : sqlite3.Connection = sqlite3.connect(MEMORY_STORE_PATH)
    
    if checkMemoryIsNoCorrupted(connection) == False:
        
        initializeAgentMemory()
        
    logger.info("Load Memory...")
    
    with sqlite3.connect(MEMORY_STORE_PATH) as dataStoredMemoryDatabase:
        
        rows = dataStoredMemoryDatabase.execute("""
                                                
                    SELECT role, content FROM messages
                    ORDER BY id ASC
                    
        """).fetchall()
        
        return [
            {
                "role": role,
                "content": content
            }
            for role, content in rows
        ]
        
    logger.info("AI Agent Memory Loaded")
        
def saveMessagesInAgentMemory(role : str, content : str) -> None:
    
    connection : sqlite3.Connection = sqlite3.connect(MEMORY_STORE_PATH)
    
    if checkMemoryIsNoCorrupted(connection) == False:
        
        initializeAgentMemory()
    
    logger.info("AI Agent Memory Saving....")
    
    with sqlite3.connect(MEMORY_STORE_PATH) as memory:
        
        memory.execute("""
            
            INSERT INTO messages (role, content) VALUES (?, ?)
                           
        """, (role, content))
        
        memory.commit()
    
    logger.info("AI Agent Memory Saved")
        