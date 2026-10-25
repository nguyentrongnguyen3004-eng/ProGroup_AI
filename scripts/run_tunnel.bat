@echo off
title Cloudflare Tunnel - ProGroup AI
echo ============================================================
echo   PROGROUP AI - KHOI DONG DUONG HAM CLOUDFLARE TUNNEL (FREE)
echo ============================================================
echo.

if not exist "%~dp0..\tools\cloudflared.exe" (
    echo Dang tai cong cu cloudflared.exe ve may (chi tai 1 lan duy nhat)...
    if not exist "%~dp0..\tools" mkdir "%~dp0..\tools"
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile '%~dp0..\tools\cloudflared.exe'"
)

echo Dang ket noi cong 5094 ra Internet qua HTTPS bao mat...
echo Vui long sao chep duong link co duoi .trycloudflare.com ben duoi:
echo.
"%~dp0..\tools\cloudflared.exe" tunnel --url http://127.0.0.1:5094
pause
