@echo off
title Ket noi ProGroup AI qua cap USB (ADB Reverse)
echo ============================================================
echo   PROGROUP AI - KET NOI DIEN THOAI QUA CAP USB (ADB REVERSE)
echo ============================================================
echo.

set "ADB_PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not exist "%ADB_PATH%" (
    where adb >nul 2>&1
    if %errorlevel% equ 0 (
        set "ADB_PATH=adb"
    ) else (
        echo [LOI] Khong tim thay cong cu adb.exe tren may tinh!
        pause
        exit /b
    )
)

echo 1. Dang kiem tra dien thoai cam cap USB...
"%ADB_PATH%" devices
echo.

echo 2. Dang thiet lap cau noi mang USB toi cong 5094...
"%ADB_PATH%" reverse tcp:5094 tcp:5094

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo [THANH CONG] Dien thoai da duoc ket noi voi Backend qua cap USB!
    echo.
    echo Gio day tren app dien thoai, moi ket noi den:
    echo   http://127.0.0.1:5094 hoac http://localhost:5094
    echo deu se truyen truc tiep qua day cap USB voi toc do cuc nhanh!
    echo ============================================================
) else (
    echo.
    echo [THAT BAI] Khong the map cong qua cap USB.
    echo Vui long kiem tra:
    echo  1. Da bat "Go loi USB" (USB Debugging) tren dien thoai chua.
    echo  2. Da chap nhan "Cho phep go loi USB" tren man hinh dien thoai chua.
    echo ============================================================
)
echo.
pause
