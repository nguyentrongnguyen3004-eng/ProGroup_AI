using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/admin")]
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
    {
        var totalUsers = await _db.NguoiDungs.CountAsync();
        var totalStudents = await _db.SinhViens.CountAsync();
        var totalLecturers = await _db.GiangViens.CountAsync();
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
