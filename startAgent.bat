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

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "BACKEND=%ROOT%\backend"
set "FRONTEND=%ROOT%\frontend"
set "VENV=%BACKEND%\.venv"
set "VENV_PYTHON=%VENV%\Scripts\python.exe"

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
    echo [ERROR] backend\startGalaxy.py not found.
    echo.
    pause
    exit /b 1
)

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
    echo [ERROR] frontend\pubspec.yaml not found.
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
REM START BACKEND
REM ------------------------------------------------------------

echo [INFO] Starting AI Agent backend...
echo.

if exist "%BACKEND%\backend.log" del /q "%BACKEND%\backend.log" >nul 2>&1
if exist "%BACKEND%\backend-error.log" del /q "%BACKEND%\backend-error.log" >nul 2>&1

start "AI Agent Backend" /min cmd /c ^
"cd /d ""%BACKEND%"" && ""%VENV_PYTHON%"" -u ""%BACKEND%\startGalaxy.py"" 1>""%BACKEND%\backend.log"" 2>""%BACKEND%\backend-error.log"""

timeout /t 3 /nobreak >nul

echo [OK] Backend process started.
echo.

REM ------------------------------------------------------------
REM CHECK BACKEND PROCESS
REM ------------------------------------------------------------

tasklist /FI "IMAGENAME eq python.exe" 2>nul | find /I "python.exe" >nul

if errorlevel 1 (
    echo [WARNING] Python backend process may have stopped.
    echo.
    echo Check:
    echo   %BACKEND%\backend.log
    echo   %BACKEND%\backend-error.log
    echo.
) else (
    echo [OK] Backend Python process is running.
    echo.
)

REM ------------------------------------------------------------
REM FLUTTER RELEASE BUILD
REM ------------------------------------------------------------

echo ============================================================
echo                 FLUTTER RELEASE BUILD
echo ============================================================
echo.

set "WINDOWS_BUILD=%FRONTEND%\build\windows\x64\runner\Release"
set "BUILD_REQUIRED=1"
set "FLUTTER_APP="

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
REM START FLUTTER RELEASE APPLICATION
REM ------------------------------------------------------------

echo ============================================================
echo                 STARTING AI AGENT APP
echo ============================================================
echo.

echo [INFO] Starting release application...
echo.

start "AI Agent Flutter App" "!FLUTTER_APP!"

if errorlevel 1 (

    echo.
    echo ============================================================
    echo [ERROR] Failed to start Flutter application.
    echo ============================================================
    echo.

    cd /d "%ROOT%"
    pause
    exit /b 1
)

echo [OK] Flutter application started.

set "FLUTTER_EXIT=0"

cd /d "%ROOT%"

echo [OK] AI Agent closed normally.

echo.
pause
exit /b %FLUTTER_EXIT%