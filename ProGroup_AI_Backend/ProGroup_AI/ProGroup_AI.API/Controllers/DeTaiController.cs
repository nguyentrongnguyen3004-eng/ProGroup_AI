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

        var results = (await query
            .Select(ToTopicResponse())
            .ToListAsync())
            .OrderByDescending(t => t.CreatedAt)
            .ToList();

        return Ok(results);
    }

    [HttpGet("cua-toi")]
    [HttpGet("lecturer-topics")]
    public async Task<ActionResult<IReadOnlyList<TopicResponse>>> GetLecturerTopics([FromQuery] int? dotDangKyId, [FromQuery] int? lopHocPhanId)
    {
        var lecturerId = await GetCurrentLecturerIdAsync();
        if (lecturerId is null)
        {
            if (User.IsInRole("ADMIN"))
            {
                var adminQuery = _db.DeTaiDoAns.AsNoTracking().AsQueryable();
                if (dotDangKyId.HasValue)
                    adminQuery = adminQuery.Where(t => t.DotDangKyId == dotDangKyId.Value);
                if (lopHocPhanId.HasValue)
                    adminQuery = adminQuery.Where(t => t.DotDangKy != null && t.DotDangKy.LopHocPhanId == lopHocPhanId.Value);
                var adminList = await adminQuery.OrderByDescending(t => t.CreatedAt).Select(ToTopicResponse()).ToListAsync();
                return Ok(adminList);
            }
            return Ok(Array.Empty<TopicResponse>());
        }

        var assignedClassIds = await _db.PhanCongGiangViens
            .Where(p => p.GiangVienId == lecturerId.Value && p.TrangThai)
            .Select(p => p.LopHocPhanId)
            .ToListAsync();

        var query = _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.GiangVienId == lecturerId.Value ||
                        (t.DotDangKy != null && assignedClassIds.Contains(t.DotDangKy.LopHocPhanId)));

        if (dotDangKyId.HasValue)
        {
            query = query.Where(t => t.DotDangKyId == dotDangKyId.Value);
        }

        if (lopHocPhanId.HasValue)
        {
            query = query.Where(t => t.DotDangKy != null && t.DotDangKy.LopHocPhanId == lopHocPhanId.Value);
        }

        var list = (await query
            .Select(ToTopicResponse())
            .ToListAsync())
            .OrderByDescending(t => t.CreatedAt)
            .ToList();

        return Ok(list);
    }

    [HttpGet("de-xuat-cua-toi")]
    public async Task<ActionResult<IReadOnlyList<TopicResponse>>> GetStudentProposedTopics()
    {
        var studentId = await GetCurrentStudentIdAsync();
        if (studentId is null) return Ok(Array.Empty<TopicResponse>());

        var list = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.SinhVienDeXuatId == studentId.Value)
            .OrderByDescending(t => t.CreatedAt)
            .Select(ToTopicResponse())
            .ToListAsync();

        return Ok(list);
    }

    [HttpGet("proposals")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<ActionResult<IReadOnlyList<TopicResponse>>> GetTopicProposals([FromQuery] int? courseId)
    {
        var lecturerId = await GetCurrentLecturerIdAsync();
        var query = _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.SinhVienDeXuatId != null || t.NguonDeTai == "SinhVienDeXuat" || t.NguonDeTai == "AIDeXuat");

        if (lecturerId.HasValue && !User.IsInRole("ADMIN"))
        {
            var assignedClassIds = await _db.PhanCongGiangViens
                .Where(p => p.GiangVienId == lecturerId.Value && p.TrangThai)
                .Select(p => p.LopHocPhanId)
                .ToListAsync();

            query = query.Where(t => t.GiangVienId == lecturerId.Value ||
                (t.DotDangKy != null && t.DotDangKy.LopHocPhan != null &&
                 assignedClassIds.Contains(t.DotDangKy.LopHocPhanId)));
        }

        if (courseId.HasValue && courseId.Value > 0)
        {
            query = query.Where(t => t.DotDangKy != null && t.DotDangKy.LopHocPhanId == courseId.Value);
        }

        var list = (await query
            .Select(ToTopicResponse())
            .ToListAsync())
            .OrderByDescending(t => t.CreatedAt)
            .ToList();

        await PopulateProposerGroupNamesAsync(list);

        return Ok(list);
    }

    private async Task PopulateProposerGroupNamesAsync(List<TopicResponse> list)
    {
        var proposerIds = list.Where(t => t.SinhVienDeXuatId.HasValue)
            .Select(t => t.SinhVienDeXuatId!.Value)
            .Distinct()
            .ToList();

        if (proposerIds.Count == 0) return;

        var dotIds = list.Select(t => t.DotDangKyId).Distinct().ToList();
        var studentGroups = await _db.NhomDoAns.AsNoTracking()
            .Where(g => dotIds.Contains(g.DotDangKyId) && g.TrangThai != "Đã hủy" &&
                        (proposerIds.Contains(g.TruongNhomId) ||
                         g.ThanhVienNhoms.Any(m => proposerIds.Contains(m.SinhVienId) && m.TrangThai == "Đã tham gia")))
            .Select(g => new
            {
                g.DotDangKyId,
                g.TenNhom,
                g.TruongNhomId,
                MemberIds = g.ThanhVienNhoms
                    .Where(m => m.TrangThai == "Đã tham gia")
                    .Select(m => m.SinhVienId)
                    .ToList()
            })
            .ToListAsync();

        foreach (var item in list)
        {
            if (!item.SinhVienDeXuatId.HasValue) continue;
            var svId = item.SinhVienDeXuatId.Value;
            var grp = studentGroups.FirstOrDefault(g =>
                g.DotDangKyId == item.DotDangKyId &&
                (g.TruongNhomId == svId || g.MemberIds.Contains(svId)));
            if (grp != null)
            {
                item.TenNhom = grp.TenNhom;
            }
        }
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
        DotDangKyDoAn? period = null;

        if (request.DotDangKyId.HasValue && request.DotDangKyId.Value > 0)
        {
            period = await _db.DotDangKyDoAns.FindAsync(request.DotDangKyId.Value);
        }

        if (request.LopHocPhanId.HasValue && request.LopHocPhanId.Value > 0)
        {
            if (period == null || period.LopHocPhanId != request.LopHocPhanId.Value)
            {
                period = await _db.DotDangKyDoAns
                    .Where(d => d.LopHocPhanId == request.LopHocPhanId.Value)
                    .OrderByDescending(d => d.TrangThai == "Đang mở")
                    .ThenByDescending(d => d.CreatedAt)
                    .FirstOrDefaultAsync();
            }
        }

        if (period == null && request.DotDangKyId.HasValue && request.DotDangKyId.Value > 0)
        {
            period = await _db.DotDangKyDoAns
                .Where(d => d.LopHocPhanId == request.DotDangKyId.Value)
                .OrderByDescending(d => d.TrangThai == "Đang mở")
                .ThenByDescending(d => d.CreatedAt)
                .FirstOrDefaultAsync();
        }

        // Tự động tạo hoặc tìm đợt đăng ký nếu học phần chưa có đợt đăng ký đồ án nào
        if (period is null)
        {
            var lhpId = (request.LopHocPhanId.HasValue && request.LopHocPhanId.Value > 0)
                ? request.LopHocPhanId.Value
                : (request.DotDangKyId.HasValue && request.DotDangKyId.Value > 0 ? request.DotDangKyId.Value : 0);

            var lhp = lhpId > 0 ? await _db.LopHocPhans.FindAsync(lhpId) : null;
            if (lhp != null)
            {
                period = new DotDangKyDoAn
                {
                    LopHocPhanId = lhp.LopHocPhanId,
                    TenDot = $"Đợt đăng ký {lhp.TenLopHocPhan}",
                    NgayBatDau = DateTime.Now.Date,
                    NgayKetThuc = DateTime.Now.Date.AddDays(30),
                    MinMembers = 2,
                    MaxMembers = 5,
                    TrangThai = "Đang mở",
                    CreatedAt = DateTime.Now
                };
                _db.DotDangKyDoAns.Add(period);
                await _db.SaveChangesAsync();
            }
            else
            {
                period = await _db.DotDangKyDoAns
                    .OrderByDescending(d => d.TrangThai == "Đang mở")
                    .ThenByDescending(d => d.CreatedAt)
                    .FirstOrDefaultAsync();

                if (period == null)
                {
                    var defaultLhp = await _db.LopHocPhans.FirstOrDefaultAsync();
                    if (defaultLhp == null)
                    {
                        defaultLhp = new LopHocPhan
                        {
                            MaLopHocPhan = "HP_DEFAULT",
                            TenLopHocPhan = "Học phần đồ án chung",
                            TrangThai = true,
                            CreatedAt = DateTime.Now
                        };
                        _db.LopHocPhans.Add(defaultLhp);
                        await _db.SaveChangesAsync();
                    }

                    period = new DotDangKyDoAn
                    {
                        LopHocPhanId = defaultLhp.LopHocPhanId,
                        TenDot = $"Đợt đăng ký {defaultLhp.TenLopHocPhan}",
                        NgayBatDau = DateTime.Now.Date,
                        NgayKetThuc = DateTime.Now.Date.AddDays(30),
                        MinMembers = 2,
                        MaxMembers = 5,
                        TrangThai = "Đang mở",
                        CreatedAt = DateTime.Now
                    };
                    _db.DotDangKyDoAns.Add(period);
                    await _db.SaveChangesAsync();
                }
            }
        }

        int? lecturerId = await GetCurrentLecturerIdAsync();

        string status = "Đang hoạt động";
        if (!string.IsNullOrWhiteSpace(request.TrangThai))
        {
            var st = request.TrangThai.Trim();
            if (st.Equals("Tạm khóa", StringComparison.OrdinalIgnoreCase) ||
                st.Equals("Đã khóa", StringComparison.OrdinalIgnoreCase))
            {
                status = "Tạm khóa";
            }
            else if (st.Equals("Chưa sử dụng", StringComparison.OrdinalIgnoreCase))
            {
                status = "Chưa sử dụng";
            }
            else if (st.Equals("Đang hoạt động", StringComparison.OrdinalIgnoreCase))
            {
                status = "Đang hoạt động";
            }
        }

        var topic = new DeTaiDoAn
        {
            DotDangKyId = period.DotDangKyId,
            TenDeTai = request.TenDeTai.Trim(),
            MoTa = request.MoTa?.Trim(),
            MucTieu = request.MucTieu?.Trim(),
            PhamVi = request.PhamVi?.Trim(),
            CongNgheDuKien = request.CongNgheDuKien?.Trim(),
            NguonDeTai = request.ResolvedNguonDeTai,
            GiangVienId = lecturerId,
            TrangThai = status,
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

        // TC_LEC_008: Cảnh báo/chặn sửa tên đề tài khi đã có nhóm được duyệt chính thức
        var hasApprovedGroup = topic.TrangThai == "Đã đăng ký" ||
            await _db.DangKyDeTais.AnyAsync(r => r.DeTaiId == id && r.TrangThai == "Đã duyệt");

        if (hasApprovedGroup && !string.Equals(topic.TenDeTai, request.TenDeTai.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            return BadRequest(new { message = "Đề tài đã có nhóm sinh viên đăng ký được duyệt chính thức. Không thể thay đổi tên đề tài." });
        }

        topic.TenDeTai = request.TenDeTai.Trim();
        topic.MoTa = request.MoTa?.Trim();
        topic.MucTieu = request.MucTieu?.Trim();
        topic.PhamVi = request.PhamVi?.Trim();
        topic.CongNgheDuKien = request.CongNgheDuKien?.Trim();

        // TC_LEC_005: Cho phép cập nhật trạng thái đề tài (Đang hoạt động / Tạm khóa / Chưa sử dụng)
        if (!string.IsNullOrWhiteSpace(request.TrangThai))
        {
            var st = request.TrangThai.Trim();
            if (st.Equals("Đang hoạt động", StringComparison.OrdinalIgnoreCase))
            {
                if (!hasApprovedGroup) topic.TrangThai = "Đang hoạt động";
            }
            else if (st.Equals("Tạm khóa", StringComparison.OrdinalIgnoreCase) ||
                     st.Equals("Đã khóa", StringComparison.OrdinalIgnoreCase))
            {
                if (!hasApprovedGroup) topic.TrangThai = "Tạm khóa";
            }
            else if (st.Equals("Chưa sử dụng", StringComparison.OrdinalIgnoreCase))
            {
                if (!hasApprovedGroup) topic.TrangThai = "Chưa sử dụng";
            }
            else if (st.Equals("Đã hủy", StringComparison.OrdinalIgnoreCase))
            {
                topic.TrangThai = "Đã hủy";
            }
            else if (st.Equals("Đã đăng ký", StringComparison.OrdinalIgnoreCase))
            {
                topic.TrangThai = "Đã đăng ký";
            }
        }

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

        DotDangKyDoAn? period = null;
        if (request.LopHocPhanId.HasValue && request.LopHocPhanId.Value > 0)
        {
            period = await _db.DotDangKyDoAns
                .OrderByDescending(d => d.TrangThai == "Đang mở")
                .ThenByDescending(d => d.DotDangKyId)
                .FirstOrDefaultAsync(d => d.LopHocPhanId == request.LopHocPhanId.Value);
        }
        if (period is null && request.DotDangKyId > 0)
        {
            period = await _db.DotDangKyDoAns.FindAsync(request.DotDangKyId);
            if (period is null)
            {
                period = await _db.DotDangKyDoAns
                    .OrderByDescending(d => d.TrangThai == "Đang mở")
                    .ThenByDescending(d => d.DotDangKyId)
                    .FirstOrDefaultAsync(d => d.LopHocPhanId == request.DotDangKyId);
            }
        }
        if (period is null && (!request.LopHocPhanId.HasValue || request.LopHocPhanId.Value <= 0) && request.DotDangKyId <= 0)
        {
            var enrolledClassIds = await _db.SinhVienLopHocPhans
                .Where(s => s.SinhVienId == studentId.Value && s.TrangThai)
                .Select(s => s.LopHocPhanId)
                .ToListAsync();

            period = await _db.DotDangKyDoAns
                .Where(d => enrolledClassIds.Contains(d.LopHocPhanId))
                .OrderByDescending(d => d.TrangThai == "Đang mở")
                .ThenByDescending(d => d.DotDangKyId)
                .FirstOrDefaultAsync();
        }
        if (period is null)
        {
            return BadRequest(new { message = "Không tìm thấy đợt đăng ký phù hợp cho lớp học phần đã chọn." });
        }

        var assignedLecturer = await _db.PhanCongGiangViens.AsNoTracking()
            .Where(p => p.LopHocPhanId == period.LopHocPhanId && p.TrangThai && p.GiangVien != null)
            .OrderByDescending(p => p.NgayPhanCong)
            .Select(p => new { p.GiangVienId, p.GiangVien!.NguoiDungId })
            .FirstOrDefaultAsync();

        var studentGroupIds = await _db.NhomDoAns
            .Where(g => g.DotDangKyId == period.DotDangKyId && g.TrangThai == "Đang hoạt động" &&
                        (g.TruongNhomId == studentId.Value ||
                         g.ThanhVienNhoms.Any(m => m.SinhVienId == studentId.Value && m.TrangThai == "Đã tham gia")))
            .Select(g => g.NhomId)
            .ToListAsync();

        if (studentGroupIds.Count > 0)
        {
            var groupHasActiveTopic = await _db.DangKyDeTais.AnyAsync(r =>
                studentGroupIds.Contains(r.NhomId) &&
                (r.TrangThai == "Chờ duyệt" || r.TrangThai == "Đã duyệt"));

            if (groupHasActiveTopic)
            {
                return BadRequest(new { message = "Nhóm của bạn đã có đề tài đang chờ duyệt hoặc đã được duyệt trong đợt này." });
            }
        }

        var hasActiveProposal = await _db.DeTaiDoAns.AnyAsync(t =>
            t.SinhVienDeXuatId == studentId.Value &&
            t.DotDangKyId == period.DotDangKyId &&
            (t.TrangThaiDuyet == "Chờ duyệt" || t.TrangThaiDuyet == "Đã duyệt"));

        if (hasActiveProposal)
        {
            return BadRequest(new { message = "Bạn đã có đề tài trong đợt này đang chờ duyệt hoặc đã được duyệt. Mỗi sinh viên chỉ gửi 1 đề tài trong một đợt." });
        }

        var topic = new DeTaiDoAn
        {
            DotDangKyId = period.DotDangKyId,
            TenDeTai = request.TenDeTai.Trim(),
            MoTa = request.MoTa?.Trim(),
            MucTieu = request.MucTieu?.Trim(),
            PhamVi = request.PhamVi?.Trim(),
            CongNgheDuKien = request.CongNgheDuKien?.Trim(),
            NguonDeTai = "Sinh viên đề xuất",
            GiangVienId = assignedLecturer?.GiangVienId,
            SinhVienDeXuatId = studentId,
            TrangThai = "Chưa sử dụng",
            TrangThaiDuyet = "Chờ duyệt",
            CreatedAt = DateTime.Now
        };

        _db.DeTaiDoAns.Add(topic);
        await _db.SaveChangesAsync();

        if (assignedLecturer != null)
        {
            _db.ThongBaos.Add(new ThongBao
            {
                NguoiDungId = assignedLecturer.NguoiDungId,
                TieuDe = "Đề xuất đề tài mới từ sinh viên",
                NoiDung = $"Sinh viên vừa đề xuất đề tài '{topic.TenDeTai}'. Vui lòng vào xem và phê duyệt.",
                LoaiThongBao = "Đề tài",
                LienKetId = topic.DeTaiId,
                LoaiLienKet = "DeTaiDoAn",
                DaDoc = false,
                CreatedAt = DateTime.Now
            });
            await _db.SaveChangesAsync();
        }

        var created = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.DeTaiId == topic.DeTaiId)
            .Select(ToTopicResponse())
            .FirstAsync();

        return CreatedAtAction(nameof(GetById), new { id = topic.DeTaiId }, created);
    }

    [HttpPut("{id:int}/duyet")]
    [HttpPut("{id:int}/tu-choi")]
    [HttpPut("{id:int}/reject")]
    [HttpPut("{id:int}/decide")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> Approve(int id, [FromBody] ApproveTopicRequest request)
    {
        var topic = await _db.DeTaiDoAns.FindAsync(id);
        if (topic is null) return NotFound(new { message = "Không tìm thấy đề tài." });

        int? lecturerId = await GetCurrentLecturerIdAsync();

        // Chỉ giảng viên phụ trách đề tài / lớp học phần (hoặc ADMIN) mới được duyệt
        if (!User.IsInRole("ADMIN"))
        {
            if (lecturerId is null) return Forbid();
            var topicPeriod = await _db.DotDangKyDoAns.AsNoTracking()
                .FirstOrDefaultAsync(d => d.DotDangKyId == topic.DotDangKyId);
            var isAssigned = topic.GiangVienId == lecturerId ||
                (topicPeriod != null && await _db.PhanCongGiangViens.AnyAsync(p =>
                    p.GiangVienId == lecturerId.Value && p.TrangThai && p.LopHocPhanId == topicPeriod.LopHocPhanId));
            if (!isAssigned)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = "Bạn không phụ trách lớp học phần của đề tài này." });
            }
        }

        if (topic.TrangThaiDuyet != "Chờ duyệt")
        {
            return BadRequest(new { message = $"Đề tài đã ở trạng thái '{topic.TrangThaiDuyet}', không thể xử lý lại." });
        }

        var path = Request.Path.Value ?? string.Empty;
        var isExplicitReject = path.Contains("tu-choi", StringComparison.OrdinalIgnoreCase)
            || path.Contains("reject", StringComparison.OrdinalIgnoreCase);

        var isApproved = !isExplicitReject && request.IsApproved;
        var rejectReason = request.Reason?.Trim();

        NhomDoAn? group = null;
        if (topic.SinhVienDeXuatId.HasValue)
        {
            var proposingSvId = topic.SinhVienDeXuatId.Value;
            // Chỉ tìm nhóm trong đúng đợt đăng ký của đề tài (không fallback sang lớp/đợt khác)
            group = await _db.NhomDoAns
                .Include(g => g.DotDangKy)
                .Include(g => g.ThanhVienNhoms)
                .FirstOrDefaultAsync(g => (g.TruongNhomId == proposingSvId || g.ThanhVienNhoms.Any(m => m.SinhVienId == proposingSvId && m.TrangThai == "Đã tham gia"))
                                         && g.DotDangKyId == topic.DotDangKyId
                                         && g.TrangThai == "Đang hoạt động");
        }

        if (isApproved && group != null)
        {
            var memberCount = group.ThanhVienNhoms.Count(m => m.TrangThai == "Đã tham gia");
            if (!group.ThanhVienNhoms.Any(m => m.SinhVienId == group.TruongNhomId && m.TrangThai == "Đã tham gia"))
                memberCount++;

            var min = group.DotDangKy?.MinMembers ?? 0;
            var max = group.DotDangKy?.MaxMembers ?? 0;
            if (memberCount < min)
            {
                return Conflict(new { message = $"Nhóm của sinh viên đề xuất chưa đủ số thành viên tối thiểu ({memberCount}/{min}). Không thể duyệt đề xuất." });
            }
            if (max > 0 && memberCount > max)
            {
                return Conflict(new { message = $"Nhóm của sinh viên đề xuất vượt quá số thành viên tối đa ({memberCount}/{max}). Không thể duyệt đề xuất." });
            }

            var hasOtherActiveReg = await _db.DangKyDeTais.AnyAsync(r =>
                r.NhomId == group.NhomId && r.DeTaiId != topic.DeTaiId &&
                (r.TrangThai == "Chờ duyệt" || r.TrangThai == "Đã duyệt"));
            if (hasOtherActiveReg)
            {
                return Conflict(new { message = "Nhóm đã có đề tài khác đang chờ duyệt hoặc đã được duyệt. Cần hủy đăng ký đó trước khi duyệt đề xuất này." });
            }
        }

        if (isApproved)
        {
            topic.TrangThaiDuyet = "Đã duyệt";
            topic.LyDoTuChoi = null;

            if (topic.GiangVienId == null && lecturerId.HasValue)
            {
                topic.GiangVienId = lecturerId;
            }

            if (group != null)
            {
                // TC_LEC_014: Đề xuất chuyển thành Đề tài chính thức được duyệt của nhóm, cập nhật vào danh sách đề tài của LHP.
                topic.TrangThai = "Đã đăng ký";

                var existingReg = await _db.DangKyDeTais
                    .FirstOrDefaultAsync(r => r.NhomId == group.NhomId && r.DeTaiId == topic.DeTaiId);

                if (existingReg != null)
                {
                    existingReg.DeTaiId = topic.DeTaiId;
                    existingReg.TrangThai = "Đã duyệt";
                    existingReg.NgayDuyet = DateTime.Now;
                    existingReg.GiangVienDuyetId = lecturerId;
                    existingReg.GhiChu = "Đề xuất đề tài đã được giảng viên phê duyệt làm đề tài chính thức của nhóm.";
                }
                else
                {
                    var newReg = new DangKyDeTai
                    {
                        NhomId = group.NhomId,
                        DeTaiId = topic.DeTaiId,
                        TrangThai = "Đã duyệt",
                        NgayDangKy = DateTime.Now,
                        NgayDuyet = DateTime.Now,
                        GiangVienDuyetId = lecturerId,
                        GhiChu = "Đề xuất đề tài đã được giảng viên phê duyệt làm đề tài chính thức của nhóm."
                    };
                    _db.DangKyDeTais.Add(newReg);
                }
            }
            else
            {
                if (topic.TrangThai == "Chờ duyệt")
                {
                    topic.TrangThai = "Chưa sử dụng";
                }
            }
        }
        else
        {
            // TC_LEC_015: Từ chối đề xuất của Sinh viên kèm góp ý chỉnh sửa
            topic.TrangThaiDuyet = "Từ chối";
            var defaultRejectReason = "Phạm vi đề tài quá rộng, cần thu hẹp lại";
            topic.LyDoTuChoi = !string.IsNullOrWhiteSpace(rejectReason) ? rejectReason : defaultRejectReason;
        }

        topic.UpdatedAt = DateTime.Now;

        // Tạo thông báo cho sinh viên đề xuất và các thành viên trong nhóm
        if (topic.SinhVienDeXuatId.HasValue)
        {
            try
            {
                var targetUserIds = new HashSet<int>();
                var sv = await _db.SinhViens.AsNoTracking().FirstOrDefaultAsync(s => s.SinhVienId == topic.SinhVienDeXuatId.Value);
                if (sv?.NguoiDungId > 0)
                {
                    targetUserIds.Add(sv.NguoiDungId);
                }

                if (group != null)
                {
                    var groupStudentIds = new HashSet<int>();
                    if (group.TruongNhomId > 0) groupStudentIds.Add(group.TruongNhomId);

                    var memberIds = await _db.ThanhVienNhoms
                        .AsNoTracking()
                        .Where(m => m.NhomId == group.NhomId && m.TrangThai != "Đã rời nhóm" && m.TrangThai != "Từ chối")
                        .Select(m => m.SinhVienId)
                        .ToListAsync();

                    foreach (var mid in memberIds) if (mid > 0) groupStudentIds.Add(mid);

                    var groupUserIds = await _db.SinhViens
                        .AsNoTracking()
                        .Where(s => groupStudentIds.Contains(s.SinhVienId) && s.NguoiDungId > 0)
                        .Select(s => s.NguoiDungId)
                        .ToListAsync();

                    foreach (var guid in groupUserIds) targetUserIds.Add(guid);

                    var directGroupUserIds = await _db.NguoiDungs
                        .AsNoTracking()
                        .Where(u => groupStudentIds.Contains(u.NguoiDungId))
                        .Select(u => u.NguoiDungId)
                        .ToListAsync();

                    foreach (var duid in directGroupUserIds) targetUserIds.Add(duid);
                }

                var tieuDe = isApproved ? "Đề xuất đề tài được duyệt" : "Đề xuất đề tài bị từ chối";
                var noiDung = isApproved
                    ? $"Đề xuất đề tài '{topic.TenDeTai}' đã được giảng viên phê duyệt thành đề tài chính thức của nhóm."
                    : $"Đề xuất đề tài '{topic.TenDeTai}' bị từ chối. Lý do: {topic.LyDoTuChoi}";

                foreach (var uid in targetUserIds)
                {
                    _db.ThongBaos.Add(new ThongBao
                    {
                        NguoiDungId = uid,
                        TieuDe = tieuDe,
                        NoiDung = noiDung,
                        LoaiThongBao = "Đề tài",
                        DaDoc = false,
                        CreatedAt = DateTime.UtcNow,
                        LienKetId = topic.DeTaiId,
                        LoaiLienKet = "de-tai"
                    });
                }
            }
            catch
            {
                // Bỏ qua lỗi thông báo nếu có
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
            return Conflict(new { message = $"Nhóm của bạn chưa đủ số thành viên tối thiểu (yêu cầu tối thiểu {period.MinMembers} thành viên)." });

        if (period.MaxMembers > 0 && activeMembers > period.MaxMembers)
            return Conflict(new { message = $"Nhóm của bạn vượt quá số thành viên tối đa (tối đa {period.MaxMembers} thành viên)." });

        var hasRegistration = await _db.DangKyDeTais.AnyAsync(x => x.NhomId == group.NhomId &&
            (x.TrangThai == "Chờ duyệt" || x.TrangThai == "Đã duyệt"));
        if (hasRegistration)
            return Conflict(new { message = "Nhóm đã có đăng ký đề tài đang chờ hoặc đã duyệt." });

        var topic = await _db.DeTaiDoAns.FirstOrDefaultAsync(x => x.DeTaiId == request.DeTaiId && x.DotDangKyId == period.DotDangKyId);
        if (topic is null) return NotFound(new { message = "Đề tài không tồn tại trong đợt đăng ký của nhóm." });
        if ((topic.TrangThai != "Chưa sử dụng" && topic.TrangThai != "Đang hoạt động") || topic.TrangThaiDuyet != "Đã duyệt")
            return Conflict(new { message = "Đề tài không khả dụng hoặc chưa được duyệt." });

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

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return Ok(new { success = true, message = "Đăng ký đề tài thành công." });
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
