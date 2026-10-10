namespace ProGroup_AI.API.DTOs.Academic;

public sealed class LopHocPhanResponse
{
    public int LopHocPhanId { get; set; }
    public string MaLopHocPhan { get; set; } = string.Empty;
    public string? TenLopHocPhan { get; set; }
    public int HocPhanId { get; set; }
    public string MaHocPhan { get; set; } = string.Empty;
    public string TenHocPhan { get; set; } = string.Empty;
    public int HocKyId { get; set; }
    public string TenHocKy { get; set; } = string.Empty;
    public string NamHoc { get; set; } = string.Empty;
    public int KhoaId { get; set; }
    public string TenKhoa { get; set; } = string.Empty;
    public int? SoLuongToiDa { get; set; }
}
