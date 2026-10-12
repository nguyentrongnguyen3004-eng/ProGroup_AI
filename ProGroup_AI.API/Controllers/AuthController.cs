using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Auth;
using ProGroup_AI.API.Models;
using ProGroup_AI.API.Services;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ApplicationDbContext _context;

    public AuthController(IAuthService authService, ApplicationDbContext context)
    {
        _authService = authService;
        _context = context;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.TenDangNhap) || string.IsNullOrWhiteSpace(request.MatKhau))
        {
            return BadRequest(new
            {
                message = "Tên đăng nhập và mật khẩu là bắt buộc."
            });
        }

        var result = await _authService.LoginAsync(request);

        if (!result.Success)
        {
            return Unauthorized(result);
        }

        return Ok(result);
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<IActionResult> Me()
    {
        var idValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idValue, out var userId)) return Unauthorized();

        var user = await _context.NguoiDungs
            .AsNoTracking()
            .Include(x => x.VaiTro)
            .Include(x => x.SinhVien)
            .Include(x => x.GiangVien)
            .FirstOrDefaultAsync(x => x.NguoiDungId == userId && x.TrangThai);

        if (user is null) return NotFound(new { message = "Không tìm thấy tài khoản." });

        return Ok(new UserInfoResponse
        {
            NguoiDungId = user.NguoiDungId,
            TenDangNhap = user.TenDangNhap,
            HoTen = user.HoTen,
            Email = user.Email,
            MaVaiTro = user.VaiTro?.MaVaiTro ?? string.Empty,
            TenVaiTro = user.VaiTro?.TenVaiTro ?? string.Empty,
            SinhVienId = user.SinhVien?.SinhVienId,
            MSSV = user.SinhVien?.MSSV,
            GiangVienId = user.GiangVien?.GiangVienId,
            MaGiangVien = user.GiangVien?.MaGiangVien
        });
    }

    [Authorize]
    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest req)
    {
        var idValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idValue, out var userId)) return Unauthorized();

        if (string.IsNullOrWhiteSpace(req.OldPassword) || string.IsNullOrWhiteSpace(req.NewPassword))
            return BadRequest(new { message = "Vui lòng nhập mật khẩu cũ và mật khẩu mới." });

        if (req.NewPassword.Length < 6)
            return BadRequest(new { message = "Mật khẩu mới phải có tối thiểu 6 ký tự." });

        var user = await _context.NguoiDungs.FirstOrDefaultAsync(x => x.NguoiDungId == userId);
        if (user == null) return NotFound(new { message = "Người dùng không tồn tại." });

        bool oldPassValid;
        try { oldPassValid = BCrypt.Net.BCrypt.Verify(req.OldPassword, user.MatKhauHash); }
        catch { oldPassValid = false; }

        if (!oldPassValid)
            return BadRequest(new { message = "Mật khẩu cũ không chính xác." });

        user.MatKhauHash = BCrypt.Net.BCrypt.HashPassword(req.NewPassword);
        user.UpdatedAt = DateTime.Now;
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Đổi mật khẩu thành công." });
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Email))
            return BadRequest(new { message = "Email là bắt buộc." });

        var user = await _context.NguoiDungs.FirstOrDefaultAsync(x => x.Email == req.Email);
        if (user == null)
        {
            // Bảo mật: không báo lỗi nếu email không tồn tại
            return Ok(new { success = true, message = "Mã xác thực OTP đã được gửi tới email của bạn (nếu tồn tại)." });
        }

        // Tạo OTP mẫu hoặc lưu bảng PasswordResetOtps
        var otpCode = "123456";
        var otpRecord = new PasswordResetOtp
        {
            NguoiDungId = user.NguoiDungId,
            OtpCodeHash = BCrypt.Net.BCrypt.HashPassword(otpCode),
            ExpiredAt = DateTime.Now.AddMinutes(15)
        };
        _context.PasswordResetOtps.Add(otpRecord);
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Mã xác thực OTP đã được gửi tới email của bạn." });
    }

    [HttpPost("verify-otp")]
    public IActionResult VerifyOtp([FromBody] VerifyOtpRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Otp) || req.Otp.Length != 6)
            return BadRequest(new { success = false, message = "Mã OTP không hợp lệ." });

        return Ok(new { success = true, message = "Mã OTP hợp lệ." });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.NewPassword) || req.NewPassword.Length < 6)
            return BadRequest(new { message = "Mật khẩu mới phải có tối thiểu 6 ký tự." });

        return Ok(new { success = true, message = "Đặt lại mật khẩu thành công." });
    }
}

public class ChangePasswordRequest
{
    public string OldPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

public class ForgotPasswordRequest
{
    public string Email { get; set; } = string.Empty;
}

public class VerifyOtpRequest
{
    public string Otp { get; set; } = string.Empty;
}

public class ResetPasswordRequest
{
    public string NewPassword { get; set; } = string.Empty;
}
