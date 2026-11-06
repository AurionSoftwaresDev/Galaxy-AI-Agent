# REST & WebSocket API Reference

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../README.md) • [📂 Docs Directory](./)

The Galaxy AI Agent server exposes both HTTP REST endpoints and a real-time streaming WebSocket connection on port `8000` (or the port defined by `AGENT_SERVER_RUNNING_PORT`).

---

## 1. Base URL

- **HTTP**: `http://127.0.0.1:8000`
- **WebSocket**: `ws://127.0.0.1:8000`

---

## 2. Health & Status

### `GET /health`
Verifies that the FastAPI server and agent runtime are active.

- **Request Headers**: None
- **Response**: `200 OK`
```json
{
  "Status": 200,
  "Message": "AI Agent Server Health Is Good."
}
```

---

## 3. Agent Execution Endpoints

### `POST /generate`
Synchronous single-turn agent execution. Takes a user prompt, processes historical memory, executes relevant tools, and returns the response.

- **Path**: `/generate`
- **Method**: `POST`
- **Request Headers**: `Content-Type: application/json`
- **Request Body**:
```json
{
  "prompt": "What is the current time and system CPU status?"
}
```
- **Response**: `201 Created`
```json
{
  "status": 201,
  "response": "The current time is 2026-11-06 08:00:00 and CPU utilization is at 18%."
}
```
- **Error Response**: `400 Bad Request` (when prompt is empty)
```json
{
  "Status": 400,
  "Error": "Prompt Is Empty"
}
```

---

## 4. WebSocket Assistant Controller

### `WebSocket /ws/assistant`
Real-time streaming bidirectional connection. Powers the Flutter desktop client and streaming frontend integrations.

- **Path**: `/ws/assistant`
- **Protocol**: `ws://` or `wss://`

#### Incoming Client Frame (Send Prompt)
```json
{
  "prompt": "Inspect my system hardware and open the 3D globe map",
  "chat_id": 1
}
```

#### Outgoing Server Events (Streamed)
The server streams incremental token chunks and tool status events:

1. **Status / Tool Execution Event**:
```json
{
  "type": "tool_call",
  "tool": "inspect_user_system",
  "status": "executing"
}
```

2. **Token Chunk Event**:
```json
{
  "type": "token",
  "content": "Your system is running Linux with 8 CPU cores..."
}
```

3. **Stream Completion Event**:
```json
{
  "type": "done",
  "total_tokens": 142
}
```

---

## 5. Chat Session Management

Organized multi-session history management backed by `chats.db`.

### `POST /create`
Creates a new named chat conversation thread.

- **Request Body**:
```json
{
  "title": "Machine Learning Research"
}
```
- **Response**: `201 Created`
```json
{
  "Status": 201,
  "Message": "Chat Created Successfully",
  "chat_id": 2
}
```

### `GET /load-all`
Fetches a list of all saved chat conversations with IDs and timestamps.

- **Response**: `200 OK`
```json
{
  "Status": 200,
  "chats": [
    {
      "id": 1,
      "title": "Default Chat",
      "created_at": "2026-11-06 07:00:00",
      "updated_at": "2026-11-06 07:30:00"
    },
    {
      "id": 2,
      "title": "Machine Learning Research",
      "created_at": "2026-11-06 07:35:00",
      "updated_at": "2026-11-06 07:45:00"
    }
  ]
}
```

### `POST /load-chat`
Loads all historical messages for a specific chat ID.

- **Request Body**:
```json
{
  "chat_id": 2
}
```
- **Response**: `200 OK`
```json
{
  "Status": 200,
  "messages": [
    {
      "id": 1,
      "chat_id": 2,
      "role": "user",
      "content": "Can you summarize our recent codebase changes?",
      "created_at": "2026-11-06 07:35:10"
    },
    {
      "id": 2,
      "chat_id": 2,
      "role": "assistant",
      "content": "All 20 agent tools have been cataloged and tested.",
      "created_at": "2026-11-06 07:35:15"
    }
  ]
}
```

### `POST /save-message`
Manually persists a message into a designated chat session.

- **Request Body**:
```json
{
  "chat_id": 2,
  "role": "user",
  "content": "Calculate the distance between New York and London"
}
```

### `PATCH /update-title`
Updates the title of an existing chat session.

- **Request Body**:
```json
{
  "chat_id": 2,
  "new_title": "Geospatial Distance Calculations"
}
```

### `POST /delete`
Permanently deletes a chat session and all associated messages via cascading foreign keys.

- **Request Body**:
```json
{
  "chat_id": 2
}
```

---

## 6. Provider & Settings Endpoints

Endpoints for inspecting and hot-swapping LLM providers at runtime.

### `GET /avaliable-providers`
Returns a list of supported and configured LLM providers.

- **Response**: `200 OK`
```json
{
  "Status": 200,
  "providers": ["gemini", "ollama", "mistral"]
}
```

### `GET /avaliable-models`
Lists available model names for each provider.

- **Response**: `200 OK`
```json
{
  "Status": 200,
  "models": {
    "gemini": "gemini-3.6-flash",
    "ollama": "qwen3:8b",
    "mistral": "mistral-small-latest"
  }
}
```

### `PATCH /change-agent-provider`
Dynamically changes the active LLM provider without server restart.

- **Request Body**:
```json
{
  "provider": "ollama"
}
```
- **Response**: `200 OK`
```json
{
  "Success": true,
  "Message": "Successfully changed agent provider to ollama"
}
```

### `PATCH /change-agent-temperature`
Adjusts the sampling temperature for model responses.

- **Request Body**:
```json
{
  "temperature": 0.4
}
```
- **Response**: `200 OK`
```json
{
  "Success": true,
  "Message": "Successfully Updated The LLM Provider Temperature"
}
```

---

## 7. Server Lifecycle Termination

### `GET /disconnect`
Gracefully initiates shutdown of the FastAPI Uvicorn process.

- **Response**: `200 OK`
```json
{
  "Status": 200,
  "Message": "Server disconnect initiated."
}
```

---

## 🔗 Cross-Document Reference
- [Architecture Guide](architecture.md) — FastAPI ASGI and Uvicorn process structure
- [Configuration Guide](configuration.md) — Configuring server port and base URL
- [Tools Reference](tools.md) — Catalog of tools invoked through `/generate` and `/ws/assistant`
- [Map Tools Guide](map_tools.md) — Map control via agent tools
