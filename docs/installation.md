# Installation & Setup Guide

> **Galaxy AI Documentation Hub**: [🏠 Root README / Master Index](../README.md) • [📂 Docs Directory](./)

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
- **Flutter SDK** *(Optional, required only if compiling the Flutter desktop client)*: Version `3.19.0` or higher.
- **C++ Compiler** *(For the one-command builder `tools/builder/build.cpp`)*: `g++` (GCC), `clang++`, or `MSVC`.

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
If building the Flutter desktop app on macOS:
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
Open `.galaxy/server/.env` and add your `GOOGLE_API_KEY` (or `MISTRAL_API_KEY`).

### Step 2: Compile `build.cpp` and Run!

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
   - Checks Python 3.10+ installation.
   - Automatically provisions `.galaxy/server/.venv`.
   - Upgrades `pip` and installs all packages from `requirements.txt`.
   - Compiles standalone server executable into `build/startGalaxy`.
2. Calls `scripts/client/buildAgent.[sh|bat]`:
   - Checks Flutter SDK installation and desktop engine support.
   - Runs `flutter pub get`.
   - Compiles release desktop bundle into `build/`.

**Done!** No manual setup or dependency commands are required.

---

## 4. Running the Project Binaries

Once the one-command build finishes, your production-ready binaries are waiting in `build/`:

### Linux / macOS:
```bash
# 1. Run backend server & interactive terminal agent:
./build/startGalaxy

# 2. Or launch the Flutter desktop client:
./build/galaxy
```

### Windows:
```cmd
:: 1. Run backend server & interactive terminal agent:
build\startGalaxy.exe

:: 2. Or launch the Flutter desktop client:
build\galaxy.exe
```

---

## 5. Verification & Health Check

Verify that the backend server is operating properly:

```bash
# Query health endpoint
curl http://127.0.0.1:8000/health
```

Expected output:
```json
{"Status": 200, "Message": "AI Agent Server Health Is Good."}
```

---

## 🔗 Cross-Document Reference
- [Configuration Guide](configuration.md) — Configuring environment variables and ports
- [Build Guide](build.md) — Detailed build flags (`--server`, `--agent`)
- [CLI Reference](cli.md) — Command line arguments for `startGalaxy`
- [Troubleshooting](troubleshooting.md) — Resolving missing packages or compiler errors
