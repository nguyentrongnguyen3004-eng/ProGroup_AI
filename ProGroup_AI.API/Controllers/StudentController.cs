using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Student;
using ProGroup_AI.API.DTOs.Topics;
using ProGroup_AI.API.DTOs.Groups;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/student")]
[Authorize(Roles = "SINHVIEN,ADMIN")]
public sealed class StudentController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public StudentController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("courses")]
    public async Task<ActionResult<IReadOnlyList<StudentCourseResponse>>> GetCourses()
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Tài khoản chưa có hồ sơ sinh viên." });
        }

        var courses = await _db.SinhVienLopHocPhans.AsNoTracking()
            .Where(s => s.SinhVienId == studentId.Value && s.TrangThai)
            .Include(s => s.LopHocPhan).ThenInclude(l => l!.HocPhan)
            .Include(s => s.LopHocPhan).ThenInclude(l => l!.HocKy)
            .Include(s => s.LopHocPhan).ThenInclude(l => l!.PhanCongGiangViens).ThenInclude(p => p.GiangVien).ThenInclude(g => g!.NguoiDung)
            .OrderBy(s => s.LopHocPhan!.MaLopHocPhan)
            .Select(s => new StudentCourseResponse
            {
                LopHocPhanId = s.LopHocPhanId,
                MaLopHocPhan = s.LopHocPhan != null ? s.LopHocPhan.MaLopHocPhan : string.Empty,
                TenLopHocPhan = s.LopHocPhan != null ? s.LopHocPhan.TenLopHocPhan ?? string.Empty : string.Empty,
                HocPhanId = s.LopHocPhan != null ? s.LopHocPhan.HocPhanId : 0,
                MaHocPhan = s.LopHocPhan != null && s.LopHocPhan.HocPhan != null ? s.LopHocPhan.HocPhan.MaHocPhan : string.Empty,
                TenHocPhan = s.LopHocPhan != null && s.LopHocPhan.HocPhan != null ? s.LopHocPhan.HocPhan.TenHocPhan : string.Empty,
                HocKyId = s.LopHocPhan != null ? s.LopHocPhan.HocKyId : 0,
                TenHocKy = s.LopHocPhan != null && s.LopHocPhan.HocKy != null ? s.LopHocPhan.HocKy.TenHocKy : string.Empty,
                NamHoc = s.LopHocPhan != null && s.LopHocPhan.HocKy != null ? s.LopHocPhan.HocKy.NamHoc : string.Empty,
                GiangVienPhuTrach = s.LopHocPhan != null ? s.LopHocPhan.PhanCongGiangViens
                    .Where(p => p.TrangThai)
                    .Select(p => p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : null)
                    .FirstOrDefault() : null,
                EmailGiangVien = s.LopHocPhan != null ? s.LopHocPhan.PhanCongGiangViens
                    .Where(p => p.TrangThai)
                    .Select(p => p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.Email : null)
                    .FirstOrDefault() : null,
                NgayThamGia = s.NgayThamGia
            })
            .ToListAsync();

        return Ok(courses);
    }

    [HttpGet("groups")]
    public async Task<IActionResult> GetMyGroups()
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Tài khoản chưa có hồ sơ sinh viên." });
        }

        var groupIds = await _db.NhomDoAns.AsNoTracking()
            .Where(g => g.TrangThai != "Đã hủy" &&
                (g.TruongNhomId == studentId.Value || g.ThanhVienNhoms.Any(m => m.SinhVienId == studentId.Value && m.TrangThai == "Đã tham gia")))
            .Select(g => g.NhomId)
            .ToListAsync();

        var groups = await _db.NhomDoAns.AsNoTracking()
            .Where(g => groupIds.Contains(g.NhomId))
            .Include(g => g.DotDangKy).ThenInclude(d => d!.LopHocPhan)
            .Include(g => g.TruongNhom).ThenInclude(s => s!.NguoiDung)
            .Include(g => g.ThanhVienNhoms).ThenInclude(m => m.SinhVien).ThenInclude(s => s!.NguoiDung)
            .Include(g => g.DangKyDeTais).ThenInclude(r => r.DeTai)
            .ToListAsync();

        var responses = groups.Select(g =>
        {
            var activeTopic = g.DangKyDeTais
                .Where(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt")
                .OrderByDescending(r => r.NgayDangKy)
                .Select(r => new
                {
                    r.DeTaiId,
                    TenDeTai = r.DeTai?.TenDeTai,
                    TrangThaiDangKy = r.TrangThai
                })
                .FirstOrDefault();

            var members = g.ThanhVienNhoms
                .Where(m => m.TrangThai == "Đã tham gia")
                .Select(m => new GroupMemberResponse
                {
                    SinhVienId = m.SinhVienId,
                    MSSV = m.SinhVien?.MSSV ?? string.Empty,
                    HoTen = m.SinhVien?.NguoiDung?.HoTen ?? string.Empty,
                    VaiTro = m.VaiTro,
                    TrangThai = m.TrangThai
                })
                .ToList();

            if (!members.Any(m => m.SinhVienId == g.TruongNhomId) && g.TruongNhom != null)
            {
                members.Insert(0, new GroupMemberResponse
                {
                    SinhVienId = g.TruongNhomId,
                    MSSV = g.TruongNhom.MSSV,
                    HoTen = g.TruongNhom.NguoiDung?.HoTen ?? string.Empty,
                    VaiTro = "Trưởng nhóm",
                    TrangThai = "Đã tham gia"
                });
            }

            return new
            {
                g.NhomId,
                g.DotDangKyId,
                TenDot = g.DotDangKy?.TenDot,
                LopHocPhanId = g.DotDangKy?.LopHocPhanId,
                TenLopHocPhan = g.DotDangKy?.LopHocPhan?.TenLopHocPhan,
                g.TenNhom,
                g.TruongNhomId,
                TruongNhom = g.TruongNhom?.NguoiDung?.HoTen ?? string.Empty,
                g.TrangThai,
                MinMembers = g.DotDangKy?.MinMembers ?? 0,
                MaxMembers = g.DotDangKy?.MaxMembers ?? 0,
                SoThanhVien = members.Count,
                ThanhViens = members,
                DeTai = activeTopic,
                g.CreatedAt
            };
        });

        return Ok(responses);
    }

    [HttpGet("topics")]
    public async Task<ActionResult<IReadOnlyList<TopicResponse>>> GetAvailableTopics()
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Tài khoản chưa có hồ sơ sinh viên." });
        }

        var enrolledClassIds = await _db.SinhVienLopHocPhans
            .Where(s => s.SinhVienId == studentId.Value && s.TrangThai)
            .Select(s => s.LopHocPhanId)
            .ToListAsync();

        var openPeriodIds = await _db.DotDangKyDoAns
            .Where(d => enrolledClassIds.Contains(d.LopHocPhanId) && d.TrangThai == "Đang mở")
            .Select(d => d.DotDangKyId)
            .ToListAsync();

        var query = _db.DeTaiDoAns.AsNoTracking()
            .Where(t => openPeriodIds.Contains(t.DotDangKyId) &&
                        t.TrangThai == "Chưa sử dụng" &&
                        t.TrangThaiDuyet == "Đã duyệt");

        var topics = await query
            .OrderByDescending(t => t.CreatedAt)
            .Select(ToTopicResponse())
            .ToListAsync();

        return Ok(topics);
    }

    private async Task<int?> GetCurrentStudentIdAsync()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idClaim, out var userId)) return null;

        return await _db.SinhViens
            .Where(s => s.NguoiDungId == userId)
            .Select(s => (int?)s.SinhVienId)
            .FirstOrDefaultAsync();
    }

    private static System.Linq.Expressions.Expression<Func<DeTaiDoAn, TopicResponse>> ToTopicResponse() => x => new TopicResponse
    {
        DeTaiId = x.DeTaiId,
        DotDangKyId = x.DotDangKyId,
        TenDot = x.DotDangKy != null ? x.DotDangKy.TenDot : null,
        LopHocPhanId = x.DotDangKy != null ? x.DotDangKy.LopHocPhanId : null,
        MaLopHocPhan = x.DotDangKy != null && x.DotDangKy.LopHocPhan != null ? x.DotDangKy.LopHocPhan.MaLopHocPhan : null,
        TenLopHocPhan = x.DotDangKy != null && x.DotDangKy.LopHocPhan != null ? x.DotDangKy.LopHocPhan.TenLopHocPhan : null,
        TenDeTai = x.TenDeTai,
        MoTa = x.MoTa,
        MucTieu = x.MucTieu,
        PhamVi = x.PhamVi,
        CongNgheDuKien = x.CongNgheDuKien,
        NguonDeTai = x.NguonDeTai,
        GiangVienId = x.GiangVienId,
        TenGiangVien = x.GiangVien != null && x.GiangVien.NguoiDung != null ? x.GiangVien.NguoiDung.HoTen : null,
        MaGiangVien = x.GiangVien != null ? x.GiangVien.MaGiangVien : null,
        SinhVienDeXuatId = x.SinhVienDeXuatId,
        TenSinhVienDeXuat = x.SinhVienDeXuat != null && x.SinhVienDeXuat.NguoiDung != null ? x.SinhVienDeXuat.NguoiDung.HoTen : null,
        MSSVDeXuat = x.SinhVienDeXuat != null ? x.SinhVienDeXuat.MSSV : null,
        TrangThai = x.TrangThai,
        TrangThaiDuyet = x.TrangThaiDuyet,
        LyDoTuChoi = x.LyDoTuChoi,
        CreatedAt = x.CreatedAt,
        UpdatedAt = x.UpdatedAt
    };
}
