using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("VaiTros")]
public class VaiTro
{
    [Key]
    public int VaiTroId { get; set; }

    [Required]
    [MaxLength(50)]
    public string MaVaiTro { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string TenVaiTro { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? MoTa { get; set; }
}