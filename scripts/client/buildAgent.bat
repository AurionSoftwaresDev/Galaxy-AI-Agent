@echo off
setlocal EnableExtensions EnableDelayedExpansion

title AI Agent - Windows Startup

echo.
echo ============================================================
echo                    AI AGENT STARTUP
echo ============================================================
echo.

REM ------------------------------------------------------------
REM ROOT DIRECTORY
REM ------------------------------------------------------------

set "CURRENT_SCRIPT_DIR=%~dp0"

for %%I in ("%CURRENT_SCRIPT_DIR%..\..") do set "ROOT=%%~fI\"

if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "FRONTEND=%ROOT%\.galaxy\client"

set "WINDOWS_BUILD_FOLDER_NAME=Release"
set "WINDOWS_BUILD_MOVE=%ROOT%\build"
set "WINDOWS_BUILD_DATA=%WINDOWS_BUILD_MOVE%\data"
set "WINDOWS_BUILD=%FRONTEND%\build\windows\x64\runner\%WINDOWS_BUILD_FOLDER_NAME%"
set "BUILD_REQUIRED=1"
set "FLUTTER_APP="

echo [INFO] Project:
echo        %ROOT%
echo.

REM ------------------------------------------------------------
REM CHECK FRONTEND
REM ------------------------------------------------------------

if not exist "%FRONTEND%" (
    echo [ERROR] frontend folder not found.
    echo.
    pause
    exit /b 1
)

if not exist "%FRONTEND%\pubspec.yaml" (
    echo [ERROR] frontend\pubspec.yaml Dependencies File Not Found.
    echo.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM CHECK FLUTTER
REM ------------------------------------------------------------

echo [INFO] Checking Flutter...

where flutter >nul 2>&1

if errorlevel 1 (

    echo [WARNING] Flutter was not found.
    echo.

    where winget >nul 2>&1

    if not errorlevel 1 (
        echo [INFO] Trying to install Flutter using winget...
        echo.

        winget install --id Flutter.Flutter -e ^
            --accept-package-agreements ^
            --accept-source-agreements

        if errorlevel 1 (
            echo.
            echo [ERROR] Flutter installation failed.
            echo.
            echo Install Flutter manually and run this file again.
            echo.
            pause
            exit /b 1
        )

        echo.
        echo [INFO] Flutter installation finished.
        echo [INFO] Close this window and run startAgent.bat again.
        echo.
        pause
        exit /b 0
    )

    echo [ERROR] Flutter is not installed.
    echo.
    echo Install Flutter and run this file again.
    echo.
    pause
    exit /b 1
)

echo [OK] Flutter detected.
call flutter --version
echo.

REM ------------------------------------------------------------
REM CHECK WINDOWS FLUTTER SUPPORT
REM ------------------------------------------------------------

echo [INFO] Checking Flutter Windows support...

call flutter devices

echo.

REM ------------------------------------------------------------
REM FLUTTER DEPENDENCIES
REM ------------------------------------------------------------

echo [INFO] Preparing Flutter dependencies...

cd /d "%FRONTEND%"

call flutter pub get

if errorlevel 1 (
    echo.
    echo [ERROR] Flutter dependency installation failed.
    echo.
    cd /d "%ROOT%"
    pause
    exit /b 1
)

echo.
echo [OK] Flutter dependencies ready.
echo.

REM ------------------------------------------------------------
REM FLUTTER RELEASE BUILD
REM ------------------------------------------------------------

echo ============================================================
echo                 FLUTTER RELEASE BUILD
echo ============================================================
echo.

echo [INFO] Checking existing Windows release build...
echo.


REM ------------------------------------------------------------
REM CHECK EXISTING RELEASE BUILD
REM ------------------------------------------------------------

if exist "%WINDOWS_BUILD%\" (

    for /f "delims=" %%F in (
        'dir /b /a:-d "%WINDOWS_BUILD%\*.exe" 2^>nul'
    ) do (

        set "FLUTTER_APP=%WINDOWS_BUILD%\%%F"
        set "BUILD_REQUIRED=0"

        goto FOUND_EXISTING_BUILD
    )
)


:FOUND_EXISTING_BUILD

if "%BUILD_REQUIRED%"=="0" (

    echo [OK] Existing Windows release build found.
    echo      !FLUTTER_APP!
    echo.

) else (

    echo [INFO] No Windows release build found.
    echo [INFO] Building Flutter Windows application...
    echo.
    echo [COMMAND] flutter build windows
    echo.

    cd /d "%FRONTEND%"

    call flutter build windows

    if errorlevel 1 (
        echo.
        echo ============================================================
        echo [ERROR] Flutter Windows release build failed.
        echo ============================================================
        echo.
        cd /d "%ROOT%"
        pause
        exit /b 1
    )

    echo.
    echo [OK] Flutter Windows release build completed.
    echo.

)

REM ------------------------------------------------------------
REM FIND RELEASE EXECUTABLE
REM ------------------------------------------------------------

set "FLUTTER_APP="

for /f "delims=" %%F in (
    'dir /b /a:-d "%WINDOWS_BUILD%\*.exe" 2^>nul'
) do (

    if not defined FLUTTER_APP (
        set "FLUTTER_APP=%WINDOWS_BUILD%\%%F"
    )
)

REM ------------------------------------------------------------
REM VALIDATE RELEASE EXECUTABLE
REM ------------------------------------------------------------

if not defined FLUTTER_APP (

    echo.
    echo ============================================================
    echo [ERROR] Flutter Windows executable was not found.
    echo ============================================================
    echo.
    echo Expected:
    echo   %WINDOWS_BUILD%\*.exe
    echo.

    cd /d "%ROOT%"
    pause
    exit /b 1
)

echo [INFO] Flutter executable:
echo        !FLUTTER_APP!
echo.

REM ------------------------------------------------------------
REM MOVE Executable File And Data Into /build
REM ------------------------------------------------------------

echo [INFO] Moving Build Files In /build...
echo

if not exist %WINDOWS_BUILD_MOVE% (
    md "%WINDOWS_BUILD_MOVE%"
)

robocopy "%WINDOWS_BUILD%" "%WINDOWS_BUILD_MOVE%" /E /R:3 /W:5

echo "[OK] Files Successfully Moved."

echo "[INFO] Clean Up Build..."

call flutter clean

echo "[OK] Cleaned Up Build"
