Add-Type -AssemblyName "System.Data"
$connStr = "Server=LAPTOP-3RHN15E2\SQLEXPRESS;Database=ProjectRegistrationDB;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Host "=== USER ROLES DISTRIBUTION ==="
    $cmd.CommandText = "SELECT v.TenVaiTro, COUNT(n.NguoiDungId) as Cnt FROM VaiTros v LEFT JOIN NguoiDungs n ON v.VaiTroId = n.VaiTroId GROUP BY v.TenVaiTro"
    $r = $cmd.ExecuteReader()
    while ($r.Read()) { Write-Host "$($r[0]): $($r[1])" }
    $r.Close()

    Write-Host "`n=== CHECK FOREIGN KEYS & ORPHANS ==="
    # Orphan ThanhVienNhoms
    $cmd.CommandText = "SELECT COUNT(*) FROM ThanhVienNhoms tv WHERE NOT EXISTS (SELECT 1 FROM NhomDoAns n WHERE n.NhomId = tv.NhomId)"
    Write-Host "Orphan ThanhVienNhoms (invalid NhomId):" $cmd.ExecuteScalar()

    # Orphan DangKyDeTais
    $cmd.CommandText = "SELECT COUNT(*) FROM DangKyDeTais dk WHERE NOT EXISTS (SELECT 1 FROM NhomDoAns n WHERE n.NhomId = dk.NhomId)"
    Write-Host "Orphan DangKyDeTais (invalid NhomId):" $cmd.ExecuteScalar()

    $cmd.CommandText = "SELECT COUNT(*) FROM DangKyDeTais dk WHERE NOT EXISTS (SELECT 1 FROM DeTaiDoAns dt WHERE dt.DeTaiId = dk.DeTaiId)"
    Write-Host "Orphan DangKyDeTais (invalid DeTaiId):" $cmd.ExecuteScalar()

    Write-Host "`n=== TOPIC STATUS DISTRIBUTION ==="
    $cmd.CommandText = "SELECT TrangThai, COUNT(*) FROM DeTaiDoAns GROUP BY TrangThai"
    $r = $cmd.ExecuteReader()
    while ($r.Read()) { Write-Host "$($r[0]): $($r[1])" }
    $r.Close()

    Write-Host "`n=== GROUP STATUS DISTRIBUTION ==="
    $cmd.CommandText = "SELECT TrangThai, COUNT(*) FROM NhomDoAns GROUP BY TrangThai"
    $r = $cmd.ExecuteReader()
    while ($r.Read()) { Write-Host "$($r[0]): $($r[1])" }
    $r.Close()

    Write-Host "`n=== PASSWORD RESET OTPS SAMPLE ==="
    $cmd.CommandText = "SELECT TOP 5 OtpId, NguoiDungId, OtpCodeHash, ExpiredAt, IsUsed, SoLanThu FROM PasswordResetOtps ORDER BY OtpId DESC"
    $r = $cmd.ExecuteReader()
    while ($r.Read()) { Write-Host "Id:$($r[0]) User:$($r[1]) Exp:$($r[3]) Used:$($r[4]) Attempts:$($r[5]) HashLen:$($r[2].ToString().Length)" }
    $r.Close()

    Write-Host "`n=== CHECK DUPLICATE ACTIVE TOPIC REGISTRATIONS ==="
    $cmd.CommandText = "SELECT DeTaiId, COUNT(*) FROM DangKyDeTais WHERE TrangThai IN ('DaDuyet', 'ChoDuyet', 'Đã duyệt', 'Chờ duyệt') GROUP BY DeTaiId HAVING COUNT(*) > 1"
    $r = $cmd.ExecuteReader()
    $hasDup = $false
    while ($r.Read()) { Write-Host "Duplicate Topic ID:$($r[0]) with $($r[1]) registrations"; $hasDup = $true }
    if (-not $hasDup) { Write-Host "No duplicate active topic registrations found (Clean!)." }
    $r.Close()

    $conn.Close()
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
