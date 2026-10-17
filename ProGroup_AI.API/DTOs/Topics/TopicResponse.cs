namespace ProGroup_AI.API.DTOs.Topics;

public sealed class TopicResponse
{
    public int DeTaiId { get; set; }
    public int DotDangKyId { get; set; }
    public string? TenDot { get; set; }
    public int? LopHocPhanId { get; set; }
    public string? MaLopHocPhan { get; set; }
    public string? TenLopHocPhan { get; set; }
    public string TenDeTai { get; set; } = string.Empty;
    public string? MoTa { get; set; }
    public string? MucTieu { get; set; }
    public string? PhamVi { get; set; }
    public string? CongNgheDuKien { get; set; }
    public string NguonDeTai { get; set; } = string.Empty;
    public int? GiangVienId { get; set; }
    public string? TenGiangVien { get; set; }
    public string? MaGiangVien { get; set; }
    public int? SinhVienDeXuatId { get; set; }
    public string? TenSinhVienDeXuat { get; set; }
    public string? MSSVDeXuat { get; set; }
    public string TrangThai { get; set; } = string.Empty;
    public string TrangThaiDuyet { get; set; } = string.Empty;
    public string? LyDoTuChoi { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
