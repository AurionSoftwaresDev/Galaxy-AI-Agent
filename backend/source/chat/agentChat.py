from source.agent.agent import agent
from source.chat.memory.agentMemory import (
    loadMessagesFromAgentMemory,
    saveMessagesInAgentMemory
)
from source.utils.logger import logger
from langchain.messages import (
    HumanMessage,
    AIMessageChunk,
    ToolMessage
)

def extractTextFromContent(content) -> str:

    """
    Extracts readable text from LangChain message content.

    LangChain can return AIMessageChunk.content as either:

        str
            "Hello, how are you?"

    or:

        list[dict]
            [
                {
                    "type": "text",
                    "text": "Hello, how are you?",
                    "index": 0
                }
            ]

    This function normalizes both formats into a plain string.
    """

    if isinstance(content, str):

        return content

    if isinstance(content, list):

        textParts: list[str] = []

        for block in content:

            if not isinstance(block, dict):

                continue

            if block.get("type") != "text":

                continue

            text = block.get("text", "")

            if isinstance(text, str) and text:

                textParts.append(text)


        return "".join(textParts)

    return ""

async def chat() -> bool:

    userPrompt : str

    while True:

        userPrompt = input("User : ")

        if userPrompt.strip() == "":

            print("[Exception] Your Prompt Is Empty. Please Write Right Prompt.")

            continue

        break

    if userPrompt.strip() == "quit-agent":

        print("[+] Agent Shutdown...")

        logger.info("User Shutdown The AI Agent")

        return False

    oldHistory: list[dict[str, str]] = (
        loadMessagesFromAgentMemory()
    )

    messages = [
        {
            "role": message["role"],
            "content": message["content"]
        }
        for message in oldHistory
    ]

    messages.append(
        HumanMessage(
            content=userPrompt
        )
    )

    finalAgentResponse: str = ""

    print("\nAI Agent : ",end = "", flush = True)

    try:

        async for token, metadata in agent.astream(
            {
                "messages": messages
            },
            stream_mode="messages"
        ):

            if isinstance(token, ToolMessage):

                continue

            if isinstance(token, AIMessageChunk):

                content = token.content

                logger.info(f"AI Response Metadata : { metadata } ")

                text = extractTextFromContent(content)

                if text:
            
                    print(text, end = "", flush = True)

                    finalAgentResponse += text

    except Exception as Error:

        logger.exception(f"AI Agent Streaming Failed. Exception : { Error }")

        return False

    print()

    saveMessagesInAgentMemory(role = "user",content = userPrompt)

    saveMessagesInAgentMemory(role ="assistant",content = finalAgentResponse)

    return True

