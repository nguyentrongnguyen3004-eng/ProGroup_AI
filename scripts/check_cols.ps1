Add-Type -AssemblyName "System.Data"
$connStr = "Server=LAPTOP-3RHN15E2\SQLEXPRESS;Database=ProjectRegistrationDB;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NguoiDungs'"
    $r = $cmd.ExecuteReader()
    while ($r.Read()) { Write-Host "$($r[0]) | $($r[1]) | Nullable:$($r[2])" }
    $r.Close()
    $conn.Close()
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
