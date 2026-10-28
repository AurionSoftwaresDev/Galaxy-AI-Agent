import google.api_core.exceptions as google_exceptions
import ollama
from fastapi import WebSocket, WebSocketDisconnect
from langchain.messages import AIMessageChunk, ToolMessage
from langchain_core.exceptions import OutputParserException
from mistralai.models.exceptions import MistralAPIException

from source.agent.agent import agent
from source.memory.agentMemory import (
    loadMessagesFromAgentMemory,
    saveMessagesInAgentMemory,
)
from source.utils.logger import logger


async def agentWebSocketController(webSocket : WebSocket) -> None:

    await webSocket.accept()

    logger.info("WebSocket Client Connected")

    try:
        
        while True:

            data = await webSocket.receive_json()

            userPrompt = data.get("content", "").strip()

            if not userPrompt:
                
                continue

            logger.info(f"User Prompt Recevied : { userPrompt }")

            oldHistory = loadMessagesFromAgentMemory()

            messages = [
                {
                    "role": message["role"],
                    "content": message["content"]
                }
                for message in oldHistory
            ]
            
            messages.append(
                {
                    "role": "user",
                    "content": userPrompt
                }
            )

            await webSocket.send_json(
                {
                    "type": "state_change",
                    "payload": {
                        "state": "thinking"
                    }
                }
            )

            finalAgentResponse = ""

            try:
                
                async for token, metadata in agent.astream({ "messages" : messages }, stream_mode = "messages"):

                    if isinstance(token, ToolMessage):

                        continue

                    if not isinstance(token, AIMessageChunk):

                        continue

                    content = token.content

                    if isinstance(content, str) and content:

                        finalAgentResponse += content

                        await webSocket.send_json({
                            "type": "text_delta",
                            "payload": {
                                "content": content
                            }
                        })

                    elif isinstance(content, list):

                        for block in content:

                            if not isinstance(block, dict):

                                continue

                            if block.get("type") != "text":

                                continue

                            text = block.get("text", "")

                            if not text:

                                continue

                            finalAgentResponse += text

                            await webSocket.send_json({
                                "type": "text_delta",
                                "payload": {
                                    "content": text
                                }
                            })

                saveMessagesInAgentMemory("user", userPrompt)
                saveMessagesInAgentMemory("assistant", finalAgentResponse) 

                await webSocket.send_json({
                    "type": "state_change",
                    "payload": {
                        "state": "completed"
                    }
                })

                await webSocket.send_json({
                    "type": "done",
                    "payload": {}
                })

                logger.info("AI Agent Streaming Response Sended To Frontend Completly")

            except (
                OutputParserException,
                google_exceptions.ResourceExhausted,
                google_exceptions.GoogleAPICallError,
                ollama.ResponseError,
                MistralAPIException,
                ConnectionError,
            ) as exception:

                logger.exception(f"AI Agent Streaming Failed. Exception : { exception }")

                await webSocket.send_json({
                    "type": "change_state",
                    "payload": {
                        "state": "error"
                    }
                })

                await webSocket.send_json({
                    "type": "error",
                    "payload": {
                        "message": "AI Agent Failed To Generate A Response."
                    }
                })
            
    except WebSocketDisconnect:

        logger.info("AI Agent Frontend To Backend WebSocket Client Disconnected")