@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0auto-tailscale.ps1" %*
if errorlevel 1 (
  echo.
  echo Setup failed. Please read the error above.
  pause
  exit /b 1
)
echo.
echo Setup completed successfully.
pause
