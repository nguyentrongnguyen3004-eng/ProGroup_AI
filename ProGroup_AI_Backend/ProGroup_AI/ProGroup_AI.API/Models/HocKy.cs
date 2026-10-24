using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("HocKys")]
public class HocKy
{
    [Key]
    public int HocKyId { get; set; }

    [Required]
    [MaxLength(100)]
    public string TenHocKy { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string NamHoc { get; set; } = string.Empty;

    [Required]
    public DateTime NgayBatDau { get; set; }

    [Required]
    public DateTime NgayKetThuc { get; set; }

    public bool TrangThai { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public ICollection<LopHocPhan> LopHocPhans { get; set; } = new List<LopHocPhan>();
}