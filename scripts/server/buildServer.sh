#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# AI AGENT - LINUX/MACOS STARTUP
# ============================================================

echo
echo "============================================================"
echo "                    AI AGENT STARTUP"
echo "============================================================"
echo

# ------------------------------------------------------------
# ROOT DIRECTORY
# ------------------------------------------------------------

ROOT="$( cd "$( dirname "${BASH_SOURCE}" )/../.." && pwd )/.galaxy"

BACKEND="$ROOT/server"
VENV="$BACKEND/.venv"
VENV_PYTHON="$VENV/bin/python"
ACTIVATE_VENV="$VENV/bin/activate"

BACKEND_TEMP=$ROOT/build/cache
BACKEND_BUILD=$ROOT/build
BACKEND_BUILD_TEMP_DATA=$ROOT/build/data

MACOS_ICON_PATH=$ROOT/scripts/icons/galaxyIcon.icns
LINUX_ICON_PATH=$ROOT/scripts/icons/galaxyIcon.png

echo "[INFO] Project:"
echo "       $ROOT"
echo

# ------------------------------------------------------------
# ERROR HANDLER
# ------------------------------------------------------------

error_exit() {
    echo
    echo "============================================================"
    echo "[ERROR] $1"
    echo "============================================================"
    echo
    exit 1
}

# ------------------------------------------------------------
# CHECK FOLDERS
# ------------------------------------------------------------

[[ -d "$BACKEND" ]] || error_exit "backend folder not found."

[[ -f "$BACKEND/startGalaxy.py" ]] \
    || error_exit "backend/startGalaxy.py not found."

# ------------------------------------------------------------
# PYTHON
# ------------------------------------------------------------

echo "[INFO] Checking Python..."

PYTHON=""

if command -v python3 >/dev/null 2>&1; then
    PYTHON="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
    PYTHON="$(command -v python)"
fi

if [[ -z "$PYTHON" ]]; then

    echo "[WARNING] Python was not found."
    echo

    if command -v apt-get >/dev/null 2>&1; then

        echo "[INFO] Debian/Ubuntu detected."
        echo "[INFO] Installing Python..."
        echo

        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv

    elif command -v pacman >/dev/null 2>&1; then

        echo "[INFO] Arch Linux detected."
        echo "[INFO] Installing Python..."
        echo

        sudo pacman -Sy --needed --noconfirm python python-pip

    elif command -v dnf >/dev/null 2>&1; then

        echo "[INFO] Fedora/RHEL detected."
        echo "[INFO] Installing Python..."
        echo

        sudo dnf install -y python3 python3-pip

    elif command -v zypper >/dev/null 2>&1; then

        echo "[INFO] openSUSE detected."
        echo "[INFO] Installing Python..."
        echo

        sudo zypper install -y python3 python3-pip

    else
        error_exit "Python is missing and your Linux package manager could not be detected."
    fi

    if command -v python3 >/dev/null 2>&1; then
        PYTHON="$(command -v python3)"
    elif command -v python >/dev/null 2>&1; then
        PYTHON="$(command -v python)"
    else
        error_exit "Python installation completed but Python could not be detected."
    fi
fi

echo "[OK] Python detected:"
"$PYTHON" --version
echo

# ------------------------------------------------------------
# CREATE VENV
# ------------------------------------------------------------

if [[ ! -f "$VENV_PYTHON" ]]; then

    echo "[INFO] Creating Linux Python virtual environment..."
    echo "[INFO] Location:"
    echo "       $VENV"
    echo

    if ! "$PYTHON" -m venv "$VENV"; then

        echo
        echo "[WARNING] python3-venv may be missing."
        echo

        if command -v apt-get >/dev/null 2>&1; then

            echo "[INFO] Installing python3-venv..."
            sudo apt-get update
            sudo apt-get install -y python3-venv

        elif command -v pacman >/dev/null 2>&1; then

            echo "[INFO] Installing Python venv dependencies..."
            sudo pacman -Sy --needed --noconfirm python

        elif command -v dnf >/dev/null 2>&1; then

            echo "[INFO] Installing Python venv dependencies..."
            sudo dnf install -y python3

        fi

        rm -rf "$VENV"

        "$PYTHON" -m venv "$VENV" \
            || error_exit "Failed to create Python virtual environment."
    fi

    echo "[OK] Linux virtual environment created."
    echo

