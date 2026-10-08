# Galaxy AI Agent Architecture

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../../README.md) • [📖 Galaxy Overview](../README.md) • [📂 Docs Directory](./)

This document provides a comprehensive technical overview of the software architecture of Galaxy AI Agent, including process models, communication boundaries, agent runtime loops, and state management.

---

## 1. System Topology

Galaxy AI Agent is designed as a hybrid client-server desktop system composed of three primary operational tiers:

```mermaid
graph TB
    subgraph UI_Layer["User Presentation Layer"]
        CLI["Terminal CLI Interface<br/>(Rich, Questionary, Keyboard)"]
        FlutterApp["Flutter Desktop Client<br/>(Linux, macOS, Windows)"]
    end

    subgraph Service_Layer["FastAPI Service Layer (:8000)"]
        FastAPIApp["FastAPI ASGI Application (server.py)"]
        Router["APIRouter (allRoutes.py)"]
        WSEndpoint["WebSocket Session Handler (/ws/assistant)"]
        RESTEndpoints["REST Routers (/agent, /chats, /settings, /server)"]
    end

    subgraph Agent_Layer["LangChain Agentic Runtime"]
        AgentCore["Agent Executor (createNewAgent)"]
        SystemPrompt["System Prompt (prompts/systemPrompt.py)"]
        LLMProvider["Active LLM Model (Gemini / Ollama / Mistral)"]
        ToolRegistry["Tool Registry (16 Structured Tools)"]
        SecurityLayer["PermissionManager (Interactive CLI approval)"]
    end

    subgraph Storage_Layer["Local SQLite Storage"]
        MemDB[("memory.db<br/>(Flat Message Log)")]
        ChatDB[("chats.db<br/>(Relational Session Store)")]
    end

    CLI -->|In-Process Async Loop| AgentCore
    FlutterApp -->|HTTP REST Requests| RESTEndpoints
    FlutterApp -->|WebSocket Stream| WSEndpoint
    RESTEndpoints --> Router
    WSEndpoint --> Router
    Router --> FastAPIApp
    FastAPIApp --> AgentCore
    AgentCore --> SystemPrompt
    AgentCore --> LLMProvider
    AgentCore --> ToolRegistry
    ToolRegistry --> SecurityLayer
    AgentCore --> Storage_Layer
```

---

## 2. Process Architecture

When launched via `python startGalaxy.py`, two primary processes are instantiated depending on the provided arguments:

1. **Uvicorn Server Daemon Process**:
   - Spawned as a background subprocess via `subprocess.Popen([sys.executable, "-m", "uvicorn", "server:agentServer", "--host", "127.0.0.1", "--port", ...])`.
   - On Windows, uses `creationflags = subprocess.CREATE_NO_WINDOW` to avoid visual clutter.
   - Redirects stdout and stderr to rotating daily log files in `source/logs/` (e.g. `Server_YYYY-MM-DD.log`).
   - Stores the active process ID in `source/logs/server.pid` for graceful shutdown and process lifecycle management.

2. **Interactive Terminal Agent Process**:
   - Launched either in the current terminal or in a new terminal window via `startNewTerminal([sys.executable, "main.py"], "Galaxy AI - Agent")`.
   - Spawns background worker threads:
     - `startKeyboardMappingThread()`: Listens for system-wide hotkeys using the `keyboard` library.
     - `AgentChatModeThread`: Runs the `asyncio` event loop driving the interactive chat prompt, Rich streaming output, and CLI slash-command executor.

3. **Flutter Desktop Process (Optional)**:
   - An independent native GUI process communicating over local loopback (`http://127.0.0.1:8000` and `ws://127.0.0.1:8000/ws/assistant`).

---

## 3. End-to-End Request & Data Flows

### A. Terminal CLI Chat Flow

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant CLI as Terminal (main.py / agentChat.py)
    participant Memory as SQLite (memory.db)
    participant Agent as LangChain Agent
    participant LLM as LLM Provider
    participant Tool as Tool Execution
    participant Security as PermissionManager

    User->>CLI: Enters prompt or slash command
    alt Prompt is a Slash Command (e.g. /help, /tools)
        CLI->>CLI: Execute registered command function
        CLI-->>User: Display command output in Rich console
    else Prompt is Agent Message
        CLI->>Memory: loadMessagesFromAgentMemory()
        Memory-->>CLI: Return previous message history
        CLI->>Agent: agent.astream({"messages": [...]}, stream_mode="messages")
        loop Token / Tool Streaming
            Agent->>LLM: Stream inference tokens
            LLM-->>Agent: Token chunk
            opt LLM calls tool (e.g. commands_executor)
                Agent->>Tool: Invoke tool function
                opt Dangerous Tool
                    Tool->>Security: askPermission()
                    Security-->>User: Prompt "Allow This Operation?" (Allow/Deny)
                    User-->>Security: User chooses Allow
                end
                Tool-->>Agent: Tool result string / JSON
            end
            Agent-->>CLI: AIMessageChunk / ToolMessage
            CLI-->>User: Stream tokens to Rich terminal UI
        end
        CLI->>Memory: saveMessagesInAgentMemory("user", userPrompt)
        CLI->>Memory: saveMessagesInAgentMemory("assistant", finalResponse)
    end
