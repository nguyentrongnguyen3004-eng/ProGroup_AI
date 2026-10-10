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
[Route("api/de-tai")]
[Authorize]
public sealed class ProjectsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public ProjectsController(ApplicationDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<ProjectResponse>>> GetAll([FromQuery] int? dotDangKyId)
    {
        var query = _db.DeTaiDoAns.AsNoTracking()
            .Where(x => x.TrangThai == "Chưa sử dụng" && x.TrangThaiDuyet == "Đã duyệt");
        if (dotDangKyId.HasValue) query = query.Where(x => x.DotDangKyId == dotDangKyId.Value);
        var rows = await query.OrderBy(x => x.TenDeTai).Select(ToResponseExpression()).ToListAsync();
        return Ok(rows);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ProjectResponse>> GetById(int id)
    {
        var row = await _db.DeTaiDoAns.AsNoTracking().Where(x => x.DeTaiId == id)
            .Select(ToResponseExpression()).FirstOrDefaultAsync();
        return row is null ? NotFound() : Ok(row);
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

        // Serialize checks and changes so two groups cannot claim the same topic simultaneously.
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
        NguonDeTai = x.NguonDeTai,
        TrangThai = x.TrangThai,
        TrangThaiDuyet = x.TrangThaiDuyet
    };
}
