namespace ProGroup_AI.API.DTOs.Academic;

public sealed class LopHocPhanResponse
{
    public int LopHocPhanId { get; set; }
    public string MaLopHocPhan { get; set; } = string.Empty;
    public string? TenLopHocPhan { get; set; }
    public int HocPhanId { get; set; }
    public string MaHocPhan { get; set; } = string.Empty;
    public string TenHocPhan { get; set; } = string.Empty;
    public int SoTinChi { get; set; } = 3;
    public int HocKyId { get; set; }
    public string TenHocKy { get; set; } = string.Empty;
    public string NamHoc { get; set; } = string.Empty;
    public int KhoaId { get; set; }
    public string TenKhoa { get; set; } = string.Empty;
    public int? SoLuongToiDa { get; set; }
    public int SoSinhVien { get; set; }
    public int SoLuongSinhVien { get; set; }
    public int? GiangVienId { get; set; }
    public string? MaGiangVien { get; set; }
    public string GiangVienTen { get; set; } = "Chưa phân công";
    public string TrangThaiDotDangKy { get; set; } = "Chưa mở";
    public string? TenDotDangKy { get; set; }
    public int SoNhom { get; set; }
    public int SoDeTai { get; set; }
}

public sealed class CreateClassRequest
{
    public string MaLopHocPhan { get; set; } = string.Empty;
    public string? TenLopHocPhan { get; set; }
    public string? MaHocPhan { get; set; }
    public string? TenHocPhan { get; set; }
    public int? SoTinChi { get; set; }
    public string? TenHocKy { get; set; }
    public string? NamHoc { get; set; }
    public int? SoLuongToiDa { get; set; }
    public int? KhoaId { get; set; }
}
