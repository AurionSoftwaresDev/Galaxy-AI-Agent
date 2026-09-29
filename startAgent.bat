@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM AI AGENT - WINDOWS STARTUP
REM ============================================================

echo.
echo ============================================================
echo                    AI AGENT STARTUP
echo ============================================================
echo.


REM ============================================================
REM ROOT DIRECTORIES
REM ============================================================

REM Directory where this batch file is located.
set "ROOT=%~dp0"

REM Remove trailing backslash.
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "BACKEND=%ROOT%\backend"
set "FRONTEND=%ROOT%\frontend"

REM Windows launcher always builds the Windows Flutter target.
set "FLUTTER_TARGET=windows"


REM ============================================================
REM VALIDATE PROJECT STRUCTURE
REM ============================================================

echo [INFO] Checking project structure...
echo.

if not exist "%BACKEND%\" (
    echo.
    echo [ERROR] Backend directory was not found:
    echo         %BACKEND%
    echo.
    pause
    exit /b 1
)

if not exist "%FRONTEND%\" (
    echo.
    echo [ERROR] Frontend directory was not found:
    echo         %FRONTEND%
    echo.
    pause
    exit /b 1
)

if not exist "%FRONTEND%\pubspec.yaml" (
    echo.
    echo [ERROR] Flutter project was not found:
    echo         %FRONTEND%\pubspec.yaml
    echo.
    pause
    exit /b 1
)

echo [OK] Project root:
echo      %ROOT%

echo [OK] Backend:
echo      %BACKEND%

echo [OK] Frontend:
echo      %FRONTEND%

echo.


REM ============================================================
REM CHECK WINDOWS
REM ============================================================

echo [INFO] Detecting operating system...
echo.

if /I not "%OS%"=="Windows_NT" (
    echo.
    echo [ERROR] This launcher is designed for Windows.
    echo.
    pause
    exit /b 1
)

echo [OK] Windows detected.
echo [OK] Flutter target: %FLUTTER_TARGET%
echo.


REM ============================================================
REM CHECK FLUTTER
REM ============================================================

echo [INFO] Checking Flutter installation...
echo.

where flutter >nul 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Flutter was not found in PATH.
    echo.
    echo Please install Flutter and add it to PATH.
    echo.
    pause
    exit /b 1
)

for /f "delims=" %%F in ('where flutter') do (
    echo [OK] Flutter:
    echo      %%F
    goto FLUTTER_FOUND
)

:FLUTTER_FOUND

echo.


REM ============================================================
REM MOVE TO FRONTEND
REM ============================================================

cd /d "%FRONTEND%"

if errorlevel 1 (
    echo.
    echo [ERROR] Could not enter Flutter frontend directory.
    echo.
    pause
    exit /b 1
)


REM ============================================================
REM FLUTTER DEPENDENCIES
REM ============================================================

echo ============================================================
echo                 FLUTTER DEPENDENCIES
echo ============================================================
echo.

echo [INFO] Checking Flutter dependencies...
echo.

call flutter pub get

if errorlevel 1 (
    echo.
    echo ============================================================
    echo [ERROR] Flutter dependency installation failed.
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Flutter dependencies are ready.
echo.


REM ============================================================
REM FLUTTER RELEASE BUILD
REM ============================================================

echo ============================================================
echo                 FLUTTER RELEASE BUILD
echo ============================================================
echo.

set "BUILD_REQUIRED=1"

echo [INFO] Checking existing Windows release build...
echo.


REM ============================================================
REM WINDOWS BUILD CHECK
REM ============================================================

set "WINDOWS_BUILD=%FRONTEND%\build\windows\x64\runner\Release"

if exist "%WINDOWS_BUILD%\" (

    dir /b "%WINDOWS_BUILD%\*.exe" >nul 2>&1

    if not errorlevel 1 (
        set "BUILD_REQUIRED=0"

        echo [OK] Existing Windows release build found.
        echo      %WINDOWS_BUILD%
    )

)


REM ============================================================
REM BUILD APPLICATION IF REQUIRED
REM ============================================================

if "%BUILD_REQUIRED%"=="1" (

    echo.
    echo [INFO] No valid Windows release build was found.
    echo [INFO] Building Flutter application...
    echo.
    echo [COMMAND] flutter build windows
    echo.

    call flutter build windows

    if errorlevel 1 (
        echo.
        echo ============================================================
        echo [ERROR] Flutter release build failed.
        echo ============================================================
        echo.
        pause
        exit /b 1
    )

    echo.
    echo [OK] Flutter release build completed successfully.
    echo.

) else (

    echo.
    echo [OK] Valid Windows release build already exists.
    echo [INFO] Skipping Flutter build.
    echo.

)


REM ============================================================
REM FIND FLUTTER EXECUTABLE
REM ============================================================

echo ============================================================
echo                 STARTING AI AGENT APP
echo ============================================================
echo.

set "FLUTTER_APP="

for /f "delims=" %%F in (
    'dir /b "%WINDOWS_BUILD%\*.exe" 2^>nul'
) do (
    if not defined FLUTTER_APP (
        set "FLUTTER_APP=%WINDOWS_BUILD%\%%F"
    )
)


REM ============================================================
REM VALIDATE FLUTTER EXECUTABLE
REM ============================================================

if not defined FLUTTER_APP (

    echo.
    echo [ERROR] Windows Flutter executable was not found.
    echo.
    echo Expected:
    echo   %WINDOWS_BUILD%\*.exe
    echo.
    pause
    exit /b 1

)


echo [INFO] Windows executable found:
echo        !FLUTTER_APP!
echo.


REM ============================================================
REM START FLUTTER APPLICATION
REM ============================================================

echo [INFO] Starting Flutter application...
echo.

start "AI Agent Flutter App" "!FLUTTER_APP!"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to start Flutter application.
    echo.
    pause
    exit /b 1
)

echo [OK] Flutter application started.
echo.


REM ============================================================
REM WAIT FOR FLUTTER APPLICATION
REM ============================================================

echo [INFO] AI Agent is running.
echo [INFO] Close the Flutter application to continue.
echo.

:WAIT_FOR_FLUTTER

tasklist /FI "WINDOWTITLE eq AI Agent Flutter App*" 2>nul | find /I "AI Agent Flutter App" >nul

if not errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto WAIT_FOR_FLUTTER
)


REM ============================================================
REM FLUTTER APPLICATION CLOSED
REM ============================================================

echo.
echo ============================================================
echo                 FLUTTER APPLICATION CLOSED
echo ============================================================
echo.


REM ============================================================
REM CLEANUP BACKEND
REM ============================================================

echo [INFO] Stopping backend...

taskkill /FI "WINDOWTITLE eq AI Agent Backend*" /T /F >nul 2>&1

if errorlevel 1 (
    echo [INFO] No running backend window was found.
) else (
    echo [OK] Backend stopped.
)

echo.


REM ============================================================
REM RETURN TO PROJECT ROOT
REM ============================================================

cd /d "%ROOT%"

echo [OK] AI Agent closed normally.
echo.

pause
exit /b 0