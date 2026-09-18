using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("LoiImports")]
public class LoiImport
{
    [Key]
    public int LoiImportId { get; set; }

    public int DotImportId { get; set; }

    public int SoDong { get; set; }

    [MaxLength(200)]
    public string? TenCot { get; set; }

    [Required]
    [MaxLength(1000)]
    public string NoiDungLoi { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(DotImportId))]
    public DotImport? DotImport { get; set; }
}