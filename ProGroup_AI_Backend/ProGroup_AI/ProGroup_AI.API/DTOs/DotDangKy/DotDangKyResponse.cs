namespace ProGroup_AI.API.DTOs.DotDangKy;

public sealed class DotDangKyResponse
{
    public int DotDangKyId { get; set; }
    public int LopHocPhanId { get; set; }
    public string? MaLopHocPhan { get; set; }
    public string? TenLopHocPhan { get; set; }
    public string TenDot { get; set; } = string.Empty;
    public DateTime NgayBatDau { get; set; }
    public DateTime NgayKetThuc { get; set; }
    public int MinMembers { get; set; }
    public int MaxMembers { get; set; }
    public string TrangThai { get; set; } = string.Empty;
    public int SoLuongNhom { get; set; }
    public int SoLuongDeTai { get; set; }
    public DateTime CreatedAt { get; set; }
}
