using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("ThongBaos")]
public class ThongBao
{
    [Key]
    public int ThongBaoId { get; set; }

    [Required]
    public int NguoiDungId { get; set; }

    [Required, StringLength(200)]
    public string TieuDe { get; set; } = string.Empty;

    [Required, StringLength(1000)]
    public string NoiDung { get; set; } = string.Empty;

    [StringLength(50)]
    public string LoaiThongBao { get; set; } = "Hệ thống";

    public bool DaDoc { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public int? LienKetId { get; set; }

    [StringLength(50)]
    public string? LoaiLienKet { get; set; }

    [ForeignKey(nameof(NguoiDungId))]
    public virtual NguoiDung? NguoiDung { get; set; }
}
