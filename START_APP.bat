@echo off
cd /d "%~dp0"

echo Starting EMS (Backend + Frontend)...
echo.
echo Backend will run on: http://localhost:5000
echo Frontend will run on: http://localhost:5173
echo.
echo After you see "Local: http://localhost:5173" below,
echo open your browser and go to:  http://localhost:5173
echo.
echo Press Ctrl+C to stop the app.
echo ========================================

npm run dev

pause
