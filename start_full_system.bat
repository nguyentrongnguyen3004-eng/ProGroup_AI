@echo off
setlocal
cd /d "%~dp0"
title Khoi dong He thong ProGroup AI Backend va Tunnel
echo ============================================================
echo      PROGROUP AI - KHOI DONG TOAN BO HE THONG BACKEND
echo ============================================================
echo.

echo 0. Dang giai phong cong va tien trinh cu neu co...
taskkill /F /IM ProGroup_AI.API.exe >nul 2>&1
taskkill /F /IM cloudflared.exe >nul 2>&1

if not exist "%~dp0tools\cloudflared.exe" (
    echo Dang tai cong cu cloudflared.exe ve may - chi tai 1 lan duy nhat...
    if not exist "%~dp0tools" mkdir "%~dp0tools"
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile '%~dp0tools\cloudflared.exe'"
)

echo 1. Dang tu dong sao luu Co so du lieu truoc khi van hanh...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\backup_database.ps1"
echo.

echo 2. Dang khoi dong Backend ASP.NET Core API tai cong 5094...
if exist "%~dp0ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API\bin\Debug\net10.0\ProGroup_AI.API.exe" (
    start "ProGroup_AI Backend API" /D "%~dp0ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API" cmd /k "bin\Debug\net10.0\ProGroup_AI.API.exe --urls=http://0.0.0.0:5094"
) else (
    start "ProGroup_AI Backend API" /D "%~dp0ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API" cmd /k "dotnet run --urls=http://0.0.0.0:5094"
)

timeout /t 5 /nobreak >nul

echo ============================================================
echo THONG TIN KET NOI CHO DIEN THOAI:
echo.
echo [CACH 1 - NHANH NHAT] Neu dien thoai dung CHUNG WI-FI voi Laptop:
echo    Dia chi API: http://192.168.1.109:5094
echo    (Test tren trinh duyet dien thoai: http://192.168.1.109:5094/api/health)
echo.
echo [CACH 2] Neu dung 4G hoac mang khac:
echo    (Vui long xem link .trycloudflare.com duoc Cloudflare cap ben duoi)
echo ============================================================
echo.
"%~dp0tools\cloudflared.exe" tunnel --url http://127.0.0.1:5094
pause
