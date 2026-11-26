$connString = "Server=LAPTOP-3RHN15E2\SQLEXPRESS;Database=ProjectRegistrationDB;Trusted_Connection=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT n.NguoiDungId, n.TenDangNhap, n.HoTen, n.Email, v.MaVaiTro, v.TenVaiTro, n.TrangThai FROM NguoiDungs n LEFT JOIN VaiTros v ON n.VaiTroId = v.VaiTroId ORDER BY n.NguoiDungId"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    $id = $reader["NguoiDungId"]
    $u = $reader["TenDangNhap"]
    $name = $reader["HoTen"]
    $role = $reader["MaVaiTro"]
    $email = $reader["Email"]
    $status = $reader["TrangThai"]
    Write-Output "[$id] User: $u | Name: $name | Role: $role | Email: $email | Status: $status"
}
$conn.Close()
