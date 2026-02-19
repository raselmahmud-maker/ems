@echo off
REM Opens the EMS project in Cursor (or VS Code if Cursor not installed)
cd /d "%~dp0"

where cursor >nul 2>nul
if %errorlevel% equ 0 (
    echo Opening in Cursor...
    start "" cursor "%cd%"
    goto done
)

where code >nul 2>nul
if %errorlevel% equ 0 (
    echo Opening in VS Code...
    start "" code "%cd%"
    goto done
)

echo.
echo No editor found in PATH.
echo Opening the project folder - you can then:
echo   1. Right-click inside the folder
echo   2. Choose "Open with Cursor" or "Open with Code"
echo   Or drag this folder into Cursor/VS Code window.
echo.
explorer "%cd%"
:done
