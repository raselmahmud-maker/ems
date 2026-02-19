@echo off
echo Creating ems-for-github folder (without node_modules)...
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0prepare-for-github-upload.ps1"
echo.
echo If the folder opened, you can close this window.
pause
