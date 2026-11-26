@echo off
title Khoi dong May ao Android (Toi uu toc do mang)
echo ============================================================
echo   PROGROUP AI - KHOI CHAY MAY AO ANDROID VOI TOI UU MANG
echo ============================================================
echo.

set "EMULATOR_EXE=%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe"
if not exist "%EMULATOR_EXE%" (
    set "EMULATOR_EXE=C:\Users\ACER\AppData\Local\Android\Sdk\emulator\emulator.exe"
)

set "ADB_EXE=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not exist "%ADB_EXE%" (
    set "ADB_EXE=adb"
)

echo 1. Dang khoi chay may ao Pixel_7_Pro_API_34 (Loai bo do tre mang ao)...
start "Pixel 7 Pro Emulator" "%EMULATOR_EXE%" -avd Pixel_7_Pro_API_34 -gpu host -netdelay none -netspeed full -dns-server 8.8.8.8,1.1.1.1

echo.
echo 2. Dang cho may ao khoi dong hoan tat de thiet lap cau noi toc do cao ADB Reverse...
"%ADB_EXE%" wait-for-device

echo 3. Dang thiet lap cau noi ADB Reverse (127.0.0.1:5094 -> Host 5094)...
"%ADB_EXE%" reverse tcp:5094 tcp:5094

echo.
echo ============================================================
echo [HOAN TAT] May ao da san sang va cau noi toc do cao da duoc kich hoat!
echo - Dia chi API tren may ao: http://127.0.0.1:5094
echo - Uu diem: Du lieu truyen truc tiep qua ADB Bridge, khong bi tre do router ao!
echo ============================================================
echo.
pause
