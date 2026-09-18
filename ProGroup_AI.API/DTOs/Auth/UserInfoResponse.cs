namespace ProGroup_AI.API.DTOs.Auth;

public class UserInfoResponse
{
    public int NguoiDungId { get; set; }

    public string TenDangNhap { get; set; } = string.Empty;

    public string HoTen { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string MaVaiTro { get; set; } = string.Empty;

    public string TenVaiTro { get; set; } = string.Empty;

    public int? SinhVienId { get; set; }

    public string? MSSV { get; set; }

    public int? GiangVienId { get; set; }

    public string? MaGiangVien { get; set; }
}