using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Profile;

public sealed class UpdateProfileRequest
{
    [MaxLength(200, ErrorMessage = "Họ tên tối đa 200 ký tự.")]
    public string? HoTen { get; set; }

    [MaxLength(20, ErrorMessage = "Số điện thoại tối đa 20 ký tự.")]
    public string? SoDienThoai { get; set; }

    [MaxLength(500, ErrorMessage = "Avatar URL tối đa 500 ký tự.")]
    public string? AvatarUrl { get; set; }
}
