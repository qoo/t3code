@echo off
rem Double-click launcher for the Electron dev client (`pnpm dev:desktop`).
rem Use this instead of dev.bat when you don't want to pair a browser: the
rem Electron shell launches the backend itself in desktop mode and hands it a
rem credential over trusted IPC, so no pairing URL is involved.
setlocal
title T3 Code - dev:desktop

cd /d "%~dp0"

rem This path runs a production web build, whose third-party-licenses plugin
rem downloads SPDX license texts with Node's global fetch. undici ignores
rem HTTP(S)_PROXY unless this is set, so behind a proxy the build dies with
rem "ConnectTimeoutError" on raw.githubusercontent.com. Harmless with no proxy
rem configured: it only tells Node to honour the standard proxy variables.
set "NODE_USE_ENV_PROXY=1"

rem The Electron renderer loads the dev app over the t3code-dev:// protocol.
rem Unbundled dev issues one request per module, which drowns Chromium's net
rem stack in ERR_INSUFFICIENT_RESOURCES and fails the app's dynamic import.
rem Bundled dev collapses that into a few chunks. The dev runner already
rem defaults this on for --share runs for the same reason; the mode is still
rem marked experimental upstream, so drop this line if you hit bundler-only bugs.
set "T3CODE_BUNDLED_DEV=1"

rem Dev windows open detached DevTools by default. Skip it here; Ctrl+Shift+I
rem (View > Toggle Developer Tools) still opens it on demand.
set "T3CODE_DESKTOP_NO_DEVTOOLS=1"

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
  echo [dev:desktop] If Electron itself failed to launch, reinstall its runtime:
  echo [dev:desktop]   node node_modules\.pnpm\electron@44.1.0\node_modules\electron\install.js
  echo [dev:desktop] Prefer that over `ensure:electron`, which unzips with python3
  echo [dev:desktop] and dies on Windows against the Microsoft Store python stub.
)
echo [dev:desktop] Window kept open so you can read the output.
pause
exit /b %DEV_EXIT%
