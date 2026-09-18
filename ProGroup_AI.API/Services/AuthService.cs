using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Auth;

namespace ProGroup_AI.API.Services;

public class AuthService : IAuthService
{
    private readonly ApplicationDbContext _context;
    private readonly IJwtService _jwtService;

    public AuthService(
        ApplicationDbContext context,
        IJwtService jwtService)
    {
        _context = context;
        _jwtService = jwtService;
    }

    public async Task<LoginResponse> LoginAsync(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.TenDangNhap))
        {
            return new LoginResponse
            {
                Success = false,
                Message = "Vui lòng nhập tên đăng nhập."
            };
        }

        if (string.IsNullOrWhiteSpace(request.MatKhau))
        {
            return new LoginResponse
            {
                Success = false,
                Message = "Vui lòng nhập mật khẩu."
            };
        }

        var user = await _context.NguoiDungs
            .Include(x => x.VaiTro)
            .Include(x => x.SinhVien)
            .Include(x => x.GiangVien)
            .FirstOrDefaultAsync(
                x => x.TenDangNhap == request.TenDangNhap
            );

        if (user == null)
        {
            return new LoginResponse
            {
                Success = false,
                Message = "Tên đăng nhập hoặc mật khẩu không chính xác."
            };
        }

        if (!user.TrangThai)
        {
            return new LoginResponse
            {
                Success = false,
                Message = "Tài khoản đã bị khóa hoặc không hoạt động."
            };
        }

        if (string.IsNullOrWhiteSpace(user.MatKhauHash))
        {
            return new LoginResponse
            {
                Success = false,
                Message = "Tài khoản chưa được thiết lập mật khẩu."
            };
        }

        bool passwordValid;

        try
        {
            passwordValid = BCrypt.Net.BCrypt.Verify(
                request.MatKhau,
                user.MatKhauHash
            );
        }
        catch
        {
            passwordValid = false;
        }

        if (!passwordValid)
        {
            return new LoginResponse
            {
                Success = false,
                Message = "Tên đăng nhập hoặc mật khẩu không chính xác."
            };
        }

        var token = _jwtService.GenerateToken(user);

        var expiresAt = DateTime.UtcNow.AddMinutes(120);

        return new LoginResponse
        {
            Success = true,
            Message = "Đăng nhập thành công.",
            Token = token,
            ExpiresAt = expiresAt,

            User = new UserInfoResponse
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
            }
        };
    }
}