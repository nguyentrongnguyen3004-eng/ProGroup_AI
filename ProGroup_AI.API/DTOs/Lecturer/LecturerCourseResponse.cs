namespace ProGroup_AI.API.DTOs.Lecturer;

public sealed class LecturerCourseResponse
{
    public int LopHocPhanId { get; set; }
    public string MaLopHocPhan { get; set; } = string.Empty;
    public string TenLopHocPhan { get; set; } = string.Empty;
    public int HocPhanId { get; set; }
    public string MaHocPhan { get; set; } = string.Empty;
    public string TenHocPhan { get; set; } = string.Empty;
    public int HocKyId { get; set; }
    public string TenHocKy { get; set; } = string.Empty;
    public string NamHoc { get; set; } = string.Empty;
    public int? SoLuongToiDa { get; set; }
    public int SoSinhVien { get; set; }
    public int SoNhom { get; set; }
    public int SoDeTai { get; set; }
    public List<CourseDotDangKyInfo> DotDangKys { get; set; } = new();
}

public sealed class CourseDotDangKyInfo
{
    public int DotDangKyId { get; set; }
    public string TenDot { get; set; } = string.Empty;
    public DateTime NgayBatDau { get; set; }
    public DateTime NgayKetThuc { get; set; }
    public int MinMembers { get; set; }
    public int MaxMembers { get; set; }
    public string TrangThai { get; set; } = string.Empty;
    public int SoNhom { get; set; }
    public int SoDeTai { get; set; }
}
