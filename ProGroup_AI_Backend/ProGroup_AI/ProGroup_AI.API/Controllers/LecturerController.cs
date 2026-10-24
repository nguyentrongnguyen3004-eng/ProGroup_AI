using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Lecturer;
using ProGroup_AI.API.DTOs.DangKyDeTai;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/lecturer")]
[Authorize(Roles = "GIANGVIEN,ADMIN")]
public sealed class LecturerController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public LecturerController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("courses")]
    public async Task<ActionResult<IReadOnlyList<LecturerCourseResponse>>> GetCourses()
    {
        var lecturerId = await GetCurrentLecturerIdAsync();
        if (lecturerId is null && !User.IsInRole("ADMIN"))
        {
            return Forbid();
        }

        var classesQuery = _db.LopHocPhans.AsNoTracking()
            .Include(c => c.HocPhan)
            .Include(c => c.HocKy)
            .Include(c => c.SinhVienLopHocPhans)
            .Include(c => c.DotDangKyDoAns).ThenInclude(d => d.NhomDoAns)
            .Include(c => c.DotDangKyDoAns).ThenInclude(d => d.DeTaiDoAns)
            .Where(c => c.TrangThai);

        if (lecturerId.HasValue)
        {
            var assignedClassIds = await _db.PhanCongGiangViens
                .Where(p => p.GiangVienId == lecturerId.Value && p.TrangThai)
                .Select(p => p.LopHocPhanId)
                .ToListAsync();

            classesQuery = classesQuery.Where(c => assignedClassIds.Contains(c.LopHocPhanId));
        }

        var classes = await classesQuery.ToListAsync();

        var responses = classes.Select(c => new LecturerCourseResponse
        {
            LopHocPhanId = c.LopHocPhanId,
            MaLopHocPhan = c.MaLopHocPhan,
            TenLopHocPhan = c.TenLopHocPhan ?? string.Empty,
            HocPhanId = c.HocPhanId,
            MaHocPhan = c.HocPhan?.MaHocPhan ?? string.Empty,
            TenHocPhan = c.HocPhan?.TenHocPhan ?? string.Empty,
            HocKyId = c.HocKyId,
            TenHocKy = c.HocKy?.TenHocKy ?? string.Empty,
            NamHoc = c.HocKy?.NamHoc ?? string.Empty,
            SoLuongToiDa = c.SoLuongToiDa,
            SoSinhVien = c.SinhVienLopHocPhans.Count(s => s.TrangThai),
            SoNhom = c.DotDangKyDoAns.SelectMany(d => d.NhomDoAns).Count(n => n.TrangThai != "Đã hủy"),
            SoDeTai = c.DotDangKyDoAns.SelectMany(d => d.DeTaiDoAns).Count(),
            DotDangKys = c.DotDangKyDoAns.Select(d => new CourseDotDangKyInfo
            {
                DotDangKyId = d.DotDangKyId,
                TenDot = d.TenDot,
                NgayBatDau = d.NgayBatDau,
                NgayKetThuc = d.NgayKetThuc,
                MinMembers = d.MinMembers,
                MaxMembers = d.MaxMembers,
                TrangThai = d.TrangThai,
                SoNhom = d.NhomDoAns.Count(n => n.TrangThai != "Đã hủy"),
                SoDeTai = d.DeTaiDoAns.Count
            }).ToList()
        }).ToList();

        return Ok(responses);
    }

    [HttpGet("statistics")]
    public async Task<ActionResult<LecturerStatisticsResponse>> GetStatistics()
    {
        var lecturerId = await GetCurrentLecturerIdAsync();
        if (lecturerId is null && !User.IsInRole("ADMIN"))
        {
            return Forbid();
        }

        IQueryable<int> assignedClassIdsQuery;
        if (lecturerId.HasValue)
        {
            assignedClassIdsQuery = _db.PhanCongGiangViens
                .Where(p => p.GiangVienId == lecturerId.Value && p.TrangThai)
                .Select(p => p.LopHocPhanId);
        }
        else
        {
            assignedClassIdsQuery = _db.LopHocPhans.Where(c => c.TrangThai).Select(c => c.LopHocPhanId);
        }

        var assignedClassIds = await assignedClassIdsQuery.ToListAsync();

        var totalClasses = assignedClassIds.Count;

        var periods = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(d => assignedClassIds.Contains(d.LopHocPhanId))
            .Include(d => d.NhomDoAns)
            .Include(d => d.DeTaiDoAns)
            .ToListAsync();

        var totalGroups = periods.SelectMany(d => d.NhomDoAns).Count(n => n.TrangThai != "Đã hủy");

        var topics = periods.SelectMany(d => d.DeTaiDoAns).ToList();
        if (lecturerId.HasValue)
        {
            var myOwnTopics = await _db.DeTaiDoAns.AsNoTracking()
                .Where(t => t.GiangVienId == lecturerId.Value && !topics.Select(x => x.DeTaiId).Contains(t.DeTaiId))
                .ToListAsync();
            topics.AddRange(myOwnTopics);
        }

        var totalTopics = topics.Count;
        var registeredTopicsCount = topics.Count(t => t.TrangThai == "Đã đăng ký");
        var pendingTopicsCount = topics.Count(t => t.TrangThaiDuyet == "Chờ duyệt");

        var topicIds = topics.Select(t => t.DeTaiId).ToList();
        var pendingRegistrationsCount = await _db.DangKyDeTais
            .CountAsync(r => topicIds.Contains(r.DeTaiId) && r.TrangThai == "Chờ duyệt");

        var percent = totalTopics > 0
            ? Math.Round((double)registeredTopicsCount / totalTopics * 100, 2)
            : 0;

        return Ok(new LecturerStatisticsResponse
        {
            TongLopHocPhan = totalClasses,
            TongNhom = totalGroups,
            TongDeTai = totalTopics,
            SoDeTaiDaDangKy = registeredTopicsCount,
            PhanTramDaDangKy = percent,
            SoDeTaiChoDuyet = pendingTopicsCount,
            SoDangKyChoDuyet = pendingRegistrationsCount
        });
    }

    [HttpGet("topic-registrations")]
    public async Task<ActionResult<IReadOnlyList<DangKyDeTaiResponse>>> GetTopicRegistrations()
    {
        var lecturerId = await GetCurrentLecturerIdAsync();
        if (lecturerId is null && !User.IsInRole("ADMIN"))
        {
            return Forbid();
        }

        var query = _db.DangKyDeTais.AsNoTracking()
            .Include(r => r.DeTai).ThenInclude(t => t!.DotDangKy).ThenInclude(d => d!.LopHocPhan)
            .Include(r => r.Nhom).ThenInclude(n => n!.TruongNhom).ThenInclude(s => s!.NguoiDung)
            .Include(r => r.GiangVienDuyet).ThenInclude(g => g!.NguoiDung)
            .AsQueryable();

        if (lecturerId.HasValue)
        {
            var assignedClassIds = await _db.PhanCongGiangViens
                .Where(p => p.GiangVienId == lecturerId.Value && p.TrangThai)
                .Select(p => p.LopHocPhanId)
                .ToListAsync();

            query = query.Where(r =>
                (r.DeTai != null && r.DeTai.GiangVienId == lecturerId.Value) ||
                (r.DeTai != null && r.DeTai.DotDangKy != null && assignedClassIds.Contains(r.DeTai.DotDangKy.LopHocPhanId)));
        }

        var list = await query
            .OrderByDescending(r => r.NgayDangKy)
            .Select(r => new DangKyDeTaiResponse
            {
                DangKyDeTaiId = r.DangKyDeTaiId,
                NhomId = r.NhomId,
                TenNhom = r.Nhom != null ? r.Nhom.TenNhom : string.Empty,
                TruongNhomId = r.Nhom != null ? r.Nhom.TruongNhomId : null,
                TenTruongNhom = r.Nhom != null && r.Nhom.TruongNhom != null && r.Nhom.TruongNhom.NguoiDung != null ? r.Nhom.TruongNhom.NguoiDung.HoTen : null,
                MSSVTruongNhom = r.Nhom != null && r.Nhom.TruongNhom != null ? r.Nhom.TruongNhom.MSSV : null,
                DeTaiId = r.DeTaiId,
                TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : string.Empty,
                DotDangKyId = r.DeTai != null ? r.DeTai.DotDangKyId : 0,
                TenDot = r.DeTai != null && r.DeTai.DotDangKy != null ? r.DeTai.DotDangKy.TenDot : null,
                LopHocPhanId = r.DeTai != null && r.DeTai.DotDangKy != null ? r.DeTai.DotDangKy.LopHocPhanId : null,
                TenLopHocPhan = r.DeTai != null && r.DeTai.DotDangKy != null && r.DeTai.DotDangKy.LopHocPhan != null ? r.DeTai.DotDangKy.LopHocPhan.TenLopHocPhan : null,
                TrangThai = r.TrangThai,
                GhiChu = r.GhiChu,
                NgayDangKy = r.NgayDangKy,
                NgayDuyet = r.NgayDuyet,
                GiangVienDuyetId = r.GiangVienDuyetId,
                TenGiangVienDuyet = r.GiangVienDuyet != null && r.GiangVienDuyet.NguoiDung != null ? r.GiangVienDuyet.NguoiDung.HoTen : null,
                SoThanhVien = r.Nhom != null ? r.Nhom.ThanhVienNhoms.Count(m => m.TrangThai == "Đã tham gia") : 0
            })
            .ToListAsync();

        return Ok(list);
    }

    private async Task<int?> GetCurrentLecturerIdAsync()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idClaim, out var userId)) return null;

        return await _db.GiangViens
            .Where(g => g.NguoiDungId == userId)
            .Select(g => (int?)g.GiangVienId)
            .FirstOrDefaultAsync();
    }
}
