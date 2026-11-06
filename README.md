# Galaxy AI Agent — Master Documentation & Project Hub

An extensible, cross-platform personal AI desktop agent and local server ecosystem built with **FastAPI**, **LangChain**, and **Flutter Desktop**. Galaxy AI integrates a local agent runtime with multi-provider LLM support (Google Gemini, local Ollama, Mistral AI), **20 operating-system automation & geospatial tools**, interactive permission guards, persistent SQLite session memory, and real-time streaming WebSocket communication.

> **Single-Source Documentation Control**: This root `README.md` serves as the central connection hub for the entire project. All technical guides in [`docs/`](docs/) are cataloged, summarized, and directly linked from this file, with reverse navigation breadcrumbs in every document.

---

## 📑 Central Documentation Hub & Master Index

Eliminate manual file checks with this single-source documentation map. Every guide in `docs/` is indexed below with its scope, target audience, and direct section links:

| # | Guide | Primary Focus | Key Sections & Direct Topics |
|---|---|---|---|
| 1 | [**Architecture Guide**](docs/architecture.md) | System Topology & Dataflow | • [System Topology](docs/architecture.md#1-system-topology)<br/>• [Process Model](docs/architecture.md#2-process-architecture)<br/>• [LangChain ReAct Runtime](docs/architecture.md#3-end-to-end-request--data-flows)<br/>• [SQLite Schema (`memory.db` & `chats.db`)](docs/architecture.md#4-sqlite-database-schemas)<br/>• [Shutdown Protocol](docs/architecture.md#5-process-shutdown-architecture) |
| 2 | [**Installation Guide**](docs/installation.md) | Prerequisites & OS Packages | • [System Requirements](docs/installation.md#1-system-requirements)<br/>• [Platform Dependencies (Ubuntu/Debian/Arch/Fedora/macOS/Windows)](docs/installation.md#2-platform-specific-dependencies)<br/>• [One-Command Build with `build.cpp`](docs/installation.md#3-setup--project-run-one-command-build-with-buildcpp)<br/>• [Running Binaries](docs/installation.md#4-running-the-project-binaries)<br/>• [Health Verification](docs/installation.md#5-verification--health-check) |
| 3 | [**Configuration Guide**](docs/configuration.md) | Environment Variables & Paths | • [LLM Credentials (`GOOGLE_API_KEY`, `MISTRAL_API_KEY`)](docs/configuration.md#1-environment-variables-env)<br/>• [Network Ports (`AGENT_SERVER_RUNNING_PORT`)](docs/configuration.md#network--server-configuration)<br/>• [SMTP Credentials for `send_email`](docs/configuration.md#smtp-email-configuration-optional-for-send_email-tool)<br/>• [SQLite File Paths & Log Stores](docs/configuration.md#2-sqlite-database-configuration)<br/>• [Flutter Client Configuration](docs/configuration.md#4-flutter-desktop-client-configuration) |
| 4 | [**REST & WebSocket API**](docs/api.md) | HTTP & Streaming Contracts | • [Health Check (`GET /health`)](docs/api.md#2-health--status)<br/>• [Single Turn Agent (`POST /generate`)](docs/api.md#3-agent-execution-endpoints)<br/>• [WebSocket Streaming (`ws://.../ws/assistant`)](docs/api.md#4-websocket-assistant-controller)<br/>• [Chat Session Management (`/create`, `/load-all`, `/load-chat`, `/save-message`, `/delete`, `/update-title`)](docs/api.md#5-chat-session-management)<br/>• [Dynamic Provider Switching (`/settings/*`)](docs/api.md#6-provider--settings-endpoints)<br/>• [Server Disconnect (`GET /disconnect`)](docs/api.md#7-server-lifecycle-termination) |
| 5 | [**CLI & Hotkeys**](docs/cli.md) | Terminal Interface & Hotkeys | • [Startup Arguments (`server=true`, `agent=true`)](docs/cli.md#1-startup-arguments-startgalaxy)<br/>• [Interactive Terminal Agent Interface](docs/cli.md#2-interactive-terminal-agent-interface)<br/>• [10 Terminal Slash Commands (`/help`, `/tools`, `/providers`, `/version`, etc.)](docs/cli.md#3-built-in-slash-commands)<br/>• [Global Shortcuts (`Ctrl+Shift+L`, `Ctrl+Alt+Q`, `Ctrl+Alt+R`, `Ctrl+Alt+Shift+C`)](docs/cli.md#4-global-keyboard-shortcuts) |
| 6 | [**Agent & LLM Engine**](docs/agent.md) | ReAct Loop, Providers & Memory | • [LangChain `create_agent` Mechanics](docs/agent.md#1-agent-engine--react-loop)<br/>• [Provider Abstraction (Gemini, Ollama, Mistral)](docs/agent.md#2-multi-provider-llm-system)<br/>• [Dynamic Provider & Temperature Switching](docs/agent.md#dynamic-provider-switching-at-runtime)<br/>• [Dual SQLite Storage Architecture](docs/agent.md#3-dual-memory-system) |
| 7 | [**20 Native Tools & Security**](docs/tools.md) | Tool Catalog & Security Guards | • [Complete 20-Tool Catalog Matrix](docs/tools.md#1-tool-catalog-summary)<br/>• [Filesystem & Archive Tools (8 Tools)](docs/tools.md#filesystem-tools)<br/>• [Map & Geospatial Tools (4 Tools)](docs/tools.md#map--geospatial-tools-maplibre-gl-js)<br/>• [OS Automation & Desktop Launcher](docs/tools.md#os--desktop-automation-tools)<br/>• [Interactive `PermissionManager` Guard](docs/tools.md#3-permission-manager--interactive-guard) |
| 8 | [**Interactive Map Tools**](docs/map_tools.md) | MapLibre GL JS Integration | • [MapLibre GL JS Architecture](docs/map_tools.md#1-map-architecture)<br/>• [Visualization Modes (Globe, Terrain, 3D Buildings)](docs/map_tools.md#2-visualization-modes--themes)<br/>• [Camera Navigation & Coordinate Markers](docs/map_tools.md#3-tool-signatures--usage)<br/>• [Great-Circle Distance Calculations](docs/map_tools.md#4-coordinate-distance-calculation) |
| 9 | [**Build & Packaging**](docs/build.md) | Unified C++ Builder & Release | • [Build Architecture Pipeline](docs/build.md#1-build-architecture)<br/>• [The C++ Builder (`tools/builder/build.cpp`)](docs/build.md#2-the-unified-c-builder-toolsbuilder)<br/>• [PyInstaller Server Bundling (`buildServer.sh/bat`)](docs/build.md#3-server-packaging-buildserversh--buildserverbat)<br/>• [Flutter Desktop Release Bundling (`buildAgent.sh/bat`)](docs/build.md#4-client-packaging-buildagentsh--buildagentbat)<br/>• [Running Project Binaries](docs/build.md#5-running-the-project-output) |
| 10 | [**Troubleshooting**](docs/troubleshooting.md) | Error Diagnostics & FAQs | • [Missing API Key Exception (Code 404)](docs/troubleshooting.md#1-environment--api-key-errors)<br/>• [Platform `ctypes.windll` Workaround](docs/troubleshooting.md#2-platform--os-quirks)<br/>• [Port 8000 Already in Use Fix](docs/troubleshooting.md#3-network--port-conflicts)<br/>• [Ollama Connection Diagnostics](docs/troubleshooting.md#5-local-ollama-provider-issues)<br/>• [Shell Permission Denied Diagnostics](docs/troubleshooting.md#6-shell-command-execution-denied) |

---

## 🔍 Developer Quick Lookup Matrix

Use this matrix to instantly jump to the exact document for common tasks without searching through directories:

| I want to... | Reference Document & Direct Section |
|---|---|
| **Build everything with a single command** | [Setup & One-Command Build](#setup--project-run-one-command-build) & [`docs/build.md`](docs/build.md#2-the-unified-c-builder-toolsbuilder) |
| **Set up API keys for Gemini, Ollama, or Mistral** | [`docs/configuration.md`](docs/configuration.md#1-environment-variables-env) |
| **Inspect or call the streaming WebSocket endpoint** | [`docs/api.md`](docs/api.md#4-websocket-assistant-controller) |
| **Inspect all 20 built-in desktop agent tools** | [`docs/tools.md`](docs/tools.md#1-tool-catalog-summary) |
| **Learn about the 4 MapLibre GL JS 3D map tools** | [`docs/map_tools.md`](docs/map_tools.md) & [`docs/tools.md`](docs/tools.md#map--geospatial-tools-maplibre-gl-js) |
| **Understand the interactive shell permission prompt** | [`docs/tools.md`](docs/tools.md#3-permission-manager--interactive-guard) |
| **Learn all 10 terminal slash commands (`/help`, `/tools`, etc.)** | [`docs/cli.md`](docs/cli.md#3-built-in-slash-commands) |
| **Use system hotkeys (`Ctrl+Alt+Q`, `Cmd+Shift+L`, etc.)** | [`docs/cli.md`](docs/cli.md#4-global-keyboard-shortcuts) |
| **View or query the SQLite message and chat tables** | [`docs/architecture.md`](docs/architecture.md#4-sqlite-database-schemas) |
| **Switch LLM model or temperature dynamically** | [`docs/agent.md`](docs/agent.md#dynamic-provider-switching-at-runtime) & [`docs/api.md`](docs/api.md#6-provider--settings-endpoints) |
| **Fix `Address already in use` or port 8000 conflicts** | [`docs/troubleshooting.md`](docs/troubleshooting.md#3-network--port-conflicts) |
| **Fix missing dependencies on Linux, macOS, or Windows** | [`docs/installation.md`](docs/installation.md#2-platform-specific-dependencies) |

---

## ⚡ Setup & Project Run (One-Command Build)

Galaxy AI features an automated C++ build runner (`tools/builder/build.cpp`). **You do not need to run multiple manual setup commands across separate terminals** (`python -m venv`, `pip install`, `flutter pub get`, etc.). Compiling `build.cpp` sets up the environments, installs all dependencies, packages the backend, and compiles the native desktop app automatically in one step:

### 1. Set Your API Key

```bash
# Copy environment template
cp .galaxy/server/.env.example .galaxy/server/.env
```

Open `.galaxy/server/.env` and specify your LLM key:

```dotenv
GOOGLE_API_KEY="your-google-ai-studio-api-key"
# MISTRAL_API_KEY="your-mistral-api-key"   # Optional secondary provider
```

### 2. Compile `build.cpp` and Done!

**Linux / macOS:**

```bash
cd tools/builder
g++ -std=c++17 build.cpp -o build && ./build
```

**Windows:**

```cmd
cd tools\builder
g++ -std=c++17 build.cpp -o build.exe && build.exe
```

> **What `build.cpp` does automatically:**
> 1. Detects Python 3.10+, provisions `.galaxy/server/.venv`, upgrades pip, and installs all `requirements.txt` packages.
> 2. Compiles the standalone server & terminal agent binary via PyInstaller into `build/startGalaxy`.
> 3. Resolves Flutter client dependencies and compiles the native desktop release bundle into `build/`.
> 
> **Done!** Everything is ready to launch.

### 3. Run the Project Binaries

Launch the compiled executables directly from `build/`:

**Linux / macOS:**

```bash
# Run backend server & interactive terminal agent:
./build/startGalaxy

# Or launch the native Flutter desktop app:
./build/galaxy
```

**Windows:**

```cmd
:: Run backend server & interactive terminal agent:
build\startGalaxy.exe

:: Or launch the native Flutter desktop app:
build\galaxy.exe
```

---

## 🏛️ System Architecture Overview

```mermaid
flowchart TD
    subgraph Clients["User Presentation Layer"]
        Terminal["Interactive Terminal CLI<br/>(Rich + Keyboard Hooks)"]
        Flutter["Flutter Desktop Client<br/>(Glowing AI Orb + Multi-Chat)"]
        External["Third-Party HTTP/WS Clients"]
    end

    subgraph Server["FastAPI Backend Runtime (:8000)"]
        Router["FastAPI Router (/generate, /chats, /settings, /ws)"]
        WSHandler["WebSocket Streaming Controller<br/>(/ws/assistant)"]
        CLIParser["Terminal Slash Command Parser (10 Commands)"]

        subgraph AgentEngine["LangChain Agentic Runtime"]
            Agent["ReAct Agent (create_agent)"]
            Provider["LLM Provider (Gemini / Ollama / Mistral)"]
            Tools["20 Built-in Native Tools"]
            PermMgr["PermissionManager (Terminal Prompt)"]
            MapContext["MapLibre GL JS Shared Context"]
        end

        subgraph Storage["Dual SQLite Stores"]
            MemDB[("memory.db<br/>(Continuous Session Memory)")]
            ChatDB[("chats.db<br/>(Organized Multi-Session History)")]
        end
    end

    Terminal --> CLIParser
    Terminal --> Agent
    Flutter -->|REST HTTP & WebSocket| Router
    External -->|REST HTTP & WebSocket| Router
    Router --> WSHandler
    WSHandler --> Agent
    CLIParser --> Agent
    Agent --> Provider
    Agent --> Tools
    Tools --> PermMgr
    Tools --> MapContext
    AgentEngine --> Storage
```

For complete technical specifications on dataflows, sequence diagrams, and process lifecycles, see the [**Architecture Guide**](docs/architecture.md).

---

## 🛠️ Built-in Agent Tools (20 Tools)

All 20 tools are registered in `source/agent/agentTools.py` and exposed to the model. Detailed schemas are available in the [**Tools Reference**](docs/tools.md) and [**Map Tools Guide**](docs/map_tools.md):

| Tool Identifier | Category | Purpose | Security Gate |
|---|---|---|:---:|
| `fetch_current_datetime` | System Info | ISO timestamp, localized time & day | Autonomous |
| `web_search` | Search | DuckDuckGo web search & scraper | Autonomous |
| `send_email` | Communication | Outgoing SMTP email dispatch | Autonomous |
| `open_browser` | System Navigation | Opens default operating system browser | Autonomous |
| `typing_tool` | Automation | Keyboard & terminal typing simulation | Autonomous |
| `inspect_user_system` | Diagnostics | CPU, RAM, platform & OS version report | Autonomous |
| `create_file` | File System | Creates UTF-8 file with directory parents | Autonomous |
| `read_file` | File System | Reads and encodes text files into prompt | Autonomous |
| `delete_file` | File System | Deletes targeted file from filesystem | Autonomous |
| `create_folder` | File System | Creates recursive folder paths | Autonomous |
| `delete_folder` | File System | Recursively deletes folder trees | Autonomous |
| `build_file_system_tree` | File System | Generates visual directory tree view | Autonomous |
| `archive_compressor` | Archiving | Compresses folders into zip, tar, gztar | Autonomous |
| `archive_extractor` | Archiving | Extracts archives into target directories | Autonomous |
| `launch_application` | OS Desktop | Cross-platform desktop application launch | Autonomous |
| `commands_executor` | Shell / Terminal | Executes shell commands in `/bin/bash` or `cmd.exe` | **Interactive Prompt (PermissionManager)** |
| `open_map` | Geospatial | Opens MapLibre GL JS interactive 3D map | Autonomous |
| `fly_to_location_on_map` | Geospatial | Smooth camera flight to lat/long coordinates | Autonomous |
| `add_marker_on_coordinate_on_map` | Geospatial | Places visual pin markers at coordinate points | Autonomous |
| `calculate_coordinate_distance_on_map` | Geospatial | Calculates great-circle distance (km) between coordinates | Autonomous |

---

## 📁 Repository Directory Structure

```text
/
├── README.md                    # Master Hub connecting all docs & builds
├── docs/                        # Complete technical documentation suite
│   ├── architecture.md          # System topology, process boundaries & SQLite schemas
│   ├── installation.md          # OS dependencies & setup instructions
│   ├── configuration.md         # Environment variables & database configs
│   ├── api.md                   # REST endpoints & WebSocket streaming specs
│   ├── cli.md                   # Launch arguments, 10 slash commands & hotkeys
│   ├── agent.md                 # LangChain ReAct loop & LLM providers
│   ├── tools.md                 # 20 agent tools & PermissionManager
│   ├── map_tools.md             # MapLibre GL JS 3D map tools & coordinate system
│   ├── build.md                 # Unified C++ build system documentation
│   └── troubleshooting.md       # Diagnostic guide & error resolutions
│
├── .galaxy/
│   ├── client/                  # Flutter Desktop UI (AI Orb, chat sidebar)
│   └── server/                  # FastAPI server, LangChain agent & SQLite databases
│       ├── main.py              # CLI agent entry point
│       ├── server.py            # FastAPI ASGI application definition
│       ├── startGalaxy.py       # Dual background server & CLI launcher
│       ├── requirements.txt     # Python dependency specifications
│       └── source/              # Modular backend source code
│
├── scripts/                     # Platform build scripts
│   ├── server/                  # buildServer.sh / buildServer.bat
│   └── client/                  # buildAgent.sh / buildAgent.bat
│
└── tools/
    └── builder/                 # Unified C++ build orchestrator (build.cpp)
```

---

## 🔄 Two-Way Document Connectivity Guarantee

To guarantee that users and developers never get stranded in subdirectories:

1. **Top-Level Hub (`README.md`)**: Direct links to all 10 documentation guides with anchor tags to specific sections.
2. **Document-Level Headers**: Every file in `docs/` starts with a top breadcrumb back to `[🏠 Root README / Master Index](../README.md)`.
3. **Document-Level Footers**: Every file in `docs/` ends with a complete cross-reference matrix to every other guide in the repository.
4. **Direct Paths**: All relative paths link directly within the repository, ensuring all links work seamlessly across GitHub, markdown viewers, and IDEs.
