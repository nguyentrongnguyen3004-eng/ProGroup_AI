using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.DotDangKy;

public sealed class CreateDotDangKyRequest
{
    [Required(ErrorMessage = "Tên đợt không được để trống.")]
    [MaxLength(200, ErrorMessage = "Tên đợt tối đa 200 ký tự.")]
    public string TenDot { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "LopHocPhanId không hợp lệ.")]
    public int LopHocPhanId { get; set; }

    [Required(ErrorMessage = "Ngày bắt đầu là bắt buộc.")]
    public DateTime NgayBatDau { get; set; }

    [Required(ErrorMessage = "Ngày kết thúc là bắt buộc.")]
    public DateTime NgayKetThuc { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Số thành viên tối thiểu phải lớn hơn 0.")]
    public int MinMembers { get; set; } = 1;

    [Range(1, int.MaxValue, ErrorMessage = "Số thành viên tối đa phải lớn hơn 0.")]
    public int MaxMembers { get; set; } = 5;
}
