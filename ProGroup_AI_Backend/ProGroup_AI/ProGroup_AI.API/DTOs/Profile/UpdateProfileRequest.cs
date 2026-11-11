using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Profile;

public sealed class UpdateProfileRequest
{
    [MaxLength(200, ErrorMessage = "Họ tên tối đa 200 ký tự.")]
    public string? HoTen { get; set; }

    [MaxLength(20, ErrorMessage = "Số điện thoại tối đa 20 ký tự.")]
    [RegularExpression(@"^[0-9]{9,11}$", ErrorMessage = "Số điện thoại chỉ được chứa các chữ số từ 0 đến 9 và có độ dài từ 9 đến 11 số.")]
    public string? SoDienThoai { get; set; }

    [MaxLength(500, ErrorMessage = "Avatar URL tối đa 500 ký tự.")]
    public string? AvatarUrl { get; set; }

    [MaxLength(100, ErrorMessage = "Học vị tối đa 100 ký tự.")]
    public string? HocVi { get; set; }

    [MaxLength(255, ErrorMessage = "Chuyên môn tối đa 255 ký tự.")]
    public string? ChuyenMon { get; set; }
}
