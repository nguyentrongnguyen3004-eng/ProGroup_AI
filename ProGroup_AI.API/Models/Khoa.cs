using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("Khoas")]
public class Khoa
{
    [Key]
    public int KhoaId { get; set; }

    [Required]
    [MaxLength(20)]
    public string MaKhoa { get; set; } = string.Empty;

    [Required]
    [MaxLength(200)]
    public string TenKhoa { get; set; } = string.Empty;

    public bool TrangThai { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public ICollection<SinhVien> SinhViens { get; set; } = new List<SinhVien>();

    public ICollection<GiangVien> GiangViens { get; set; } = new List<GiangVien>();

    public ICollection<HocPhan> HocPhans { get; set; } = new List<HocPhan>();

    public ICollection<LopHocPhan> LopHocPhans { get; set; } = new List<LopHocPhan>();
}