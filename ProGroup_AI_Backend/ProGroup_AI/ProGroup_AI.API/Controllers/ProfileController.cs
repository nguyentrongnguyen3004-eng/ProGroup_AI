using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Profile;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/profile")]
[Authorize]
public sealed class ProfileController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public ProfileController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<ProfileResponse>> GetProfile()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await _db.NguoiDungs.AsNoTracking()
            .Include(u => u.VaiTro)
            .Include(u => u.SinhVien).ThenInclude(s => s!.Khoa)
            .Include(u => u.GiangVien).ThenInclude(g => g!.Khoa)
            .FirstOrDefaultAsync(u => u.NguoiDungId == userId);

        if (user is null)
        {
            return NotFound(new { message = "Không tìm thấy thông tin người dùng." });
        }

        var response = new ProfileResponse
        {
            NguoiDungId = user.NguoiDungId,
            TenDangNhap = user.TenDangNhap,
            Email = user.Email,
            HoTen = user.HoTen,
            SoDienThoai = user.SoDienThoai,
            AvatarUrl = user.AvatarUrl,
            VaiTroId = user.VaiTroId,
            MaVaiTro = user.VaiTro?.MaVaiTro ?? string.Empty,
            TenVaiTro = user.VaiTro?.TenVaiTro ?? string.Empty,
            TrangThai = user.TrangThai,
            CreatedAt = user.CreatedAt
        };

        if (user.SinhVien is not null)
        {
            var enrolledCourses = await _db.SinhVienLopHocPhans.AsNoTracking()
                .Where(s => s.SinhVienId == user.SinhVien.SinhVienId && s.TrangThai)
                .Include(s => s.LopHocPhan).ThenInclude(l => l!.HocPhan)
                .Select(s => new StudentCourseInfo
                {
                    LopHocPhanId = s.LopHocPhanId,
                    MaLopHocPhan = s.LopHocPhan != null ? s.LopHocPhan.MaLopHocPhan : string.Empty,
                    TenLopHocPhan = s.LopHocPhan != null ? s.LopHocPhan.TenLopHocPhan ?? string.Empty : string.Empty,
                    TenHocPhan = s.LopHocPhan != null && s.LopHocPhan.HocPhan != null ? s.LopHocPhan.HocPhan.TenHocPhan : null
                })
                .ToListAsync();

            response.SinhVien = new StudentProfileInfo
            {
                SinhVienId = user.SinhVien.SinhVienId,
                MSSV = user.SinhVien.MSSV,
                KhoaId = user.SinhVien.KhoaId,
                TenKhoa = user.SinhVien.Khoa?.TenKhoa,
                MaKhoa = user.SinhVien.Khoa?.MaKhoa,
                NgaySinh = user.SinhVien.NgaySinh,
                GioiTinh = user.SinhVien.GioiTinh,
                LopHocPhans = enrolledCourses
            };
        }

        if (user.GiangVien is not null)
        {
            response.GiangVien = new LecturerProfileInfo
            {
                GiangVienId = user.GiangVien.GiangVienId,
                MaGiangVien = user.GiangVien.MaGiangVien,
                KhoaId = user.GiangVien.KhoaId,
                TenKhoa = user.GiangVien.Khoa?.TenKhoa,
                MaKhoa = user.GiangVien.Khoa?.MaKhoa,
                HocVi = user.GiangVien.HocVi,
                ChuyenMon = user.GiangVien.ChuyenMon
            };
        }

        return Ok(response);
    }

    [HttpPut]
    public async Task<ActionResult<ProfileResponse>> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await _db.NguoiDungs.FirstOrDefaultAsync(u => u.NguoiDungId == userId);
        if (user is null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        if (!string.IsNullOrWhiteSpace(request.HoTen))
        {
            user.HoTen = request.HoTen.Trim();
        }

        if (request.SoDienThoai is not null)
        {
            user.SoDienThoai = string.IsNullOrWhiteSpace(request.SoDienThoai) ? null : request.SoDienThoai.Trim();
        }

        if (request.AvatarUrl is not null)
        {
            user.AvatarUrl = string.IsNullOrWhiteSpace(request.AvatarUrl) ? null : request.AvatarUrl.Trim();
        }

        user.UpdatedAt = DateTime.Now;
        await _db.SaveChangesAsync();

        return await GetProfile();
    }

    [HttpPost("avatar")]
    public async Task<IActionResult> UploadAvatar([FromBody] UploadAvatarRequest request)
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await _db.NguoiDungs.FirstOrDefaultAsync(u => u.NguoiDungId == userId);
        if (user is null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        if (string.IsNullOrWhiteSpace(request.AvatarData))
        {
            user.AvatarUrl = null;
            user.UpdatedAt = DateTime.Now;
            await _db.SaveChangesAsync();
            return Ok(new { avatarUrl = (string?)null, message = "Đã xóa ảnh đại diện." });
        }

        var data = request.AvatarData.Trim();
        byte[] bytes;
        string extension = ".jpg";

        if (data.StartsWith("data:image/"))
        {
            var commaIndex = data.IndexOf(',');
            if (commaIndex == -1)
            {
                return BadRequest(new { message = "Định dạng ảnh không hợp lệ." });
            }

            var header = data[..commaIndex];
            if (header.Contains("png")) extension = ".png";
            else if (header.Contains("webp")) extension = ".webp";
            else if (header.Contains("gif")) extension = ".gif";

            try
            {
                bytes = Convert.FromBase64String(data[(commaIndex + 1)..]);
            }
            catch
            {
                return BadRequest(new { message = "Dữ liệu Base64 không hợp lệ." });
            }
        }
        else
        {
            try
            {
                bytes = Convert.FromBase64String(data);
            }
            catch
            {
                return BadRequest(new { message = "Dữ liệu Base64 không hợp lệ." });
            }
        }

        if (bytes.Length > 5 * 1024 * 1024)
        {
            return BadRequest(new { message = "Kích thước ảnh tối đa là 5MB." });
        }

        var wwwroot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
        var avatarsDir = Path.Combine(wwwroot, "uploads", "avatars");
        if (!Directory.Exists(avatarsDir))
        {
            Directory.CreateDirectory(avatarsDir);
        }

        var fileName = $"user_{userId}_{DateTimeOffset.UtcNow.ToUnixTimeSeconds()}{extension}";
        var filePath = Path.Combine(avatarsDir, fileName);

        await System.IO.File.WriteAllBytesAsync(filePath, bytes);

        var relativeUrl = $"/uploads/avatars/{fileName}";
        user.AvatarUrl = relativeUrl;
        user.UpdatedAt = DateTime.Now;
        await _db.SaveChangesAsync();

        return Ok(new { avatarUrl = relativeUrl, message = "Cập nhật ảnh đại diện thành công." });
    }
}