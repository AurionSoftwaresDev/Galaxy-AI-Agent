# Troubleshooting & Frequently Asked Questions

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../../README.md) • [📖 Galaxy Overview](../README.md) • [📂 Docs Directory](./)

This guide addresses common setup errors, runtime exceptions, and platform limitations encountered in Galaxy AI Agent.

---

## 1. Environment & API Key Errors

### Symptom: `[Exception] Providers Keys Not Found Check Logs` (Exit code 404)
- **Cause**: Galaxy requires at least one configured LLM provider key at startup. The function `validateUserEnviromentVariables()` checks both `GOOGLE_API_KEY` and `MISTRAL_API_KEY`.
- **Solution**:
  1. Open `Galaxy/.galaxy/server/.env`.
  2. Ensure at least one API key is defined and not empty:
     ```dotenv
     GOOGLE_API_KEY="AIzaSy..."
     ```
  3. Restart the server binary: `./Galaxy/build/startGalaxy` (or `python startGalaxy.py`).

---

## 2. Platform & OS Quirks

### Symptom: `AttributeError: module 'ctypes' has no attribute 'windll'` on Linux/macOS
- **Cause**: The module `source/gui/widgets/DialogBox.py` contains a top-level call to `ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(...)`, which is only available on Windows.
- **Occurrence**: This occurs if `validateUserEnviromentVariables()` triggers the GUI error dialog because API keys are missing on a non-Windows OS.
- **Solution**: Configure your `GOOGLE_API_KEY` in `.env` so that the dialog fallback is never invoked, or wrap the `ctypes.windll` call in an `if sys.platform.startswith("win"):` guard.

---

## 3. Network & Port Conflicts

### Symptom: `Uvicorn failed to bind to 127.0.0.1:8000: Address already in use`
- **Cause**: A previous server instance or another local service is using port 8000.
- **Resolution**:
  - **Linux / macOS**:
    ```bash
    # Identify and terminate process on port 8000
    lsof -i :8000
    kill -9 <PID>
    ```
  - **Windows**:
    ```cmd
    netstat -ano | findstr :8000
    taskkill /PID <PID> /F
    ```
  - **Alternative**: Change the server port in `.env`:
    ```dotenv
    AGENT_SERVER_RUNNING_PORT=8080
    ```
    Then update the base URL in the Flutter client settings modal to `http://127.0.0.1:8080`.

---

## 4. Flutter Desktop Connection Issues

### Symptom: Glowing Orb shows red border with label `Disconnected`
- **Cause**: The Flutter client cannot connect to `http://127.0.0.1:8000/health` or `ws://127.0.0.1:8000/ws/assistant`.
- **Checklist**:
  1. Confirm the backend server is running:
     ```bash
     curl -i http://127.0.0.1:8000/health
     ```
     Should return:
     ```json
     {"Status": 200, "Message": "AI Agent Server Health Is Good."}
     ```
  2. Check if a firewall is blocking local loopback WebSocket connections.
  3. In the Flutter client, open Settings and verify the URL matches your backend (`http://127.0.0.1:8000`).

---

## 5. Local Ollama Provider Issues

### Symptom: `Failed to invoke Ollama model 'qwen3:8b'`
- **Cause**: Ollama is selected as active provider, but either the Ollama daemon is not running or the model has not been pulled.
- **Solution**:
  1. Start the Ollama server:
     ```bash
     ollama serve
     ```
  2. Pull the default Galaxy Ollama model:
     ```bash
     ollama pull qwen3:8b
     ```
  3. Verify availability via `ollama list`.

---

## 6. Shell Command Execution Denied

### Symptom: `commands_executor` returns `Permission Denied!`
- **Explanation**: This is normal security behavior. The `commands_executor` tool prompts for user approval via the terminal before running any shell commands. If the user presses `Deny` or sends a break signal, the operation is halted safely.

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

