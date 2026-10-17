using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Academic;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/lop-hoc-phan")]
[Authorize]
public sealed class LopHocPhanController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public LopHocPhanController(ApplicationDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<LopHocPhanResponse>>> GetAll([FromQuery] int? hocKyId)
    {
        var query = _db.LopHocPhans.AsNoTracking()
            .Where(x => x.TrangThai && x.HocPhan != null && x.HocPhan.TrangThai && x.HocKy != null && x.HocKy.TrangThai);
        if (hocKyId.HasValue) query = query.Where(x => x.HocKyId == hocKyId.Value);

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
            TenKhoa = x.Khoa == null ? string.Empty : x.Khoa.TenKhoa,
            SoLuongToiDa = x.SoLuongToiDa
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
                MaHocPhan = x.HocPhan == null ? string.Empty : x.HocPhan.MaHocPhan,
                TenHocPhan = x.HocPhan == null ? string.Empty : x.HocPhan.TenHocPhan,
                HocKyId = x.HocKyId,
                TenHocKy = x.HocKy == null ? string.Empty : x.HocKy.TenHocKy,
                NamHoc = x.HocKy == null ? string.Empty : x.HocKy.NamHoc,
                KhoaId = x.KhoaId,
                TenKhoa = x.Khoa == null ? string.Empty : x.Khoa.TenKhoa,
                SoLuongToiDa = x.SoLuongToiDa
            }).FirstOrDefaultAsync();
        return row is null ? NotFound() : Ok(row);
    }

    [Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateClassRequest request)
    {
        var code = request.MaLopHocPhan?.Trim() ?? string.Empty;
        if (string.IsNullOrEmpty(code)) return BadRequest(new { message = "Mã lớp học phần không được để trống." });

        if (await _db.LopHocPhans.AnyAsync(x => x.MaLopHocPhan == code))
        {
            return Conflict(new { message = "Mã lớp học phần đã tồn tại." });
        }

        var hocPhanCode = request.MaHocPhan?.Trim() ?? "HP001";
        var hocPhan = await _db.HocPhans.FirstOrDefaultAsync(h => h.MaHocPhan == hocPhanCode);
        if (hocPhan == null)
        {
            hocPhan = new HocPhan
            {
                MaHocPhan = hocPhanCode,
                TenHocPhan = !string.IsNullOrWhiteSpace(request.TenHocPhan) ? request.TenHocPhan.Trim() : hocPhanCode,
                SoTinChi = request.SoTinChi ?? 3,
                TrangThai = true
            };
            _db.HocPhans.Add(hocPhan);
            await _db.SaveChangesAsync();
        }

        var hocKy = await _db.HocKys.OrderByDescending(k => k.HocKyId).FirstOrDefaultAsync();
        if (hocKy == null)
        {
            hocKy = new HocKy
            {
                TenHocKy = request.TenHocKy ?? "Học kỳ 1",
                NamHoc = request.NamHoc ?? "2026-2027",
                NgayBatDau = DateTime.Today,
                NgayKetThuc = DateTime.Today.AddMonths(4),
                TrangThai = true
            };
            _db.HocKys.Add(hocKy);
            await _db.SaveChangesAsync();
        }

        var defaultKhoa = await _db.Khoas.FirstOrDefaultAsync();
        var khoaId = defaultKhoa?.KhoaId ?? 1;

        var lopHocPhan = new LopHocPhan
        {
            MaLopHocPhan = code,
            TenLopHocPhan = !string.IsNullOrWhiteSpace(request.TenLopHocPhan) ? request.TenLopHocPhan.Trim() : hocPhan.TenHocPhan,
            HocPhanId = hocPhan.HocPhanId,
            HocKyId = hocKy.HocKyId,
            KhoaId = khoaId,
            SoLuongToiDa = request.SoLuongToiDa ?? 50,
            TrangThai = true
        };

        _db.LopHocPhans.Add(lopHocPhan);
        await _db.SaveChangesAsync();

        return Ok(new { success = true, lopHocPhanId = lopHocPhan.LopHocPhanId, message = "Tạo lớp học phần thành công." });
    }
}
