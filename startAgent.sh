#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# AI AGENT - FLUTTER APPLICATION STARTUP
# ============================================================

echo
echo "============================================================"
echo "                    AI AGENT STARTUP"
echo "============================================================"
echo


# ============================================================
# ROOT DIRECTORIES
# ============================================================

# Directory where this script is located.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKEND="$ROOT/backend"
FRONTEND="$ROOT/frontend"


# ============================================================
# ERROR HANDLER
# ============================================================

error_exit() {
    echo
    echo "[ERROR] $1"
    echo
    exit 1
}


# ============================================================
# VALIDATE PROJECT STRUCTURE
# ============================================================

echo "[INFO] Checking project structure..."
echo

if [[ ! -d "$BACKEND" ]]; then
    error_exit "Backend directory was not found: $BACKEND"
fi

if [[ ! -d "$FRONTEND" ]]; then
    error_exit "Frontend directory was not found: $FRONTEND"
fi

if [[ ! -f "$FRONTEND/pubspec.yaml" ]]; then
    error_exit "Flutter project was not found: $FRONTEND/pubspec.yaml"
fi

echo "[OK] Project root:"
echo "     $ROOT"

echo "[OK] Backend:"
echo "     $BACKEND"

echo "[OK] Frontend:"
echo "     $FRONTEND"
echo


# ============================================================
# DETECT HOST / FLUTTER BUILD TARGET
# ============================================================

echo "[INFO] Detecting Flutter desktop target..."
echo

case "$(uname -s)" in

    Linux*)
        FLUTTER_TARGET="linux"
        ;;

    Darwin*)
        FLUTTER_TARGET="macos"
        ;;

    MINGW*|MSYS*|CYGWIN*)
        FLUTTER_TARGET="windows"
        ;;

    *)
        error_exit "Unsupported operating system: $(uname -s)"
        ;;

esac

echo "[OK] Flutter target detected:"
echo "     $FLUTTER_TARGET"
echo


# ============================================================
# CHECK FLUTTER
# ============================================================

if ! command -v flutter >/dev/null 2>&1; then
    error_exit "Flutter was not found in PATH."
fi

echo "[OK] Flutter detected:"
echo "     $(command -v flutter)"
echo


# ============================================================
# MOVE TO FRONTEND
# ============================================================

cd "$FRONTEND"


# ============================================================
# FLUTTER DEPENDENCIES
# ============================================================

echo "============================================================"
echo "                 FLUTTER DEPENDENCIES"
echo "============================================================"
echo

echo "[INFO] Checking Flutter dependencies..."
echo

flutter pub get \
    || error_exit "Flutter dependency installation failed."

echo
echo "[OK] Flutter dependencies are ready."
echo


# ============================================================
# FLUTTER RELEASE BUILD
# ============================================================

echo "============================================================"
echo "                 FLUTTER RELEASE BUILD"
echo "============================================================"
echo

BUILD_REQUIRED=1


# ============================================================
# LINUX BUILD CHECK
# ============================================================

if [[ "$FLUTTER_TARGET" == "linux" ]]; then

    LINUX_BUILD="$FRONTEND/build/linux/x64/release/bundle"

    if [[ -d "$LINUX_BUILD" ]] &&
       find "$LINUX_BUILD" \
           -maxdepth 1 \
           -type f \
           -executable \
           -print -quit \
           | grep -q .; then

        BUILD_REQUIRED=0

        echo "[OK] Existing Linux release build found."
        echo "     $LINUX_BUILD"

    fi

fi


# ============================================================
# MACOS BUILD CHECK
# ============================================================

if [[ "$FLUTTER_TARGET" == "macos" ]]; then

    MACOS_BUILD="$FRONTEND/build/macos/Build/Products/Release"

    if find "$MACOS_BUILD" \
        -maxdepth 1 \
        -type d \
        -name "*.app" \
        -print -quit \
        2>/dev/null \
        | grep -q .; then

        BUILD_REQUIRED=0

        echo "[OK] Existing macOS release build found."
        echo "     $MACOS_BUILD"

    fi

fi


# ============================================================
# WINDOWS BUILD CHECK
# ============================================================

