<<<<<<< HEAD
=======
﻿using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Security.Claims;
>>>>>>> origin/Backend
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
<<<<<<< HEAD
using ProGroup_AI.API.DTOs.Admin;
=======
>>>>>>> origin/Backend
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/admin")]
<<<<<<< HEAD
[Authorize(Roles = "ADMIN")]
public sealed class AdminController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public AdminController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("users")]
    public async Task<ActionResult<IReadOnlyList<AdminUserResponse>>> GetUsers(
        [FromQuery] string? role,
        [FromQuery] string? search)
    {
        var query = _db.NguoiDungs.AsNoTracking()
            .Include(u => u.VaiTro)
            .Include(u => u.SinhVien).ThenInclude(s => s!.Khoa)
            .Include(u => u.GiangVien).ThenInclude(g => g!.Khoa)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(role))
        {
            var roleFilter = role.Trim().ToUpperInvariant();
            query = query.Where(u => u.VaiTro != null && (
                u.VaiTro.MaVaiTro.ToUpper() == roleFilter ||
                u.VaiTro.MaVaiTro.ToUpper().Contains(roleFilter) ||
                u.VaiTro.TenVaiTro.ToUpper().Contains(roleFilter) ||
                (roleFilter == "SINHVIEN" && (u.VaiTro.MaVaiTro.Contains("SV") || u.VaiTro.TenVaiTro.Contains("Sinh viên"))) ||
                (roleFilter == "GIANGVIEN" && (u.VaiTro.MaVaiTro.Contains("GV") || u.VaiTro.TenVaiTro.Contains("Giảng viên"))) ||
                (roleFilter == "GIAOVUKHOA" && (u.VaiTro.MaVaiTro.Contains("GVK") || u.VaiTro.MaVaiTro.Contains("GIAOVU") || u.VaiTro.TenVaiTro.Contains("Giáo vụ"))) ||
                (roleFilter == "PHONGDAOTAO" && (u.VaiTro.MaVaiTro.Contains("PDT") || u.VaiTro.MaVaiTro.Contains("DAOTAO") || u.VaiTro.TenVaiTro.Contains("Đào tạo"))) ||
                (roleFilter == "ADMIN" && (u.VaiTro.MaVaiTro.Contains("ADMIN") || u.VaiTro.TenVaiTro.Contains("Quản trị")))
            ));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(u =>
                u.TenDangNhap.Contains(s) ||
                u.HoTen.Contains(s) ||
                u.Email.Contains(s) ||
                (u.SinhVien != null && u.SinhVien.MSSV.Contains(s)) ||
                (u.GiangVien != null && u.GiangVien.MaGiangVien.Contains(s)));
        }

        var users = await query
            .OrderByDescending(u => u.CreatedAt)
            .Select(u => new AdminUserResponse
            {
                NguoiDungId = u.NguoiDungId,
                TenDangNhap = u.TenDangNhap,
                Email = u.Email,
                HoTen = u.HoTen,
                SoDienThoai = u.SoDienThoai,
                AvatarUrl = u.AvatarUrl,
                VaiTroId = u.VaiTroId,
                MaVaiTro = u.VaiTro != null ? u.VaiTro.MaVaiTro : string.Empty,
                TenVaiTro = u.VaiTro != null ? u.VaiTro.TenVaiTro : string.Empty,
                TrangThai = u.TrangThai,
                CreatedAt = u.CreatedAt,
                SinhVienId = u.SinhVien != null ? u.SinhVien.SinhVienId : null,
                MSSV = u.SinhVien != null ? u.SinhVien.MSSV : null,
                GiangVienId = u.GiangVien != null ? u.GiangVien.GiangVienId : null,
                MaGiangVien = u.GiangVien != null ? u.GiangVien.MaGiangVien : null,
                KhoaId = u.SinhVien != null ? u.SinhVien.KhoaId : (u.GiangVien != null ? u.GiangVien.KhoaId : null),
                TenKhoa = u.SinhVien != null && u.SinhVien.Khoa != null ? u.SinhVien.Khoa.TenKhoa : (u.GiangVien != null && u.GiangVien.Khoa != null ? u.GiangVien.Khoa.TenKhoa : null)
            })
            .ToListAsync();

        return Ok(users);
    }

    [HttpGet("overview")]
    [HttpGet("stats")]
    public async Task<ActionResult<AdminOverviewResponse>> GetOverview()
