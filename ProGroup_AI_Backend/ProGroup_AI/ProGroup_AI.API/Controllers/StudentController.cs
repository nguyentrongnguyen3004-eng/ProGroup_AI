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
[Authorize]
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
            return Ok(Array.Empty<StudentCourseResponse>());
        }

        var courses = await _db.SinhVienLopHocPhans.AsNoTracking()
            .Where(s => s.SinhVienId == studentId.Value && s.TrangThai)
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
                NgayThamGia = s.NgayThamGia,
                TrangThai = s.LopHocPhan != null && s.LopHocPhan.DotDangKyDoAns.Any(d => d.TrangThai == "Đang mở" && DateTime.Now >= d.NgayBatDau && DateTime.Now <= d.NgayKetThuc)
                    ? "Đang mở"
                    : "Đã đóng"
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
            return Ok(Array.Empty<StudentCourseResponse>());
        }

        // Dùng projection trực tiếp thay vì 4x .Include() để tránh Cartesian explosion và giảm SQL Memory Grant
        var groups = await _db.NhomDoAns.AsNoTracking()
            .Where(g => g.TrangThai != "Đã hủy" &&
                (g.TruongNhomId == studentId.Value || g.ThanhVienNhoms.Any(m => m.SinhVienId == studentId.Value && m.TrangThai == "Đã tham gia")))
            .Select(g => new
            {
                g.NhomId,
                g.DotDangKyId,
                TenDot = g.DotDangKy != null ? g.DotDangKy.TenDot : null,
                LopHocPhanId = g.DotDangKy != null ? (int?)g.DotDangKy.LopHocPhanId : null,
                TenLopHocPhan = g.DotDangKy != null && g.DotDangKy.LopHocPhan != null ? g.DotDangKy.LopHocPhan.TenLopHocPhan : null,
                g.TenNhom,
                g.TruongNhomId,
                TruongNhomHoTen = g.TruongNhom != null && g.TruongNhom.NguoiDung != null ? g.TruongNhom.NguoiDung.HoTen : string.Empty,
                TruongNhomMSSV = g.TruongNhom != null ? g.TruongNhom.MSSV : string.Empty,
                HasTruongNhomRecord = g.TruongNhom != null,
                g.TrangThai,
                MinMembers = g.DotDangKy != null ? g.DotDangKy.MinMembers : 0,
                MaxMembers = g.DotDangKy != null ? g.DotDangKy.MaxMembers : 0,
                g.CreatedAt,
                Members = g.ThanhVienNhoms
                    .Where(m => m.TrangThai == "Đã tham gia")
                    .Select(m => new GroupMemberResponse
                    {
                        SinhVienId = m.SinhVienId,
                        MSSV = m.SinhVien != null ? m.SinhVien.MSSV : string.Empty,
                        HoTen = m.SinhVien != null && m.SinhVien.NguoiDung != null ? m.SinhVien.NguoiDung.HoTen : string.Empty,
                        VaiTro = m.VaiTro,
                        TrangThai = m.TrangThai
                    })
                    .ToList(),
                ActiveTopic = g.DangKyDeTais
                    .Where(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt")
                    .OrderByDescending(r => r.NgayDangKy)
                    .Select(r => new
                    {
                        r.DeTaiId,
                        TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : null,
                        TrangThaiDangKy = r.TrangThai
                    })
                    .FirstOrDefault()
            })
            .ToListAsync();

        var responses = groups.Select(g =>
        {
            var members = g.Members;
            if (!members.Any(m => m.SinhVienId == g.TruongNhomId) && g.HasTruongNhomRecord)
            {
                members.Insert(0, new GroupMemberResponse
                {
                    SinhVienId = g.TruongNhomId,
                    MSSV = g.TruongNhomMSSV,
                    HoTen = g.TruongNhomHoTen,
                    VaiTro = "Trưởng nhóm",
                    TrangThai = "Đã tham gia"
                });
            }

            return new
            {
                g.NhomId,
                g.DotDangKyId,
                g.TenDot,
                g.LopHocPhanId,
                g.TenLopHocPhan,
                g.TenNhom,
                g.TruongNhomId,
                TruongNhom = g.TruongNhomHoTen,
                g.TrangThai,
                g.MinMembers,
                g.MaxMembers,
                SoThanhVien = members.Count,
                ThanhViens = members,
                DeTai = g.ActiveTopic,
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
            return Ok(Array.Empty<TopicResponse>());
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
                        (t.TrangThai == "Chưa sử dụng" || t.TrangThai == "Đang hoạt động") &&
                        t.TrangThaiDuyet == "Đã duyệt");

        var topics = (await query
            .Select(ToTopicResponse())
            .ToListAsync())
            .OrderByDescending(t => t.CreatedAt)
            .ToList();

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
