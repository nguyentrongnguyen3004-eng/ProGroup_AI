using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("NguoiDungs")]
public class NguoiDung
{
    [Key]
    public int NguoiDungId { get; set; }

    [Required]
    [MaxLength(100)]
    public string TenDangNhap { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string MatKhauHash { get; set; } = string.Empty;

    [Required]
    [MaxLength(150)]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(200)]
    public string HoTen { get; set; } = string.Empty;

    [MaxLength(20)]
    public string? SoDienThoai { get; set; }

    [MaxLength(500)]
    public string? AvatarUrl { get; set; }

    public int VaiTroId { get; set; }

    public bool TrangThai { get; set; } = true;

    public bool YeuCauDoiMatKhau { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public DateTime? UpdatedAt { get; set; }

    [ForeignKey(nameof(VaiTroId))]
    public VaiTro? VaiTro { get; set; }

    public SinhVien? SinhVien { get; set; }

    public GiangVien? GiangVien { get; set; }

    public ICollection<PasswordResetOtp> PasswordResetOtps { get; set; } = new List<PasswordResetOtp>();

    public ICollection<AIRequest> AIRequests { get; set; } = new List<AIRequest>();

    public ICollection<DotImport> DotImports { get; set; } = new List<DotImport>();
}