using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Governance;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/governance")]
[Authorize(Roles = "GIAOVUKHOA,ADMIN,PHONGDAOTAO")]
public sealed class GovernanceController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public GovernanceController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("courses")]
    public async Task<IActionResult> GetCourses()
    {
        var courses = await _db.LopHocPhans.AsNoTracking()
            .Include(c => c.HocPhan)
            .Include(c => c.HocKy)
            .Include(c => c.Khoa)
            .Include(c => c.PhanCongGiangViens).ThenInclude(p => p.GiangVien).ThenInclude(g => g!.NguoiDung)
            .Include(c => c.SinhVienLopHocPhans)
            .OrderBy(c => c.MaLopHocPhan)
            .Select(c => new
            {
                c.LopHocPhanId,
                c.MaLopHocPhan,
                c.TenLopHocPhan,
                c.HocPhanId,
                MaHocPhan = c.HocPhan != null ? c.HocPhan.MaHocPhan : string.Empty,
                TenHocPhan = c.HocPhan != null ? c.HocPhan.TenHocPhan : string.Empty,
                c.HocKyId,
                TenHocKy = c.HocKy != null ? c.HocKy.TenHocKy : string.Empty,
                NamHoc = c.HocKy != null ? c.HocKy.NamHoc : string.Empty,
                c.KhoaId,
                TenKhoa = c.Khoa != null ? c.Khoa.TenKhoa : string.Empty,
                c.SoLuongToiDa,
                SoSinhVien = c.SinhVienLopHocPhans.Count(s => s.TrangThai),
                GiangViens = c.PhanCongGiangViens
                    .Where(p => p.TrangThai)
                    .Select(p => new
                    {
                        p.GiangVienId,
                        MaGiangVien = p.GiangVien != null ? p.GiangVien.MaGiangVien : string.Empty,
                        HoTen = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : string.Empty,
                        p.VaiTro
                    }).ToList(),
                c.TrangThai
            })
            .ToListAsync();

        return Ok(courses);
    }

    [HttpGet("assignments")]
    public async Task<ActionResult<IReadOnlyList<AssignmentResponse>>> GetAssignments([FromQuery] int? lopHocPhanId)
    {
        var query = _db.PhanCongGiangViens.AsNoTracking()
            .Include(p => p.LopHocPhan)
            .Include(p => p.GiangVien).ThenInclude(g => g!.NguoiDung)
            .AsQueryable();

        if (lopHocPhanId.HasValue)
        {
            query = query.Where(p => p.LopHocPhanId == lopHocPhanId.Value);
        }

        var results = await query
            .OrderByDescending(p => p.NgayPhanCong)
            .Select(p => new AssignmentResponse
            {
                PhanCongId = p.PhanCongId,
                LopHocPhanId = p.LopHocPhanId,
                MaLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.MaLopHocPhan : string.Empty,
                TenLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.TenLopHocPhan ?? string.Empty : string.Empty,
                GiangVienId = p.GiangVienId,
                MaGiangVien = p.GiangVien != null ? p.GiangVien.MaGiangVien : string.Empty,
                HoTen = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : string.Empty,
                Email = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.Email : string.Empty,
                VaiTro = p.VaiTro,
                NgayPhanCong = p.NgayPhanCong,
                TrangThai = p.TrangThai
            })
            .ToListAsync();

        return Ok(results);
    }

    [HttpPost("assignments")]
    public async Task<IActionResult> CreateAssignment([FromBody] AssignmentRequest request)
    {
        var courseExists = await _db.LopHocPhans.AnyAsync(c => c.LopHocPhanId == request.LopHocPhanId);
        if (!courseExists)
        {
            return BadRequest(new { message = "Lớp học phần không tồn tại." });
        }

        var lecturerExists = await _db.GiangViens.AnyAsync(g => g.GiangVienId == request.GiangVienId);
        if (!lecturerExists)
        {
            return BadRequest(new { message = "Giảng viên không tồn tại." });
        }

        var existingAssignment = await _db.PhanCongGiangViens
            .FirstOrDefaultAsync(p => p.LopHocPhanId == request.LopHocPhanId && p.GiangVienId == request.GiangVienId);

        if (existingAssignment is not null)
        {
            if (existingAssignment.TrangThai)
            {
                return Conflict(new { message = "Giảng viên này đã được phân công vào lớp học phần này." });
            }

            existingAssignment.TrangThai = true;
            existingAssignment.VaiTro = !string.IsNullOrWhiteSpace(request.VaiTro) ? request.VaiTro.Trim() : "Giảng viên phụ trách";
            existingAssignment.NgayPhanCong = DateTime.Now;
            await _db.SaveChangesAsync();

            return Ok(new { success = true, message = "Đã kích hoạt lại phân công giảng viên." });
        }

        var assignment = new PhanCongGiangVien
        {
            LopHocPhanId = request.LopHocPhanId,
            GiangVienId = request.GiangVienId,
            VaiTro = !string.IsNullOrWhiteSpace(request.VaiTro) ? request.VaiTro.Trim() : "Giảng viên phụ trách",
            NgayPhanCong = DateTime.Now,
            TrangThai = true
        };

        _db.PhanCongGiangViens.Add(assignment);
        await _db.SaveChangesAsync();

        var created = await _db.PhanCongGiangViens.AsNoTracking()
            .Include(p => p.LopHocPhan)
            .Include(p => p.GiangVien).ThenInclude(g => g!.NguoiDung)
            .Where(p => p.PhanCongId == assignment.PhanCongId)
            .Select(p => new AssignmentResponse
            {
                PhanCongId = p.PhanCongId,
                LopHocPhanId = p.LopHocPhanId,
                MaLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.MaLopHocPhan : string.Empty,
                TenLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.TenLopHocPhan ?? string.Empty : string.Empty,
                GiangVienId = p.GiangVienId,
                MaGiangVien = p.GiangVien != null ? p.GiangVien.MaGiangVien : string.Empty,
                HoTen = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : string.Empty,
                Email = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.Email : string.Empty,
                VaiTro = p.VaiTro,
                NgayPhanCong = p.NgayPhanCong,
                TrangThai = p.TrangThai
            })
            .FirstAsync();

        return CreatedAtAction(nameof(GetAssignments), new { lopHocPhanId = assignment.LopHocPhanId }, created);
    }

    [HttpGet("students")]
    public async Task<IActionResult> GetStudents([FromQuery] int? khoaId, [FromQuery] string? search)
    {
        var query = _db.SinhViens.AsNoTracking()
            .Include(s => s.NguoiDung)
            .Include(s => s.Khoa)
            .AsQueryable();

        if (khoaId.HasValue)
        {
            query = query.Where(s => s.KhoaId == khoaId.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(sv => sv.MSSV.Contains(s) || (sv.NguoiDung != null && (sv.NguoiDung.HoTen.Contains(s) || sv.NguoiDung.Email.Contains(s))));
        }

        var students = await query
            .OrderBy(s => s.MSSV)
            .Select(s => new
            {
                s.SinhVienId,
                s.MSSV,
                s.NguoiDungId,
                HoTen = s.NguoiDung != null ? s.NguoiDung.HoTen : string.Empty,
                Email = s.NguoiDung != null ? s.NguoiDung.Email : string.Empty,
                SoDienThoai = s.NguoiDung != null ? s.NguoiDung.SoDienThoai : null,
                s.KhoaId,
                TenKhoa = s.Khoa != null ? s.Khoa.TenKhoa : string.Empty,
                s.NgaySinh,
                s.GioiTinh,
                TrangThai = s.NguoiDung != null && s.NguoiDung.TrangThai
            })
            .ToListAsync();

        return Ok(students);
    }

    [HttpGet("lecturers")]
    public async Task<IActionResult> GetLecturers([FromQuery] int? khoaId, [FromQuery] string? search)
    {
        var query = _db.GiangViens.AsNoTracking()
            .Include(g => g.NguoiDung)
            .Include(g => g.Khoa)
            .AsQueryable();

        if (khoaId.HasValue)
        {
            query = query.Where(g => g.KhoaId == khoaId.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(gv => gv.MaGiangVien.Contains(s) || (gv.NguoiDung != null && (gv.NguoiDung.HoTen.Contains(s) || gv.NguoiDung.Email.Contains(s))));
        }

        var lecturers = await query
            .OrderBy(g => g.MaGiangVien)
            .Select(g => new
            {
                g.GiangVienId,
                g.MaGiangVien,
                g.NguoiDungId,
                HoTen = g.NguoiDung != null ? g.NguoiDung.HoTen : string.Empty,
                Email = g.NguoiDung != null ? g.NguoiDung.Email : string.Empty,
                SoDienThoai = g.NguoiDung != null ? g.NguoiDung.SoDienThoai : null,
                g.KhoaId,
                TenKhoa = g.Khoa != null ? g.Khoa.TenKhoa : string.Empty,
                g.HocVi,
                g.ChuyenMon,
                TrangThai = g.NguoiDung != null && g.NguoiDung.TrangThai
            })
            .ToListAsync();

        return Ok(lecturers);
    }
}
