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
            .Where(x => x.LopHocPhanId == id)
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
}
