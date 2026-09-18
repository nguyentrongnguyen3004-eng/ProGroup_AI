using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("HocPhans")]
public class HocPhan
{
    [Key]
    public int HocPhanId { get; set; }

    [Required]
    [MaxLength(30)]
    public string MaHocPhan { get; set; } = string.Empty;

    [Required]
    [MaxLength(300)]
    public string TenHocPhan { get; set; } = string.Empty;

    public int SoTinChi { get; set; }

    public int? KhoaId { get; set; }

    [MaxLength(1000)]
    public string? MoTa { get; set; }

    public bool TrangThai { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(KhoaId))]
    public Khoa? Khoa { get; set; }

    public ICollection<LopHocPhan> LopHocPhans { get; set; } = new List<LopHocPhan>();
}