from source.utils.agentUtils.startupUtils.typingAnimation import typingTextOnTerminal
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
from source.utils.TerminalUI import TerminalUI
from rich.console import Console
from source.cli.cli import CLI

terminalUI : TerminalUI     =   TerminalUI()
console : Console           =   Console()
cli : CLI                   =   CLI()

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

        console.print(f"{"__" * 65}", style = "dim")

        console.print("User : ", end = "", style = "bold cyan")

        userPrompt = input()

        if userPrompt.strip() == "":

            continue

        break

    userCommands : list[str] = cli.extractCommandFromUserPrompt(userPrompt)

    if userCommands:

        cli.executeCLICommands(commands = userCommands)

        return True

    else:

        if userPrompt.strip() == "quit-agent":

            typingTextOnTerminal("[+] Agent Shutdown...", speed = 0.03)

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

        finalAgentResponse : str = ""

        try:

            terminalUI.start()
            terminalUI.thinking()

            async for token, metadata in agent.astream(
                {
                    "messages": messages
                },
                stream_mode="messages"
            ):

                if isinstance(token, ToolMessage):

                    logger.debug(f"TOOL MESSAGE : { token }")

                    terminalUI.toolCompleted()

                    continue

                if isinstance(token, AIMessageChunk):

                    logger.debug(f"AI Chunk Message : { token }")

                    logger.info(f"AI Response Metadata : { metadata } ")

                    toolCallChunks = token.tool_call_chunks

                    if toolCallChunks:

                        toolName = toolCallChunks[0].get("name")

                        if toolName:

                            terminalUI.toolStarted(toolName = toolName)

                        continue

                    text = extractTextFromContent(content = token.content)

                    if text:

                        terminalUI.printResponseChunk(
                            text = text
                        )

                        finalAgentResponse += text

            terminalUI.finishResponse()

        except Exception as Error:

            terminalUI.error()

            logger.exception(f"AI Agent Streaming Failed. Exception : { Error }")

            return False

        finally:

            terminalUI.finish()

            console.print(f"{"__" * 65}", style = "dim")

        print()

        saveMessagesInAgentMemory(role = "user", content = userPrompt)

        saveMessagesInAgentMemory(role = "assistant", content = finalAgentResponse)

        return True

    