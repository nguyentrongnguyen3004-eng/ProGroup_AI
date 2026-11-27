using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.DotDangKy;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/dot-dang-ky")]
[Authorize]
public sealed class DotDangKyController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public DotDangKyController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<DotDangKyResponse>>> GetAll([FromQuery] int? lopHocPhanId)
    {
        var query = _db.DotDangKyDoAns.AsNoTracking().AsQueryable();

        if (lopHocPhanId.HasValue)
        {
            query = query.Where(d => d.LopHocPhanId == lopHocPhanId.Value);
        }

        var results = await query
            .OrderByDescending(d => d.NgayBatDau)
            .Select(ToResponse())
            .ToListAsync();

        return Ok(results);
    }

    [HttpGet("dang-mo")]
    public async Task<ActionResult<IReadOnlyList<DotDangKyResponse>>> GetOpenPeriods()
    {
        var now = DateTime.Now;
        var results = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(d => d.TrangThai == "Đang mở")
            .OrderBy(d => d.NgayKetThuc)
            .Select(ToResponse())
            .ToListAsync();

        return Ok(results);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<DotDangKyResponse>> GetById(int id)
    {
        var item = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(d => d.DotDangKyId == id)
            .Select(ToResponse())
            .FirstOrDefaultAsync();

        return item is null ? NotFound(new { message = "Không tìm thấy đợt đăng ký." }) : Ok(item);
    }

    [HttpPost]
    [Authorize(Roles = "GIANGVIEN,ADMIN,GIAOVUKHOA")]
    public async Task<ActionResult<DotDangKyResponse>> Create([FromBody] CreateDotDangKyRequest request)
    {
        // TC_LEC_027: Chặn chọn Ngày bắt đầu của đợt đăng ký trong quá khứ
        if (request.NgayBatDau.Date < DateTime.Today)
        {
            return BadRequest(new { message = "Ngày bắt đầu không được ở trong quá khứ." });
        }

        if (request.NgayKetThuc <= request.NgayBatDau)
        {
            return BadRequest(new { message = "Ngày kết thúc phải sau ngày bắt đầu." });
        }

        if (request.MinMembers <= 0 || request.MaxMembers < request.MinMembers)
        {
            return BadRequest(new { message = "Số lượng thành viên không hợp lệ (Min > 0 và Max >= Min)." });
        }

        var course = await _db.LopHocPhans.AsNoTracking().FirstOrDefaultAsync(c => c.LopHocPhanId == request.LopHocPhanId);
        if (course is null)
        {
            return BadRequest(new { message = "Lớp học phần không tồn tại." });
        }

        var status = (DateTime.Now >= request.NgayBatDau && DateTime.Now <= request.NgayKetThuc)
            ? "Đang mở"
            : "Chưa mở";

        var period = new DotDangKyDoAn
        {
            TenDot = request.TenDot.Trim(),
            LopHocPhanId = request.LopHocPhanId,
            NgayBatDau = request.NgayBatDau,
            NgayKetThuc = request.NgayKetThuc,
            MinMembers = request.MinMembers,
            MaxMembers = request.MaxMembers,
            TrangThai = status,
            CreatedAt = DateTime.Now
        };

        _db.DotDangKyDoAns.Add(period);
        await _db.SaveChangesAsync();

        if (status == "Đang mở")
        {
            await NotifyStaffOnPeriodActivatedAsync(period, course);
        }

        var created = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(d => d.DotDangKyId == period.DotDangKyId)
            .Select(ToResponse())
            .FirstAsync();

        return CreatedAtAction(nameof(GetById), new { id = period.DotDangKyId }, created);
    }

    [HttpPut("{id:int}/trang-thai")]
    [Authorize(Roles = "GIANGVIEN,ADMIN,GIAOVUKHOA")]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateTrangThaiDotRequest request)
    {
        var period = await _db.DotDangKyDoAns.FindAsync(id);
        if (period is null)
        {
            return NotFound(new { message = "Không tìm thấy đợt đăng ký." });
        }

        var validStatuses = new[] { "Chưa mở", "Đang mở", "Đã đóng" };
        if (!validStatuses.Contains(request.TrangThai))
        {
            return BadRequest(new { message = "Trạng thái không hợp lệ. Phải là 'Chưa mở', 'Đang mở' hoặc 'Đã đóng'." });
        }

        var wasOpen = period.TrangThai == "Đang mở";
        period.TrangThai = request.TrangThai;
        await _db.SaveChangesAsync();

        if (!wasOpen && request.TrangThai == "Đang mở")
        {
            var course = await _db.LopHocPhans.AsNoTracking()
                .FirstOrDefaultAsync(c => c.LopHocPhanId == period.LopHocPhanId);
            if (course != null)
            {
                await NotifyStaffOnPeriodActivatedAsync(period, course);
            }
        }

        var updated = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(d => d.DotDangKyId == id)
            .Select(ToResponse())
            .FirstAsync();

        return Ok(updated);
    }

    private async Task NotifyStaffOnPeriodActivatedAsync(DotDangKyDoAn period, LopHocPhan course)
    {
        var tenLhp = string.IsNullOrWhiteSpace(course.TenLopHocPhan)
            ? course.MaLopHocPhan
            : course.TenLopHocPhan;

        var staffUserIds = await _db.NguoiDungs.AsNoTracking()
            .Where(u => u.TrangThai && u.VaiTro != null &&
                        (u.VaiTro.MaVaiTro == "PHONGDAOTAO" || u.VaiTro.MaVaiTro == "GIAOVUKHOA"))
            .Select(u => u.NguoiDungId)
            .ToListAsync();

        foreach (var uid in staffUserIds)
        {
            _db.ThongBaos.Add(new ThongBao
            {
                NguoiDungId = uid,
                TieuDe = $"Đợt đăng ký đồ án mới: {period.TenDot}",
                NoiDung = $"Đợt đăng ký đồ án cho LHP {tenLhp} vừa được kích hoạt.",
                LoaiThongBao = "Hệ thống",
                LienKetId = period.DotDangKyId,
                LoaiLienKet = "DotDangKyDoAn",
                DaDoc = false,
                CreatedAt = DateTime.Now
            });
        }

        if (staffUserIds.Count > 0)
        {
            await _db.SaveChangesAsync();
        }
    }

    private static System.Linq.Expressions.Expression<Func<DotDangKyDoAn, DotDangKyResponse>> ToResponse() => d => new DotDangKyResponse
    {
        DotDangKyId = d.DotDangKyId,
        LopHocPhanId = d.LopHocPhanId,
        MaLopHocPhan = d.LopHocPhan != null ? d.LopHocPhan.MaLopHocPhan : null,
        TenLopHocPhan = d.LopHocPhan != null ? d.LopHocPhan.TenLopHocPhan : null,
        TenDot = d.TenDot,
        NgayBatDau = d.NgayBatDau,
        NgayKetThuc = d.NgayKetThuc,
        MinMembers = d.MinMembers,
        MaxMembers = d.MaxMembers,
        TrangThai = d.TrangThai,
        SoLuongNhom = d.NhomDoAns.Count(n => n.TrangThai != "Đã hủy"),
        SoLuongDeTai = d.DeTaiDoAns.Count,
        CreatedAt = d.CreatedAt
    };
}