```

### B. WebSocket Streaming Flow (Flutter / GUI Client)

```mermaid
sequenceDiagram
    autonumber
    actor Client as Flutter Desktop Client
    participant WS as WebSocket Controller (/ws/assistant)
    participant Mem as SQLite (memory.db)
    participant Agent as LangChain Agent
    participant LLM as LLM Provider

    Client->>WS: Connect to ws://127.0.0.1:8000/ws/assistant
    WS-->>Client: WebSocket Accept
    Client->>WS: Send {"content": "Explain binary search"}
    WS->>Mem: loadMessagesFromAgentMemory()
    Mem-->>WS: Return history
    WS-->>Client: {"type": "state_change", "payload": {"state": "thinking"}}
    WS->>Agent: agent.astream({"messages": [...]})
    loop Stream Tokens
        Agent->>LLM: Stream tokens
        LLM-->>Agent: Token chunk
        Agent-->>WS: AIMessageChunk
        WS-->>Client: {"type": "text_delta", "payload": {"content": token}}
    end
    WS->>Mem: saveMessagesInAgentMemory("user", prompt)
    WS->>Mem: saveMessagesInAgentMemory("assistant", fullText)
    WS-->>Client: {"type": "state_change", "payload": {"state": "completed"}}
    WS-->>Client: {"type": "done", "payload": {}}
```

---

## 4. State Management and Transitions

The Flutter desktop application maintains state through the `AssistantController` and visualizes state via the animated `AiOrb` widget:

```mermaid
stateDiagram-v2
    [*] --> Disconnected
    Disconnected --> Connecting: connect() / Server Ping
    Connecting --> Listening: Health check OK & WS open
    Connecting --> Disconnected: Connection failed
    
    Listening --> Thinking: sendPrompt(text)
    Thinking --> Speaking: Stream tokens received (audio active)
    Thinking --> Listening: Stream completes (done event)
    Speaking --> Listening: Speech playback finished / Cancelled
    
    Thinking --> Error: WebSocket / Backend error
    Listening --> Disconnected: Server terminated / socket dropped
    Error --> Listening: User retry / new prompt
```

| State | Orb Visual Behavior | Description |
|---|---|---|
| `disconnected` | Dim gray / pulsing red border | Server is unreachable or offline on port 8000. |
| `connecting` | Cyan/purple gentle breathing pulse | Attempting handshake with backend. |
| `listening` (idle) | Deep neon blue/indigo ambient wave | Ready for user audio or text input. |
| `thinking` | High-frequency purple/magenta energy orbit | Agent is reasoning or invoking tools. |
| `speaking` | Dynamic audio-reactive cyan/violet pulse | Assistant is streaming voice or completing output. |
| `error` | Amber/red alert glow | Request failed, timeout, or invalid response. |

---

## 5. Storage Architecture

Galaxy AI maintains two decoupled SQLite databases in `Galaxy/.galaxy/server/databases/memory/`:

### A. Agent Message Memory (`memory.db`)
Used by `agentResponse.py`, `agentWebSocketController.py`, and `agentChat.py` for standard ongoing conversational memory.

```sql
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### B. Session Chat Memory (`chats.db`)
Used by the Flutter client and `/chats/*` endpoints to manage distinct titled conversations:

```sql
CREATE TABLE chats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chat_id INTEGER NOT NULL,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE
);

CREATE INDEX idx_messages_chat_id ON messages(chat_id);
```

---

## 6. Process Shutdown Architecture

When the user triggers `/terminate-server` or `GET /server/disconnect`:
1. The server reads `source/logs/server.pid`.
2. Inspects process table using `psutil`.
3. Verifies process name contains `python` or `uvicorn` and terminates the PID.
4. Scans open sockets for processes listening on `AGENT_SERVER_RUNNING_PORT` (default 8000) and terminates matches.
5. Returns `HTTP 204 No Content` to the calling client before completing shutdown.

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

