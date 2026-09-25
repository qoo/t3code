@echo off
rem Double-click launcher for the Electron dev client (`pnpm dev:desktop`).
rem Use this instead of dev.bat when you don't want to pair a browser: the
rem Electron shell launches the backend itself in desktop mode and hands it a
rem credential over trusted IPC, so no pairing URL is involved.
setlocal
title T3 Code - dev:desktop

cd /d "%~dp0"

where pnpm >nul 2>nul
if errorlevel 1 (
  echo [dev:desktop] pnpm was not found on PATH.
  echo [dev:desktop] Install it with:  npm install -g pnpm@11.10.0
  echo.
  pause
  exit /b 1
)

if not exist "node_modules\" (
  echo [dev:desktop] node_modules is missing - installing dependencies, this takes a while...
  echo.
  call pnpm install
  if errorlevel 1 (
    echo.
    echo [dev:desktop] pnpm install failed. Fix the error above and run this again.
    echo.
    pause
    exit /b 1
  )
  echo.
)

echo [dev:desktop] Starting the Electron client. Unlike dev.bat this does build:
echo [dev:desktop] the t3 server package, then the Electron main process in watch
echo [dev:desktop] mode, so the first launch is noticeably slower. The web layer
echo [dev:desktop] still hot-reloads afterwards.
echo.
echo [dev:desktop] Press Ctrl+C in this window to stop. Do not close it with the X,
echo [dev:desktop] which can leave the backend running and holding its port.
echo.

call pnpm dev:desktop
set "DEV_EXIT=%ERRORLEVEL%"

echo.
if not "%DEV_EXIT%"=="0" (
  echo [dev:desktop] dev:desktop exited with code %DEV_EXIT%.
  echo [dev:desktop] If Electron itself failed to launch, repair its runtime with:
  echo [dev:desktop]   pnpm --filter @t3tools/desktop ensure:electron
)
echo [dev:desktop] Window kept open so you can read the output.
pause
exit /b %DEV_EXIT%
