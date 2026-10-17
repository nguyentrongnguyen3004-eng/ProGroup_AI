using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Admin;

public sealed class CreateUserRequest
{
    [Required(ErrorMessage = "Tên đăng nhập không được để trống.")]
    [MaxLength(100, ErrorMessage = "Tên đăng nhập tối đa 100 ký tự.")]
    public string TenDangNhap { get; set; } = string.Empty;

    [Required(ErrorMessage = "Mật khẩu không được để trống.")]
    [MinLength(6, ErrorMessage = "Mật khẩu tối thiểu 6 ký tự.")]
    public string MatKhau { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email không được để trống.")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ.")]
    [MaxLength(150, ErrorMessage = "Email tối đa 150 ký tự.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Họ tên không được để trống.")]
    [MaxLength(200, ErrorMessage = "Họ tên tối đa 200 ký tự.")]
    public string HoTen { get; set; } = string.Empty;

    [MaxLength(20, ErrorMessage = "Số điện thoại tối đa 20 ký tự.")]
    public string? SoDienThoai { get; set; }

    public int? VaiTroId { get; set; }
    public string? MaVaiTro { get; set; }

    public int? KhoaId { get; set; }

    // Dành cho sinh viên
    public string? MSSV { get; set; }
    public DateTime? NgaySinh { get; set; }
    public string? GioiTinh { get; set; }

    // Dành cho giảng viên
    public string? MaGiangVien { get; set; }
    public string? HocVi { get; set; }
    public string? ChuyenMon { get; set; }
}
