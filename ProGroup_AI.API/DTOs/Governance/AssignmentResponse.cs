namespace ProGroup_AI.API.DTOs.Governance;

public sealed class AssignmentResponse
{
    public int PhanCongId { get; set; }
    public int LopHocPhanId { get; set; }
    public string MaLopHocPhan { get; set; } = string.Empty;
    public string TenLopHocPhan { get; set; } = string.Empty;
    public int GiangVienId { get; set; }
    public string MaGiangVien { get; set; } = string.Empty;
    public string HoTen { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string VaiTro { get; set; } = string.Empty;
    public DateTime NgayPhanCong { get; set; }
    public bool TrangThai { get; set; }
}
