namespace ProGroup_AI.API.DTOs.DangKyDeTai;

public sealed class DangKyDeTaiResponse
{
    public int DangKyDeTaiId { get; set; }
    public int NhomId { get; set; }
    public string TenNhom { get; set; } = string.Empty;
    public int? TruongNhomId { get; set; }
    public string? TenTruongNhom { get; set; }
    public string? MSSVTruongNhom { get; set; }
    public int DeTaiId { get; set; }
    public string TenDeTai { get; set; } = string.Empty;
    public int DotDangKyId { get; set; }
    public string? TenDot { get; set; }
    public int? LopHocPhanId { get; set; }
    public string? TenLopHocPhan { get; set; }
    public string TrangThai { get; set; } = string.Empty;
    public string? GhiChu { get; set; }
    public DateTime NgayDangKy { get; set; }
    public DateTime? NgayDuyet { get; set; }
    public int? GiangVienDuyetId { get; set; }
    public string? TenGiangVienDuyet { get; set; }
    public int SoThanhVien { get; set; }
}
