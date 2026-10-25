param(
    [string]$ServerInstance = "LAPTOP-3RHN15E2\SQLEXPRESS",
    [string]$DatabaseName = "ProjectRegistrationDB",
    [int]$KeepRecent = 7
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path "$PSScriptRoot\..").Path
$backupDir = Join-Path $root "backups"

if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

$timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$backupFileName = "${DatabaseName}_backup_${timestamp}.bak"
$backupFilePath = Join-Path $backupDir $backupFileName

Write-Host "[Auto-Backup] Dang sao luu co so du lieu '$DatabaseName'..." -ForegroundColor Cyan

$sqlcmdPath = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\SQLCMD.EXE"
if (-not (Test-Path $sqlcmdPath)) {
    $found = (where.exe sqlcmd)
    if ($found) { $sqlcmdPath = $found[0] }
}

$sqlQuery = "BACKUP DATABASE [$DatabaseName] TO DISK = N'$backupFilePath' WITH FORMAT, INIT, NAME = N'$DatabaseName Automatic Backup', STATS = 10"

try {
    & $sqlcmdPath -S $ServerInstance -E -Q $sqlQuery | Out-Null
    $fileSizeMB = [math]::Round(((Get-Item $backupFilePath).Length / 1MB), 2)
    Write-Host "[Auto-Backup] Sao luu thanh cong: $backupFileName ($fileSizeMB MB)" -ForegroundColor Green

    # Cập nhật file bản sao lưu mới nhất tại ProGroup_AI_Backend\ProGroup_AI\ProjectRegistrationDB_backup.bak
    $latestBak = Join-Path $root "ProGroup_AI_Backend\ProGroup_AI\ProjectRegistrationDB_backup.bak"
    Copy-Item -Path $backupFilePath -Destination $latestBak -Force

    # Dọn dẹp: Chỉ giữ lại $KeepRecent bản sao lưu mới nhất
    $allBackups = Get-ChildItem -Path $backupDir -Filter "*.bak" | Sort-Object CreationTime -Descending
    if ($allBackups.Count -gt $KeepRecent) {
        $toRemove = $allBackups | Select-Object -Skip $KeepRecent
        foreach ($file in $toRemove) {
            Remove-Item $file.FullName -Force
            Write-Host "[Auto-Backup] Da don dep ban sao luu cu: $($file.Name)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "[Auto-Backup] Canh bao: Khong the thuc hien sao luu: $_" -ForegroundColor Yellow
}
