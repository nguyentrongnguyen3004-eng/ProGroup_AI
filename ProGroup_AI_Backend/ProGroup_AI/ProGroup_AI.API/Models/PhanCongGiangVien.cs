using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("PhanCongGiangViens")]
public class PhanCongGiangVien
{
    [Key]
    public int PhanCongId { get; set; }

    public int LopHocPhanId { get; set; }

    public int GiangVienId { get; set; }

    [Required]
    [MaxLength(100)]
    public string VaiTro { get; set; } = "Giảng viên phụ trách";

    public DateTime NgayPhanCong { get; set; } = DateTime.Now;

    public bool TrangThai { get; set; } = true;

    [ForeignKey(nameof(LopHocPhanId))]
    public LopHocPhan? LopHocPhan { get; set; }

    [ForeignKey(nameof(GiangVienId))]
    public GiangVien? GiangVien { get; set; }
}