using System.Data;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Topics;
using ProGroup_AI.API.DTOs.Projects;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/de-tai")]
[Authorize]
public sealed class DeTaiController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public DeTaiController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<TopicResponse>>> GetAll(
        [FromQuery] int? dotDangKyId,
        [FromQuery] int? lopHocPhanId,
        [FromQuery] string? trangThaiDuyet,
        [FromQuery] string? nguonDeTai)
    {
        var query = _db.DeTaiDoAns.AsNoTracking().AsQueryable();

        if (dotDangKyId.HasValue)
        {
            query = query.Where(t => t.DotDangKyId == dotDangKyId.Value);
        }

        if (lopHocPhanId.HasValue)
        {
            query = query.Where(t => t.DotDangKy != null && t.DotDangKy.LopHocPhanId == lopHocPhanId.Value);
        }

        if (!string.IsNullOrWhiteSpace(trangThaiDuyet))
        {
            query = query.Where(t => t.TrangThaiDuyet == trangThaiDuyet.Trim());
        }

        if (!string.IsNullOrWhiteSpace(nguonDeTai))
        {
            query = query.Where(t => t.NguonDeTai == nguonDeTai.Trim());
        }

        var results = await query
            .OrderByDescending(t => t.CreatedAt)
            .Select(ToTopicResponse())
            .ToListAsync();

        return Ok(results);
    }

    [HttpGet("cua-toi")]
    [HttpGet("lecturer-topics")]
    public async Task<ActionResult<IReadOnlyList<TopicResponse>>> GetLecturerTopics([FromQuery] int? dotDangKyId)
    {
        var lecturerId = await GetCurrentLecturerIdAsync();
        if (lecturerId is null)
        {
            if (User.IsInRole("ADMIN"))
            {
                var adminQuery = _db.DeTaiDoAns.AsNoTracking().AsQueryable();
                if (dotDangKyId.HasValue)
                    adminQuery = adminQuery.Where(t => t.DotDangKyId == dotDangKyId.Value);
                var adminList = await adminQuery.OrderByDescending(t => t.CreatedAt).Select(ToTopicResponse()).ToListAsync();
                return Ok(adminList);
            }
            return Forbid();
        }

        var query = _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.GiangVienId == lecturerId.Value);

        if (dotDangKyId.HasValue)
        {
            query = query.Where(t => t.DotDangKyId == dotDangKyId.Value);
        }

        var list = await query
            .OrderByDescending(t => t.CreatedAt)
            .Select(ToTopicResponse())
            .ToListAsync();

        return Ok(list);
    }

    [HttpGet("de-xuat-cua-toi")]
    public async Task<ActionResult<IReadOnlyList<TopicResponse>>> GetStudentProposedTopics()
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null) return Forbid();

        var list = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.SinhVienDeXuatId == studentId.Value)
            .OrderByDescending(t => t.CreatedAt)
            .Select(ToTopicResponse())
            .ToListAsync();

        return Ok(list);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TopicResponse>> GetById(int id)
    {
        var topic = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.DeTaiId == id)
            .Select(ToTopicResponse())
            .FirstOrDefaultAsync();

        return topic is null ? NotFound(new { message = "Không tìm thấy đề tài." }) : Ok(topic);
    }

    [HttpPost]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<ActionResult<TopicResponse>> Create([FromBody] CreateTopicRequest request)
    {
        var period = await _db.DotDangKyDoAns.FindAsync(request.DotDangKyId);
        if (period is null)
        {
            return BadRequest(new { message = "Đợt đăng ký không tồn tại." });
        }

        int? lecturerId = await GetCurrentLecturerIdAsync();

        var topic = new DeTaiDoAn
        {
            DotDangKyId = request.DotDangKyId,
            TenDeTai = request.TenDeTai.Trim(),
            MoTa = request.MoTa?.Trim(),
            MucTieu = request.MucTieu?.Trim(),
            PhamVi = request.PhamVi?.Trim(),
            CongNgheDuKien = request.CongNgheDuKien?.Trim(),
            NguonDeTai = "Giảng viên",
            GiangVienId = lecturerId,
            TrangThai = "Chưa sử dụng",
            TrangThaiDuyet = "Đã duyệt",
            CreatedAt = DateTime.Now
        };

        _db.DeTaiDoAns.Add(topic);
        await _db.SaveChangesAsync();

        var created = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.DeTaiId == topic.DeTaiId)
            .Select(ToTopicResponse())
            .FirstAsync();

        return CreatedAtAction(nameof(GetById), new { id = topic.DeTaiId }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateTopicRequest request)
    {
        var topic = await _db.DeTaiDoAns.FindAsync(id);
        if (topic is null) return NotFound(new { message = "Không tìm thấy đề tài." });

        var lecturerId = await GetCurrentLecturerIdAsync();
        if (!User.IsInRole("ADMIN") && topic.GiangVienId != lecturerId)
        {
            return Forbid();
        }

        if (request.DotDangKyId.HasValue && request.DotDangKyId.Value != topic.DotDangKyId)
        {
            var periodExists = await _db.DotDangKyDoAns.AnyAsync(d => d.DotDangKyId == request.DotDangKyId.Value);
            if (!periodExists)
                return BadRequest(new { message = "Đợt đăng ký mới không tồn tại." });
            topic.DotDangKyId = request.DotDangKyId.Value;
        }

        topic.TenDeTai = request.TenDeTai.Trim();
        topic.MoTa = request.MoTa?.Trim();
        topic.MucTieu = request.MucTieu?.Trim();
        topic.PhamVi = request.PhamVi?.Trim();
        topic.CongNgheDuKien = request.CongNgheDuKien?.Trim();
        topic.UpdatedAt = DateTime.Now;


        await _db.SaveChangesAsync();

        var updated = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.DeTaiId == id)
            .Select(ToTopicResponse())
            .FirstAsync();

        return Ok(updated);
    }

    [HttpPost("de-xuat")]
    [Authorize(Policy = "StudentOnly")]
    public async Task<ActionResult<TopicResponse>> Propose([FromBody] ProposeTopicRequest request)
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Tài khoản chưa có hồ sơ sinh viên." });
        }

        var period = await _db.DotDangKyDoAns.FindAsync(request.DotDangKyId);
        if (period is null)
        {
            return BadRequest(new { message = "Đợt đăng ký không tồn tại." });
        }

        var topic = new DeTaiDoAn
        {
            DotDangKyId = request.DotDangKyId,
            TenDeTai = request.TenDeTai.Trim(),
            MoTa = request.MoTa?.Trim(),
            MucTieu = request.MucTieu?.Trim(),
            PhamVi = request.PhamVi?.Trim(),
            CongNgheDuKien = request.CongNgheDuKien?.Trim(),
            NguonDeTai = "Sinh viên đề xuất",
            SinhVienDeXuatId = studentId,
            TrangThai = "Chưa sử dụng",
            TrangThaiDuyet = "Chờ duyệt",
            CreatedAt = DateTime.Now
        };

        _db.DeTaiDoAns.Add(topic);
        await _db.SaveChangesAsync();

        var created = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.DeTaiId == topic.DeTaiId)
            .Select(ToTopicResponse())
            .FirstAsync();

        return CreatedAtAction(nameof(GetById), new { id = topic.DeTaiId }, created);
    }

    [HttpPut("{id:int}/duyet")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> Approve(int id, [FromBody] ApproveTopicRequest request)
    {
        var topic = await _db.DeTaiDoAns.FindAsync(id);
        if (topic is null) return NotFound(new { message = "Không tìm thấy đề tài." });

        if (request.IsApproved)
        {
            topic.TrangThaiDuyet = "Đã duyệt";
            topic.LyDoTuChoi = null;
        }
        else
        {
            topic.TrangThaiDuyet = "Từ chối";
            topic.LyDoTuChoi = request.LyDoTuChoi?.Trim();
        }

        topic.UpdatedAt = DateTime.Now;

        // Tạo thông báo cho sinh viên nếu đây là đề tài do sinh viên đề xuất
        if (topic.SinhVienDeXuatId.HasValue)
        {
            var sv = await _db.SinhViens.FirstOrDefaultAsync(s => s.SinhVienId == topic.SinhVienDeXuatId.Value);
            if (sv != null && sv.NguoiDungId > 0)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = sv.NguoiDungId,
                    TieuDe = request.IsApproved ? "Đề xuất đề tài được duyệt" : "Đề xuất đề tài bị từ chối",
                    NoiDung = request.IsApproved
                        ? $"Đề xuất đề tài '{topic.TenDeTai}' của bạn đã được giảng viên phê duyệt."
                        : $"Đề xuất đề tài '{topic.TenDeTai}' bị từ chối. Lý do: {request.LyDoTuChoi ?? "Không có"}",
                    LoaiThongBao = "Đề tài",
                    DaDoc = false,
                    CreatedAt = DateTime.UtcNow,
                    LienKetId = topic.DeTaiId,
                    LoaiLienKet = "de-tai"
                });
            }
        }

        await _db.SaveChangesAsync();

        var updated = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.DeTaiId == id)
            .Select(ToTopicResponse())
            .FirstAsync();

        return Ok(updated);
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> Delete(int id)
    {
        var topic = await _db.DeTaiDoAns
            .Include(t => t.DangKyDeTais)
            .FirstOrDefaultAsync(t => t.DeTaiId == id);

        if (topic is null) return NotFound(new { message = "Không tìm thấy đề tài." });

        var lecturerId = await GetCurrentLecturerIdAsync();
        if (!User.IsInRole("ADMIN") && topic.GiangVienId != lecturerId)
        {
            return Forbid();
        }

        if (topic.DangKyDeTais.Any(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt"))
        {
            return BadRequest(new { message = "Không thể xóa đề tài đã có nhóm đăng ký hoặc được duyệt." });
        }

        _db.DeTaiDoAns.Remove(topic);
        await _db.SaveChangesAsync();

        return Ok(new { success = true, message = "Đã xóa đề tài." });
    }

    // Compatibility endpoint for ProjectsController / Flutter TopicService: POST /api/de-tai/dang-ky
    [Authorize(Policy = "StudentOnly")]
    [HttpPost("dang-ky")]
    public async Task<IActionResult> RegisterProject([FromBody] RegisterProjectRequest request)
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Tài khoản chưa có hồ sơ sinh viên." });
        }

        await using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        var group = await _db.NhomDoAns
            .Include(x => x.DotDangKy)
            .Include(x => x.ThanhVienNhoms)
            .FirstOrDefaultAsync(x => x.NhomId == request.NhomId && x.TruongNhomId == studentId.Value && x.TrangThai == "Đang hoạt động");

        if (group is null) return Conflict(new { message = "Không tìm thấy nhóm hoạt động do bạn làm trưởng nhóm." });

        var period = group.DotDangKy;
        if (period is null || period.TrangThai != "Đang mở" || DateTime.Now < period.NgayBatDau || DateTime.Now > period.NgayKetThuc)
            return Conflict(new { message = "Đợt đăng ký đồ án hiện không mở." });

        var activeMembers = group.ThanhVienNhoms.Count(x => x.TrangThai == "Đã tham gia");
        if (!group.ThanhVienNhoms.Any(x => x.SinhVienId == group.TruongNhomId && x.TrangThai == "Đã tham gia"))
            activeMembers++;

        if (activeMembers < period.MinMembers)
            return Conflict(new { message = "Nhóm chưa đủ số thành viên tối thiểu." });

        var hasRegistration = await _db.DangKyDeTais.AnyAsync(x => x.NhomId == group.NhomId &&
            (x.TrangThai == "Chờ duyệt" || x.TrangThai == "Đã duyệt"));
        if (hasRegistration)
            return Conflict(new { message = "Nhóm đã có đăng ký đề tài đang chờ hoặc đã duyệt." });

        var topic = await _db.DeTaiDoAns.FirstOrDefaultAsync(x => x.DeTaiId == request.DeTaiId && x.DotDangKyId == period.DotDangKyId);
        if (topic is null) return NotFound(new { message = "Đề tài không tồn tại trong đợt đăng ký của nhóm." });
        if (topic.TrangThai != "Chưa sử dụng" || topic.TrangThaiDuyet != "Đã duyệt")
            return Conflict(new { message = "Đề tài không khả dụng hoặc chưa được duyệt." });

        var registration = new DangKyDeTai
        {
            NhomId = group.NhomId,
            DeTaiId = topic.DeTaiId,
            TrangThai = "Chờ duyệt",
            NgayDangKy = DateTime.Now
        };

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
