using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Auth;

public class LoginRequest
{
    [Required]
    public string TenDangNhap { get; set; } = string.Empty;

    [Required]
    public string MatKhau { get; set; } = string.Empty;
}
