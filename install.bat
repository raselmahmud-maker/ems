@echo off
echo ========================================
echo   EMS - Employee Management System
echo   Installer
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Installing root dependencies...
call npm install
if errorlevel 1 goto error

echo.
echo [2/4] Installing server dependencies...
cd server
call npm install
if errorlevel 1 goto error
cd ..

echo.
echo [3/4] Installing client dependencies...
cd client
call npm install
if errorlevel 1 goto error
cd ..

echo.
echo ========================================
echo   Installation complete.
echo ========================================
echo.
echo Next steps:
echo   1. Copy server\.env.example to server\.env
echo   2. Set MONGODB_URI and JWT_SECRET in server\.env
echo   3. Run: node server\src\scripts\seedAdmin.js  (to create first admin)
echo   4. Run: npm run dev  (to start the app)
echo.
pause
exit /b 0

:error
echo.
echo Installation failed. Check the messages above.
pause
exit /b 1
