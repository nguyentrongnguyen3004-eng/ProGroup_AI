@echo off
setlocal
cd /d "%~dp0"
title Khoi dong He thong ProGroup AI Backend
echo ============================================================
echo      PROGROUP AI - KHOI DONG TOAN BO HE THONG BACKEND
echo ============================================================
echo.

echo 0. Dang giai phong cong va tien trinh cu neu co...
taskkill /F /IM ProGroup_AI.API.exe >nul 2>&1

echo 1. Dang tu dong sao luu Co so du lieu truoc khi van hanh...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\backup_database.ps1"
echo.

echo 2. Dang khoi dong Backend ASP.NET Core API tai cong 5094...
if exist "%~dp0ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API\bin\Debug\net10.0\ProGroup_AI.API.exe" (
    start "ProGroup_AI Backend API" /D "%~dp0ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API" cmd /k "bin\Debug\net10.0\ProGroup_AI.API.exe --urls=http://0.0.0.0:5094"
) else (
    start "ProGroup_AI Backend API" /D "%~dp0ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API" cmd /k "dotnet run --urls=http://0.0.0.0:5094"
)

REM Tu dong thiet lap cau noi qua cap USB neu co cam dien thoai
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" reverse tcp:5094 tcp:5094 >nul 2>&1
)

timeout /t 3 /nobreak >nul

echo ============================================================
echo THONG TIN KET NOI CHO DIEN THOAI:
echo.
echo [CACH 1 - QUA CAP USB] Neu dang cam day cap:
echo    Dia chi API: http://127.0.0.1:5094 hoac http://localhost:5094
echo    (Da duoc tu dong thiet lap cau noi ADB Reverse)
echo.
echo [CACH 2 - QUA WI-FI] Neu dien thoai dung CHUNG WI-FI voi Laptop:
echo    Dia chi API: http://192.168.1.109:5094
echo    (Test tren trinh duyet dien thoai: http://192.168.1.109:5094/api/health)
echo ============================================================
echo.
echo He thong Backend da san sang hoat dong!
pause
