@echo off
chcp 65001 >nul
title Phát hành bản cập nhật tự động - ProGroup AI
echo ============================================================
echo      PROGROUP AI - PHÁT HÀNH BẢN CẬP NHẬT TỰ ĐỘNG (OTA)
echo ============================================================
echo.
set /p "CHANGELOG=Nhập nội dung cập nhật (hoặc ấn Enter để dùng mặc định): "

if "%CHANGELOG%"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-update.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-update.ps1" -Changelog "%CHANGELOG%"
)

echo.
pause
