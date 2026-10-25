using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/bao-cao")]
[Authorize]
public class BaoCaoTienDoController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public BaoCaoTienDoController(ApplicationDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// Lấy danh sách báo cáo tiến độ của một nhóm
    /// </summary>
    [HttpGet("nhom/{nhomId:int}")]
    public async Task<IActionResult> GetByGroup(int nhomId)
    {
        var list = await _db.BaoCaoTienDos
            .AsNoTracking()
            .Include(b => b.GiangVien).ThenInclude(g => g!.NguoiDung)
            .Include(b => b.DeTai)
            .Where(b => b.NhomId == nhomId)
            .OrderByDescending(b => b.TuanBaoCao)
            .ThenByDescending(b => b.NgayNop)
            .Select(b => new
            {
                b.BaoCaoId,
                b.NhomId,
                b.DeTaiId,
                TenDeTai = b.DeTai != null ? b.DeTai.TenDeTai : string.Empty,
                b.TieuDe,
                b.NoiDung,
                b.FileUrl,
                b.GithubUrl,
                b.DemoUrl,
                b.TuanBaoCao,
                b.NgayNop,
                b.TrangThai,
                b.NhanXetGiangVien,
                b.Diem,
                b.GiangVienId,
                TenGiangVien = b.GiangVien != null && b.GiangVien.NguoiDung != null ? b.GiangVien.NguoiDung.HoTen : string.Empty,
                b.NgayNhanXet
            })
            .ToListAsync();

        return Ok(list);
    }

    /// <summary>
    /// Lấy chi tiết một báo cáo
    /// </summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var b = await _db.BaoCaoTienDos
            .AsNoTracking()
            .Include(x => x.GiangVien).ThenInclude(g => g!.NguoiDung)
            .Include(x => x.DeTai)
            .Include(x => x.Nhom)
            .FirstOrDefaultAsync(x => x.BaoCaoId == id);

        if (b is null) return NotFound(new { message = "Không tìm thấy báo cáo tiến độ." });

        return Ok(new
        {
            b.BaoCaoId,
            b.NhomId,
            TenNhom = b.Nhom?.TenNhom ?? string.Empty,
            b.DeTaiId,
            TenDeTai = b.DeTai?.TenDeTai ?? string.Empty,
            b.TieuDe,
            b.NoiDung,
            b.FileUrl,
            b.GithubUrl,
            b.DemoUrl,
            b.TuanBaoCao,
            b.NgayNop,
            b.TrangThai,
            b.NhanXetGiangVien,
            b.Diem,
            b.GiangVienId,
            TenGiangVien = b.GiangVien?.NguoiDung?.HoTen ?? string.Empty,
            b.NgayNhanXet
        });
    }

    /// <summary>
    /// Sinh viên nộp báo cáo tiến độ
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> SubmitReport([FromBody] SubmitReportRequest request)
    {
        var group = await _db.NhomDoAns
            .Include(g => g.DangKyDeTais).ThenInclude(d => d.DeTai)
            .Include(g => g.TruongNhom)
            .FirstOrDefaultAsync(g => g.NhomId == request.NhomId);

        if (group is null) return NotFound(new { message = "Không tìm thấy nhóm." });

        var approvedReg = group.DangKyDeTais.FirstOrDefault(d => d.TrangThai == "Đã duyệt");
        int? deTaiId = approvedReg?.DeTaiId ?? group.DangKyDeTais.FirstOrDefault()?.DeTaiId;

        var report = new BaoCaoTienDo
        {
            NhomId = request.NhomId,
            DeTaiId = deTaiId,
            TieuDe = request.TieuDe.Trim(),
            NoiDung = (request.NoiDung ?? string.Empty).Trim(),
            FileUrl = request.FileUrl?.Trim(),
            GithubUrl = request.GithubUrl?.Trim(),
            DemoUrl = request.DemoUrl?.Trim(),
            TuanBaoCao = request.TuanBaoCao <= 0 ? 1 : request.TuanBaoCao,
            NgayNop = DateTime.UtcNow,
            TrangThai = "Đã nộp"
        };

        _db.BaoCaoTienDos.Add(report);

        // Tự động tạo thông báo gửi tới Giảng viên hướng dẫn
        if (approvedReg?.DeTai?.GiangVienId.HasValue == true)
        {
            var gv = await _db.GiangViens.FirstOrDefaultAsync(g => g.GiangVienId == approvedReg.DeTai.GiangVienId.Value);
            if (gv != null && gv.NguoiDungId > 0)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = gv.NguoiDungId,
                    TieuDe = $"Báo cáo tiến độ mới: Nhóm {group.TenNhom}",
                    NoiDung = $"Nhóm '{group.TenNhom}' đã nộp báo cáo tuần {report.TuanBaoCao}: '{report.TieuDe}'. Vui lòng vào xem và nhận xét.",
                    LoaiThongBao = "Tiến độ",
                    DaDoc = false,
                    CreatedAt = DateTime.UtcNow,
                    LienKetId = group.NhomId,
                    LoaiLienKet = "bao-cao-tien-do"
                });
            }
        }

        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = report.BaoCaoId }, new
        {
            report.BaoCaoId,
            report.NhomId,
            report.TieuDe,
            report.TuanBaoCao,
            report.TrangThai,
            report.NgayNop,
            message = "Nộp báo cáo tiến độ thành công."
        });
    }

    /// <summary>
    /// Giảng viên chấm điểm và nhận xét báo cáo
    /// </summary>
    [HttpPut("{id:int}/cham-diem")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> GradeReport(int id, [FromBody] GradeReportRequest request)
    {
        var report = await _db.BaoCaoTienDos
            .Include(b => b.Nhom).ThenInclude(n => n!.TruongNhom)
            .Include(b => b.Nhom).ThenInclude(n => n!.ThanhVienNhoms).ThenInclude(m => m.SinhVien)
            .FirstOrDefaultAsync(b => b.BaoCaoId == id);

        if (report is null) return NotFound(new { message = "Không tìm thấy báo cáo tiến độ." });

        int? gvId = null;
        if (int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var uid))
        {
            var gv = await _db.GiangViens.FirstOrDefaultAsync(g => g.NguoiDungId == uid);
            gvId = gv?.GiangVienId;
        }

        report.Diem = request.Diem;
        report.NhanXetGiangVien = request.NhanXetGiangVien?.Trim();
        report.TrangThai = string.IsNullOrWhiteSpace(request.TrangThai) ? "Đạt" : request.TrangThai.Trim();
        report.GiangVienId = gvId;
        report.NgayNhanXet = DateTime.UtcNow;

        // Tạo thông báo cho toàn bộ thành viên nhóm
        if (report.Nhom != null)
        {
            var memberUserIds = new HashSet<int>();
            if (report.Nhom.TruongNhom?.NguoiDungId > 0)
                memberUserIds.Add(report.Nhom.TruongNhom.NguoiDungId);

            foreach (var m in report.Nhom.ThanhVienNhoms)
            {
                if (m.SinhVien?.NguoiDungId > 0)
                    memberUserIds.Add(m.SinhVien.NguoiDungId);
            }

            var diemStr = report.Diem.HasValue ? $"{report.Diem.Value:0.#}/10" : "Đã nhận xét";
            foreach (var mUserId in memberUserIds)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = mUserId,
                    TieuDe = $"Đánh giá báo cáo: {report.TieuDe}",
                    NoiDung = $"Giảng viên đã nhận xét báo cáo tuần {report.TuanBaoCao}. Kết quả: {report.TrangThai} ({diemStr}). Lời nhận xét: {report.NhanXetGiangVien ?? "Không có"}",
                    LoaiThongBao = "Tiến độ",
                    DaDoc = false,
                    CreatedAt = DateTime.UtcNow,
                    LienKetId = report.BaoCaoId,
                    LoaiLienKet = "bao-cao-tien-do"
                });
            }
        }

        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            report.BaoCaoId,
            report.Diem,
            report.NhanXetGiangVien,
            report.TrangThai,
            report.NgayNhanXet,
            message = "Đã lưu nhận xét và điểm số thành công."
        });
    }

    /// <summary>
    /// Giảng viên lấy toàn bộ báo cáo cần xem xét của các nhóm
    /// </summary>
    [HttpGet("giang-vien")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> GetReportsForLecturer()
    {
        var list = await _db.BaoCaoTienDos
            .AsNoTracking()
            .Include(b => b.Nhom)
            .Include(b => b.DeTai)
            .Include(b => b.GiangVien).ThenInclude(g => g!.NguoiDung)
            .OrderByDescending(b => b.NgayNop)
            .Select(b => new
            {
                b.BaoCaoId,
                b.NhomId,
                TenNhom = b.Nhom != null ? b.Nhom.TenNhom : string.Empty,
                b.DeTaiId,
                TenDeTai = b.DeTai != null ? b.DeTai.TenDeTai : string.Empty,
                b.TieuDe,
                b.NoiDung,
                b.FileUrl,
                b.GithubUrl,
                b.DemoUrl,
                b.TuanBaoCao,
                b.NgayNop,
                b.TrangThai,
                b.NhanXetGiangVien,
                b.Diem,
                b.GiangVienId,
                TenGiangVien = b.GiangVien != null && b.GiangVien.NguoiDung != null ? b.GiangVien.NguoiDung.HoTen : string.Empty,
                b.NgayNhanXet
            })
            .ToListAsync();

        return Ok(list);
    }
}

public sealed class SubmitReportRequest
{
    public int NhomId { get; set; }
    public string TieuDe { get; set; } = string.Empty;
    public string? NoiDung { get; set; }
    public string? FileUrl { get; set; }
    public string? GithubUrl { get; set; }
    public string? DemoUrl { get; set; }
    public int TuanBaoCao { get; set; } = 1;
}

public sealed class GradeReportRequest
{
    public decimal? Diem { get; set; }
    public string? NhanXetGiangVien { get; set; }
    public string? TrangThai { get; set; } // Đạt, Cần chỉnh sửa, Không đạt
}
