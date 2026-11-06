namespace ProGroup_AI.API.DTOs.Admin;

public sealed class ChangeRoleRequest
{
    public int? VaiTroId { get; set; }
    public string? MaVaiTro { get; set; }
    public int? KhoaId { get; set; }
}

public sealed class ImportUserItemDto
{
    public string TenDangNhap { get; set; } = string.Empty;
    public string MatKhau { get; set; } = "123456aA@";
    public string HoTen { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? SoDienThoai { get; set; }
    public string VaiTro { get; set; } = "SINHVIEN";
    public string? Khoa { get; set; }
    public string? MSSV { get; set; }
    public string? MaGiangVien { get; set; }
    public string? HocVi { get; set; }
    public string? ChuyenMon { get; set; }
}

public sealed class ImportUsersRequest
{
    public List<ImportUserItemDto> Users { get; set; } = new();
}

public sealed class ImportUsersResponse
{
    public bool Success { get; set; }
    public int Total { get; set; }
    public int SuccessCount { get; set; }
    public int FailedCount { get; set; }
    public List<string> Errors { get; set; } = new();
    public string Message { get; set; } = string.Empty;
}
