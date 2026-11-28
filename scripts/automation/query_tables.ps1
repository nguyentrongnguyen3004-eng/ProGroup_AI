Add-Type -AssemblyName "System.Data"
$connStr = "Server=LAPTOP-3RHN15E2\SQLEXPRESS;Database=ProjectRegistrationDB;Integrated Security=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    Write-Host "Connected to ProjectRegistrationDB!"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
    $reader = $cmd.ExecuteReader()
    $tables = @()
    while ($reader.Read()) {
        $tables += $reader.GetString(0)
    }
    $reader.Close()
    
    foreach ($tbl in $tables) {
        $cmd.CommandText = "SELECT COUNT(*) FROM [$tbl]"
        $count = $cmd.ExecuteScalar()
        Write-Host "$tbl : $count rows"
    }
    $conn.Close()
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
