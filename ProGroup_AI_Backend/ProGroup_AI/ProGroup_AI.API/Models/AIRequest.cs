using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("AIRequests")]
public class AIRequest
{
    [Key]
    public int AIRequestId { get; set; }

    public int NguoiDungId { get; set; }

    [Required]
    [MaxLength(100)]
    public string ChucNangAI { get; set; } = string.Empty;

    [Required]
    public string Prompt { get; set; } = string.Empty;

    public string? Response { get; set; }

    [Required]
    [MaxLength(50)]
    public string TrangThai { get; set; } = "Thành công";

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(NguoiDungId))]
    public NguoiDung? NguoiDung { get; set; }
}