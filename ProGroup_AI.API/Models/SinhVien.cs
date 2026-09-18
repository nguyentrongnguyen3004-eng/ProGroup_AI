using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("SinhViens")]
public class SinhVien
{
    [Key]
    public int SinhVienId { get; set; }

    public int NguoiDungId { get; set; }

    [Required]
    [MaxLength(30)]
    public string MSSV { get; set; } = string.Empty;

    public int KhoaId { get; set; }

    public DateTime? NgaySinh { get; set; }

    [MaxLength(10)]
    public string? GioiTinh { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [ForeignKey(nameof(NguoiDungId))]
    public NguoiDung? NguoiDung { get; set; }

    [ForeignKey(nameof(KhoaId))]
    public Khoa? Khoa { get; set; }

    public ICollection<SinhVienLopHocPhan> SinhVienLopHocPhans { get; set; } = new List<SinhVienLopHocPhan>();

    public ICollection<NhomDoAn> NhomDoAns { get; set; } = new List<NhomDoAn>();

    public ICollection<ThanhVienNhom> ThanhVienNhoms { get; set; } = new List<ThanhVienNhom>();

    public ICollection<DeTaiDoAn> DeTaiDeXuat { get; set; } = new List<DeTaiDoAn>();
}