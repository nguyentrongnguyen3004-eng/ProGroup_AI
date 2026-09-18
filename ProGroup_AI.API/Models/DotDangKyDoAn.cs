using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("DotDangKyDoAns")]
public class DotDangKyDoAn
{
    [Key]
    public int DotDangKyId { get; set; }

    public int LopHocPhanId { get; set; }

    [Required]
    [MaxLength(200)]
    public string TenDot { get; set; } = string.Empty;

    public DateTime NgayBatDau { get; set; }

    public DateTime NgayKetThuc { get; set; }

    public int MinMembers { get; set; }

    public int MaxMembers { get; set; }

    [Required]
    [MaxLength(50)]
    public string TrangThai { get; set; } = "Chưa mở";

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(LopHocPhanId))]
    public LopHocPhan? LopHocPhan { get; set; }

    public ICollection<NhomDoAn> NhomDoAns { get; set; } = new List<NhomDoAn>();

    public ICollection<DeTaiDoAn> DeTaiDoAns { get; set; } = new List<DeTaiDoAn>();
}