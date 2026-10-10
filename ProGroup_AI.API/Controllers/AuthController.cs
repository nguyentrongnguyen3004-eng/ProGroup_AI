using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Auth;
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
    public async Task<IActionResult> Login(
        [FromBody] LoginRequest request)
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
}
