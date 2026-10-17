using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Governance;

public sealed class AssignmentRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "LopHocPhanId không hợp lệ.")]
    public int LopHocPhanId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "GiangVienId không hợp lệ.")]
    public int GiangVienId { get; set; }

    [MaxLength(100, ErrorMessage = "Vai trò tối đa 100 ký tự.")]
    public string? VaiTro { get; set; } = "Giảng viên phụ trách";
}
