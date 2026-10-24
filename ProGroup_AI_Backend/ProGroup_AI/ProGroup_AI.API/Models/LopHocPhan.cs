using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("LopHocPhans")]
public class LopHocPhan
{
    [Key]
    public int LopHocPhanId { get; set; }

    [Required]
    [MaxLength(50)]
    public string MaLopHocPhan { get; set; } = string.Empty;

    [MaxLength(300)]
    public string? TenLopHocPhan { get; set; }

    public int HocPhanId { get; set; }

    public int HocKyId { get; set; }

    public int KhoaId { get; set; }

    public int? SoLuongToiDa { get; set; }

    public bool TrangThai { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(HocPhanId))]
    public HocPhan? HocPhan { get; set; }

    [ForeignKey(nameof(HocKyId))]
    public HocKy? HocKy { get; set; }

    [ForeignKey(nameof(KhoaId))]
    public Khoa? Khoa { get; set; }

    public ICollection<PhanCongGiangVien> PhanCongGiangViens { get; set; } = new List<PhanCongGiangVien>();

    public ICollection<SinhVienLopHocPhan> SinhVienLopHocPhans { get; set; } = new List<SinhVienLopHocPhan>();

    public ICollection<DotDangKyDoAn> DotDangKyDoAns { get; set; } = new List<DotDangKyDoAn>();
}