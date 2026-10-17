namespace ProGroup_AI.API.DTOs.Admin;

public sealed class AdminUserResponse
{
    public int NguoiDungId { get; set; }
    public string TenDangNhap { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string HoTen { get; set; } = string.Empty;
    public string? SoDienThoai { get; set; }
    public string? AvatarUrl { get; set; }
    public int VaiTroId { get; set; }
    public string MaVaiTro { get; set; } = string.Empty;
    public string TenVaiTro { get; set; } = string.Empty;
    public bool TrangThai { get; set; }
    public DateTime CreatedAt { get; set; }

    // Role-specific identifiers
    public int? SinhVienId { get; set; }
    public string? MSSV { get; set; }
    public int? GiangVienId { get; set; }
    public string? MaGiangVien { get; set; }
    public int? KhoaId { get; set; }
    public string? TenKhoa { get; set; }
}
