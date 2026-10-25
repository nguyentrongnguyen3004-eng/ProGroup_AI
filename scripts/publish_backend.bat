@echo off
title Dong goi Backend ProGroup AI de Deploy Cloud
echo ============================================================
echo   PROGROUP AI - DONG GOI BACKEND (DOTNET PUBLISH)
echo ============================================================
echo.
cd /d "%~dp0..\ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API"
echo Dang build va publish ban Release...
dotnet publish -c Release -o "%~dp0..\publish_output"
echo.
echo ============================================================
echo Hoan tat! Thu muc publish da duoc tao tai:
echo %~dp0..\publish_output
echo.
echo Ban co the nen zip toan bo file ben trong thu muc do va upload
echo len MonsterASP.NET hoac bat ky hosting nao!
echo ============================================================
pause
