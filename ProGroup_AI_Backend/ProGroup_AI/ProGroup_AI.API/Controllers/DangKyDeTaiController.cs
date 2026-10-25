using System.Data;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.DangKyDeTai;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/dang-ky-de-tai")]
[Authorize]
public sealed class DangKyDeTaiController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public DangKyDeTaiController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    [HttpGet("/api/de-tai/registrations")]
    public async Task<ActionResult<IReadOnlyList<DangKyDeTaiResponse>>> GetAll(
        [FromQuery] int? dotDangKyId,
        [FromQuery] string? trangThai)
    {
        var query = _db.DangKyDeTais.AsNoTracking().AsQueryable();

        if (dotDangKyId.HasValue)
        {
            query = query.Where(r => r.DeTai != null && r.DeTai.DotDangKyId == dotDangKyId.Value);
        }

        if (!string.IsNullOrWhiteSpace(trangThai))
        {
            query = query.Where(r => r.TrangThai == trangThai.Trim());
        }

        // Nếu là giảng viên thông thường (không phải admin/giáo vụ), chỉ xem các đăng ký thuộc lớp giảng viên phụ trách hoặc đề tài do mình tạo
        if (User.IsInRole("GIANGVIEN") && !User.IsInRole("ADMIN") && !User.IsInRole("GIAOVUKHOA"))
        {
            var lecturerId = await GetCurrentLecturerIdAsync();
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
        }

        var results = await query
            .OrderByDescending(r => r.NgayDangKy)
            .Select(ToResponse())
            .ToListAsync();

        return Ok(results);
    }

    [HttpGet("cua-nhom/{nhomId:int}")]
    public async Task<ActionResult<IReadOnlyList<DangKyDeTaiResponse>>> GetByGroup(int nhomId)
    {
        var results = await _db.DangKyDeTais.AsNoTracking()
            .Where(r => r.NhomId == nhomId)
            .OrderByDescending(r => r.NgayDangKy)
            .Select(ToResponse())
            .ToListAsync();

        return Ok(results);
    }

    [HttpPost]
    [Authorize(Policy = "StudentOnly")]
    public async Task<IActionResult> RegisterTopic([FromBody] CreateDangKyDeTaiRequest request)
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Tài khoản chưa có hồ sơ sinh viên." });
        }

        await using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);

        var group = await _db.NhomDoAns
            .Include(g => g.DotDangKy)
            .Include(g => g.ThanhVienNhoms)
            .FirstOrDefaultAsync(g => g.NhomId == request.NhomId && g.TruongNhomId == studentId.Value && g.TrangThai == "Đang hoạt động");

        if (group is null)
        {
            return Conflict(new { message = "Không tìm thấy nhóm hoạt động do bạn làm trưởng nhóm." });
        }

        var period = group.DotDangKy;
        if (period is null || period.TrangThai != "Đang mở" || DateTime.Now < period.NgayBatDau || DateTime.Now > period.NgayKetThuc)
        {
            return Conflict(new { message = "Đợt đăng ký đồ án hiện không mở tiếp nhận đăng ký." });
        }

        var activeMemberCount = group.ThanhVienNhoms.Count(m => m.TrangThai == "Đã tham gia");
        if (!group.ThanhVienNhoms.Any(m => m.SinhVienId == group.TruongNhomId && m.TrangThai == "Đã tham gia"))
        {
            activeMemberCount++;
        }

        if (activeMemberCount < period.MinMembers)
        {
            return Conflict(new { message = $"Nhóm chưa đủ số thành viên tối thiểu ({period.MinMembers} thành viên)." });
        }

        var hasActiveReg = await _db.DangKyDeTais.AnyAsync(r => r.NhomId == group.NhomId &&
            (r.TrangThai == "Chờ duyệt" || r.TrangThai == "Đã duyệt"));

        if (hasActiveReg)
        {
            return Conflict(new { message = "Nhóm đã có đề tài đang chờ duyệt hoặc đã duyệt thành công." });
        }

        var topic = await _db.DeTaiDoAns
            .FirstOrDefaultAsync(t => t.DeTaiId == request.DeTaiId && t.DotDangKyId == period.DotDangKyId);

        if (topic is null)
        {
            return NotFound(new { message = "Đề tài không tồn tại trong đợt đăng ký này." });
        }

        if (topic.TrangThai != "Chưa sử dụng" || topic.TrangThaiDuyet != "Đã duyệt")
        {
            return Conflict(new { message = "Đề tài hiện không khả dụng để đăng ký." });
        }

        var isAlreadyRegistered = await _db.DangKyDeTais.AnyAsync(r => r.DeTaiId == topic.DeTaiId &&
            (r.TrangThai == "Chờ duyệt" || r.TrangThai == "Đã duyệt"));

        if (isAlreadyRegistered)
        {
            return Conflict(new { message = "Đề tài này đã có nhóm khác đăng ký." });
        }

        var registration = new DangKyDeTai
        {
            NhomId = group.NhomId,
            DeTaiId = topic.DeTaiId,
            TrangThai = "Chờ duyệt",
            NgayDangKy = DateTime.Now
        };

        topic.TrangThai = "Đã đăng ký";
        _db.DangKyDeTais.Add(registration);

        // Gửi thông báo cho Giảng viên phụ trách đề tài
        if (topic.GiangVienId.HasValue)
        {
            var gv = await _db.GiangViens.FirstOrDefaultAsync(g => g.GiangVienId == topic.GiangVienId.Value);
            if (gv != null && gv.NguoiDungId > 0)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = gv.NguoiDungId,
                    TieuDe = "Nhóm đăng ký đề tài mới",
                    NoiDung = $"Nhóm '{group.TenNhom}' vừa đăng ký đề tài '{topic.TenDeTai}'. Vui lòng xem xét duyệt đề tài.",
                    LoaiThongBao = "Đề tài",
                    DaDoc = false,
                    CreatedAt = DateTime.UtcNow,
                    LienKetId = registration.DangKyDeTaiId,
                    LoaiLienKet = "dang-ky-de-tai"
                });
            }
        }

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        var created = await _db.DangKyDeTais.AsNoTracking()
            .Where(r => r.DangKyDeTaiId == registration.DangKyDeTaiId)
            .Select(ToResponse())
            .FirstAsync();

        return Ok(created);
    }

    [HttpPut("{id:int}/duyet")]
    [HttpPut("{id:int}/decide")]
    [HttpPut("/api/de-tai/registrations/{id:int}/decide")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> DecideRegistration(int id, [FromBody] ApproveDangKyDeTaiRequest request)
    {
        var registration = await _db.DangKyDeTais
            .Include(r => r.DeTai)
            .FirstOrDefaultAsync(r => r.DangKyDeTaiId == id);

        if (registration is null)
        {
            return NotFound(new { message = "Không tìm thấy thông tin đăng ký đề tài." });
        }

        int? lecturerId = await GetCurrentLecturerIdAsync();

        if (request.IsApproved)
        {
            registration.TrangThai = "Đã duyệt";
            registration.NgayDuyet = DateTime.Now;
            registration.GiangVienDuyetId = lecturerId;
            registration.GhiChu = request.ResolvedGhiChu?.Trim();

            if (registration.DeTai is not null)
            {
                registration.DeTai.TrangThai = "Đã đăng ký";
            }
        }
        else
        {
            registration.TrangThai = "Từ chối";
            registration.NgayDuyet = DateTime.Now;
            registration.GiangVienDuyetId = lecturerId;
            registration.GhiChu = request.ResolvedGhiChu?.Trim();

            if (registration.DeTai is not null)
            {
                registration.DeTai.TrangThai = "Chưa sử dụng";
            }
        }


        // Tạo thông báo cho toàn bộ thành viên nhóm
        try
        {
            var grp = await _db.NhomDoAns
                .Include(g => g.TruongNhom)
                .Include(g => g.ThanhVienNhoms).ThenInclude(m => m.SinhVien)
                .FirstOrDefaultAsync(g => g.NhomId == registration.NhomId);

            if (grp != null)
            {
                var userIds = new HashSet<int>();
                if (grp.TruongNhom?.NguoiDungId > 0)
                    userIds.Add(grp.TruongNhom.NguoiDungId);

                foreach (var m in grp.ThanhVienNhoms)
                {
                    if (m.SinhVien?.NguoiDungId > 0)
                        userIds.Add(m.SinhVien.NguoiDungId);
                }

                var tenDeTai = registration.DeTai?.TenDeTai ?? "đề tài";
                var tieuDe = request.IsApproved ? "Đăng ký đề tài được duyệt" : "Đăng ký đề tài bị từ chối";
                var noiDung = request.IsApproved
                    ? $"Giảng viên đã duyệt đăng ký đề tài '{tenDeTai}' cho nhóm '{grp.TenNhom}'."
                    : $"Giảng viên từ chối đăng ký đề tài '{tenDeTai}' của nhóm '{grp.TenNhom}'. Lý do: {request.ResolvedGhiChu ?? "Không có"}";

                foreach (var uid in userIds)
                {
                    _db.ThongBaos.Add(new ThongBao
                    {
                        NguoiDungId = uid,
                        TieuDe = tieuDe,
                        NoiDung = noiDung,
                        LoaiThongBao = "Đề tài",
                        DaDoc = false,
                        CreatedAt = DateTime.UtcNow,
                        LienKetId = registration.DangKyDeTaiId,
                        LoaiLienKet = "dang-ky-de-tai"
                    });
                }
            }
        }
        catch { }

        await _db.SaveChangesAsync();

        var updated = await _db.DangKyDeTais.AsNoTracking()
            .Where(r => r.DangKyDeTaiId == id)
            .Select(ToResponse())
            .FirstAsync();

        return Ok(updated);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> CancelRegistration(int id)
    {
        var registration = await _db.DangKyDeTais
            .Include(r => r.DeTai)
            .Include(r => r.Nhom)
            .FirstOrDefaultAsync(r => r.DangKyDeTaiId == id);

        if (registration is null)
        {
            return NotFound(new { message = "Không tìm thấy thông tin đăng ký." });
        }

        var studentId = await GetCurrentStudentIdAsync();
        var isLeader = studentId.HasValue && registration.Nhom?.TruongNhomId == studentId.Value;
        var isAdmin = User.IsInRole("ADMIN");

        if (!isLeader && !isAdmin)
        {
            return Forbid();
        }

        if (registration.TrangThai == "Đã duyệt" && !isAdmin)
        {
            return BadRequest(new { message = "Không thể hủy đăng ký đã được phê duyệt." });
        }

        if (registration.DeTai is not null)
        {
            registration.DeTai.TrangThai = "Chưa sử dụng";
        }

        _db.DangKyDeTais.Remove(registration);
        await _db.SaveChangesAsync();

        return Ok(new { success = true, message = "Đã hủy đăng ký đề tài." });
    }

    private int? GetCurrentUserId()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idClaim, out var id) ? id : null;
    }

    private async Task<int?> GetCurrentLecturerIdAsync()
    {
        var userId = GetCurrentUserId();
        if (userId is null) return null;
        return await _db.GiangViens
            .Where(g => g.NguoiDungId == userId.Value)
            .Select(g => (int?)g.GiangVienId)
            .FirstOrDefaultAsync();
    }

    private async Task<int?> GetCurrentStudentIdAsync()
    {
        var userId = GetCurrentUserId();
        if (userId is null) return null;
        return await _db.SinhViens
            .Where(s => s.NguoiDungId == userId.Value)
            .Select(s => (int?)s.SinhVienId)
            .FirstOrDefaultAsync();
    }

    private static System.Linq.Expressions.Expression<Func<DangKyDeTai, DangKyDeTaiResponse>> ToResponse() => r => new DangKyDeTaiResponse
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
    };
}
