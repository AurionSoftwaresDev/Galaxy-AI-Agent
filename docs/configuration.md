# Configuration & Environment Reference

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../../README.md) • [📖 Galaxy Overview](../README.md) • [📂 Docs Directory](./)

This document details all configuration options, environment variables, database locations, and logging conventions in Galaxy AI Agent.

---

## 1. Environment Variables (`.env`)

Configuration is managed via Python `dotenv` from `Galaxy/.galaxy/server/.env`. A template is provided at `.env.example`.

### LLM Provider Credentials

| Variable Name | Type | Required | Description |
|---|---|---|---|
| `GOOGLE_API_KEY` | String | Conditional* | Google AI Studio / Gemini API key. Required when using Gemini models (default model: `gemini-3.6-flash`). |
| `MISTRAL_API_KEY` | String | Conditional* | Mistral AI API key. Required when using Mistral models (default model: `mistral-small-latest`). |

*\* At startup, `validateUserEnviromentVariables()` checks that at least one of `GOOGLE_API_KEY` or `MISTRAL_API_KEY` is present in the environment.*

### Network & Server Configuration

| Variable Name | Type | Default | Description |
|---|---|---|---|
| `AGENT_SERVER_RUNNING_PORT` | Integer | `8000` | The network port on which Uvicorn binds the FastAPI server (`127.0.0.1:<PORT>`). |
| `SERVER_URL` | String | `http://localhost:<PORT>` | The external or base URL used to construct client connection links. |

### SMTP Email Configuration (Optional for `send_email` Tool)

These settings are used by `source/services/sendEmail.py` when the agent invokes the `send_email` tool.

| Variable Name | Type | Example | Description |
|---|---|---|---|
| `SMTP_SENDER_EMAIL` | String | `agentgalaxyai@gmail.com` | Authenticated email address sending the messages. |
| `SMTP_PORT` | Integer / String | `587` | Port for SMTP server (usually `587` for TLS or `465` for SSL). |
| `SMTP_SERVER_HOST` | String | `smtp.gmail.com` | Hostname of the outgoing SMTP mail server. |
| `SMTP_SENDER_PASSWORD` | String | `your-app-password` | App-specific password or authentication credential. |

---

## 2. SQLite Database Configuration

All SQLite storage paths are configured in `source/config/databasePaths.py`:

```python
MEMORY_STORE_PATH = Path(...) / "databases" / "memory" / "memory.db"
CHAT_STORE_PATH   = Path(...) / "databases" / "memory" / "chats.db"
```

- **`memory.db`**: Stores continuous conversational turns (`messages` table). Automatically initialized on startup by `initializeAgentMemory()`.
- **`chats.db`**: Stores distinct named chat sessions and associated messages (`chats` and `messages` tables). Automatically initialized by `initializeChatAgentMemory()`.

Both database directories are automatically created if they do not exist.

---

## 3. Log Files and Process Identification

Logs and process state files are managed in `source/config/LogPaths.py`:

- **Log Directory**: `Galaxy/.galaxy/server/source/logs/` (or relative path defined in `SERVER_LOGS_PATH`).
- **Server Logs**: `Server_<YYYY-MM-DD>.log` — Daily stdout captures from the Uvicorn daemon.
- **Server Error Logs**: `ServerErrors_<YYYY-MM-DD>.log` — Daily stderr captures from the Uvicorn daemon.
- **PID Store**: `server.pid` — Contains the active process ID of the Uvicorn server, utilized by `/server/disconnect` and `/terminate-server` to perform clean terminations.

---

## 4. Flutter Desktop Client Configuration

In the Flutter client (`Galaxy/.galaxy/client`), settings are defined in `lib/models/backend_config.dart`:

```dart
class BackendConfig {
  final String baseUrl; // Default: 'http://127.0.0.1:8000'
  final Duration connectionTimeout; // Default: 5 seconds
  final Duration reconnectInterval; // Default: 3 seconds
  ...
}
```

The user can modify the backend URL at runtime via the Flutter settings modal without re-compiling the app.

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

