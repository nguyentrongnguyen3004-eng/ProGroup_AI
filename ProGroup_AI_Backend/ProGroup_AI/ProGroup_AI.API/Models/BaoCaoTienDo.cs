using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("BaoCaoTienDos")]
public class BaoCaoTienDo
{
    [Key]
    public int BaoCaoId { get; set; }

    [Required]
    public int NhomId { get; set; }

    public int? DeTaiId { get; set; }

    [Required, StringLength(200)]
    public string TieuDe { get; set; } = string.Empty;

    public string NoiDung { get; set; } = string.Empty;

    [StringLength(500)]
    public string? FileUrl { get; set; }

    [StringLength(500)]
    public string? GithubUrl { get; set; }

    [StringLength(500)]
    public string? DemoUrl { get; set; }

    public int TuanBaoCao { get; set; } = 1;

    public DateTime NgayNop { get; set; } = DateTime.UtcNow;

    [StringLength(50)]
    public string TrangThai { get; set; } = "Đã nộp"; // Đã nộp, Cần chỉnh sửa, Đạt, Không đạt

    public string? NhanXetGiangVien { get; set; }

    [Column(TypeName = "decimal(4, 2)")]
    public decimal? Diem { get; set; }

    public int? GiangVienId { get; set; }

    public DateTime? NgayNhanXet { get; set; }

    [ForeignKey(nameof(NhomId))]
    public virtual NhomDoAn? Nhom { get; set; }

    [ForeignKey(nameof(DeTaiId))]
    public virtual DeTaiDoAn? DeTai { get; set; }

    [ForeignKey(nameof(GiangVienId))]
    public virtual GiangVien? GiangVien { get; set; }
}
