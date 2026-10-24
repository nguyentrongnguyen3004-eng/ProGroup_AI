using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("DangKyDeTais")]
public class DangKyDeTai
{
    [Key]
    public int DangKyDeTaiId { get; set; }

    public int NhomId { get; set; }

    public int DeTaiId { get; set; }

    public DateTime NgayDangKy { get; set; } = DateTime.Now;

    [Required]
    [MaxLength(50)]
    public string TrangThai { get; set; } = "Chờ duyệt";

    [MaxLength(1000)]
    public string? GhiChu { get; set; }

    public DateTime? NgayDuyet { get; set; }

    public int? GiangVienDuyetId { get; set; }

    [ForeignKey(nameof(NhomId))]
    public NhomDoAn? Nhom { get; set; }

    [ForeignKey(nameof(DeTaiId))]
    public DeTaiDoAn? DeTai { get; set; }

    [ForeignKey(nameof(GiangVienDuyetId))]
    public GiangVien? GiangVienDuyet { get; set; }
}