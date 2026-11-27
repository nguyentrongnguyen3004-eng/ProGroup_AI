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
[Authorize(Roles = "GIANGVIEN,ADMIN,PHONGDAOTAO,GIAOVUKHOA")]
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
        if (lecturerId is null && (!User.IsInRole("ADMIN") && !User.IsInRole("PHONGDAOTAO") && !User.IsInRole("GIAOVUKHOA")))
        {
            return Ok(Array.Empty<LecturerCourseResponse>());
        }

        var classesQuery = _db.LopHocPhans.AsNoTracking()
            .Where(c => c.TrangThai);

        if (lecturerId.HasValue)
        {
            classesQuery = classesQuery.Where(c =>
                c.PhanCongGiangViens.Any(p => p.GiangVienId == lecturerId.Value && p.TrangThai));
        }

        // Dùng projection trực tiếp xuống SQL để đếm số lượng thay vì tải toàn bộ SinhVienLopHocPhans/NhomDoAns vào RAM
        var responses = await classesQuery
            .Select(c => new LecturerCourseResponse
            {
                LopHocPhanId = c.LopHocPhanId,
                MaLopHocPhan = c.MaLopHocPhan,
                TenLopHocPhan = c.TenLopHocPhan ?? string.Empty,
                HocPhanId = c.HocPhanId,
                MaHocPhan = c.HocPhan != null ? c.HocPhan.MaHocPhan : string.Empty,
                TenHocPhan = c.HocPhan != null ? c.HocPhan.TenHocPhan : string.Empty,
                HocKyId = c.HocKyId,
                TenHocKy = c.HocKy != null ? c.HocKy.TenHocKy : string.Empty,
                NamHoc = c.HocKy != null ? c.HocKy.NamHoc : string.Empty,
                NgayKetThucHocKy = c.HocKy != null ? (DateTime?)c.HocKy.NgayKetThuc : null,
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
            })
            .ToListAsync();

        return Ok(responses);
    }

    [HttpGet("statistics")]
    public async Task<ActionResult<LecturerStatisticsResponse>> GetStatistics()
    {
        var lecturerId = await GetCurrentLecturerIdAsync();
        if (lecturerId is null && (!User.IsInRole("ADMIN") && !User.IsInRole("PHONGDAOTAO") && !User.IsInRole("GIAOVUKHOA")))
        {
            return Ok(new LecturerStatisticsResponse());
        }

        var assignedClassIds = lecturerId.HasValue
            ? await _db.PhanCongGiangViens.AsNoTracking()
                .Where(p => p.GiangVienId == lecturerId.Value && p.TrangThai)
                .Select(p => p.LopHocPhanId)
                .ToListAsync()
            : await _db.LopHocPhans.AsNoTracking()
                .Where(c => c.TrangThai)
                .Select(c => c.LopHocPhanId)
                .ToListAsync();

        var totalClasses = assignedClassIds.Count;

        var totalGroups = await _db.NhomDoAns.AsNoTracking()
            .CountAsync(n => n.DotDangKy != null && assignedClassIds.Contains(n.DotDangKy.LopHocPhanId) && n.TrangThai != "Đã hủy");

        var topicStats = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => (t.DotDangKy != null && assignedClassIds.Contains(t.DotDangKy.LopHocPhanId)) ||
                        (lecturerId.HasValue && t.GiangVienId == lecturerId.Value))
            .Select(t => new { t.DeTaiId, t.TrangThai, t.TrangThaiDuyet })
            .ToListAsync();

        var totalTopics = topicStats.Count;
        var registeredTopicsCount = topicStats.Count(t => t.TrangThai == "Đã đăng ký");
        var pendingTopicsCount = topicStats.Count(t => t.TrangThaiDuyet == "Chờ duyệt");

        var topicIds = topicStats.Select(t => t.DeTaiId).ToList();
        var pendingRegistrationsCount = topicIds.Count == 0
            ? 0
            : await _db.DangKyDeTais.AsNoTracking()
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
        if (lecturerId is null && (!User.IsInRole("ADMIN") && !User.IsInRole("PHONGDAOTAO") && !User.IsInRole("GIAOVUKHOA")))
        {
            return Ok(Array.Empty<LecturerCourseResponse>());
        }

        var query = _db.DangKyDeTais.AsNoTracking().AsQueryable();

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
