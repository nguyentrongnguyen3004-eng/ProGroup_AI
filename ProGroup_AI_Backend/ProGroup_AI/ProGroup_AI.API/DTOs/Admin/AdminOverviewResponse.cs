namespace ProGroup_AI.API.DTOs.Admin;

public sealed class AdminOverviewResponse
{
    public int TongNguoiDung { get; set; }
    public int TongSinhVien { get; set; }
    public int TongGiangVien { get; set; }
    public int TongLopHocPhan { get; set; }
    public int TongDeTai { get; set; }
    public int TongDeTaiDaDuyet { get; set; }
    public int TongNhom { get; set; }
    public int TongDangKyDeTai { get; set; }
    public int DotDangKyDangMo { get; set; }
    public int TongKhoa { get; set; }
    public int TongSinhVienLamDoAn { get; set; }
    public double TyLeHoanThanh { get; set; }
    public string HocKyHienTai { get; set; } = "Học kỳ 1 (2026-2027)";
    public IReadOnlyList<DepartmentStatItem> ThongKeTheoKhoa { get; set; } = Array.Empty<DepartmentStatItem>();
    public GradeDistributionDto PhoDiem { get; set; } = new();
}

public sealed class DepartmentStatItem
{
    public int KhoaId { get; set; }
    public string MaKhoa { get; set; } = string.Empty;
    public string TenKhoa { get; set; } = string.Empty;
    public int SoLopHocPhan { get; set; }
    public int SoSinhVien { get; set; }
    public int SoNhom { get; set; }
    public int SoDeTai { get; set; }
}

public sealed class GradeDistributionDto
{
    public int XuatSac { get; set; }
    public int Gioi { get; set; }
    public int Kha { get; set; }
    public int TrungBinh { get; set; }
    public int Rot { get; set; }
}
