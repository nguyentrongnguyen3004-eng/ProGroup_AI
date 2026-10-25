param(
    [string]$Version = "",
    [string]$Changelog = "• Cập nhật tính năng mới và cải thiện hiệu năng hệ thống."
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  PROGROUP AI - TỰ ĐỘNG ĐÓNG GÓI & PHÁT HÀNH OTA " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

$root = $PSScriptRoot
$frontendDir = Join-Path $root "ProGroup_AI_Frontend\progroup_ai_frontend"
$backendDir = Join-Path $root "ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API"
$downloadsDir = Join-Path $backendDir "wwwroot\downloads"
$pubspecPath = Join-Path $frontendDir "pubspec.yaml"
$servicePath = Join-Path $frontendDir "lib\services\app_update_service.dart"
$versionJsonPath = Join-Path $downloadsDir "version.json"

if (-not (Test-Path $pubspecPath)) {
    Write-Error "Không tìm thấy file pubspec.yaml tại: $pubspecPath"
}

# 1. Đọc versionCode hiện tại từ pubspec.yaml
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

Write-Host "`n[1/4] Nâng phiên bản:" -ForegroundColor Green
Write-Host "      Từ: v$currentVer (code $currentCode)"
Write-Host "      -> Lên: v$newVer (code $newCode)"

# Cập nhật pubspec.yaml
$newPubspec = $pubspecContent -replace "version:\s*[0-9\.]+\+[0-9]+", "version: $newVer+$newCode"
Set-Content -Path $pubspecPath -Value $newPubspec -NoNewline

# Cập nhật app_update_service.dart
$serviceContent = Get-Content $servicePath -Raw
$serviceContent = $serviceContent -replace "currentVersion = '[^']+';", "currentVersion = '$newVer';"
$serviceContent = $serviceContent -replace "currentVersionCode = [0-9]+;", "currentVersionCode = $newCode;"
Set-Content -Path $servicePath -Value $serviceContent -NoNewline

# 2. Build APK
Write-Host "`n[2/4] Đang đóng gói APK mới (flutter build apk --debug)..." -ForegroundColor Green
Push-Location $frontendDir
try {
    & "C:\Users\ACER\flutter\bin\flutter.bat" build apk --debug
} finally {
    Pop-Location
}

$apkSource = Join-Path $frontendDir "build\app\outputs\flutter-apk\app-debug.apk"
if (-not (Test-Path $apkSource)) {
    Write-Error "Build thất bại, không tìm thấy file APK tại: $apkSource"
}

# 3. Copy APK vào wwwroot/downloads của Backend
Write-Host "`n[3/4] Đang copy file APK vào thư mục máy chủ Backend..." -ForegroundColor Green
if (-not (Test-Path $downloadsDir)) {
    New-Item -ItemType Directory -Path $downloadsDir -Force | Out-Null
}
$apkDest = Join-Path $downloadsDir "app-latest.apk"
Copy-Item -Path $apkSource -Destination $apkDest -Force

$apkSizeMB = [math]::Round(((Get-Item $apkDest).Length / 1MB), 1)

# 4. Ghi metadata version.json cho Backend API
Write-Host "`n[4/4] Cập nhật version.json cho máy chủ..." -ForegroundColor Green
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

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " PHÁT HÀNH BẢN CẬP NHẬT THÀNH CÔNG!" -ForegroundColor Yellow
Write-Host " Phiên bản mới : v$newVer (Build $newCode)" -ForegroundColor White
Write-Host " Dung lượng    : $apkSizeMB MB" -ForegroundColor White
Write-Host " Người dùng mở app trên điện thoại sẽ tự động" -ForegroundColor Green
Write-Host " nhận được thông báo cập nhật ngay lập tức!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
