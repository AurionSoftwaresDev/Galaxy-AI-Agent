# CLI & Keyboard Controls

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../../README.md) • [📖 Galaxy Overview](../README.md) • [📂 Docs Directory](./)

Galaxy AI Agent includes a terminal-based interactive agent runtime, command-line launch arguments, prompt slash-commands, and system-wide keyboard shortcuts.

---

## 1. Startup Arguments (`startGalaxy`)

The launcher binary (generated automatically by compiling `build.cpp` into `Galaxy/build/startGalaxy`) or script accepts flags to toggle between the server daemon and the interactive agent:

```bash
# Running compiled binary:
./Galaxy/build/startGalaxy [OPTIONS]

# Or via Python runtime:
python startGalaxy.py [OPTIONS]
```

### Options

| Command | Effect |
|---|---|
| `./Galaxy/build/startGalaxy` (or `python startGalaxy.py`) | Starts **both** the FastAPI server (background) and the interactive terminal agent. |
| `./Galaxy/build/startGalaxy server=true` | Starts only the background FastAPI server. |
| `./Galaxy/build/startGalaxy agent=true` | Starts only the interactive terminal agent. |
| `./Galaxy/build/startGalaxy server=true agent=false` | Starts only the server; omits the agent terminal. |
| `./Galaxy/build/startGalaxy server=false agent=true` | Starts only the agent; omits starting the server. |
| `./Galaxy/build/startGalaxy -h` or `--help` | Prints the launcher help menu and exits. |

---

## 2. Interactive Terminal Agent Interface

When launched with `agent=true` (or directly via `python main.py`):

1. The terminal displays the animated Galaxy AI startup banner.
2. A background keyboard mapping thread initializes to register global shortcuts.
3. The prompt displays:
   ```text
   User : 
   ```
4. As the agent reasons and streams tokens, the Rich terminal UI renders:
   - **Thinking status**
   - **Active tool execution badge** (e.g. `Executing: commands_executor`)
   - **Streaming response tokens**
5. Typing `quit-agent` or pressing `Ctrl+C` triggers graceful shutdown.

---

## 3. Built-in Slash Commands

The agent parses slash commands entered at the `User : ` prompt via `source/cli/cli.py`:

| Slash Command | Handler | Description |
|---|---|---|
| `/help` | `commands.help` | Lists available slash commands and usage help. |
| `/status` | `commands.status` | Displays current runtime status of the agent. |
| `/tools` | `commands.tools` | Lists all 16 registered agent tools and descriptions. |
| `/providers` | `commands.provider` | Displays the current active LLM provider. |
| `/version` | `commands.version` | Displays the Galaxy AI version information. |
| `/clear` | `commands.clear` | Clears the current terminal window. |
| `/exit` | `commands.exit` | Terminates the terminal agent session. |
| `/terminate-server` | `commands.terminateServer` | Sends termination signal to the Uvicorn server daemon. |

---

## 4. Global Keyboard Shortcuts

Galaxy AI Agent runs a background listener (`source/controllers/keyboardMapping/keyboardController.py`) using the `keyboard` library. 

Modifiers adapt dynamically to the host operating system:
- **Windows / Linux**: `Ctrl`
- **macOS (Darwin)**: `Cmd`

| Shortcut | macOS Shortcut | Action |
|---|---|---|
| `Ctrl + Alt + Q` | `Cmd + Alt + Q` | **Stop AI Agent**: Immediately shuts down the agent process. |
| `Ctrl + Alt + Shift + C` | `Cmd + Alt + Shift + C` | **Launch Chat Mode**: Initiates interactive agent chat session thread. |
| `Ctrl + Alt + R` | `Cmd + Alt + R` | **Speak Mode**: Triggers voice handler *(Implementation Note: Currently prints a stub message "This Is Not Implement!").* |
| `Ctrl + Shift + L` | `Cmd + Shift + L` | **Clear Screen**: Clears the active terminal screen. |

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

