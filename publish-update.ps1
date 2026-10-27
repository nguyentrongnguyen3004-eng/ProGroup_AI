param(
    [string]$Version = "",
    [string]$Changelog = "Cap nhat tinh nang moi va cai thien hieu nang he thong."
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  PROGROUP AI - TU DONG DONG GOI VA PHAT HANH OTA " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

$root = $PSScriptRoot
$frontendDir = Join-Path $root "ProGroup_AI_Frontend\progroup_ai_frontend"
$backendDir = Join-Path $root "ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API"
$downloadsDir = Join-Path $backendDir "wwwroot\downloads"
$pubspecPath = Join-Path $frontendDir "pubspec.yaml"
$servicePath = Join-Path $frontendDir "lib\services\app_update_service.dart"
$versionJsonPath = Join-Path $downloadsDir "version.json"

if (-not (Test-Path $pubspecPath)) {
    Write-Error "Khong tim thay file pubspec.yaml tai: $pubspecPath"
}

# 0. Tu dong sao luu Database truoc khi dong goi
Write-Host "`n[0/5] Tu dong sao luu Co so du lieu..." -ForegroundColor Green
$backupScript = Join-Path $root "scripts\backup_database.ps1"
if (Test-Path $backupScript) {
    & $backupScript
}

# 1. Doc versionCode hien tai tu pubspec.yaml
$pubspecContent = Get-Content $pubspecPath -Raw
if ($pubspecContent -match "version:\s*([0-9\.]+)\+([0-9]+)") {
    $currentVer = $matches[1]
    $currentCode = [int]$matches[2]
} else {
    $currentVer = "1.0.2"
    $currentCode = 2
}

$newCode = $currentCode + 1
$newVer = if ($Version) { $Version } else {
    $parts = $currentVer.Split('.')
    if ($parts.Length -eq 3) {
        "$($parts[0]).$($parts[1]).$([int]$parts[2] + 1)"
    } else {
        "$currentVer.$newCode"
    }
}

Write-Host "`n[1/4] Nang phien ban:" -ForegroundColor Green
Write-Host "      Tu: v$currentVer (code $currentCode)"
Write-Host "      -> Len: v$newVer (code $newCode)"

# Cap nhat pubspec.yaml
$newPubspec = $pubspecContent -replace "version:\s*[0-9\.]+\+[0-9]+", "version: $newVer+$newCode"
Set-Content -Path $pubspecPath -Value $newPubspec -NoNewline

# Cap nhat app_update_service.dart
$serviceContent = Get-Content $servicePath -Raw
$serviceContent = $serviceContent -replace "currentVersion = '[^']+';", "currentVersion = '$newVer';"
$serviceContent = $serviceContent -replace "currentVersionCode = [0-9]+;", "currentVersionCode = $newCode;"
Set-Content -Path $servicePath -Value $serviceContent -NoNewline

# 2. Build APK
Write-Host "`n[2/4] Dang dong goi APK moi (flutter build apk --debug)..." -ForegroundColor Green
Push-Location $frontendDir
try {
    & "C:\Users\ACER\flutter\bin\flutter.bat" build apk --debug
} finally {
    Pop-Location
}

$apkSource = Join-Path $frontendDir "build\app\outputs\flutter-apk\app-debug.apk"
if (-not (Test-Path $apkSource)) {
    Write-Error "Build that bai, khong tim thay file APK tai: $apkSource"
}

# 3. Copy APK vao wwwroot/downloads cua Backend
Write-Host "`n[3/4] Dang copy file APK vao thu muc may chu Backend..." -ForegroundColor Green
if (-not (Test-Path $downloadsDir)) {
    New-Item -ItemType Directory -Path $downloadsDir -Force | Out-Null
}
$apkDest = Join-Path $downloadsDir "app-latest.apk"
Copy-Item -Path $apkSource -Destination $apkDest -Force

$apkSizeMB = [math]::Round(((Get-Item $apkDest).Length / 1MB), 1)

# 4. Ghi metadata version.json cho Backend API
Write-Host "`n[4/4] Cap nhat version.json cho may chu..." -ForegroundColor Green
$meta = @{
    version = $newVer
    versionCode = $newCode
    minSupportedVersion = "1.0.0"
    changelog = $Changelog
    isForceUpdate = $false
    fileSize = "$apkSizeMB MB"
    releaseDate = (Get-Date).ToString("dd/MM/yyyy HH:mm")
}
$meta | ConvertTo-Json -Depth 5 | Set-Content -Path $versionJsonPath -Encoding UTF8

# 5. Tu dong dong bo ma nguon len GitHub
Write-Host "`n[Tu dong] Dang dong bo ma nguon moi len GitHub..." -ForegroundColor Green
try {
    Push-Location $root
    git add .
    git commit -m "chore(release): bump version to v$newVer (build $newCode) - $Changelog"
    git push origin main
    Write-Host "          Da day ma nguon len GitHub thanh cong!" -ForegroundColor Gray
} catch {
    Write-Host "          (Luu y: Khong the day len GitHub)" -ForegroundColor Yellow
} finally {
    Pop-Location
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " PHAT HANH BAN CAP NHAT THANH CONG!" -ForegroundColor Yellow
Write-Host " Phien ban moi : v$newVer (Build $newCode)" -ForegroundColor White
Write-Host " Dung luong    : $apkSizeMB MB" -ForegroundColor White
Write-Host " May chu & Git : Da cap nhat day du" -ForegroundColor White
Write-Host " Nguoi dung mo app tren dien thoai se tu dong" -ForegroundColor Green
Write-Host " nhan duoc thong bao cap nhat ngay lap tuc!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
