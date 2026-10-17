namespace ProGroup_AI.API.DTOs.Student;

public sealed class StudentCourseResponse
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
    public string? GiangVienPhuTrach { get; set; }
    public string? EmailGiangVien { get; set; }
    public DateTime NgayThamGia { get; set; }
}
