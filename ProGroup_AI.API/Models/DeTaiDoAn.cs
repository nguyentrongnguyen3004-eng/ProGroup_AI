using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("DeTaiDoAns")]
public class DeTaiDoAn
{
    [Key]
    public int DeTaiId { get; set; }

    public int DotDangKyId { get; set; }

    [Required]
    [MaxLength(500)]
    public string TenDeTai { get; set; } = string.Empty;

    public string? MoTa { get; set; }

    public string? MucTieu { get; set; }

    public string? PhamVi { get; set; }

    [MaxLength(1000)]
    public string? CongNgheDuKien { get; set; }

    [Required]
    [MaxLength(50)]
    public string NguonDeTai { get; set; } = string.Empty;

    public int? GiangVienId { get; set; }

    public int? SinhVienDeXuatId { get; set; }

    [Required]
    [MaxLength(50)]
    public string TrangThai { get; set; } = "Chưa sử dụng";

    [Required]
    [MaxLength(50)]
    public string TrangThaiDuyet { get; set; } = "Chờ duyệt";

    [MaxLength(1000)]
    public string? LyDoTuChoi { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public DateTime? UpdatedAt { get; set; }

    [ForeignKey(nameof(DotDangKyId))]
    public DotDangKyDoAn? DotDangKy { get; set; }

    [ForeignKey(nameof(GiangVienId))]
    public GiangVien? GiangVien { get; set; }

    [ForeignKey(nameof(SinhVienDeXuatId))]
    public SinhVien? SinhVienDeXuat { get; set; }

    public ICollection<DangKyDeTai> DangKyDeTais { get; set; } = new List<DangKyDeTai>();
}