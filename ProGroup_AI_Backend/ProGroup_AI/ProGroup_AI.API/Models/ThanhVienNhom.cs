using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("ThanhVienNhoms")]
public class ThanhVienNhom
{
    [Key]
    public int ThanhVienNhomId { get; set; }

    public int NhomId { get; set; }

    public int SinhVienId { get; set; }

    [Required]
    [MaxLength(50)]
    public string VaiTro { get; set; } = "Thành viên";

    public DateTime NgayThamGia { get; set; } = DateTime.Now;

    [Required]
    [MaxLength(50)]
    public string TrangThai { get; set; } = "Đã tham gia";

    [ForeignKey(nameof(NhomId))]
    public NhomDoAn? Nhom { get; set; }

    [ForeignKey(nameof(SinhVienId))]
    public SinhVien? SinhVien { get; set; }
}