=======
[Authorize(Policy = "AdminOnly")]
public class AdminController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public AdminController(ApplicationDbContext db) => _db = db;

    [HttpGet("users")]
    public async Task<IActionResult> GetUsers()
    {
        var users = await _db.NguoiDungs.AsNoTracking()
            .Include(u => u.VaiTro)
            .OrderByDescending(u => u.CreatedAt)
            .Select(u => new
            {
                u.NguoiDungId,
                u.TenDangNhap,
                u.HoTen,
                u.Email,
                u.SoDienThoai,
                u.TrangThai,
                u.CreatedAt,
                Role = u.VaiTro != null ? u.VaiTro.MaVaiTro : "",
                RoleName = u.VaiTro != null ? u.VaiTro.TenVaiTro : ""
            })
            .ToListAsync();
        return Ok(users);
    }

    [HttpPut("users/{id:int}/status")]
    public async Task<IActionResult> UpdateUserStatus(int id, [FromBody] UpdateStatusRequest req)
    {
        var user = await _db.NguoiDungs.FindAsync(id);
        if (user == null) return NotFound(new { message = "Người dùng không tồn tại" });

        user.TrangThai = req.TrangThai;
        user.UpdatedAt = DateTime.Now;
        await _db.SaveChangesAsync();
        return Ok(new { message = "Cập nhật trạng thái thành công" });
    }

    [HttpGet("stats")]
    public async Task<IActionResult> GetStats()
