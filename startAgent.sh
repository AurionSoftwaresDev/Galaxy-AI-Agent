#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# AI AGENT - LINUX STARTUP
# ============================================================

echo
echo "============================================================"
echo "                    AI AGENT STARTUP"
echo "============================================================"
echo

# ------------------------------------------------------------
# ROOT DIRECTORY
# ------------------------------------------------------------

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKEND="$ROOT/backend"
FRONTEND="$ROOT/frontend"
VENV="$BACKEND/.venv"
VENV_PYTHON="$VENV/bin/python"

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

[[ -d "$FRONTEND" ]] \
    || error_exit "frontend folder not found."

[[ -f "$FRONTEND/pubspec.yaml" ]] \
    || error_exit "frontend/pubspec.yaml not found."

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
# FLUTTER
# ------------------------------------------------------------

echo "[INFO] Checking Flutter..."

if ! command -v flutter >/dev/null 2>&1; then

    echo
    echo "[ERROR] Flutter was not found."
    echo
    echo "Please install Flutter for your Linux distribution."
    echo "Then run this script again."
    echo

    exit 1
fi

echo "[OK] Flutter detected."
flutter --version
echo

# ------------------------------------------------------------
# FLUTTER DEPENDENCIES
# ------------------------------------------------------------

echo "[INFO] Preparing Flutter dependencies..."

cd "$FRONTEND"

flutter pub get \
    || error_exit "Flutter dependency installation failed."

echo
echo "[OK] Flutter dependencies ready."
echo

# ------------------------------------------------------------
# BACKEND LOGS
# ------------------------------------------------------------

BACKEND_LOG="$BACKEND/backend.log"
BACKEND_ERROR_LOG="$BACKEND/backend-error.log"

rm -f "$BACKEND_LOG" "$BACKEND_ERROR_LOG"

# ------------------------------------------------------------
# START BACKEND
# ------------------------------------------------------------

echo "[INFO] Starting AI Agent backend..."
echo

cd "$BACKEND"

"$VENV_PYTHON" -u "$BACKEND/startGalaxy.py" \
    >"$BACKEND_LOG" \
    2>"$BACKEND_ERROR_LOG" &

BACKEND_PID=$!

echo "$BACKEND_PID" > "$BACKEND/backend.pid"

echo "[OK] Backend started."
echo "[INFO] Backend PID: $BACKEND_PID"
echo

# ------------------------------------------------------------
# CHECK BACKEND
# ------------------------------------------------------------

sleep 3

if ! kill -0 "$BACKEND_PID" 2>/dev/null; then

    echo "[WARNING] Backend stopped unexpectedly."
    echo
    echo "Backend log:"
    echo "  $BACKEND_LOG"
    echo
    echo "Backend error log:"
    echo "  $BACKEND_ERROR_LOG"
    echo

    exit 1
fi

echo "[OK] Backend process is running."
echo

# ------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------

cleanup() {

    echo
    echo "============================================================"
    echo "                    SHUTTING DOWN"
    echo "============================================================"
    echo

    if kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo "[INFO] Stopping backend..."
        kill "$BACKEND_PID" 2>/dev/null || true
        wait "$BACKEND_PID" 2>/dev/null || true
        echo "[OK] Backend stopped."
    fi

    rm -f "$BACKEND/backend.pid"
}

trap cleanup EXIT INT TERM

# ------------------------------------------------------------
# FLUTTER RELEASE BUILD
# ------------------------------------------------------------

echo "============================================================"
echo "                 FLUTTER RELEASE BUILD"
echo "============================================================"
echo

LINUX_BUILD="$FRONTEND/build/linux/x64/release/bundle"

BUILD_REQUIRED=1
FLUTTER_APP=""


# ------------------------------------------------------------
# CHECK EXISTING RELEASE BUILD
# ------------------------------------------------------------

echo "[INFO] Checking existing Linux release build..."
echo


if [[ -d "$LINUX_BUILD" ]]; then

    FLUTTER_APP="$(
        find "$LINUX_BUILD" \
            -maxdepth 1 \
            -type f \
            -executable \
            -print \
            -quit
    )"

    if [[ -n "$FLUTTER_APP" ]]; then
        BUILD_REQUIRED=0
    fi

fi


# ------------------------------------------------------------
# EXISTING BUILD FOUND
# ------------------------------------------------------------

if [[ "$BUILD_REQUIRED" -eq 0 ]]; then

    echo "[OK] Existing Linux release build found."
    echo "     $FLUTTER_APP"
    echo

else

    echo "[INFO] No valid Linux release build found."
    echo "[INFO] Building Flutter Linux application..."
    echo
    echo "[COMMAND] flutter build linux"
    echo

    cd "$FRONTEND"

    flutter build linux \
        || error_exit "Flutter Linux release build failed."

    echo
    echo "[OK] Flutter Linux release build completed."
    echo

fi


# ------------------------------------------------------------
# FIND RELEASE EXECUTABLE
# ------------------------------------------------------------

FLUTTER_APP="$(
    find "$LINUX_BUILD" \
        -maxdepth 1 \
        -type f \
        -executable \
        -print \
        -quit
)"


# ------------------------------------------------------------
# VALIDATE RELEASE EXECUTABLE
# ------------------------------------------------------------

if [[ -z "$FLUTTER_APP" ]]; then

    error_exit \
        "Linux Flutter executable was not found after release build."

fi


echo "[INFO] Flutter executable:"
echo "       $FLUTTER_APP"
echo


# ------------------------------------------------------------
# START FLUTTER RELEASE APPLICATION
# ------------------------------------------------------------

echo "============================================================"
echo "                 STARTING AI AGENT APP"
echo "============================================================"
echo

echo "[INFO] Starting release application..."
echo

"$FLUTTER_APP" &

FLUTTER_PID=$!

echo "[OK] Flutter application started."
echo "[INFO] Flutter PID: $FLUTTER_PID"
echo
echo "[INFO] Close the Flutter application to continue."
echo


# ------------------------------------------------------------
# WAIT FOR FLUTTER APPLICATION
# ------------------------------------------------------------

set +e

wait "$FLUTTER_PID"

FLUTTER_EXIT=$?

set -e


# ------------------------------------------------------------
# FLUTTER APPLICATION CLOSED
# ------------------------------------------------------------

echo
echo "============================================================"
echo "                 FLUTTER APPLICATION CLOSED"
echo "============================================================"
echo

exit "$FLUTTER_EXIT"