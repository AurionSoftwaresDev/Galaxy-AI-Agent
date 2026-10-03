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

setlocal enabledelayedexpansion

set "CURRENT_SCRIPT_DIR=%~dp0"

for %%I in ("%CURRENT_SCRIPT_DIR%..\..") do set "ROOT=%%~fI\.galaxy"

if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "BACKEND=%ROOT%\server"
set "VENV=%BACKEND%\.venv"
set "VENV_PYTHON=%VENV%\Scripts\python.exe"

set "BACKEND_TEMP=%ROOT%\build\cache"
set "BACKEND_BUILD=%ROOT%\build\"
set "BACKEND_BUILD_TEMP_DATA=%ROOT%\build\data"

echo [INFO] Project:
echo        %ROOT%
echo.

REM ------------------------------------------------------------
REM CHECK BACKEND
REM ------------------------------------------------------------

if not exist "%BACKEND%" (
    echo [ERROR] backend folder not found.
    echo.
    pause
    exit /b 1
)

if not exist "%BACKEND%\startGalaxy.py" (
    echo [ERROR] backend\startGalaxy.py Server File Not Found.
    echo.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM FIND PYTHON
REM ------------------------------------------------------------

echo [INFO] Checking Python...

set "PYTHON_CMD="

where py >nul 2>&1

if not errorlevel 1 (
    py -3 --version >nul 2>&1

    if not errorlevel 1 (
        set "PYTHON_CMD=py -3"
    )
)

if not defined PYTHON_CMD (
    where python >nul 2>&1

    if not errorlevel 1 (
        python --version >nul 2>&1

        if not errorlevel 1 (
            set "PYTHON_CMD=python"
        )
    )
)

REM ------------------------------------------------------------
REM INSTALL PYTHON IF MISSING
REM ------------------------------------------------------------

if not defined PYTHON_CMD (

    echo [WARNING] Python was not found.
    echo [INFO] Trying to install Python using winget...
    echo.

    where winget >nul 2>&1

    if errorlevel 1 (
        echo [ERROR] winget is not available.
        echo.
        echo Please install Python 3 from:
        echo https://www.python.org/downloads/windows/
        echo.
        echo IMPORTANT:
        echo Enable "Add Python to PATH" during installation.
        echo.
        pause
        exit /b 1
    )

    winget install --id Python.Python.3.13 -e ^
        --accept-package-agreements ^
        --accept-source-agreements

    if errorlevel 1 (
        echo.
        echo [ERROR] Python installation failed.
        echo.
        pause
        exit /b 1
    )

    echo.
    echo [INFO] Python installation finished.
    echo [INFO] Starting a new environment check...
    echo.

    where py >nul 2>&1

    if not errorlevel 1 (
        py -3 --version >nul 2>&1

        if not errorlevel 1 (
            set "PYTHON_CMD=py -3"
        )
    )
)

if not defined PYTHON_CMD (
    echo.
    echo [ERROR] Python is installed but could not be detected.
    echo.
    echo Close this window and run startAgent.bat again.
    echo.
    pause
    exit /b 1
)

echo [OK] Python detected.
%PYTHON_CMD% --version
echo.

REM ------------------------------------------------------------
REM CREATE WINDOWS VIRTUAL ENVIRONMENT
REM ------------------------------------------------------------

if not exist "%VENV_PYTHON%" (

    echo [INFO] Creating Windows Python virtual environment...
    echo [INFO] Location:
    echo        %VENV%
    echo.

    %PYTHON_CMD% -m venv "%VENV%"

    if errorlevel 1 (
        echo.
        echo ============================================================
        echo [ERROR] Failed to create Python virtual environment.
        echo ============================================================
        echo.
        echo Python venv/ensurepip is unavailable.
        echo.
        echo Please repair/reinstall Python and make sure:
        echo   - pip is installed
        echo   - Python Launcher is installed
        echo   - standard library is installed
        echo.
        pause
        exit /b 1
    )

    echo [OK] Windows virtual environment created.
    echo.
) else (
    echo [OK] Existing Windows virtual environment found.
    echo.
)

REM ------------------------------------------------------------
REM CHECK VENV PYTHON
REM ------------------------------------------------------------

if not exist "%VENV_PYTHON%" (
    echo [ERROR] Virtual environment Python was not created correctly.
    echo.
    pause
    exit /b 1
)

echo [INFO] Virtual environment Python:
echo        %VENV_PYTHON%
echo.

REM ------------------------------------------------------------
REM UPGRADE PIP
REM ------------------------------------------------------------

echo [INFO] Updating pip...

"%VENV_PYTHON%" -m pip install --upgrade pip

if errorlevel 1 (
    echo.
    echo [ERROR] pip update failed.
    echo.
    pause
    exit /b 1
)

echo [OK] pip ready.
echo.

REM ------------------------------------------------------------
REM FIND REQUIREMENTS FILE
REM ------------------------------------------------------------

set "REQUIREMENTS="

if exist "%BACKEND%\requirements.txt" (
    set "REQUIREMENTS=%BACKEND%\requirements.txt"
)

if not defined REQUIREMENTS (
    if exist "%BACKEND%\requirement.txt" (
        set "REQUIREMENTS=%BACKEND%\requirement.txt"
    )
)

if not defined REQUIREMENTS (
    echo [WARNING] No requirements.txt found.
    echo [WARNING] Skipping Python dependency installation.
    echo.
) else (

    echo [INFO] Installing backend dependencies...
    echo        %REQUIREMENTS%
    echo.

    "%VENV_PYTHON%" -m pip install -r "%REQUIREMENTS%"

    if errorlevel 1 (
        echo.
        echo [ERROR] Failed to install Python dependencies.
        echo.
        echo Check:
        echo   %REQUIREMENTS%
        echo.
        pause
        exit /b 1
    )

    echo.
    echo [OK] Backend dependencies ready.
    echo.
)

echo [Info] Building Server Executable File...

if not exist "%ROOT%\build"
    md "%ROOT%\build"
)

pyinstaller --onefile %BACKEND%\startGalaxy.py --distpath %ROOT%\build --workpath %BACKEND_TEMP% --specpath %BACKEND_BUILD_TEMP_DATA%\server

echo [OK] Server Executable Created.