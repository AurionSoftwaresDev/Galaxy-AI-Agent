#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# AI AGENT - DESKTOP STARTUP
# ============================================================

echo
echo "============================================================"
echo "                    AI AGENT STARTUP"
echo "============================================================"
echo

# ------------------------------------------------------------
# ROOT DIRECTORY
# ------------------------------------------------------------

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

FRONTEND="$ROOT/.galaxy/client"

MOVE_BUILD="$ROOT/build"

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

[[ -d "$FRONTEND" ]] \
    || error_exit "frontend folder not found."

[[ -f "$FRONTEND/pubspec.yaml" ]] \
    || error_exit "frontend/pubspec.yaml not found."

# ------------------------------------------------------------
# DETECT OPERATING SYSTEM
# ------------------------------------------------------------

OS="$(uname -s)"

case "$OS" in

    Linux)
        PLATFORM="Linux"
        FLUTTER_BUILD_COMMAND="flutter build linux"
        RELEASE_BUILD="$FRONTEND/build/linux/x64/release/bundle"
        ;;
        
    Darwin)
        PLATFORM="macOS"
        FLUTTER_BUILD_COMMAND="flutter build macos"
        RELEASE_BUILD="$FRONTEND/build/macos/Build/Products/Release"
        ;;
        
    *)
        error_exit "Unsupported operating system: $OS"
        ;;

esac

echo "[INFO] Operating System:"
echo "       $PLATFORM"
echo

# ------------------------------------------------------------
# FLUTTER
# ------------------------------------------------------------

echo "[INFO] Checking Flutter..."

if ! command -v flutter >/dev/null 2>&1; then

    echo
    echo "[ERROR] Flutter was not found."
    echo
    echo "Please install Flutter for your operating system."
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
# FLUTTER RELEASE BUILD
# ------------------------------------------------------------

echo "============================================================"
echo "              FLUTTER $PLATFORM RELEASE BUILD"
echo "============================================================"
echo

BUILD_REQUIRED=1
FLUTTER_APP=""

# ------------------------------------------------------------
# CHECK EXISTING RELEASE BUILD
# ------------------------------------------------------------

echo "[INFO] Checking existing $PLATFORM release build..."
echo

if [[ -d "$RELEASE_BUILD" ]]; then

    if [[ "$PLATFORM" == "Linux" ]]; then

        FLUTTER_APP="$(
            find "$RELEASE_BUILD" \
                -maxdepth 1 \
                -type f \
                -executable \
                -print \
                -quit
        )"

    elif [[ "$PLATFORM" == "macOS" ]]; then

        FLUTTER_APP="$(
            find "$RELEASE_BUILD" \
                -maxdepth 1 \
                -type d \
                -name "*.app" \
                -print \
                -quit
        )"

    fi

    if [[ -n "$FLUTTER_APP" ]]; then
        BUILD_REQUIRED=0
    fi

fi

# ------------------------------------------------------------
# EXISTING BUILD FOUND
# ------------------------------------------------------------

if [[ "$BUILD_REQUIRED" -eq 0 ]]; then

    echo "[OK] Existing $PLATFORM release build found."
    echo "     $FLUTTER_APP"
    echo

else

    echo "[INFO] No valid $PLATFORM release build found."
    echo "[INFO] Building Flutter $PLATFORM application..."
    echo
    echo "[COMMAND] $FLUTTER_BUILD_COMMAND"
    echo

    cd "$FRONTEND"

    $FLUTTER_BUILD_COMMAND \
        || error_exit "Flutter $PLATFORM release build failed."

    echo
    echo "[OK] Flutter $PLATFORM release build completed."
    echo

fi

# ------------------------------------------------------------
# FIND RELEASE BUILD
# ------------------------------------------------------------

if [[ "$PLATFORM" == "Linux" ]]; then

    FLUTTER_APP="$(
        find "$RELEASE_BUILD" \
            -maxdepth 1 \
            -type f \
            -executable \
            -print \
            -quit
    )"

elif [[ "$PLATFORM" == "macOS" ]]; then

    FLUTTER_APP="$(
        find "$RELEASE_BUILD" \
            -maxdepth 1 \
            -type d \
            -name "*.app" \
            -print \
            -quit
    )"

fi

# ------------------------------------------------------------
# VALIDATE RELEASE BUILD
# ------------------------------------------------------------

if [[ -z "$FLUTTER_APP" ]]; then

    error_exit \
        "$PLATFORM Flutter release application was not found after build."

fi

echo "[INFO] Flutter application:"
echo "       $FLUTTER_APP"
echo

# -----------------------------------------------------------
# MOVE Executable File And Data Into /build
# ------------------------------------------------------------

echo [INFO] Moving Build Files In /build...
echo

mkdir -p $MOVE_BUILD

cp -r "$BUILD_SOURCE/"* "$MOVE_BUILD/"

echo [INFO] Cleaning Up Build Temporary Data...

flutter clean

echo [OK] Cleaned Build Temporary Data

echo "============================================================"
echo "                 BUILD SUCCESSFUL"
echo "============================================================"
echo