>>>>>>> origin/Backend
    {
        var totalUsers = await _db.NguoiDungs.CountAsync();
        var totalStudents = await _db.SinhViens.CountAsync();
        var totalLecturers = await _db.GiangViens.CountAsync();
<<<<<<< HEAD
        var totalClasses = await _db.LopHocPhans.CountAsync();
        var totalTopics = await _db.DeTaiDoAns.CountAsync();
        var totalGroups = await _db.NhomDoAns.CountAsync(n => n.TrangThai != "Đã hủy");
        var totalRegistrations = await _db.DangKyDeTais.CountAsync();
        var openPeriods = await _db.DotDangKyDoAns.CountAsync(d => d.TrangThai == "Đang mở");

        return Ok(new AdminOverviewResponse
        {
            TongNguoiDung = totalUsers,
            TongSinhVien = totalStudents,
            TongGiangVien = totalLecturers,
            TongLopHocPhan = totalClasses,
            TongDeTai = totalTopics,
            TongNhom = totalGroups,
            TongDangKyDeTai = totalRegistrations,
            DotDangKyDangMo = openPeriods
        });
    }

    [HttpPost("users")]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        var username = request.TenDangNhap.Trim();
        var email = request.Email.Trim();

        var usernameExists = await _db.NguoiDungs.AnyAsync(u => u.TenDangNhap == username);
        if (usernameExists)
        {
            return Conflict(new { message = "Tên đăng nhập đã tồn tại trong hệ thống." });
        }

        var emailExists = await _db.NguoiDungs.AnyAsync(u => u.Email == email);
        if (emailExists)
        {
            return Conflict(new { message = "Email đã tồn tại trong hệ thống." });
        }

        VaiTro? role = null;
        if (request.VaiTroId.HasValue)
        {
            role = await _db.VaiTros.FindAsync(request.VaiTroId.Value);
        }
        else if (!string.IsNullOrWhiteSpace(request.MaVaiTro))
        {
            var code = request.MaVaiTro.Trim().ToUpperInvariant();
            role = await _db.VaiTros.FirstOrDefaultAsync(v => v.MaVaiTro.ToUpper() == code);
        }

        if (role is null)
        {
            return BadRequest(new { message = "Vai trò được chỉ định không tồn tại." });
        }

        var defaultKhoa = await _db.Khoas.FirstOrDefaultAsync();
        var khoaId = request.KhoaId ?? defaultKhoa?.KhoaId ?? 1;

        var user = new NguoiDung
        {
            TenDangNhap = username,
            MatKhauHash = BCrypt.Net.BCrypt.HashPassword(request.MatKhau),
            Email = email,
            HoTen = request.HoTen.Trim(),
            SoDienThoai = request.SoDienThoai?.Trim(),
            VaiTroId = role.VaiTroId,
            TrangThai = true,
            CreatedAt = DateTime.Now
        };

        _db.NguoiDungs.Add(user);
        await _db.SaveChangesAsync();

        if (role.MaVaiTro.Equals("SINHVIEN", StringComparison.OrdinalIgnoreCase))
        {
            var mssv = !string.IsNullOrWhiteSpace(request.MSSV) ? request.MSSV.Trim() : username;
            var sinhVien = new SinhVien
            {
                NguoiDungId = user.NguoiDungId,
                MSSV = mssv,
                KhoaId = khoaId,
                NgaySinh = request.NgaySinh,
                GioiTinh = request.GioiTinh?.Trim(),
                CreatedAt = DateTime.Now
            };
            _db.SinhViens.Add(sinhVien);
            await _db.SaveChangesAsync();
        }
        else if (role.MaVaiTro.Equals("GIANGVIEN", StringComparison.OrdinalIgnoreCase))
        {
            var magv = !string.IsNullOrWhiteSpace(request.MaGiangVien) ? request.MaGiangVien.Trim() : username;
            var giangVien = new GiangVien
            {
                NguoiDungId = user.NguoiDungId,
                MaGiangVien = magv,
                KhoaId = khoaId,
                HocVi = request.HocVi?.Trim(),
                ChuyenMon = request.ChuyenMon?.Trim(),
                CreatedAt = DateTime.Now
            };
            _db.GiangViens.Add(giangVien);
            await _db.SaveChangesAsync();
        }

        var created = await _db.NguoiDungs.AsNoTracking()
            .Include(u => u.VaiTro)
            .Include(u => u.SinhVien).ThenInclude(s => s!.Khoa)
            .Include(u => u.GiangVien).ThenInclude(g => g!.Khoa)
            .Where(u => u.NguoiDungId == user.NguoiDungId)
            .Select(u => new AdminUserResponse
            {
                NguoiDungId = u.NguoiDungId,
                TenDangNhap = u.TenDangNhap,
                Email = u.Email,
                HoTen = u.HoTen,
                SoDienThoai = u.SoDienThoai,
                AvatarUrl = u.AvatarUrl,
                VaiTroId = u.VaiTroId,
                MaVaiTro = u.VaiTro != null ? u.VaiTro.MaVaiTro : string.Empty,
                TenVaiTro = u.VaiTro != null ? u.VaiTro.TenVaiTro : string.Empty,
                TrangThai = u.TrangThai,
                CreatedAt = u.CreatedAt,
                SinhVienId = u.SinhVien != null ? u.SinhVien.SinhVienId : null,
                MSSV = u.SinhVien != null ? u.SinhVien.MSSV : null,
                GiangVienId = u.GiangVien != null ? u.GiangVien.GiangVienId : null,
                MaGiangVien = u.GiangVien != null ? u.GiangVien.MaGiangVien : null,
                KhoaId = u.SinhVien != null ? u.SinhVien.KhoaId : (u.GiangVien != null ? u.GiangVien.KhoaId : null),
                TenKhoa = u.SinhVien != null && u.SinhVien.Khoa != null ? u.SinhVien.Khoa.TenKhoa : (u.GiangVien != null && u.GiangVien.Khoa != null ? u.GiangVien.Khoa.TenKhoa : null)
            })
            .FirstAsync();

        return CreatedAtAction(nameof(GetUsers), new { search = user.TenDangNhap }, created);
    }

    [HttpPut("users/{id:int}/toggle-status")]
    [HttpPut("users/{id:int}/status")]
    public async Task<IActionResult> ToggleUserStatus(int id, [FromBody] UpdateUserStatusRequest? request = null)
    {
        var user = await _db.NguoiDungs.FindAsync(id);
        if (user is null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        if (request?.TrangThai.HasValue == true)
        {
            user.TrangThai = request.TrangThai.Value;
        }
        else
        {
            user.TrangThai = !user.TrangThai;
        }

        user.UpdatedAt = DateTime.Now;
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            userId = user.NguoiDungId,
            trangThai = user.TrangThai,
            message = user.TrangThai ? "Đã kích hoạt tài khoản." : "Đã khóa tài khoản."
        });
    }
}
=======
        var totalCourses = await _db.LopHocPhans.CountAsync();
        var totalTopics = await _db.DeTaiDoAns.CountAsync();
        var totalGroups = await _db.NhomDoAns.CountAsync();

        return Ok(new
        {
            totalUsers,
            totalStudents,
            totalLecturers,
            totalCourses,
            totalTopics,
            totalGroups
        });
    }
}

public class UpdateStatusRequest
{
    public bool TrangThai { get; set; }
}
>>>>>>> origin/Backend
