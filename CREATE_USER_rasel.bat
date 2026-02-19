@echo off
cd /d "%~dp0"

echo Creating user: rasel@maam.sa / Farhan784 (admin, approved)
echo.

cd server
node src\scripts\createUser.js
cd ..

echo.
pause
