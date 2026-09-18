using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("NhomDoAns")]
public class NhomDoAn
{
    [Key]
    public int NhomId { get; set; }

    public int DotDangKyId { get; set; }

    [Required]
    [MaxLength(200)]
    public string TenNhom { get; set; } = string.Empty;

    public int TruongNhomId { get; set; }

    [Required]
    [MaxLength(50)]
    public string TrangThai { get; set; } = "Đang hoạt động";

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public DateTime? UpdatedAt { get; set; }

    [ForeignKey(nameof(DotDangKyId))]
    public DotDangKyDoAn? DotDangKy { get; set; }

    [ForeignKey(nameof(TruongNhomId))]
    public SinhVien? TruongNhom { get; set; }

    public ICollection<ThanhVienNhom> ThanhVienNhoms { get; set; } = new List<ThanhVienNhom>();

    public ICollection<DangKyDeTai> DangKyDeTais { get; set; } = new List<DangKyDeTai>();
}