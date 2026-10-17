using System.Data;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Projects;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/projects")]
[Authorize]
public sealed class ProjectsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public ProjectsController(ApplicationDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<ProjectResponse>>> GetAll([FromQuery] int? dotDangKyId, [FromQuery] int? lopHocPhanId)
    {
        var query = _db.DeTaiDoAns.AsNoTracking()
            .Where(x => x.TrangThai == "Chưa sử dụng" && x.TrangThaiDuyet == "Đã duyệt");

        if (dotDangKyId.HasValue) 
            query = query.Where(x => x.DotDangKyId == dotDangKyId.Value);

        if (lopHocPhanId.HasValue)
        {
            var periodIds = await _db.DotDangKyDoAns
                .Where(x => x.LopHocPhanId == lopHocPhanId.Value)
                .Select(x => x.DotDangKyId)
                .ToListAsync();
            query = query.Where(x => periodIds.Contains(x.DotDangKyId));
        }

        var rows = await query.OrderBy(x => x.TenDeTai).Select(ToResponseExpression()).ToListAsync();
        return Ok(rows);
    }

    [HttpGet("lecturer-topics")]
    [Authorize(Policy = "LecturerOnly")]
    public async Task<ActionResult<IReadOnlyList<ProjectResponse>>> GetLecturerTopics([FromQuery] int? dotDangKyId)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var giangVienId = await _db.GiangViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.GiangVienId).FirstOrDefaultAsync();
        if (giangVienId == null) return Forbid();

        var query = _db.DeTaiDoAns.AsNoTracking().Where(x => x.GiangVienId == giangVienId);
        if (dotDangKyId.HasValue) query = query.Where(x => x.DotDangKyId == dotDangKyId.Value);
        
        var rows = await query.OrderByDescending(x => x.DeTaiId).Select(ToResponseExpression()).ToListAsync();
        return Ok(rows);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ProjectResponse>> GetById(int id)
    {
        var row = await _db.DeTaiDoAns.AsNoTracking().Where(x => x.DeTaiId == id)
            .Select(ToResponseExpression()).FirstOrDefaultAsync();
        return row is null ? NotFound() : Ok(row);
    }

    [Authorize(Policy = "LecturerOnly")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateProjectRequest request)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var giangVienId = await _db.GiangViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.GiangVienId).FirstOrDefaultAsync();
        if (giangVienId == null) return Forbid();

        var topic = new DeTaiDoAn
        {
            DotDangKyId = request.DotDangKyId,
            TenDeTai = request.TenDeTai,
            MoTa = request.MoTa,
            MucTieu = request.MucTieu,
            PhamVi = request.PhamVi,
            CongNgheDuKien = request.CongNgheDuKien,
            NguonDeTai = "Giảng viên",
            TrangThai = "Chưa sử dụng",
            TrangThaiDuyet = "Đã duyệt",
            GiangVienId = giangVienId
        };

        _db.DeTaiDoAns.Add(topic);
        await _db.SaveChangesAsync();

        var created = await _db.DeTaiDoAns.AsNoTracking().Where(x => x.DeTaiId == topic.DeTaiId)
            .Select(ToResponseExpression()).FirstOrDefaultAsync();

        return CreatedAtAction(nameof(GetById), new { id = topic.DeTaiId }, created);
    }

    [Authorize(Policy = "StudentOnly")]
    [HttpPost("propose")]
    public async Task<IActionResult> ProposeTopic([FromBody] CreateProjectRequest request)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var studentId = await _db.SinhViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.SinhVienId).FirstOrDefaultAsync();
        if (studentId == null) return Forbid();

        var topic = new DeTaiDoAn
        {
            DotDangKyId = request.DotDangKyId,
            TenDeTai = request.TenDeTai,
            MoTa = request.MoTa,
            MucTieu = request.MucTieu,
            PhamVi = request.PhamVi,
            CongNgheDuKien = request.CongNgheDuKien,
            NguonDeTai = "Sinh viên đề xuất",
            TrangThai = "Chưa sử dụng",
            TrangThaiDuyet = "Chờ duyệt",
            SinhVienDeXuatId = studentId
        };

        _db.DeTaiDoAns.Add(topic);
        await _db.SaveChangesAsync();

        var created = await _db.DeTaiDoAns.AsNoTracking().Where(x => x.DeTaiId == topic.DeTaiId)
            .Select(ToResponseExpression()).FirstOrDefaultAsync();

        return CreatedAtAction(nameof(GetById), new { id = topic.DeTaiId }, created);
    }

    [Authorize(Policy = "LecturerOnly")]
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateProjectRequest request)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var giangVienId = await _db.GiangViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.GiangVienId).FirstOrDefaultAsync();
        if (giangVienId == null) return Forbid();

        var topic = await _db.DeTaiDoAns.FirstOrDefaultAsync(x => x.DeTaiId == id && x.GiangVienId == giangVienId);
        if (topic is null) return NotFound(new { message = "Không tìm thấy đề tài hoặc bạn không có quyền sửa." });

        topic.TenDeTai = request.TenDeTai;
        topic.MoTa = request.MoTa;
        topic.MucTieu = request.MucTieu;
        topic.PhamVi = request.PhamVi;
        topic.CongNgheDuKien = request.CongNgheDuKien;

        await _db.SaveChangesAsync();
        var updated = await _db.DeTaiDoAns.AsNoTracking().Where(x => x.DeTaiId == id).Select(ToResponseExpression()).FirstOrDefaultAsync();
        return Ok(updated);
    }

    [Authorize(Policy = "LecturerOnly")]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var giangVienId = await _db.GiangViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.GiangVienId).FirstOrDefaultAsync();
        if (giangVienId == null) return Forbid();

        var topic = await _db.DeTaiDoAns.FirstOrDefaultAsync(x => x.DeTaiId == id && x.GiangVienId == giangVienId);
        if (topic is null) return NotFound(new { message = "Không tìm thấy đề tài hoặc bạn không có quyền xóa." });

        if (topic.TrangThai != "Chưa sử dụng") return Conflict(new { message = "Không thể xóa đề tài đã được đăng ký hoặc sử dụng." });

        _db.DeTaiDoAns.Remove(topic);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [Authorize(Policy = "StudentOnly")]
    [HttpPost("dang-ky")]
    public async Task<IActionResult> Register([FromBody] RegisterProjectRequest request)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var studentId = await _db.SinhViens.Where(x => x.NguoiDungId == userId)
            .Select(x => (int?)x.SinhVienId).FirstOrDefaultAsync();
        if (studentId is null)
        {
            var problem = new ProblemDetails
            {
                Status = StatusCodes.Status403Forbidden,
                Title = "Tài khoản chưa có hồ sơ sinh viên.",
                Detail = "Liên hệ quản trị viên để liên kết tài khoản với hồ sơ sinh viên."
            };
            problem.Extensions["code"] = "student_profile_missing";
            return StatusCode(StatusCodes.Status403Forbidden, problem);
        }

        await using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        var group = await _db.NhomDoAns.Include(x => x.DotDangKy)
            .Include(x => x.ThanhVienNhoms)
            .FirstOrDefaultAsync(x => x.NhomId == request.NhomId && x.TruongNhomId == studentId.Value && x.TrangThai == "Đang hoạt động");
        if (group is null) return Conflict(new { message = "Không tìm thấy nhóm hoạt động do bạn dẫn dắt." });
        var period = group.DotDangKy;
        if (period is null || period.TrangThai != "Đang mở" || DateTime.Now < period.NgayBatDau || DateTime.Now > period.NgayKetThuc)
            return Conflict(new { message = "Đợt đăng ký đồ án hiện không mở." });

        var activeMembers = group.ThanhVienNhoms.Count(x => x.TrangThai == "Đã tham gia");
        if (!group.ThanhVienNhoms.Any(x => x.SinhVienId == group.TruongNhomId && x.TrangThai == "Đã tham gia")) activeMembers++;
        if (activeMembers < period.MinMembers) return Conflict(new { message = "Nhóm chưa đủ số thành viên tối thiểu." });

        var hasRegistration = await _db.DangKyDeTais.AnyAsync(x => x.NhomId == group.NhomId &&
            (x.TrangThai == "Chờ duyệt" || x.TrangThai == "Đã duyệt"));
        if (hasRegistration) return Conflict(new { message = "Nhóm đã có đăng ký đề tài đang xử lý hoặc đã được duyệt." });

        var topic = await _db.DeTaiDoAns.FirstOrDefaultAsync(x => x.DeTaiId == request.DeTaiId && x.DotDangKyId == period.DotDangKyId);
        if (topic is null) return NotFound(new { message = "Đề tài không tồn tại trong đợt đăng ký của nhóm." });
        if (topic.TrangThai != "Chưa sử dụng" || topic.TrangThaiDuyet != "Đã duyệt")
            return Conflict(new { message = "Đề tài không còn khả dụng hoặc chưa được duyệt." });
        if (await _db.DangKyDeTais.AnyAsync(x => x.DeTaiId == topic.DeTaiId &&
            (x.TrangThai == "Chờ duyệt" || x.TrangThai == "Đã duyệt")))
            return Conflict(new { message = "Đề tài đã có nhóm đăng ký." });

        var registration = new DangKyDeTai { NhomId = group.NhomId, DeTaiId = topic.DeTaiId, TrangThai = "Chờ duyệt" };
        topic.TrangThai = "Đã đăng ký";
        _db.DangKyDeTais.Add(registration);
        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return CreatedAtAction(nameof(GetById), new { id = topic.DeTaiId }, new
        {
            registration.DangKyDeTaiId,
            registration.NhomId,
            registration.DeTaiId,
            registration.TrangThai,
            registration.NgayDangKy
        });
    }

    private static System.Linq.Expressions.Expression<Func<DeTaiDoAn, ProjectResponse>> ToResponseExpression() => x => new ProjectResponse
    {
        DeTaiId = x.DeTaiId,
        DotDangKyId = x.DotDangKyId,
        TenDeTai = x.TenDeTai,
        MoTa = x.MoTa,
        MucTieu = x.MucTieu,
        PhamVi = x.PhamVi,
        CongNgheDuKien = x.CongNgheDuKien,
        NguonDeTai = x.NguonDeTai ?? "",
        TrangThai = x.TrangThai ?? "",
        TrangThaiDuyet = x.TrangThaiDuyet ?? "",
        GiangVienId = x.GiangVienId,
        GiangVienTen = x.GiangVien != null && x.GiangVien.NguoiDung != null ? x.GiangVien.NguoiDung.HoTen : ""
    };

    [HttpGet("registrations")]
    [Authorize(Policy = "LecturerOnly")]
    public async Task<IActionResult> GetTopicRegistrations()
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var giangVienId = await _db.GiangViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.GiangVienId).FirstOrDefaultAsync();
        if (giangVienId == null) return Forbid();

        var registrations = await _db.DangKyDeTais.AsNoTracking()
            .Include(r => r.DeTai)
            .Include(r => r.Nhom).ThenInclude(n => n!.TruongNhom).ThenInclude(s => s!.NguoiDung)
            .Include(r => r.Nhom).ThenInclude(n => n!.DotDangKy).ThenInclude(d => d!.LopHocPhan)
            .Where(r => r.DeTai!.GiangVienId == giangVienId)
            .Select(r => new
            {
                r.DangKyDeTaiId,
                r.NhomId,
                NhomTen = r.Nhom != null ? r.Nhom.TenNhom : "",
                TruongNhomTen = r.Nhom != null && r.Nhom.TruongNhom != null && r.Nhom.TruongNhom.NguoiDung != null ? r.Nhom.TruongNhom.NguoiDung.HoTen : "",
                LopHocPhanTen = r.Nhom != null && r.Nhom.DotDangKy != null && r.Nhom.DotDangKy.LopHocPhan != null ? r.Nhom.DotDangKy.LopHocPhan.TenLopHocPhan : "",
                r.DeTaiId,
                DeTaiTen = r.DeTai != null ? r.DeTai.TenDeTai : "",
                r.NgayDangKy,
                r.TrangThai,
                r.GhiChu
            })
            .ToListAsync();

        return Ok(registrations);
    }

    [HttpPut("registrations/{id:int}/decide")]
    [Authorize(Policy = "LecturerOnly")]
    public async Task<IActionResult> DecideRegistration(int id, [FromBody] DecideRegistrationRequest req)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId)) return Unauthorized();
        var giangVienId = await _db.GiangViens.Where(x => x.NguoiDungId == userId).Select(x => (int?)x.GiangVienId).FirstOrDefaultAsync();
        if (giangVienId == null) return Forbid();

        var reg = await _db.DangKyDeTais.Include(r => r.DeTai).FirstOrDefaultAsync(r => r.DangKyDeTaiId == id);
        if (reg == null) return NotFound(new { message = "Đơn đăng ký không tồn tại" });
        if (reg.DeTai == null || reg.DeTai.GiangVienId != giangVienId) return Forbid();

        reg.TrangThai = req.DongY ? "Đã duyệt" : "Từ chối";
        reg.NgayDuyet = DateTime.Now;
        reg.GiangVienDuyetId = giangVienId;
        reg.GhiChu = req.GhiChu;

        if (!req.DongY)
        {
            reg.DeTai.TrangThai = "Chưa sử dụng";
        }

        await _db.SaveChangesAsync();
        return Ok(new { message = req.DongY ? "Đã duyệt đăng ký đề tài" : "Đã từ chối đăng ký đề tài" });
    }
}

public class DecideRegistrationRequest
{
    public bool DongY { get; set; }
    public string? GhiChu { get; set; }
}

public class CreateProjectRequest
{
    public int DotDangKyId { get; set; }
    public string TenDeTai { get; set; } = string.Empty;
    public string? MoTa { get; set; }
    public string? MucTieu { get; set; }
    public string? PhamVi { get; set; }
    public string? CongNgheDuKien { get; set; }
}

public class UpdateProjectRequest
{
    public string TenDeTai { get; set; } = string.Empty;
    public string? MoTa { get; set; }
    public string? MucTieu { get; set; }
    public string? PhamVi { get; set; }
    public string? CongNgheDuKien { get; set; }
    public string? TrangThai { get; set; }
}
