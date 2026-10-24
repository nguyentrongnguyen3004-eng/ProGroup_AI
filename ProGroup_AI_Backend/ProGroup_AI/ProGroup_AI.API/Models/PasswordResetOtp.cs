using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("PasswordResetOtps")]
public class PasswordResetOtp
{
    [Key]
    public int OtpId { get; set; }

    public int NguoiDungId { get; set; }

    [Required]
    [MaxLength(500)]
    public string OtpCodeHash { get; set; } = string.Empty;

    public DateTime ExpiredAt { get; set; }

    public int SoLanThu { get; set; } = 0;

    public bool IsUsed { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(NguoiDungId))]
    public NguoiDung? NguoiDung { get; set; }
}