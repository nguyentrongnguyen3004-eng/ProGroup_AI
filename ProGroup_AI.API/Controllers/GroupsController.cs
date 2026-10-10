using System.Data;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Groups;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/groups")]
[Authorize]
public sealed class GroupsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public GroupsController(ApplicationDbContext db) => _db = db;

    [Authorize(Policy = "StudentOnly")]
    [HttpGet("mine")]
    public async Task<IActionResult> Mine()
    {
        var studentAccess = await ResolveCurrentStudent();
        if (studentAccess.Error is not null) return studentAccess.Error;
        var studentId = studentAccess.StudentId!.Value;
        var ids = await _db.NhomDoAns.AsNoTracking()
            .Where(g => g.TruongNhomId == studentId || g.ThanhVienNhoms.Any(m => m.SinhVienId == studentId && m.TrangThai == "Đã tham gia"))
            .Select(g => g.NhomId).ToListAsync();
        var groups = await _db.NhomDoAns.AsNoTracking().Where(g => ids.Contains(g.NhomId))
            .Include(g => g.DotDangKy).ThenInclude(d => d!.LopHocPhan)
            .Include(g => g.TruongNhom).ThenInclude(s => s!.NguoiDung)
            .Include(g => g.ThanhVienNhoms).ThenInclude(m => m.SinhVien).ThenInclude(s => s!.NguoiDung)
            .ToListAsync();
        return Ok(groups.Select(ToResponse));
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var group = await LoadGroup(id);
        if (group is null) return NotFound();
        var isAdmin = User.IsInRole("ADMIN");
        var isLecturer = User.IsInRole("GIANGVIEN");
        var isOfficeStaff = User.IsInRole("PHONGDAOTAO") || User.IsInRole("GIAOVUKHOA");
        var staffCanView = isAdmin;

        if (isLecturer && group.DotDangKy is not null &&
            int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
        {
            staffCanView = await _db.PhanCongGiangViens.AsNoTracking().AnyAsync(x =>
                x.LopHocPhanId == group.DotDangKy.LopHocPhanId && x.TrangThai &&
                x.GiangVien != null && x.GiangVien.NguoiDungId == userId);
        }

        // The current schema has no faculty/office scope mapping for these roles.
        if (isOfficeStaff && !isAdmin) return Forbid();

        int? studentId = null;
        if (!staffCanView && !isLecturer)
        {
            var studentAccess = await ResolveCurrentStudent();
            if (studentAccess.Error is not null) return studentAccess.Error;
            studentId = studentAccess.StudentId;
        }
        if (!staffCanView && !isLecturer &&
            group.TruongNhomId != studentId &&
            !group.ThanhVienNhoms.Any(m => m.SinhVienId == studentId && m.TrangThai == "Đã tham gia")) return Forbid();
        if (isLecturer && !staffCanView) return Forbid();
        return Ok(ToResponse(group));
    }

    [Authorize(Policy = "StudentOnly")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateGroupRequest request)
    {
        var studentAccess = await ResolveCurrentStudent();
        if (studentAccess.Error is not null) return studentAccess.Error;
        var studentId = studentAccess.StudentId!.Value;
        var groupName = request.TenNhom.Trim();
        if (groupName.Length == 0) return BadRequest(new { message = "Tên nhóm không được để trống." });
        await using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        var period = await _db.DotDangKyDoAns.Include(x => x.LopHocPhan).FirstOrDefaultAsync(x => x.DotDangKyId == request.DotDangKyId);
        if (period is null) return NotFound(new { message = "Đợt đăng ký không tồn tại." });
        if (!IsOpen(period)) return Conflict(new { message = "Đợt đăng ký đồ án hiện không mở." });
        if (!await IsEnrolled(studentId, period.LopHocPhanId)) return Conflict(new { message = "Sinh viên chưa thuộc lớp học phần của đợt này." });
        if (await HasGroupInPeriod(studentId, period.DotDangKyId)) return Conflict(new { message = "Sinh viên đã thuộc một nhóm trong đợt này." });
        if (await _db.NhomDoAns.AnyAsync(x => x.DotDangKyId == period.DotDangKyId && x.TenNhom == groupName))
            return Conflict(new { message = "Tên nhóm đã được sử dụng trong đợt này." });

        var group = new NhomDoAn { DotDangKyId = period.DotDangKyId, TenNhom = groupName, TruongNhomId = studentId };
        group.ThanhVienNhoms.Add(new ThanhVienNhom { SinhVienId = studentId, VaiTro = "Trưởng nhóm", TrangThai = "Đã tham gia" });
        _db.NhomDoAns.Add(group);
        await _db.SaveChangesAsync();
        await transaction.CommitAsync();
        return CreatedAtAction(nameof(GetById), new { id = group.NhomId }, new { group.NhomId, group.TenNhom });
    }

    [Authorize(Policy = "StudentOnly")]
    [HttpPost("{id:int}/members")]
    public async Task<IActionResult> AddMember(int id, [FromBody] AddGroupMemberRequest request)
    {
        var studentAccess = await ResolveCurrentStudent();
        if (studentAccess.Error is not null) return studentAccess.Error;
        var leaderId = studentAccess.StudentId!.Value;
        await using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        var group = await _db.NhomDoAns.Include(x => x.DotDangKy).FirstOrDefaultAsync(x => x.NhomId == id);
        if (group is null) return NotFound();
        if (group.TruongNhomId != leaderId) return Forbid();
        if (group.TrangThai != "Đang hoạt động" || group.DotDangKy is null || !IsOpen(group.DotDangKy)) return Conflict(new { message = "Nhóm hoặc đợt đăng ký không còn mở." });
        if (request.SinhVienId == leaderId) return Conflict(new { message = "Sinh viên đã là trưởng nhóm." });
        var student = await _db.SinhViens.FirstOrDefaultAsync(x => x.SinhVienId == request.SinhVienId);
        if (student is null) return NotFound(new { message = "Không tìm thấy sinh viên." });
        if (!await IsEnrolled(student.SinhVienId, group.DotDangKy.LopHocPhanId)) return Conflict(new { message = "Sinh viên chưa thuộc lớp học phần của đợt này." });
        if (await HasGroupInPeriod(student.SinhVienId, group.DotDangKyId)) return Conflict(new { message = "Sinh viên đã thuộc một nhóm trong đợt này." });
        var activeStudentIds = await _db.ThanhVienNhoms
            .Where(x => x.NhomId == id && x.TrangThai == "Đã tham gia")
            .Select(x => x.SinhVienId)
            .ToListAsync();
        var memberCount = activeStudentIds.Count;
        if (!activeStudentIds.Contains(group.TruongNhomId)) memberCount++;
        if (memberCount >= group.DotDangKy.MaxMembers) return Conflict(new { message = "Nhóm đã đủ số lượng thành viên tối đa." });

        var former = await _db.ThanhVienNhoms.FirstOrDefaultAsync(x => x.NhomId == id && x.SinhVienId == student.SinhVienId);
        if (former is null) _db.ThanhVienNhoms.Add(new ThanhVienNhom { NhomId = id, SinhVienId = student.SinhVienId, VaiTro = "Thành viên", TrangThai = "Đã tham gia" });
        else { former.TrangThai = "Đã tham gia"; former.NgayThamGia = DateTime.Now; }
        await _db.SaveChangesAsync();
        await transaction.CommitAsync();
        return NoContent();
    }

    [Authorize(Policy = "StudentOnly")]
    [HttpDelete("{id:int}/members/{studentId:int}")]
    public async Task<IActionResult> RemoveMember(int id, int studentId)
    {
        var studentAccess = await ResolveCurrentStudent();
        if (studentAccess.Error is not null) return studentAccess.Error;
        var leaderId = studentAccess.StudentId!.Value;
        var group = await _db.NhomDoAns.FirstOrDefaultAsync(x => x.NhomId == id);
        if (group is null) return NotFound();
        if (group.TruongNhomId != leaderId) return Forbid();
        if (studentId == group.TruongNhomId) return Conflict(new { message = "Không thể xóa trưởng nhóm; hãy chuyển quyền trưởng nhóm trước." });
        var member = await _db.ThanhVienNhoms.FirstOrDefaultAsync(x => x.NhomId == id && x.SinhVienId == studentId && x.TrangThai == "Đã tham gia");
        if (member is null) return NotFound(new { message = "Thành viên không tồn tại trong nhóm." });
        member.TrangThai = "Đã rời nhóm";
        await _db.SaveChangesAsync();
        return NoContent();
    }

    private async Task<NhomDoAn?> LoadGroup(int id) => await _db.NhomDoAns.AsNoTracking()
        .Include(g => g.DotDangKy).ThenInclude(d => d!.LopHocPhan)
        .Include(g => g.TruongNhom).ThenInclude(s => s!.NguoiDung)
        .Include(g => g.ThanhVienNhoms).ThenInclude(m => m.SinhVien).ThenInclude(s => s!.NguoiDung)
        .FirstOrDefaultAsync(g => g.NhomId == id);

    private GroupResponse ToResponse(NhomDoAn g)
    {
        var members = g.ThanhVienNhoms.Where(m => m.TrangThai == "Đã tham gia").Select(m => new GroupMemberResponse
        {
            SinhVienId = m.SinhVienId, MSSV = m.SinhVien?.MSSV ?? string.Empty,
            HoTen = m.SinhVien?.NguoiDung?.HoTen ?? string.Empty, VaiTro = m.VaiTro, TrangThai = m.TrangThai
        }).ToList();
        if (!members.Any(m => m.SinhVienId == g.TruongNhomId)) members.Insert(0, new GroupMemberResponse
        {
            SinhVienId = g.TruongNhomId, MSSV = g.TruongNhom?.MSSV ?? string.Empty,
            HoTen = g.TruongNhom?.NguoiDung?.HoTen ?? string.Empty, VaiTro = "Trưởng nhóm", TrangThai = "Đã tham gia"
        });
        return new GroupResponse
        {
            NhomId = g.NhomId, DotDangKyId = g.DotDangKyId, LopHocPhanId = g.DotDangKy?.LopHocPhanId ?? 0,
            TenNhom = g.TenNhom, TrangThai = g.TrangThai, TruongNhomId = g.TruongNhomId,
            TruongNhom = g.TruongNhom?.NguoiDung?.HoTen ?? string.Empty,
            MinMembers = g.DotDangKy?.MinMembers ?? 0, MaxMembers = g.DotDangKy?.MaxMembers ?? 0, ThanhViens = members
        };
    }

    private async Task<(int? StudentId, IActionResult? Error)> ResolveCurrentStudent()
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
            return (null, Unauthorized(new ProblemDetails
            {
                Status = StatusCodes.Status401Unauthorized,
                Title = "JWT thiếu claim định danh người dùng hợp lệ."
            }));

        var studentId = await _db.SinhViens
            .Where(x => x.NguoiDungId == userId)
            .Select(x => (int?)x.SinhVienId)
            .FirstOrDefaultAsync();
        if (studentId is null)
        {
            var problem = new ProblemDetails
            {
                Status = StatusCodes.Status403Forbidden,
                Title = "Tài khoản chưa có hồ sơ sinh viên.",
                Detail = "Liên hệ quản trị viên để liên kết tài khoản với hồ sơ sinh viên."
            };
            problem.Extensions["code"] = "student_profile_missing";
            return (null, StatusCode(StatusCodes.Status403Forbidden, problem));
        }

        return (studentId, null);
    }

    private Task<bool> IsEnrolled(int studentId, int classId) => _db.SinhVienLopHocPhans.AnyAsync(x => x.SinhVienId == studentId && x.LopHocPhanId == classId && x.TrangThai);

    private Task<bool> HasGroupInPeriod(int studentId, int periodId) => _db.NhomDoAns.AnyAsync(g => g.DotDangKyId == periodId && g.TrangThai != "Đã hủy" &&
        (g.TruongNhomId == studentId || g.ThanhVienNhoms.Any(m => m.SinhVienId == studentId && m.TrangThai == "Đã tham gia")));

    private static bool IsOpen(DotDangKyDoAn period) => period.TrangThai == "Đang mở" && DateTime.Now >= period.NgayBatDau && DateTime.Now <= period.NgayKetThuc;
}
