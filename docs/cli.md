# CLI & Keyboard Controls

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../README.md) • [📂 Docs Directory](./)

Galaxy AI Agent includes a terminal-based interactive agent runtime, command-line launch arguments, prompt slash-commands, and system-wide keyboard shortcuts.

---

## 1. Startup Arguments (`startGalaxy`)

The launcher binary (generated automatically by compiling `build.cpp` into `build/startGalaxy`) or the python script accepts flags to toggle between the server daemon and the interactive agent:

```bash
# Running compiled binary:
./build/startGalaxy [OPTIONS]

# Or via Python runtime:
python startGalaxy.py [OPTIONS]
```

### Options Matrix

| Command | Effect |
|---|---|
| `./build/startGalaxy` (or `python startGalaxy.py`) | Starts **both** the FastAPI server (background) and the interactive terminal agent. |
| `./build/startGalaxy server=true` | Starts only the background FastAPI server. |
| `./build/startGalaxy agent=true` | Starts only the interactive terminal agent. |
| `./build/startGalaxy server=true agent=false` | Starts only the server; omits the agent terminal. |
| `./build/startGalaxy server=false agent=true` | Starts only the agent; omits starting the server. |
| `./build/startGalaxy -h` or `--help` | Prints the launcher help menu and exits immediately. |

---

## 2. Interactive Terminal Agent Interface

When launched with `agent=true` (or directly via `python main.py`):

1. The terminal displays the animated Galaxy AI startup banner.
2. A background keyboard mapping thread initializes to register global hotkeys.
3. The prompt displays:
   ```text
   User : 
   ```
4. As the agent reasons and streams tokens, the Rich terminal UI renders:
   - **Thinking status spinner**
   - **Active tool execution badge** (e.g. `Executing: commands_executor`, `Executing: open_map`)
   - **Streaming response tokens** in real-time
5. Typing `/exit`, `quit-agent`, or pressing `Ctrl+C` triggers graceful shutdown.

---

## 3. Built-in Slash Commands

The agent parses slash commands entered at the `User : ` prompt via `source/cli/commandRegistry.py`:

| Slash Command | Handler | Description |
|---|---|---|
| `/help` | `commands.help` | Lists all available slash commands and usage help. |
| `/status` | `commands.status` | Displays the current runtime health and operational status. |
| `/tools` | `commands.tools` | Lists all 20 registered agent tools and descriptions. |
| `/version` | `commands.version` | Displays the current Galaxy AI Agent and runtime version. |
| `/exit` | `commands.exit` | Gracefully closes the interactive agent session. |
| `/clear` | `commands.clear` | Clears the terminal screen buffer. |
| `/providers` | `commands.provider` | Inspects and displays configured LLM providers (Gemini, Ollama, Mistral). |
| `/start-server` | `commands.startServer` | Spawns or restarts the background FastAPI Uvicorn server. |
| `/terminate-server` | `commands.terminateServer` | Terminates the running background FastAPI server process. |
| `/cleanup-logs` | `commands.cleanUpLogs` | Rotates and purges old historical log files from `source/logs/`. |

---

## 4. Global Keyboard Shortcuts

Galaxy AI Agent registers system-wide global hotkeys via `source/constants/keyboardShortcuts.py` and `keyboardController.py`. Modifiers automatically adapt based on your platform:
- **macOS (`Darwin`)**: `Cmd`
- **Windows / Linux**: `Ctrl`

| Shortcut | macOS Shortcut | Action | Description |
|---|---|---|---|
| `Ctrl+Shift+L` | `Cmd+Shift+L` | **Clear Screen** | Clears the current active terminal screen. |
| `Ctrl+Alt+Q` | `Cmd+Alt+Q` | **Agent Stop** | Immediately stops the current agent reasoning or streaming loop. |
| `Ctrl+Alt+R` | `Cmd+Alt+R` | **Start Recognition** | Activates voice/audio input recognition mode. |
| `Ctrl+Alt+Shift+C` | `Cmd+Alt+Shift+C` | **Chat Trigger** | Focuses or initiates agent chat message prompt. |

> **Note for Linux Users**: The `keyboard` library requires root/superuser privileges or access to `/dev/input` for global key interception outside an active terminal window. Within the terminal window, all standard controls function out of the box.

---

## 🔗 Cross-Document Reference
- [Architecture Guide](architecture.md) — Process model and keyboard thread architecture
- [Installation Guide](installation.md) — Dependencies needed for keyboard handling
- [Tools Reference](tools.md) — Details on the `typing_tool` and `commands_executor`
- [API Reference](api.md) — Interacting with the agent without the CLI
