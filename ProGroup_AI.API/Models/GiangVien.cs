using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("GiangViens")]
public class GiangVien
{
    [Key]
    public int GiangVienId { get; set; }

    public int NguoiDungId { get; set; }

    [Required]
    [MaxLength(30)]
    public string MaGiangVien { get; set; } = string.Empty;

    public int KhoaId { get; set; }

    [MaxLength(100)]
    public string? HocVi { get; set; }

    [MaxLength(200)]
    public string? ChuyenMon { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(NguoiDungId))]
    public NguoiDung? NguoiDung { get; set; }

    [ForeignKey(nameof(KhoaId))]
    public Khoa? Khoa { get; set; }

    public ICollection<PhanCongGiangVien> PhanCongGiangViens { get; set; } = new List<PhanCongGiangVien>();

    public ICollection<DeTaiDoAn> DeTaiDoAns { get; set; } = new List<DeTaiDoAn>();

    public ICollection<DangKyDeTai> DangKyDeTaisDuyet { get; set; } = new List<DangKyDeTai>();
}