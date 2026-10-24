using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProGroup_AI.API.Models;

[Table("SinhVienLopHocPhans")]
public class SinhVienLopHocPhan
{
    [Key]
    public int SinhVienLopHocPhanId { get; set; }

    public int SinhVienId { get; set; }

    public int LopHocPhanId { get; set; }

    public DateTime NgayThamGia { get; set; } = DateTime.Now;

    public bool TrangThai { get; set; } = true;

    [ForeignKey(nameof(SinhVienId))]
    public SinhVien? SinhVien { get; set; }

    [ForeignKey(nameof(LopHocPhanId))]
    public LopHocPhan? LopHocPhan { get; set; }
}