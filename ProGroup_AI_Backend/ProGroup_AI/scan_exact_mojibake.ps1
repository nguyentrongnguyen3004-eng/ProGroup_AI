[System.Reflection.Assembly]::LoadWithPartialName('System.Data') | Out-Null
$connStr = 'Server=LAPTOP-3RHN15E2\SQLEXPRESS;Database=ProjectRegistrationDB;Integrated Security=True;TrustServerCertificate=True;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('nvarchar', 'varchar', 'nchar', 'char', 'text', 'ntext')
  AND TABLE_NAME NOT LIKE 'sys%' AND TABLE_NAME NOT LIKE '__EF%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
"@
$r = $cmd.ExecuteReader()
$cols = @()
while ($r.Read()) {
    $cols += [PSCustomObject]@{ Table = $r[0]; Column = $r[1] }
}
$r.Close()

Write-Host "=== SCANNING ALL COLUMNS FOR EXACT MOJIBAKE SIGNATURES ==="
# Signatures:
# 1. N'Ã¡', N'Ã³', N'Ã©', N'Ã­', N'Ãº', N'Ã½', N'Ãª', N'Ã´'
# 2. N'á»' (0xE1 0xBB)
# 3. N'áº' (0xE1 0xBA)
# 4. N'Ă¡' (0xC4 0x82 0xA1)
# 5. N'Ä‘' (0xC4 0x91)
# 6. N'Ä' (0xC4 0x90)
# 7. N'Â' followed by non-space non-vowel

$total = 0
foreach ($c in $cols) {
    $t = $c.Table
    $col = $c.Column
    $sql = @"
    SELECT COUNT(*) FROM [$t]
    WHERE [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ã¡%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ã³%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ã©%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ã­%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ãº%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ã½%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ãª%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ã´%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%á»%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%áº%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ă¡%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ä‘%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ä%'
       OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Â '%
"@
    try {
        $cmd.CommandText = $sql
        $cnt = [int]$cmd.ExecuteScalar()
        if ($cnt -gt 0) {
            Write-Host ("EXACT MOJIBAKE in " + $t + "." + $col + ": " + $cnt)
            $total += $cnt
            # Print samples
            $sampleCmd = $conn.CreateCommand()
            $sampleCmd.CommandText = "SELECT TOP 3 [$col] FROM [$t] WHERE [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ã¡%' OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%á»%' OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%áº%' OR [$col] COLLATE Latin1_General_BIN2 LIKE N'%Ă¡%';"
            $sr = $sampleCmd.ExecuteReader()
            while ($sr.Read()) {
                Write-Host ("   -> " + $sr[0])
            }
            $sr.Close()
        }
    } catch {
    }
}

Write-Host "`nTOTAL CONFIRMED MOJIBAKE FOUND: $total"
$conn.Close()
