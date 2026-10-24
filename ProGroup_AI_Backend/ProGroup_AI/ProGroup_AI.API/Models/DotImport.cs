using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("DotImports")]
public class DotImport
{
    [Key]
    public int DotImportId { get; set; }

    [Required]
    [MaxLength(100)]
    public string LoaiDuLieu { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string TenFile { get; set; } = string.Empty;

    public int NguoiImportId { get; set; }

    public int TongSoDong { get; set; } = 0;

    public int SoDongThanhCong { get; set; } = 0;

    public int SoDongLoi { get; set; } = 0;

    [Required]
    [MaxLength(50)]
    public string TrangThai { get; set; } = "Đang xử lý";

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(NguoiImportId))]
    public NguoiDung? NguoiImport { get; set; }

    public ICollection<LoiImport> LoiImports { get; set; } = new List<LoiImport>();
}