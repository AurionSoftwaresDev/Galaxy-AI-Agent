# Troubleshooting & Frequently Asked Questions

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../README.md) • [📂 Docs Directory](./)

This guide addresses common setup errors, runtime exceptions, and platform limitations encountered in Galaxy AI Agent.

---

## 1. Environment & API Key Errors

### Symptom: `[Exception] Providers Keys Not Found Check Logs` (Exit code 404)
- **Cause**: Galaxy requires at least one configured LLM provider key at startup. The function `validateUserEnviromentVariables()` checks both `GOOGLE_API_KEY` and `MISTRAL_API_KEY`.
- **Solution**:
  1. Open `.galaxy/server/.env`.
  2. Ensure at least one API key is defined and not empty:
     ```dotenv
     GOOGLE_API_KEY="AIzaSy..."
     ```
  3. Restart the server binary: `./build/startGalaxy` (or `python startGalaxy.py`).

---

## 2. Platform & OS Quirks

### Symptom: `AttributeError: module 'ctypes' has no attribute 'windll'` on Linux/macOS
- **Cause**: The module `source/gui/widgets/DialogBox.py` contains a top-level call to `ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(...)`, which is only available on Windows.
- **Occurrence**: This occurs if `validateUserEnviromentVariables()` triggers the GUI error dialog because API keys are missing on a non-Windows OS.
- **Solution**: Configure your `GOOGLE_API_KEY` in `.env` so that the missing-key dialog is never invoked.

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
  - **Alternative**: Change the server port in `.galaxy/server/.env`:
    ```dotenv
    AGENT_SERVER_RUNNING_PORT=8080
    ```
    Then update the base URL in the Flutter client settings modal to `http://127.0.0.1:8080`.

---

## 4. Flutter Desktop Connection Issues

### Symptom: Glowing Orb shows red border with label `Disconnected`
- **Cause**: The Flutter client cannot connect to `http://127.0.0.1:8000/health` or `ws://127.0.0.1:8000/ws/assistant`.
- **Checklist**:
  1. Verify the backend server is running: `curl http://127.0.0.1:8000/health`.
  2. If using a custom port in `.env`, update the port in Flutter Settings.
  3. Check `.galaxy/server/source/logs/` for traceback logs.

---

## 5. Local Ollama Provider Issues

### Symptom: `Connection refused` when invoking local model
- **Cause**: The Ollama daemon is not running on `http://127.0.0.1:11434`.
- **Resolution**:
  1. Ensure Ollama is installed: `ollama --version`.
  2. Start the daemon: `ollama serve`.
  3. Pull the required model: `ollama pull qwen3:8b`.

---

## 6. Shell Command Execution Denied

### Symptom: `ToolExecutionError: User denied permission to execute shell command`
- **Cause**: The `commands_executor` tool requires explicit approval via `PermissionManager`.
- **Resolution**:
  - In the interactive terminal, press `y` and `Enter` when prompted.
  - In automated/scripted environments, execute shell operations before invoking the agent.

---

## 7. Map Tools Display Diagnostics

### Symptom: Map window fails to initialize
- **Cause**: System lacks a running window manager or display server (e.g. running in a headless SSH session).
- **Resolution**: Run the agent in a standard desktop session (X11, Wayland, macOS Quartz, or Windows Desktop) to allow WebEngine window rendering.

---

## 🔗 Cross-Document Reference
- [Configuration Guide](configuration.md) — Environment variables and port configurations
- [Installation Guide](installation.md) — Dependencies and setup commands
- [Architecture Guide](architecture.md) — Process model and logging flow
- [Map Tools Guide](map_tools.md) — Geospatial tool usage