else
    echo "[OK] Existing Linux virtual environment found."
    echo
fi

[[ -x "$VENV_PYTHON" ]] \
    || error_exit "Virtual environment Python is missing."

# ------------------------------------------------------------
# Activate Virtual Enviroment
# ------------------------------------------------------------
source $ACTIVATE_VENV

# ------------------------------------------------------------
# PIP
# ------------------------------------------------------------

echo "[INFO] Updating pip..."

"$VENV_PYTHON" -m pip install --upgrade pip \
    || error_exit "Failed to update pip."

echo
echo "[OK] pip ready."
echo

# ------------------------------------------------------------
# REQUIREMENTS
# ------------------------------------------------------------

REQUIREMENTS=""

if [[ -f "$BACKEND/requirements.txt" ]]; then
    REQUIREMENTS="$BACKEND/requirements.txt"
elif [[ -f "$BACKEND/requirement.txt" ]]; then
    REQUIREMENTS="$BACKEND/requirement.txt"
fi

if [[ -n "$REQUIREMENTS" ]]; then

    echo "[INFO] Installing backend dependencies..."
    echo "       $REQUIREMENTS"
    echo

    "$VENV_PYTHON" -m pip install -r "$REQUIREMENTS" \
        || error_exit "Failed to install Python dependencies."

    echo
    echo "[OK] Backend dependencies ready."
    echo

else
    echo "[WARNING] No requirements.txt found."
    echo "[WARNING] Skipping Python dependency installation."
    echo
fi

# ------------------------------------------------------------ 
# MOVE ENVIRONMENT FILE .env
# ------------------------------------------------------------ 

echo [Info] Moving Envrionment .env File To /build...

cp $BACKEND "$ROOT\build"

echo [OK] Successfully Moved Environment File

# ------------------------------------------------------------ 
# BUILD BACKEND EXECUTABLE
# ------------------------------------------------------------ 

echo [INFO] Building Server Executable File...
mkdir -p "$ROOT\build"


if [[ "$OS" == "Linux" ]]; then

    %VENV_PYTHON% -m nuitka --mode=onefile \
    --follow-imports \
    --include-package="$BACKEND/source" \
    --include-package=fastapi \
    --include-package=uvicorn \
    --include-package=cryptography \
    --include-package=langchain \
    --output-dir="$BACKEND_BUILD" \
    --output-filename=server_cli_launcher \
    "$BACKEND/startGalaxy.py"

    # Linux icon automation
    mkdir -p "$HOME/.local/share/icons"
    mkdir -p "$HOME/.local/share/applications"

    cp "$LINUX_ICON_PATH" \
    "$HOME/.local/share/icons/server_cli_launcher.png"

    cat > "$HOME/.local/share/applications/server_cli_launcher.desktop" <<EOF
[Desktop Entry]
Name=Server CLI Launcher
Exec=$BACKEND_BUILD/server_cli_launcher
Icon=$HOME/.local/share/icons/server_cli_launcher.png
Type=Application
Terminal=true
Categories=Utility;
EOF

    chmod +x "$HOME/.local/share/applications/server_cli_launcher.desktop"

    echo "Linux build and icon setup completed."

    exit 0

fi

%VENV_PYTHON% -m nuitka --mode=onefile \
--follow-imports \
--include-package=$BACKEND/source \
--include-package=fastapi \
--include-package=uvicorn \
--include-package=cryptography \
--include-package=langchain \
--output-dir="$BACKEND_BUILD" \
--output-filename=server_cli_launcher.exe \
--macos-create-app-bundle \
--macos-app-icon=$MACOS_ICON_PATH \
"$BACKEND\startGalaxy.py"

if [[ $? -ne 0 ]]; then
    echo
    echo "[ERROR] Failed to build Server Executable."
    echo
    exit 1
fi

echo [OK] Server Executable Created.