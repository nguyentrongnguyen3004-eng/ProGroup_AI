using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.DotDangKy;

public sealed class UpdateTrangThaiDotRequest
{
    [Required(ErrorMessage = "Trạng thái không được để trống.")]
    [RegularExpression("^(Chưa mở|Đang mở|Đã đóng)$", ErrorMessage = "Trạng thái chỉ có thể là: Chưa mở, Đang mở, Đã đóng")]
    public string TrangThai { get; set; } = string.Empty;
}
