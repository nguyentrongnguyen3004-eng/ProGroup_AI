using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Auth;
using ProGroup_AI.API.Models;
using ProGroup_AI.API.Services;

namespace ProGroup_AI.API.Controllers;

public class ForgotPasswordSendOtpRequest
{
    public string Email { get; set; } = string.Empty;
}

public class VerifyOtpRequest
{
    public string Email { get; set; } = string.Empty;
    public string Otp { get; set; } = string.Empty;
}

public class ResetPasswordWithOtpRequest
{
    public string Email { get; set; } = string.Empty;
    public string Otp { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ApplicationDbContext _context;
    private readonly IEmailService _emailService;

    public AuthController(IAuthService authService, ApplicationDbContext context, IEmailService emailService)
    {
        _authService = authService;
        _context = context;
        _emailService = emailService;
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
    [HttpPut("change-email")]
    public async Task<IActionResult> ChangeEmail([FromBody] ChangeEmailRequest request)
    {
        var idValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idValue, out var userId)) return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.Email))
            return BadRequest(new { message = "Email không được để trống." });

        var cleanEmail = request.Email.Trim();
        var user = await _context.NguoiDungs.FirstOrDefaultAsync(x => x.NguoiDungId == userId);
        if (user is null) return NotFound(new { message = "Không tìm thấy tài khoản." });

        var emailExists = await _context.NguoiDungs.AnyAsync(x => x.Email == cleanEmail && x.NguoiDungId != userId);
        if (emailExists)
            return Conflict(new { message = "Email này đã được sử dụng bởi tài khoản khác." });

        user.Email = cleanEmail;
        await _context.SaveChangesAsync();
        return Ok(new { success = true, email = user.Email });
    }

    [Authorize]
    [HttpPut("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var idValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idValue, out var userId)) return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.CurrentPassword) || string.IsNullOrWhiteSpace(request.NewPassword))
            return BadRequest(new { message = "Vui lòng nhập đầy đủ mật khẩu hiện tại và mật khẩu mới." });

        var user = await _context.NguoiDungs.FirstOrDefaultAsync(x => x.NguoiDungId == userId);
        if (user is null) return NotFound(new { message = "Không tìm thấy tài khoản." });

        if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.MatKhauHash))
            return BadRequest(new { message = "Mật khẩu hiện tại không chính xác." });

        user.MatKhauHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        await _context.SaveChangesAsync();
        return Ok(new { success = true, message = "Đổi mật khẩu thành công." });
    }

    /// <summary>
    /// Gửi mã OTP xác thực qua Email thật bằng Gmail SMTP
    /// </summary>
    [HttpPost("forgot-password/send-otp")]
    public async Task<IActionResult> SendOtp([FromBody] ForgotPasswordSendOtpRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
            return BadRequest(new { success = false, message = "Địa chỉ email không được để trống." });

        var cleanEmail = request.Email.Trim();
        var user = await _context.NguoiDungs.FirstOrDefaultAsync(x => x.Email == cleanEmail && x.TrangThai);
        if (user is null)
        {
            // Bảo mật: không báo rõ user không tồn tại, nhưng với app trường học ta có thể thông báo rõ ràng để hỗ trợ người dùng
            return NotFound(new { success = false, message = "Không tìm thấy tài khoản nào khớp với địa chỉ email này." });
        }

        // Sinh mã 6 chữ số ngẫu nhiên
        var otpCode = Random.Shared.Next(100000, 999999).ToString();
        var otpHash = BCrypt.Net.BCrypt.HashPassword(otpCode);

        // Hủy các OTP cũ chưa dùng của người dùng này
        var oldOtps = await _context.PasswordResetOtps
            .Where(x => x.NguoiDungId == user.NguoiDungId && !x.IsUsed)
            .ToListAsync();
        foreach (var old in oldOtps)
        {
            old.IsUsed = true;
        }

        // Tạo bản ghi OTP mới (hạn dùng 5 phút)
        var otpRecord = new PasswordResetOtp
        {
            NguoiDungId = user.NguoiDungId,
            OtpCodeHash = otpHash,
            ExpiredAt = DateTime.Now.AddMinutes(5),
            CreatedAt = DateTime.Now,
            IsUsed = false,
            SoLanThu = 0
        };
        _context.PasswordResetOtps.Add(otpRecord);
        await _context.SaveChangesAsync();

        // Gửi email thật qua Gmail SMTP
        var sent = await _emailService.SendOtpEmailAsync(user.Email, otpCode, user.HoTen);
        if (!sent)
        {
            return StatusCode(500, new { success = false, message = "Không thể gửi email OTP qua máy chủ Gmail. Vui lòng kiểm tra lại cấu hình kết nối mạng." });
        }

        return Ok(new
        {
            success = true,
            message = $"Mã OTP đã được gửi đến email {cleanEmail}. Vui lòng kiểm tra hộp thư đến (hoặc hòm thư rác).",
            email = cleanEmail
        });
    }

    /// <summary>
    /// Kiểm tra tính hợp lệ của mã OTP
    /// </summary>
    [HttpPost("forgot-password/verify-otp")]
    public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Otp))
            return BadRequest(new { success = false, message = "Email và mã OTP là bắt buộc." });

        var cleanEmail = request.Email.Trim();
        var user = await _context.NguoiDungs.FirstOrDefaultAsync(x => x.Email == cleanEmail && x.TrangThai);
        if (user is null)
            return NotFound(new { success = false, message = "Không tìm thấy tài khoản." });

        var validOtp = await _context.PasswordResetOtps
            .Where(x => x.NguoiDungId == user.NguoiDungId && !x.IsUsed && x.ExpiredAt > DateTime.Now)
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync();

        if (validOtp is null)
            return BadRequest(new { success = false, message = "Mã OTP đã hết hạn hoặc không tồn tại. Vui lòng yêu cầu gửi lại mã mới." });

        if (validOtp.SoLanThu >= 5)
        {
            validOtp.IsUsed = true;
            await _context.SaveChangesAsync();
            return BadRequest(new { success = false, message = "Bạn đã nhập sai OTP quá 5 lần. Vui lòng yêu cầu mã mới." });
        }

        var isCorrect = BCrypt.Net.BCrypt.Verify(request.Otp.Trim(), validOtp.OtpCodeHash);
        if (!isCorrect)
        {
            validOtp.SoLanThu += 1;
            await _context.SaveChangesAsync();
            return BadRequest(new { success = false, message = $"Mã OTP không chính xác. Bạn còn {5 - validOtp.SoLanThu} lần thử." });
        }

        return Ok(new { success = true, message = "Mã OTP hợp lệ." });
    }

    /// <summary>
    /// Đặt lại mật khẩu mới bằng mã OTP
    /// </summary>
    [HttpPost("forgot-password/reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordWithOtpRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Otp) || string.IsNullOrWhiteSpace(request.NewPassword))
            return BadRequest(new { success = false, message = "Email, mã OTP và mật khẩu mới là bắt buộc." });

        if (request.NewPassword.Length < 6)
            return BadRequest(new { success = false, message = "Mật khẩu mới phải có ít nhất 6 ký tự." });

        var cleanEmail = request.Email.Trim();
        var user = await _context.NguoiDungs.FirstOrDefaultAsync(x => x.Email == cleanEmail && x.TrangThai);
        if (user is null)
            return NotFound(new { success = false, message = "Không tìm thấy tài khoản." });

        var validOtp = await _context.PasswordResetOtps
            .Where(x => x.NguoiDungId == user.NguoiDungId && !x.IsUsed && x.ExpiredAt > DateTime.Now)
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync();

        if (validOtp is null)
            return BadRequest(new { success = false, message = "Mã OTP đã hết hạn hoặc không tồn tại." });

        var isCorrect = BCrypt.Net.BCrypt.Verify(request.Otp.Trim(), validOtp.OtpCodeHash);
        if (!isCorrect)
            return BadRequest(new { success = false, message = "Mã OTP không chính xác." });

        // Đổi mật khẩu
        user.MatKhauHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        validOtp.IsUsed = true;
        await _context.SaveChangesAsync();

        return Ok(new { success = true, message = "Đặt lại mật khẩu thành công. Vui lòng đăng nhập bằng mật khẩu mới." });
    }
}
