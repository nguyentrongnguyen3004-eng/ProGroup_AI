@echo off
title Khoi dong He thong ProGroup AI Backend & Tunnel
echo ============================================================
echo      PROGROUP AI - KHOI DONG TOAN BO HE THONG BACKEND
echo ============================================================
echo.

if not exist "%~dp0tools\cloudflared.exe" (
    echo Dang tai cong cu cloudflared.exe ve may (chi tai 1 lan duy nhat)...
    if not exist "%~dp0tools" mkdir "%~dp0tools"
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile '%~dp0tools\cloudflared.exe'"
)

echo 1. Dang khoi dong Backend ASP.NET Core API tai cong 5094...
start "ProGroup_AI Backend API" cmd /k "cd /d "%~dp0ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API" && dotnet run --urls=http://0.0.0.0:5094"

timeout /t 5 /nobreak >nul

echo 2. Dang khoi dong Cloudflare Tunnel...
echo.
echo Khi man hinh hien thi link "https://....trycloudflare.com",
echo ban co the truy cap vao /swagger tren dien thoai de kiem tra.
echo ============================================================
echo.
"%~dp0tools\cloudflared.exe" tunnel --url http://127.0.0.1:5094
pause
