@echo off
cd /d "%~dp0"

echo ========================================
echo   Create admin user (fix login)
echo ========================================
echo.

if not exist "server\.env" (
    echo ERROR: server\.env not found.
    echo Copy server\.env.example to server\.env first.
    pause
    exit /b 1
)

echo Creating admin user...
echo Default login: admin@company.com / Admin@123
echo.

cd server
node src\scripts\seedAdmin.js
cd ..

echo.
echo If you see "Admin created" above, try logging in with:
echo   Email:    admin@company.com
echo   Password: Admin@123
echo.
pause
