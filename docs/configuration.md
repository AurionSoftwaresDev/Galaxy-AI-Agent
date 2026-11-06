# Configuration & Environment Reference

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../README.md) • [📂 Docs Directory](./)

This document details all configuration options, environment variables, database locations, and logging conventions in Galaxy AI Agent.

---

## 1. Environment Variables (`.env`)

Configuration is managed via Python `dotenv` from `.galaxy/server/.env`. A template is provided at `.galaxy/server/.env.example`.

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

- **Directory**: `.galaxy/server/source/logs/`
- **Daily Server Logs**: `Server_YYYY-MM-DD.log`
- **PID Lockfile**: `server.pid` stores the active Uvicorn process ID. Used by `findServerPID()` and `/disconnect` to manage graceful process lifecycle.

---

## 4. Flutter Desktop Client Configuration

The Flutter desktop client (`.galaxy/client/`) connects to the local backend using the base URL:
- Default: `http://127.0.0.1:8000`
- Configurable via the in-app settings dialog.

---

## 🔗 Cross-Document Reference
- [Installation Guide](installation.md) — Creating the `.env` file during initial setup
- [Architecture Guide](architecture.md) — Schema definitions for `memory.db` and `chats.db`
- [API Reference](api.md) — Endpoints utilizing configured ports and credentials
- [Troubleshooting](troubleshooting.md) — Diagnosing missing environment variables
