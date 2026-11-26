using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Governance;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/governance")]
[Authorize(Roles = "GIAOVUKHOA,ADMIN,PHONGDAOTAO")]
public sealed class GovernanceController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public GovernanceController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("courses")]
    public async Task<IActionResult> GetCourses()
    {
        var courses = await _db.LopHocPhans.AsNoTracking()
            .OrderBy(c => c.MaLopHocPhan)
            .Select(c => new
            {
                c.LopHocPhanId,
                c.MaLopHocPhan,
                c.TenLopHocPhan,
                c.HocPhanId,
                MaHocPhan = c.HocPhan != null ? c.HocPhan.MaHocPhan : string.Empty,
                TenHocPhan = c.HocPhan != null ? c.HocPhan.TenHocPhan : string.Empty,
                c.HocKyId,
                TenHocKy = c.HocKy != null ? c.HocKy.TenHocKy : string.Empty,
                NamHoc = c.HocKy != null ? c.HocKy.NamHoc : string.Empty,
                c.KhoaId,
                TenKhoa = c.Khoa != null ? c.Khoa.TenKhoa : string.Empty,
                c.SoLuongToiDa,
                SoSinhVien = c.SinhVienLopHocPhans.Count(s => s.TrangThai),
                GiangViens = c.PhanCongGiangViens
                    .Where(p => p.TrangThai)
                    .Select(p => new
                    {
                        p.GiangVienId,
                        MaGiangVien = p.GiangVien != null ? p.GiangVien.MaGiangVien : string.Empty,
                        HoTen = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : string.Empty,
                        p.VaiTro
                    }).ToList(),
                c.TrangThai
            })
            .ToListAsync();

        return Ok(courses);
    }

    [HttpGet("assignments")]
    public async Task<ActionResult<IReadOnlyList<AssignmentResponse>>> GetAssignments([FromQuery] int? lopHocPhanId)
    {
        var query = _db.PhanCongGiangViens.AsNoTracking().AsQueryable();

        if (lopHocPhanId.HasValue)
        {
            query = query.Where(p => p.LopHocPhanId == lopHocPhanId.Value);
        }

        var results = await query
            .OrderByDescending(p => p.NgayPhanCong)
            .Select(p => new AssignmentResponse
            {
                PhanCongId = p.PhanCongId,
                LopHocPhanId = p.LopHocPhanId,
                MaLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.MaLopHocPhan : string.Empty,
                TenLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.TenLopHocPhan ?? string.Empty : string.Empty,
                GiangVienId = p.GiangVienId,
                MaGiangVien = p.GiangVien != null ? p.GiangVien.MaGiangVien : string.Empty,
                HoTen = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : string.Empty,
                Email = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.Email : string.Empty,
                VaiTro = p.VaiTro,
                NgayPhanCong = p.NgayPhanCong,
                TrangThai = p.TrangThai
            })
            .ToListAsync();

        return Ok(results);
    }

    [HttpPost("assignments")]
    public async Task<IActionResult> CreateAssignment([FromBody] AssignmentRequest request)
    {
        var course = await _db.LopHocPhans.AsNoTracking().FirstOrDefaultAsync(c => c.LopHocPhanId == request.LopHocPhanId);
        if (course is null)
        {
            return BadRequest(new { message = "Lớp học phần không tồn tại." });
        }

        var lecturer = await _db.GiangViens.AsNoTracking()
            .Include(g => g.NguoiDung)
            .FirstOrDefaultAsync(g => g.GiangVienId == request.GiangVienId);
        if (lecturer is null)
        {
            return BadRequest(new { message = "Giảng viên không tồn tại." });
        }

        // 1. Vô hiệu hóa phân công cũ của các giảng viên khác trên lớp này và thông báo
        var activeOthers = await _db.PhanCongGiangViens
            .Include(p => p.GiangVien)
            .Where(p => p.LopHocPhanId == request.LopHocPhanId && p.TrangThai && p.GiangVienId != request.GiangVienId)
            .ToListAsync();

        foreach (var old in activeOthers)
        {
            old.TrangThai = false;
            if (old.GiangVien?.NguoiDungId != null)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = old.GiangVien.NguoiDungId,
                    TieuDe = "Thay đổi phân công giảng dạy",
                    NoiDung = $"Lớp học phần '{course.TenLopHocPhan ?? course.MaLopHocPhan}' ({course.MaLopHocPhan}) đã được chuyển giao cho giảng viên khác phụ trách.",
                    LoaiThongBao = "Phân công",
                    LienKetId = course.LopHocPhanId,
                    LoaiLienKet = "LopHocPhan",
                    DaDoc = false,
                    CreatedAt = DateTime.Now
                });
            }
        }

        // 2. Chuyển giao các đề tài của lớp học phần sang giảng viên mới
        var courseTopics = await _db.DeTaiDoAns
            .Where(t => t.DotDangKy != null && t.DotDangKy.LopHocPhanId == request.LopHocPhanId && t.GiangVienId != request.GiangVienId)
            .ToListAsync();
        foreach (var topic in courseTopics)
        {
            topic.GiangVienId = request.GiangVienId;
            topic.UpdatedAt = DateTime.Now;
        }

        var existingAssignment = await _db.PhanCongGiangViens
            .FirstOrDefaultAsync(p => p.LopHocPhanId == request.LopHocPhanId && p.GiangVienId == request.GiangVienId);

        if (existingAssignment is not null)
        {
            existingAssignment.TrangThai = true;
            existingAssignment.VaiTro = !string.IsNullOrWhiteSpace(request.VaiTro) ? request.VaiTro.Trim() : "Giảng viên phụ trách";
            existingAssignment.NgayPhanCong = DateTime.Now;
            _db.ThongBaos.Add(new ThongBao
            {
                NguoiDungId = lecturer.NguoiDungId,
                TieuDe = "Phân công giảng dạy mới",
                NoiDung = $"Bạn vừa được phân công phụ trách lớp học phần '{course.TenLopHocPhan ?? course.MaLopHocPhan}' ({course.MaLopHocPhan}).",
                LoaiThongBao = "Phân công",
                LienKetId = course.LopHocPhanId,
                LoaiLienKet = "LopHocPhan",
                DaDoc = false,
                CreatedAt = DateTime.Now
            });
            await _db.SaveChangesAsync();

            return Ok(new { success = true, message = "Đã cập nhật phân công giảng viên phụ trách lớp học phần." });
        }

        var assignment = new PhanCongGiangVien
        {
            LopHocPhanId = request.LopHocPhanId,
            GiangVienId = request.GiangVienId,
            VaiTro = !string.IsNullOrWhiteSpace(request.VaiTro) ? request.VaiTro.Trim() : "Giảng viên phụ trách",
            NgayPhanCong = DateTime.Now,
            TrangThai = true
        };

        _db.PhanCongGiangViens.Add(assignment);
        _db.ThongBaos.Add(new ThongBao
        {
            NguoiDungId = lecturer.NguoiDungId,
            TieuDe = "Phân công giảng dạy mới",
            NoiDung = $"Bạn vừa được phân công phụ trách lớp học phần '{course.TenLopHocPhan ?? course.MaLopHocPhan}' ({course.MaLopHocPhan}).",
            LoaiThongBao = "Phân công",
            LienKetId = course.LopHocPhanId,
            LoaiLienKet = "LopHocPhan",
            DaDoc = false,
            CreatedAt = DateTime.Now
        });
        await _db.SaveChangesAsync();

        var created = await _db.PhanCongGiangViens.AsNoTracking()
            .Include(p => p.LopHocPhan)
            .Include(p => p.GiangVien).ThenInclude(g => g!.NguoiDung)
            .Where(p => p.PhanCongId == assignment.PhanCongId)
            .Select(p => new AssignmentResponse
            {
                PhanCongId = p.PhanCongId,
                LopHocPhanId = p.LopHocPhanId,
                MaLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.MaLopHocPhan : string.Empty,
                TenLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.TenLopHocPhan ?? string.Empty : string.Empty,
                GiangVienId = p.GiangVienId,
                MaGiangVien = p.GiangVien != null ? p.GiangVien.MaGiangVien : string.Empty,
                HoTen = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : string.Empty,
                Email = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.Email : string.Empty,
                VaiTro = p.VaiTro,
                NgayPhanCong = p.NgayPhanCong,
                TrangThai = p.TrangThai
            })
            .FirstAsync();

        return CreatedAtAction(nameof(GetAssignments), new { lopHocPhanId = assignment.LopHocPhanId }, created);
    }

    /// <summary>
    /// Đổi giảng viên phụ trách cho một lớp học phần (TC_GVK_009)
    /// </summary>
    [HttpPut("assignments")]
    public async Task<IActionResult> UpdateAssignment([FromBody] AssignmentRequest request)
    {
        var course = await _db.LopHocPhans.AsNoTracking().FirstOrDefaultAsync(c => c.LopHocPhanId == request.LopHocPhanId);
        if (course is null) return BadRequest(new { message = "Lớp học phần không tồn tại." });

        var newLecturer = await _db.GiangViens.AsNoTracking().FirstOrDefaultAsync(g => g.GiangVienId == request.GiangVienId);
        if (newLecturer is null) return BadRequest(new { message = "Giảng viên mới không tồn tại." });

        var activeOthers = await _db.PhanCongGiangViens
            .Include(p => p.GiangVien)
            .Where(p => p.LopHocPhanId == request.LopHocPhanId && p.TrangThai && p.GiangVienId != request.GiangVienId)
            .ToListAsync();
        foreach (var old in activeOthers)
        {
            old.TrangThai = false;
            if (old.GiangVien?.NguoiDungId != null)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = old.GiangVien.NguoiDungId,
                    TieuDe = "Thay đổi phân công giảng dạy",
                    NoiDung = $"Lớp học phần '{course.TenLopHocPhan ?? course.MaLopHocPhan}' ({course.MaLopHocPhan}) đã được chuyển giao cho giảng viên khác phụ trách.",
                    LoaiThongBao = "Phân công",
                    LienKetId = course.LopHocPhanId,
                    LoaiLienKet = "LopHocPhan",
                    DaDoc = false,
                    CreatedAt = DateTime.Now
                });
            }
        }

        // Chuyển giao các đề tài của lớp học phần sang giảng viên mới
        var courseTopics = await _db.DeTaiDoAns
            .Where(t => t.DotDangKy != null && t.DotDangKy.LopHocPhanId == request.LopHocPhanId && t.GiangVienId != request.GiangVienId)
            .ToListAsync();
        foreach (var topic in courseTopics)
        {
            topic.GiangVienId = request.GiangVienId;
            topic.UpdatedAt = DateTime.Now;
        }

        var target = await _db.PhanCongGiangViens
            .FirstOrDefaultAsync(p => p.LopHocPhanId == request.LopHocPhanId && p.GiangVienId == request.GiangVienId);
        if (target != null)
        {
            target.TrangThai = true;
            target.VaiTro = !string.IsNullOrWhiteSpace(request.VaiTro) ? request.VaiTro.Trim() : "Giảng viên phụ trách";
            target.NgayPhanCong = DateTime.Now;
        }
        else
        {
            _db.PhanCongGiangViens.Add(new PhanCongGiangVien
            {
                LopHocPhanId = request.LopHocPhanId,
                GiangVienId = request.GiangVienId,
                VaiTro = !string.IsNullOrWhiteSpace(request.VaiTro) ? request.VaiTro.Trim() : "Giảng viên phụ trách",
                NgayPhanCong = DateTime.Now,
                TrangThai = true
            });
        }

        _db.ThongBaos.Add(new ThongBao
        {
            NguoiDungId = newLecturer.NguoiDungId,
            TieuDe = "Cập nhật phân công giảng dạy",
            NoiDung = $"Bạn vừa được điều chuyển phụ trách lớp học phần '{course.TenLopHocPhan ?? course.MaLopHocPhan}' ({course.MaLopHocPhan}).",
            LoaiThongBao = "Phân công",
            LienKetId = course.LopHocPhanId,
            LoaiLienKet = "LopHocPhan",
            DaDoc = false,
            CreatedAt = DateTime.Now
        });

        await _db.SaveChangesAsync();
        return Ok(new { success = true, message = "Đã cập nhật giảng viên phụ trách lớp học phần." });
    }

    /// <summary>
    /// Hủy phân công giảng viên khỏi lớp học phần khi chưa có nhóm đăng ký (TC_GVK_010)
    /// </summary>
    [HttpDelete("assignments")]
    [HttpDelete("assignments/{lopHocPhanId:int}")]
    public async Task<IActionResult> DeleteAssignment(int? lopHocPhanId = null, [FromQuery] int? courseId = null, [FromQuery] int? giangVienId = null)
    {
        var lhpId = lopHocPhanId ?? courseId;
        if (!lhpId.HasValue || lhpId.Value <= 0)
            return BadRequest(new { message = "Thiếu mã lớp học phần cần hủy phân công." });

        var hasActiveGroupReg = await _db.DangKyDeTais.AnyAsync(r =>
            r.DeTai != null && r.DeTai.DotDangKy != null &&
            r.DeTai.DotDangKy.LopHocPhanId == lhpId.Value &&
            r.TrangThai != "Đã hủy");
        if (hasActiveGroupReg)
        {
            return BadRequest(new { message = "Không thể hủy phân công vì lớp học phần đã có nhóm đăng ký đề tài." });
        }

        var assignments = await _db.PhanCongGiangViens
            .Where(p => p.LopHocPhanId == lhpId.Value && p.TrangThai && (!giangVienId.HasValue || p.GiangVienId == giangVienId.Value))
            .ToListAsync();
        if (assignments.Count == 0)
            return NotFound(new { message = "Không tìm thấy phân công giảng viên đang hoạt động." });

        foreach (var item in assignments)
        {
            item.TrangThai = false;
        }
        await _db.SaveChangesAsync();

        return Ok(new { success = true, message = "Đã hủy phân công giảng viên. Lớp học phần quay về trạng thái chưa phân công." });
    }

    [HttpGet("students")]
    public async Task<IActionResult> GetStudents([FromQuery] int? khoaId, [FromQuery] string? search, [FromQuery] int? page = null, [FromQuery] int? pageSize = null)
    {
        var query = _db.SinhViens.AsNoTracking().AsQueryable();

        if (khoaId.HasValue)
        {
            query = query.Where(s => s.KhoaId == khoaId.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(sv => sv.MSSV.Contains(s) || (sv.NguoiDung != null && (sv.NguoiDung.HoTen.Contains(s) || sv.NguoiDung.Email.Contains(s))));
        }

        IQueryable<SinhVien> orderedQuery = query.OrderBy(s => s.MSSV);
        if (page.HasValue && page.Value > 0 && pageSize.HasValue && pageSize.Value > 0)
        {
            var size = Math.Min(pageSize.Value, 200);
            orderedQuery = orderedQuery.Skip((page.Value - 1) * size).Take(size);
        }

        var students = await orderedQuery
            .Select(s => new
            {
                s.SinhVienId,
                s.MSSV,
                s.NguoiDungId,
                HoTen = s.NguoiDung != null ? s.NguoiDung.HoTen : string.Empty,
                Email = s.NguoiDung != null ? s.NguoiDung.Email : string.Empty,
                SoDienThoai = s.NguoiDung != null ? s.NguoiDung.SoDienThoai : null,
                s.KhoaId,
                TenKhoa = s.Khoa != null ? s.Khoa.TenKhoa : string.Empty,
                s.NgaySinh,
                s.GioiTinh,
                TrangThai = s.NguoiDung != null && s.NguoiDung.TrangThai
            })
            .ToListAsync();

        return Ok(students);
    }

    [HttpGet("lecturers")]
    public async Task<IActionResult> GetLecturers([FromQuery] int? khoaId, [FromQuery] string? search)
    {
        var query = _db.GiangViens.AsNoTracking().AsQueryable();

        if (khoaId.HasValue)
        {
            query = query.Where(g => g.KhoaId == khoaId.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(gv =>
                gv.MaGiangVien.Contains(s) ||
                (gv.ChuyenMon != null && gv.ChuyenMon.Contains(s)) ||
                (gv.NguoiDung != null && (gv.NguoiDung.HoTen.Contains(s) || gv.NguoiDung.Email.Contains(s))));
        }

        var lecturers = await query
            .OrderBy(g => g.MaGiangVien)
            .Select(g => new
            {
                g.GiangVienId,
                g.MaGiangVien,
                g.NguoiDungId,
                HoTen = g.NguoiDung != null ? g.NguoiDung.HoTen : string.Empty,
                Email = g.NguoiDung != null ? g.NguoiDung.Email : string.Empty,
                SoDienThoai = g.NguoiDung != null ? g.NguoiDung.SoDienThoai : null,
                g.KhoaId,
                TenKhoa = g.Khoa != null ? g.Khoa.TenKhoa : string.Empty,
                g.HocVi,
                g.ChuyenMon,
                SoLopPhuTrach = g.PhanCongGiangViens.Count(p => p.TrangThai),
                TrangThai = g.NguoiDung != null && g.NguoiDung.TrangThai
            })
            .ToListAsync();

        return Ok(lecturers);
    }
}
