using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Academic;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/lop-hoc-phan")]
[Authorize]
public sealed class LopHocPhanController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public LopHocPhanController(ApplicationDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<LopHocPhanResponse>>> GetAll([FromQuery] int? hocKyId, [FromQuery] bool? myClassesOnly)
    {
        var query = _db.LopHocPhans.AsNoTracking()
            .Where(x => x.TrangThai && x.HocPhan != null && x.HocPhan.TrangThai && x.HocKy != null && x.HocKy.TrangThai);
        
        if (hocKyId.HasValue) 
            query = query.Where(x => x.HocKyId == hocKyId.Value);

        // Nếu là sinh viên và yêu cầu lấy lớp của mình (hoặc mặc định myClassesOnly != false)
        if (int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId) && User.IsInRole("SINHVIEN") && myClassesOnly != false)
        {
            var studentId = await _db.SinhViens.Where(s => s.NguoiDungId == userId).Select(s => (int?)s.SinhVienId).FirstOrDefaultAsync();
            if (studentId != null)
            {
                var enrolledClassIds = await _db.SinhVienLopHocPhans
                    .Where(s => s.SinhVienId == studentId.Value && s.TrangThai)
                    .Select(s => s.LopHocPhanId)
                    .ToListAsync();
                if (enrolledClassIds.Count > 0)
                {
                    query = query.Where(x => enrolledClassIds.Contains(x.LopHocPhanId));
                }
            }
        }

        var rows = await query.OrderBy(x => x.MaLopHocPhan).Select(x => new LopHocPhanResponse
        {
            LopHocPhanId = x.LopHocPhanId,
            MaLopHocPhan = x.MaLopHocPhan,
            TenLopHocPhan = x.TenLopHocPhan,
            HocPhanId = x.HocPhanId,
            MaHocPhan = x.HocPhan!.MaHocPhan,
            TenHocPhan = x.HocPhan.TenHocPhan,
            HocKyId = x.HocKyId,
            TenHocKy = x.HocKy!.TenHocKy,
            NamHoc = x.HocKy.NamHoc,
            KhoaId = x.KhoaId,
            TenKhoa = x.Khoa != null ? x.Khoa.TenKhoa : string.Empty,
            SoLuongToiDa = x.SoLuongToiDa,
            GiangVienId = x.PhanCongGiangViens.Where(p => p.TrangThai).Select(p => (int?)p.GiangVienId).FirstOrDefault(),
            GiangVienTen = x.PhanCongGiangViens
                .Where(p => p.TrangThai && p.GiangVien != null && p.GiangVien.NguoiDung != null)
                .Select(p => p.GiangVien!.NguoiDung!.HoTen)
                .FirstOrDefault() ?? "Chưa phân công",
            GiangVienHocVi = x.PhanCongGiangViens
                .Where(p => p.TrangThai && p.GiangVien != null)
                .Select(p => p.GiangVien!.HocVi)
                .FirstOrDefault()
        }).ToListAsync();

        return Ok(rows);
    }

    [Authorize(Policy = "LecturerOnly")]
    [HttpGet("me")]
    public async Task<ActionResult<IReadOnlyList<LopHocPhanResponse>>> GetMyClasses()
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
            return Unauthorized();
        
        var giangVienId = await _db.GiangViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.GiangVienId).FirstOrDefaultAsync();
        if (giangVienId == null) return Forbid();

        var query = _db.LopHocPhans.AsNoTracking()
            .Where(x => x.TrangThai && x.PhanCongGiangViens.Any(p => p.GiangVienId == giangVienId && p.TrangThai));

        var rows = await query.OrderBy(x => x.MaLopHocPhan).Select(x => new LopHocPhanResponse
        {
            LopHocPhanId = x.LopHocPhanId,
            MaLopHocPhan = x.MaLopHocPhan,
            TenLopHocPhan = x.TenLopHocPhan,
            HocPhanId = x.HocPhanId,
            MaHocPhan = x.HocPhan!.MaHocPhan,
            TenHocPhan = x.HocPhan.TenHocPhan,
            HocKyId = x.HocKyId,
            TenHocKy = x.HocKy!.TenHocKy,
            NamHoc = x.HocKy.NamHoc,
            KhoaId = x.KhoaId,
            TenKhoa = x.Khoa != null ? x.Khoa.TenKhoa : string.Empty,
            SoLuongToiDa = x.SoLuongToiDa,
            GiangVienId = giangVienId,
            GiangVienTen = x.PhanCongGiangViens
                .Where(p => p.TrangThai && p.GiangVien != null && p.GiangVien.NguoiDung != null)
                .Select(p => p.GiangVien!.NguoiDung!.HoTen)
                .FirstOrDefault() ?? "Chưa phân công",
            GiangVienHocVi = x.PhanCongGiangViens
                .Where(p => p.TrangThai && p.GiangVien != null)
                .Select(p => p.GiangVien!.HocVi)
                .FirstOrDefault()
        }).ToListAsync();

        return Ok(rows);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<LopHocPhanResponse>> GetById(int id)
    {
        var row = await _db.LopHocPhans.AsNoTracking()
            .Where(x => x.LopHocPhanId == id && x.TrangThai &&
                x.HocPhan != null && x.HocPhan.TrangThai &&
                x.HocKy != null && x.HocKy.TrangThai)
            .Select(x => new LopHocPhanResponse
            {
                LopHocPhanId = x.LopHocPhanId,
                MaLopHocPhan = x.MaLopHocPhan,
                TenLopHocPhan = x.TenLopHocPhan,
                HocPhanId = x.HocPhanId,
                MaHocPhan = x.HocPhan!.MaHocPhan,
                TenHocPhan = x.HocPhan.TenHocPhan,
                HocKyId = x.HocKyId,
                TenHocKy = x.HocKy!.TenHocKy,
                NamHoc = x.HocKy.NamHoc,
                KhoaId = x.KhoaId,
                TenKhoa = x.Khoa != null ? x.Khoa.TenKhoa : string.Empty,
                SoLuongToiDa = x.SoLuongToiDa,
                GiangVienId = x.PhanCongGiangViens.Where(p => p.TrangThai).Select(p => (int?)p.GiangVienId).FirstOrDefault(),
                GiangVienTen = x.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null && p.GiangVien.NguoiDung != null)
                    .Select(p => p.GiangVien!.NguoiDung!.HoTen)
                    .FirstOrDefault() ?? "Chưa phân công",
                GiangVienHocVi = x.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null)
                    .Select(p => p.GiangVien!.HocVi)
                    .FirstOrDefault()
            }).FirstOrDefaultAsync();

        return row is null ? NotFound() : Ok(row);
    }

    [HttpGet("{id:int}/dot-dang-ky")]
    public async Task<IActionResult> GetRegistrationPeriod(int id)
    {
        var period = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(x => x.LopHocPhanId == id)
            .OrderByDescending(x => x.DotDangKyId)
            .Select(x => new
            {
                x.DotDangKyId,
                x.LopHocPhanId,
                x.TenDot,
                x.NgayBatDau,
                x.NgayKetThuc,
                x.MinMembers,
                x.MaxMembers,
                x.TrangThai,
                IsOpen = x.TrangThai == "Đang mở" && DateTime.Now >= x.NgayBatDau && DateTime.Now <= x.NgayKetThuc
            })
            .FirstOrDefaultAsync();

        if (period == null)
            return NotFound(new { message = "Lớp học phần chưa có đợt đăng ký đồ án nào." });

        return Ok(period);
    }

    [HttpGet("{id:int}/sinh-vien")]
    public async Task<IActionResult> GetStudentsInClass(int id)
    {
        var students = await _db.SinhVienLopHocPhans.AsNoTracking()
            .Where(x => x.LopHocPhanId == id && x.TrangThai)
            .Include(x => x.SinhVien).ThenInclude(s => s!.NguoiDung)
            .Select(x => new
            {
                x.SinhVienId,
                MSSV = x.SinhVien != null ? x.SinhVien.MSSV : string.Empty,
                HoTen = x.SinhVien != null && x.SinhVien.NguoiDung != null ? x.SinhVien.NguoiDung.HoTen : string.Empty,
                Email = x.SinhVien != null && x.SinhVien.NguoiDung != null ? x.SinhVien.NguoiDung.Email : string.Empty
            })
            .ToListAsync();

        return Ok(students);
    }
}