if [[ "$FLUTTER_TARGET" == "windows" ]]; then

    WINDOWS_BUILD="$FRONTEND/build/windows/x64/runner/Release"

    if [[ -d "$WINDOWS_BUILD" ]] &&
       find "$WINDOWS_BUILD" \
           -maxdepth 1 \
           -type f \
           -iname "*.exe" \
           -print -quit \
           | grep -q .; then

        BUILD_REQUIRED=0

        echo "[OK] Existing Windows release build found."
        echo "     $WINDOWS_BUILD"

    fi

fi


# ============================================================
# BUILD APPLICATION IF REQUIRED
# ============================================================

if [[ "$BUILD_REQUIRED" -eq 1 ]]; then

    echo
    echo "[INFO] No valid Flutter release build was found."
    echo "[INFO] Building Flutter application..."
    echo
    echo "[COMMAND] flutter build $FLUTTER_TARGET"
    echo

    flutter build "$FLUTTER_TARGET" \
        || error_exit "Flutter release build failed."

    echo
    echo "[OK] Flutter release build completed successfully."
    echo

else

    echo
    echo "[OK] Valid release build already exists."
    echo "[INFO] Skipping Flutter build."
    echo

fi


# ============================================================
# START BUILT FLUTTER APPLICATION
# ============================================================

echo "============================================================"
echo "                 STARTING AI AGENT APP"
echo "============================================================"
echo


# ============================================================
# LINUX
# ============================================================

if [[ "$FLUTTER_TARGET" == "linux" ]]; then

    LINUX_BUILD="$FRONTEND/build/linux/x64/release/bundle"

    FLUTTER_APP="$(
        find "$LINUX_BUILD" \
            -maxdepth 1 \
            -type f \
            -executable \
            -print \
            -quit
    )"

    if [[ -z "$FLUTTER_APP" ]]; then
        error_exit "Linux Flutter executable was not found."
    fi

    echo "[INFO] Starting:"
    echo "       $FLUTTER_APP"
    echo

    "$FLUTTER_APP" &

    FLUTTER_PID=$!

    echo "[OK] Flutter application started."
    echo "[INFO] Flutter PID: $FLUTTER_PID"
    echo

    # set -e would terminate the script when the application
    # exits with a non-zero code, so temporarily disable it.
    set +e
    wait "$FLUTTER_PID"
    FLUTTER_EXIT=$?
    set -e

fi


# ============================================================
# MACOS
# ============================================================

if [[ "$FLUTTER_TARGET" == "macos" ]]; then

    MACOS_BUILD="$FRONTEND/build/macos/Build/Products/Release"

    FLUTTER_APP="$(
        find "$MACOS_BUILD" \
            -maxdepth 1 \
            -type d \
            -name "*.app" \
            -print \
            -quit
    )"

    if [[ -z "$FLUTTER_APP" ]]; then
        error_exit "macOS Flutter application was not found."
    fi

    echo "[INFO] Starting:"
    echo "       $FLUTTER_APP"
    echo

    open "$FLUTTER_APP"

    echo "[OK] Flutter application started."
    echo

    FLUTTER_EXIT=0

fi


# ============================================================
# WINDOWS
# ============================================================

if [[ "$FLUTTER_TARGET" == "windows" ]]; then

    WINDOWS_BUILD="$FRONTEND/build/windows/x64/runner/Release"

    FLUTTER_APP="$(
        find "$WINDOWS_BUILD" \
            -maxdepth 1 \
            -type f \
            -iname "*.exe" \
            -print \
            -quit
    )"

    if [[ -z "$FLUTTER_APP" ]]; then
        error_exit "Windows Flutter executable was not found."
    fi

    echo "[INFO] Windows executable found:"
    echo "       $FLUTTER_APP"
    echo

    "$FLUTTER_APP" &

    FLUTTER_PID=$!

    echo "[OK] Flutter application started."
    echo "[INFO] Flutter PID: $FLUTTER_PID"
    echo

    set +e
    wait "$FLUTTER_PID"
    FLUTTER_EXIT=$?
    set -e

fi


# ============================================================
# APPLICATION CLOSED
# ============================================================

echo
echo "============================================================"
echo "                 FLUTTER APPLICATION CLOSED"
echo "============================================================"
echo

echo "[INFO] Exit code: $FLUTTER_EXIT"
echo

exit "$FLUTTER_EXIT"