@echo off
title Build APK ProGroup AI
echo ============================================================
echo   PROGROUP AI - DONG GOI FILE APK MOI NHAT CHO DIEN THOAI
echo ============================================================
echo.
cd /d "%~dp0ProGroup_AI_Frontend\progroup_ai_frontend"

echo 1. Dang kiem tra dependencies...
call flutter pub get

echo.
echo 2. Dang build file APK...
call flutter build apk --debug

echo.
echo ============================================================
echo HOAN TAT! File APK moi nhat da duoc tao tai:
echo %~dp0ProGroup_AI_Frontend\progroup_ai_frontend\build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Ban chi can copy file app-debug.apk nay sang dien thoai va cai dat!
echo ============================================================
pause
