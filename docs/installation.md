# Installation & Setup Guide

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../../README.md) • [📖 Galaxy Overview](../README.md) • [📂 Docs Directory](./)

This guide walks you through setting up Galaxy AI Agent on Linux, macOS, and Windows.

---

## 1. System Requirements

### Hardware
- **CPU**: 64-bit multi-core processor (x86_64 or ARM64 / Apple Silicon).
- **RAM**: Minimum 4 GB RAM (8 GB+ recommended, especially if running local Ollama models).
- **Disk Space**: At least 2 GB for dependencies, virtual environments, and caches.

### Software Prerequisites
- **Python**: Version `3.10` or higher (verify via `python3 --version`).
- **Git**: Latest stable release.
- **Flutter SDK** *(Optional, required for Flutter desktop app)*: Version `3.19.0` or higher.
- **C++ Compiler** *(Optional, for tools/builder)*: `g++`, `clang++`, or `MSVC`.

---

## 2. Platform-Specific Dependencies

### Linux (Ubuntu / Debian)
```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv build-essential \
    clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

### Linux (Arch Linux)
```bash
sudo pacman -Syu --needed python python-pip base-devel clang cmake ninja pkgconf gtk3
```

### Linux (Fedora / RHEL)
```bash
sudo dnf install -y python3 python3-pip python3-devel gcc-c++ clang cmake ninja-build gtk3-devel
```

### macOS
Ensure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```
If using Flutter desktop on macOS:
```bash
brew install cocoapods
```

### Windows
- Install **Python 3.10+** from [python.org](https://www.python.org/) (ensure **"Add Python to PATH"** is checked during installation).
- Install **Git for Windows**.
- For C++ compilation: Visual Studio Community with "Desktop development with C++" or MinGW-w64.

---

## 3. Setup & Project Run: One-Command Build with `build.cpp`

Galaxy completely eliminates running multiple manual setup commands across different directories. The unified builder in `tools/builder/build.cpp` automatically manages virtual environments, installs requirements, builds caches, and compiles standalone binaries for both the backend server and desktop client.

### Step 1: Configure Environment (.env)
```bash
cp .galaxy/server/.env.example .galaxy/server/.env
```
Add your `GOOGLE_API_KEY` or `MISTRAL_API_KEY` to `.galaxy/server/.env`.

### Step 2: Compile `build.cpp` and Done!

Navigate to `tools/builder`:
```bash
cd tools/builder
```

- **Linux / macOS**:
  ```bash
  g++ -std=c++17 build.cpp -o build
  ./build
  ```
- **Windows (MinGW)**:
  ```cmd
  g++ -std=c++17 build.cpp -o build.exe
  build.exe
  ```
- **Windows (MSVC)**:
  ```cmd
  cl /EHsc /std:c++17 build.cpp /Fe:build.exe
  build.exe
  ```

### What `build.cpp` Executes Automatically:
1. Calls `scripts/server/buildServer.[sh|bat]`:
   - Checks Python 3.10+ installation (and auto-installs via package manager on Linux if needed).
   - Automatically provisions `.galaxy/server/.venv`.
   - Upgrades `pip` and installs all packages from `requirements.txt`.
   - Compiles standalone server executable into `Galaxy/build/`.
2. Calls `scripts/client/buildAgent.[sh|bat]`:
   - Checks Flutter SDK installation and desktop engine support.
   - Runs `flutter pub get`.
   - Compiles release desktop bundle into `Galaxy/build/`.

**Done!** No manual setup or dependency commands are required.

---

## 4. Running the Project

Once the one-command build finishes, your production-ready binaries are waiting in `Galaxy/build/`:

### Linux / macOS:
```bash
# 1. Run backend server & interactive terminal agent:
./Galaxy/build/startGalaxy

# 2. Or launch the Flutter desktop client:
./Galaxy/build/galaxy
```

### Windows:
```cmd
:: 1. Run backend server & interactive terminal agent:
Galaxy\build\startGalaxy.exe

:: 2. Or launch the Flutter desktop client:
Galaxy\build\galaxy.exe
```

---

## 5. Verification & Health Check

After launching the server, verify operational health via the health endpoint:

```bash
curl http://127.0.0.1:8000/health
```

Expected response:
```json
{
  "Status": 200,
  "Message": "AI Agent Server Health Is Good."
}
```

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

