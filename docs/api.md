# REST & WebSocket API Reference

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../../README.md) • [📖 Galaxy Overview](../README.md) • [📂 Docs Directory](./)

The Galaxy AI Agent server exposes both HTTP REST endpoints and a real-time WebSocket connection on port `8000` (or `AGENT_SERVER_RUNNING_PORT`).

---

## 1. Base URL

- **HTTP**: `http://127.0.0.1:8000`
- **WebSocket**: `ws://127.0.0.1:8000`

---

## 2. Health & Status

### `GET /health`
Checks whether the agent server is running and healthy.

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

### `POST /agent/generate`
Synchronous single-turn agent completion. Executes the agent against previous memory and returns the complete assistant response.

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
  "response": "The current time is 2026-10-08 14:30:00 and CPU utilization is at 18%."
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

### `WebSocket /ws/assistant`
Real-time bi-directional streaming endpoint. Emits token deltas and lifecycle events as the agent generates text.

#### Client to Server Message
```json
{
  "content": "List the files in the current folder"
}
```

#### Server to Client Stream Events

1. **State Change Event (Thinking)**:
```json
{
  "type": "state_change",
  "payload": {
    "state": "thinking"
  }
}
```

2. **Text Delta Event (Repeated for each token)**:
```json
{
  "type": "text_delta",
  "payload": {
    "content": "Here "
  }
}
```

3. **State Change Event (Completed)**:
```json
{
  "type": "state_change",
  "payload": {
    "state": "completed"
  }
}
```

4. **Done Event**:
```json
{
  "type": "done",
  "payload": {}
}
```

5. **Error Event**:
```json
{
  "type": "error",
  "payload": {
    "message": "AI Agent Failed To Generate A Response."
  }
}
```

---

## 4. Settings & Model Management

*Note: In the implementation, the route prefix paths are defined with the exact spelling `/settings/avaliable-*`.*

### `GET /settings/avaliable-providers`
Returns all supported LLM providers.

- **Response**: `200 OK`
```json
{
  "Status": 200,
  "Providers": ["gemini", "ollama", "mistral"]
}
```

---

### `GET /settings/avaliable-models`
Returns the list of configured models for each provider.

- **Response**: `200 OK`
```json
{
  "Status": 200,
  "Models": ["gemini-3.6-flash", "qwen3:8b", "mistral-small-latest"]
}
```

---

### `PATCH /settings/change-agent-provider`
Switches the active LLM provider and reinitializes the agent runtime.

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
  "Old Provider": "gemini",
  "New Provider": "ollama"
}
```
- **Error Response**: `404 Not Found` (unsupported provider)
```json
{
  "Success": false,
  "Error": "Your 'openai' Provider Does Not Supported",
  "Supported Providers": ["gemini", "ollama", "mistral"]
}
```

---

### `PATCH /settings/change-agent-temperature`
Updates the temperature parameter of the active LLM provider.

- **Request Body**:
```json
{
  "temperature": 0.4
}
```
- **Response**: `201 Created`
```json
{
  "Old Temperature": 0.2,
  "New Temperature": 0.4
}
```

---

## 5. Multi-Session Chat History Management (`/chats`)

These endpoints interact with `chats.db`.

### `GET /chats/load-all`
Fetches a list of all saved chat sessions.

- **Response**: `200 OK`
```json
[
  {
    "id": 1,
    "title": "Project Setup",
    "created_at": "2026-10-08 10:00:00",
    "updated_at": "2026-10-08 10:15:00"
  }
]
```

---

### `POST /chats/create`
Creates a new conversation session. Automatically increments titles (e.g. `Untitled Chat 1`) if collisions occur.

- **Request Body**:
```json
{
  "title": "Backend Optimization"
}
```
- **Response**: `201 Created`
```json
{
  "Status": 201,
  "Message": "Chat Successfully Created",
  "Chat Id": 2,
  "Chat Title": "Backend Optimization"
}
```

---

### `POST /chats/load-chat`
Retrieves a specific chat session and all associated messages.

- **Request Body**:
```json
{
  "chatId": 2,
  "title": null
}
```
- **Response**: `200 OK`
```json
{
  "Status": 200,
  "Message": "Successfully Fetchd Chat!",
  "Chat History": {
    "id": 2,
    "title": "Backend Optimization",
    "messages": [
      {
        "id": 1,
        "chat_id": 2,
        "role": "user",
        "content": "How can we optimize SQLite?",
        "created_at": "2026-10-08 10:02:00"
      }
    ]
  }
}
```

---

### `POST /chats/save-message`
Appends a message to an existing chat session.

- **Request Body**:
```json
{
  "chatId": 2,
  "role": "user",
  "content": "How do indexes help query speed?"
}
```
- **Response**: `202 Accepted`
```json
{
  "Status": 202,
  "Your Role": "user",
  "Your Message": "How do indexes help query speed?",
  "Message": "Successfully Message Saved!"
}
```

---

### `PATCH /chats/update-title`
Renames an existing chat session.

- **Request Body**:
```json
{
  "chatId": 2,
  "title": "Database Tuning"
}
```
- **Response**: `202 Accepted`
```json
{
  "Status": 202,
  "Old Title": "Backend Optimization",
  "New Title": "Database Tuning",
  "Message": "Successfully Chat Renamed Saved!"
}
```

---

### `POST /chats/delete`
Deletes a chat session and cascades deletion to all associated messages.

- **Request Body**:
```json
{
  "chatId": 2
}
```
- **Response**: `200 OK`
```json
{
  "Status": 200,
  "Message": "Successfully Chat Deleted!",
  "Chat ID": 2
}
```

---

## 6. Server Lifecycle Management

### `GET /server/disconnect`
Signals the server to cleanly terminate itself. It locates the process PID via `source/logs/server.pid` or matches the listening port, terminates the process tree, and exits.

- **Response**: `204 No Content`

---

## 📚 Central Documentation Hub

All technical documentation is connected to and managed centrally from the root [**README.md**](../../README.md).

| Document | Focus & Topic | Link |
|---|---|:---:|
| **Central Hub** | Root README, Master Index & One-Command Build | [README.md](../../README.md) |
| **Project Overview** | Complete Ecosystem & Architecture Summary | [Galaxy/README.md](../README.md) |
| **System Architecture** | Process Boundaries, Sequence Flows & Dataflow | [architecture.md](architecture.md) |
| **Installation Guide** | Prerequisites & OS Packages (Linux, macOS, Windows) | [installation.md](installation.md) |
| **Configuration Guide** | `.env` Variables, SQLite Stores & SMTP Settings | [configuration.md](configuration.md) |
| **API & WebSocket** | REST Endpoints, Payloads & Streaming Events | [api.md](api.md) |
| **CLI & Hotkeys** | Flags (`server=true`), Slash Commands & Hotkeys | [cli.md](cli.md) |
| **Agent & LLM Engine** | LangChain ReAct Loop, Multi-Provider & Memory | [agent.md](agent.md) |
| **16 Native Tools** | Tool Signatures, Parameters & Interactive Guard | [tools.md](tools.md) |
| **Build & Packaging** | Unified C++ Builder (`build.cpp`) & Bundling | [build.md](build.md) |
| **Troubleshooting** | API Key Errors, Port Conflicts & FAQs | [troubleshooting.md](troubleshooting.md) |

