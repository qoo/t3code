@echo off
rem Double-click launcher for the T3 Code dev servers (server + web).
rem Dev runs straight from TypeScript source, so there is no build step here.
setlocal
title T3 Code - dev

cd /d "%~dp0"

where pnpm >nul 2>nul
if errorlevel 1 (
  echo [dev] pnpm was not found on PATH.
  echo [dev] Install it with:  npm install -g pnpm@11.10.0
  echo.
  pause
  exit /b 1
)

if not exist "node_modules\" (
  echo [dev] node_modules is missing - installing dependencies, this takes a while...
  echo.
  call pnpm install
  if errorlevel 1 (
    echo.
    echo [dev] pnpm install failed. Fix the error above and run this again.
    echo.
    pause
    exit /b 1
  )
  echo.
)

echo [dev] Starting T3 Code. Watch for the [dev-runner] line below - it prints
echo [dev] the real server and web URLs, which are derived from this checkout's
echo [dev] path rather than being fixed. Press Ctrl+C to stop.
echo.

call pnpm dev
set "DEV_EXIT=%ERRORLEVEL%"

echo.
if not "%DEV_EXIT%"=="0" echo [dev] dev exited with code %DEV_EXIT%.
echo [dev] Window kept open so you can read the output.
pause
exit /b %DEV_EXIT%
