using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Admin;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]
public sealed class AdminController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public AdminController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("users")]
    public async Task<ActionResult<IReadOnlyList<AdminUserResponse>>> GetUsers(
        [FromQuery] string? role,
        [FromQuery] string? search,
        [FromQuery] int? page = null,
        [FromQuery] int? pageSize = null)
    {
        var query = _db.NguoiDungs.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(role))
        {
            var roleFilter = role.Trim().ToUpperInvariant();
            query = query.Where(u => u.VaiTro != null && (
                u.VaiTro.MaVaiTro.ToUpper() == roleFilter ||
                u.VaiTro.MaVaiTro.ToUpper().Contains(roleFilter) ||
                u.VaiTro.TenVaiTro.ToUpper().Contains(roleFilter) ||
                (roleFilter == "SINHVIEN" && (u.VaiTro.MaVaiTro.Contains("SV") || u.VaiTro.TenVaiTro.Contains("Sinh viên"))) ||
                (roleFilter == "GIANGVIEN" && (u.VaiTro.MaVaiTro.Contains("GV") || u.VaiTro.TenVaiTro.Contains("Giảng viên"))) ||
                (roleFilter == "GIAOVUKHOA" && (u.VaiTro.MaVaiTro.Contains("GVK") || u.VaiTro.MaVaiTro.Contains("GIAOVU") || u.VaiTro.TenVaiTro.Contains("Giáo vụ"))) ||
                (roleFilter == "PHONGDAOTAO" && (u.VaiTro.MaVaiTro.Contains("PDT") || u.VaiTro.MaVaiTro.Contains("DAOTAO") || u.VaiTro.TenVaiTro.Contains("Đào tạo"))) ||
                (roleFilter == "ADMIN" && (u.VaiTro.MaVaiTro.Contains("ADMIN") || u.VaiTro.TenVaiTro.Contains("Quản trị")))
            ));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(u =>
                u.TenDangNhap.Contains(s) ||
                u.HoTen.Contains(s) ||
                u.Email.Contains(s) ||
                (u.SinhVien != null && u.SinhVien.MSSV.Contains(s)) ||
                (u.GiangVien != null && u.GiangVien.MaGiangVien.Contains(s)));
        }

        IQueryable<NguoiDung> orderedQuery = query.OrderByDescending(u => u.CreatedAt);
        if (page.HasValue && page.Value > 0 && pageSize.HasValue && pageSize.Value > 0)
        {
            var size = Math.Min(pageSize.Value, 200);
            orderedQuery = orderedQuery.Skip((page.Value - 1) * size).Take(size);
        }

        var users = await orderedQuery
            .Select(u => new AdminUserResponse
            {
                NguoiDungId = u.NguoiDungId,
                TenDangNhap = u.TenDangNhap,
                Email = u.Email,
                HoTen = u.HoTen,
                SoDienThoai = u.SoDienThoai,
                AvatarUrl = u.AvatarUrl,
                VaiTroId = u.VaiTroId,
                MaVaiTro = u.VaiTro != null ? u.VaiTro.MaVaiTro : string.Empty,
                TenVaiTro = u.VaiTro != null ? u.VaiTro.TenVaiTro : string.Empty,
                TrangThai = u.TrangThai,
                CreatedAt = u.CreatedAt,
                SinhVienId = u.SinhVien != null ? u.SinhVien.SinhVienId : null,
                MSSV = u.SinhVien != null ? u.SinhVien.MSSV : null,
                GiangVienId = u.GiangVien != null ? u.GiangVien.GiangVienId : null,
                MaGiangVien = u.GiangVien != null ? u.GiangVien.MaGiangVien : null,
                KhoaId = u.SinhVien != null ? u.SinhVien.KhoaId : (u.GiangVien != null ? u.GiangVien.KhoaId : null),
                TenKhoa = u.SinhVien != null && u.SinhVien.Khoa != null ? u.SinhVien.Khoa.TenKhoa : (u.GiangVien != null && u.GiangVien.Khoa != null ? u.GiangVien.Khoa.TenKhoa : null)
            })
            .ToListAsync();

        return Ok(users);
    }

    [HttpGet("overview")]
    [HttpGet("stats")]
    public async Task<ActionResult<AdminOverviewResponse>> GetOverview()
    {
        var totalUsers = await _db.NguoiDungs.AsNoTracking().CountAsync();
        var totalStudents = await _db.SinhViens.AsNoTracking().CountAsync();
        var totalLecturers = await _db.GiangViens.AsNoTracking().CountAsync();
        var totalClasses = await _db.LopHocPhans.AsNoTracking().CountAsync();

        var totalTopics = await _db.DeTaiDoAns.AsNoTracking().CountAsync();
        var totalApprovedTopics = await _db.DeTaiDoAns.AsNoTracking()
            .CountAsync(d => d.TrangThaiDuyet == "Đã duyệt");

        var totalGroups = await _db.NhomDoAns.AsNoTracking().CountAsync(n => n.TrangThai != "Đã hủy");

        var regStatusCounts = await _db.DangKyDeTais.AsNoTracking()
            .GroupBy(d => d.TrangThai)
            .Select(g => new { TrangThai = g.Key, Count = g.Count() })
            .ToListAsync();
        var totalRegistrations = regStatusCounts.Sum(x => x.Count);
        var completedGroups = regStatusCounts.Where(x => x.TrangThai == "Đã duyệt").Sum(x => x.Count);

        var openPeriods = await _db.DotDangKyDoAns.AsNoTracking().CountAsync(d => d.TrangThai == "Đang mở");

        var activeStudentsDoingThesis = await _db.ThanhVienNhoms.AsNoTracking()
            .Where(tv => tv.TrangThai == "Đã tham gia" && tv.Nhom != null && tv.Nhom.TrangThai != "Đã hủy")
            .Select(tv => tv.SinhVienId)
            .Distinct()
            .CountAsync();

        double completionRate = totalGroups > 0 ? Math.Round((double)completedGroups / totalGroups * 100, 1) : 0.0;

        var grades = await _db.BaoCaoTienDos.AsNoTracking()
            .Where(b => b.Diem.HasValue)
            .Select(b => (double)b.Diem!.Value)
            .ToListAsync();

        var gradeDistribution = new GradeDistributionDto
        {
            XuatSac = grades.Count(g => g >= 9.0),
            Gioi = grades.Count(g => g >= 8.0 && g < 9.0),
            Kha = grades.Count(g => g >= 7.0 && g < 8.0),
            TrungBinh = grades.Count(g => g >= 5.0 && g < 7.0),
            Rot = grades.Count(g => g < 5.0)
        };

        var activeSemesterEntity = await _db.HocKys.AsNoTracking()
            .Where(h => h.TrangThai)
            .OrderByDescending(h => h.HocKyId)
            .Select(h => new { h.HocKyId, Name = $"{h.TenHocKy} ({h.NamHoc})" })
            .FirstOrDefaultAsync();
        var activeSemester = activeSemesterEntity?.Name ?? "Học kỳ 1 (2026-2027)";
        var orphanStudents = await _db.SinhViens.AsNoTracking().CountAsync(s => s.Khoa == null);

        var departments = await _db.Khoas.AsNoTracking().Select(k => new DepartmentStatItem
        {
            KhoaId = k.KhoaId,
            MaKhoa = k.MaKhoa,
            TenKhoa = k.TenKhoa,
            SoLopHocPhan = k.LopHocPhans.Count(l => l.TrangThai),
            SoSinhVien = k.SinhViens.Count(),
            SoNhom = k.LopHocPhans.SelectMany(l => l.DotDangKyDoAns).SelectMany(d => d.NhomDoAns).Count(n => n.TrangThai != "Đã hủy"),
            SoDeTai = k.LopHocPhans.SelectMany(l => l.DotDangKyDoAns).SelectMany(d => d.DeTaiDoAns).Count()
        }).ToListAsync();
        var totalFaculties = departments.Count;

        return Ok(new AdminOverviewResponse
        {
            TongNguoiDung = totalUsers,
            TongSinhVien = totalStudents,
            TongGiangVien = totalLecturers,
            TongLopHocPhan = totalClasses,
            TongDeTai = totalTopics,
            TongDeTaiDaDuyet = totalApprovedTopics,
            TongNhom = totalGroups,
            TongDangKyDeTai = totalRegistrations,
            DotDangKyDangMo = openPeriods,
            TongKhoa = totalFaculties,
            TongSinhVienLamDoAn = activeStudentsDoingThesis > 0 ? activeStudentsDoingThesis : totalStudents,
            SoSinhVienChuaGanKhoa = orphanStudents,
            TyLeHoanThanh = completionRate,
            HocKyHienTaiId = activeSemesterEntity?.HocKyId,
            HocKyHienTai = activeSemester,
            ThongKeTheoKhoa = departments,
            PhoDiem = gradeDistribution
        });
    }

    [Authorize(Roles = "ADMIN,GIAOVUKHOA")]
    [HttpGet("activity-logs")]
    public async Task<IActionResult> GetActivityLogs([FromQuery] int limit = 50)
    {
        var takeLimit = Math.Clamp(limit, 1, 200);
        var perSourceLimit = Math.Min(takeLimit, 50);
        var logs = new List<(DateTime Time, string Actor, string Action, string Target, string Description, string Role, string Status, string Ip)>();
        var requestIp = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "N/A";

        var recentUsers = await _db.NguoiDungs.AsNoTracking()
            .OrderByDescending(u => u.CreatedAt)
            .Take(perSourceLimit)
            .Select(u => new
            {
                u.CreatedAt,
                u.TenDangNhap,
                u.HoTen,
                TenVaiTro = u.VaiTro != null ? u.VaiTro.TenVaiTro : "Người dùng",
                u.TrangThai
            })
            .ToListAsync();

        foreach (var u in recentUsers)
        {
            logs.Add((
                u.CreatedAt,
                u.TenDangNhap,
                "Tạo tài khoản",
                u.TenDangNhap,
                $"Tài khoản {u.TenDangNhap} ({u.HoTen}) đã được khởi tạo trong hệ thống.",
                u.TenVaiTro,
                u.TrangThai ? "Thành công" : "Đã khóa",
                requestIp
            ));
        }

        var recentRegs = await _db.DangKyDeTais.AsNoTracking()
            .OrderByDescending(d => d.NgayDangKy)
            .Take(perSourceLimit)
            .Select(d => new
            {
                d.NgayDangKy,
                TenNhom = d.Nhom != null ? d.Nhom.TenNhom : null,
                TenDeTai = d.DeTai != null ? d.DeTai.TenDeTai : null,
                d.TrangThai
            })
            .ToListAsync();

        foreach (var r in recentRegs)
        {
            logs.Add((
                r.NgayDangKy,
                r.TenNhom ?? "Nhóm sinh viên",
                "Đăng ký đề tài",
                r.TenDeTai ?? "Đề tài",
                $"Nhóm {r.TenNhom} đăng ký đề tài '{r.TenDeTai}'.",
                "Sinh viên",
                r.TrangThai == "Đã duyệt" ? "Thành công" : (r.TrangThai == "Từ chối" ? "Thất bại" : "Chờ xử lý"),
                requestIp
            ));
        }

        var sorted = logs
            .OrderByDescending(x => x.Time)
            .Take(takeLimit)
            .Select((x, idx) => new
            {
                id = idx + 1,
                time = x.Time,
                actor = x.Actor,
                action = x.Action,
                target = x.Target,
                description = x.Description,
                role = x.Role,
                status = x.Status,
                ipAddress = x.Ip
            })
            .ToList();

        return Ok(sorted);
    }

    [Authorize(Roles = "ADMIN")]
    [HttpPost("users")]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        var username = request.TenDangNhap.Trim();
        var email = request.Email.Trim();

        var usernameExists = await _db.NguoiDungs.AnyAsync(u => u.TenDangNhap == username);
        if (usernameExists)
        {
            return Conflict(new { message = "Tên đăng nhập đã tồn tại trong hệ thống." });
        }

        var emailExists = await _db.NguoiDungs.AnyAsync(u => u.Email == email);
        if (emailExists)
        {
            return Conflict(new { message = "Email đã tồn tại trong hệ thống." });
        }

        VaiTro? role = null;
        if (request.VaiTroId.HasValue)
        {
            role = await _db.VaiTros.FindAsync(request.VaiTroId.Value);
        }
        else if (!string.IsNullOrWhiteSpace(request.MaVaiTro))
        {
            var code = request.MaVaiTro.Trim().ToUpperInvariant();
            role = await _db.VaiTros.FirstOrDefaultAsync(v => v.MaVaiTro.ToUpper() == code);
        }

        if (role is null)
        {
            return BadRequest(new { message = "Vai trò được chỉ định không tồn tại." });
        }

        var defaultKhoa = await _db.Khoas.FirstOrDefaultAsync();
        var khoaId = request.KhoaId ?? defaultKhoa?.KhoaId ?? 1;

        string? soDienThoai = null;
        if (!string.IsNullOrWhiteSpace(request.SoDienThoai))
        {
            var phone = request.SoDienThoai.Trim();
            if (!System.Text.RegularExpressions.Regex.IsMatch(phone, @"^[0-9]{10,11}$"))
            {
                return BadRequest(new { message = "Số điện thoại phải từ 10-11 chữ số và không chứa ký tự chữ." });
            }
            soDienThoai = phone;
        }

        string? studentMssv = null;
        if (role.MaVaiTro.Equals("SINHVIEN", StringComparison.OrdinalIgnoreCase))
        {
            studentMssv = !string.IsNullOrWhiteSpace(request.MSSV) ? request.MSSV.Trim() : username;
            if (studentMssv.Length > 30)
            {
                return BadRequest(new { message = "MSSV (Tên đăng nhập sinh viên) tối đa 30 ký tự." });
            }
            if (await _db.SinhViens.AnyAsync(s => s.MSSV == studentMssv))
            {
                return Conflict(new { message = $"MSSV '{studentMssv}' đã tồn tại trong hệ thống." });
            }
        }

        var user = new NguoiDung
        {
            TenDangNhap = username,
            MatKhauHash = BCrypt.Net.BCrypt.HashPassword(request.MatKhau),
            Email = email,
            HoTen = request.HoTen.Trim(),
            SoDienThoai = soDienThoai,
            VaiTroId = role.VaiTroId,
            TrangThai = request.TrangThai,
            CreatedAt = DateTime.Now
        };

        _db.NguoiDungs.Add(user);
        await _db.SaveChangesAsync();

        if (role.MaVaiTro.Equals("SINHVIEN", StringComparison.OrdinalIgnoreCase))
        {
            var sinhVien = new SinhVien
            {
                NguoiDungId = user.NguoiDungId,
                MSSV = studentMssv!,
                KhoaId = khoaId,
                NgaySinh = request.NgaySinh,
                GioiTinh = request.GioiTinh?.Trim(),
                CreatedAt = DateTime.Now
            };
            _db.SinhViens.Add(sinhVien);
            await _db.SaveChangesAsync();
        }
        else if (role.MaVaiTro.Equals("GIANGVIEN", StringComparison.OrdinalIgnoreCase))
        {
            var magv = !string.IsNullOrWhiteSpace(request.MaGiangVien) ? request.MaGiangVien.Trim() : username;
            var giangVien = new GiangVien
            {
                NguoiDungId = user.NguoiDungId,
                MaGiangVien = magv,
                KhoaId = khoaId,
                HocVi = request.HocVi?.Trim(),
                ChuyenMon = request.ChuyenMon?.Trim(),
                CreatedAt = DateTime.Now
            };
            _db.GiangViens.Add(giangVien);
            await _db.SaveChangesAsync();

            var gvkIds = await _db.NguoiDungs.AsNoTracking()
                .Where(u => u.TrangThai && u.VaiTro != null && u.VaiTro.MaVaiTro == "GIAOVUKHOA")
                .Select(u => u.NguoiDungId)
                .ToListAsync();
            var khoaTen = await _db.Khoas.AsNoTracking()
                .Where(k => k.KhoaId == khoaId)
                .Select(k => k.TenKhoa)
                .FirstOrDefaultAsync() ?? "Khoa";
            foreach (var gvkId in gvkIds)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = gvkId,
                    TieuDe = "Bổ sung giảng viên mới",
                    NoiDung = $"Tài khoản Giảng viên {user.HoTen} vừa được kích hoạt thuộc {khoaTen}.",
                    LoaiThongBao = "Hệ thống",
                    LienKetId = giangVien.GiangVienId,
                    LoaiLienKet = "GiangVien",
                    DaDoc = false,
                    CreatedAt = DateTime.Now
                });
            }
            if (gvkIds.Count > 0) await _db.SaveChangesAsync();
        }

        var created = await _db.NguoiDungs.AsNoTracking()
            .Include(u => u.VaiTro)
            .Include(u => u.SinhVien).ThenInclude(s => s!.Khoa)
            .Include(u => u.GiangVien).ThenInclude(g => g!.Khoa)
            .Where(u => u.NguoiDungId == user.NguoiDungId)
            .Select(u => new AdminUserResponse
            {
                NguoiDungId = u.NguoiDungId,
                TenDangNhap = u.TenDangNhap,
                Email = u.Email,
                HoTen = u.HoTen,
                SoDienThoai = u.SoDienThoai,
                AvatarUrl = u.AvatarUrl,
                VaiTroId = u.VaiTroId,
                MaVaiTro = u.VaiTro != null ? u.VaiTro.MaVaiTro : string.Empty,
                TenVaiTro = u.VaiTro != null ? u.VaiTro.TenVaiTro : string.Empty,
                TrangThai = u.TrangThai,
                CreatedAt = u.CreatedAt,
                SinhVienId = u.SinhVien != null ? u.SinhVien.SinhVienId : null,
                MSSV = u.SinhVien != null ? u.SinhVien.MSSV : null,
                GiangVienId = u.GiangVien != null ? u.GiangVien.GiangVienId : null,
                MaGiangVien = u.GiangVien != null ? u.GiangVien.MaGiangVien : null,
                KhoaId = u.SinhVien != null ? u.SinhVien.KhoaId : (u.GiangVien != null ? u.GiangVien.KhoaId : null),
                TenKhoa = u.SinhVien != null && u.SinhVien.Khoa != null ? u.SinhVien.Khoa.TenKhoa : (u.GiangVien != null && u.GiangVien.Khoa != null ? u.GiangVien.Khoa.TenKhoa : null)
            })
            .FirstAsync();

        return CreatedAtAction(nameof(GetUsers), new { search = user.TenDangNhap }, created);
    }

    [Authorize(Roles = "ADMIN")]
    [HttpPut("users/{id:int}/toggle-status")]
    [HttpPut("users/{id:int}/status")]
    public async Task<IActionResult> ToggleUserStatus(int id, [FromBody] UpdateUserStatusRequest? request = null)
    {
        var user = await _db.NguoiDungs.FindAsync(id);
        if (user is null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        var targetStatus = request?.TrangThai ?? !user.TrangThai;
        var currentAdminClaim = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        if (int.TryParse(currentAdminClaim, out var currentAdminId)
            && user.NguoiDungId == currentAdminId
            && !targetStatus)
        {
            return BadRequest(new { message = "Bạn không thể tự khóa tài khoản quản trị đang đăng nhập." });
        }

        user.TrangThai = targetStatus;
        user.UpdatedAt = DateTime.Now;
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            userId = user.NguoiDungId,
            trangThai = user.TrangThai,
            message = user.TrangThai ? "Đã kích hoạt tài khoản." : "Đã khóa tài khoản."
        });
    }

    [Authorize(Roles = "ADMIN")]
    [HttpPut("users/{id:int}/reset-password")]
    public async Task<IActionResult> ResetPassword(int id, [FromBody] ResetUserPasswordRequest? request = null)
    {
        var user = await _db.NguoiDungs.FindAsync(id);
        if (user is null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }

        var newPassword = string.IsNullOrWhiteSpace(request?.NewPassword) ? "123456aA@" : request.NewPassword.Trim();
        user.MatKhauHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        user.UpdatedAt = DateTime.Now;
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            userId = user.NguoiDungId,
            newPassword,
            message = $"Đã đặt lại mật khẩu cho tài khoản '{user.TenDangNhap}' thành: {newPassword}"
        });
    }

    public sealed class ResetUserPasswordRequest
    {
        public string? NewPassword { get; set; }
    }

    [Authorize(Roles = "ADMIN")]
    [HttpPut("users/{id:int}/role")]
    public async Task<IActionResult> ChangeRole(int id, [FromBody] ChangeRoleRequest request)
    {
        var user = await _db.NguoiDungs.Include(u => u.VaiTro).FirstOrDefaultAsync(u => u.NguoiDungId == id);
        if (user is null) return NotFound(new { message = "Không tìm thấy người dùng." });

        VaiTro? targetRole = null;
        if (request.VaiTroId.HasValue)
        {
            targetRole = await _db.VaiTros.FindAsync(request.VaiTroId.Value);
        }
        else if (!string.IsNullOrWhiteSpace(request.MaVaiTro))
        {
            var code = request.MaVaiTro.Trim().ToUpperInvariant();
            targetRole = await _db.VaiTros.FirstOrDefaultAsync(v => v.MaVaiTro.ToUpper() == code);
        }

        if (targetRole is null)
        {
            return BadRequest(new { message = "Vai trò đích không tồn tại." });
        }

        user.VaiTroId = targetRole.VaiTroId;
        user.UpdatedAt = DateTime.Now;

        var defaultKhoa = await _db.Khoas.FirstOrDefaultAsync();
        var khoaId = request.KhoaId ?? defaultKhoa?.KhoaId ?? 1;

        if (targetRole.MaVaiTro.Equals("GIANGVIEN", StringComparison.OrdinalIgnoreCase))
        {
            var gv = await _db.GiangViens.FirstOrDefaultAsync(g => g.NguoiDungId == id);
            if (gv is null)
            {
                _db.GiangViens.Add(new GiangVien
                {
                    NguoiDungId = id,
                    MaGiangVien = "GV_" + user.TenDangNhap,
                    KhoaId = khoaId,
                    HocVi = "ThS.",
                    ChuyenMon = "Công nghệ phần mềm",
                    CreatedAt = DateTime.Now
                });
            }
        }
        else if (targetRole.MaVaiTro.Equals("SINHVIEN", StringComparison.OrdinalIgnoreCase))
        {
            var sv = await _db.SinhViens.FirstOrDefaultAsync(s => s.NguoiDungId == id);
            if (sv is null)
            {
                _db.SinhViens.Add(new SinhVien
                {
                    NguoiDungId = id,
                    MSSV = "SV_" + user.TenDangNhap,
                    KhoaId = khoaId,
                    CreatedAt = DateTime.Now
                });
            }
        }

        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            userId = user.NguoiDungId,
            vaiTroId = targetRole.VaiTroId,
            maVaiTro = targetRole.MaVaiTro,
            tenVaiTro = targetRole.TenVaiTro,
            message = $"Đã cập nhật vai trò người dùng thành '{targetRole.TenVaiTro}'."
        });
    }

    [Authorize(Roles = "ADMIN")]
    [HttpDelete("users/{id:int}")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        var user = await _db.NguoiDungs
            .Include(u => u.SinhVien)
            .Include(u => u.GiangVien)
            .FirstOrDefaultAsync(u => u.NguoiDungId == id);

        if (user is null) return NotFound(new { message = "Không tìm thấy người dùng." });

        bool hasConstraint = false;
        if (await _db.DotImports.AnyAsync(d => d.NguoiImportId == id)) hasConstraint = true;

        if (!hasConstraint && user.SinhVien != null)
        {
            var svId = user.SinhVien.SinhVienId;
            var inClass = await _db.SinhVienLopHocPhans.AnyAsync(s => s.SinhVienId == svId);
            var inGroup = await _db.ThanhVienNhoms.AnyAsync(t => t.SinhVienId == svId);
            var isLeader = await _db.NhomDoAns.AnyAsync(n => n.TruongNhomId == svId);
            var hasProposals = await _db.DeTaiDoAns.AnyAsync(d => d.SinhVienDeXuatId == svId);
            if (inClass || inGroup || isLeader || hasProposals) hasConstraint = true;
        }

        if (!hasConstraint && user.GiangVien != null)
        {
            var gvId = user.GiangVien.GiangVienId;
            var assigned = await _db.PhanCongGiangViens.AnyAsync(p => p.GiangVienId == gvId);
            var hasTopics = await _db.DeTaiDoAns.AnyAsync(d => d.GiangVienId == gvId);
            var hasApprovals = await _db.DangKyDeTais.AnyAsync(r => r.GiangVienDuyetId == gvId);
            if (assigned || hasTopics || hasApprovals) hasConstraint = true;
        }

        if (hasConstraint)
        {
            return BadRequest(new
            {
                message = "Không thể xóa tài khoản do người dùng đã có dữ liệu liên kết trong hệ thống (lớp học phần, nhóm đồ án, đề tài). Khuyến nghị sử dụng chức năng 'Khóa tài khoản' để bảo toàn tính toàn vẹn dữ liệu lịch sử."
            });
        }

        if (user.SinhVien != null) _db.SinhViens.Remove(user.SinhVien);
        if (user.GiangVien != null) _db.GiangViens.Remove(user.GiangVien);
        _db.NguoiDungs.Remove(user);
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            message = $"Đã xóa người dùng '{user.TenDangNhap}' thành công."
        });
    }

    [Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]
    [HttpPost("users/import")]
    [HttpPost("users/batch")]
    public async Task<IActionResult> ImportUsers([FromBody] ImportUsersRequest request)
    {
        if (request?.Users == null || request.Users.Count == 0)
        {
            return BadRequest(new ImportUsersResponse
            {
                Success = false,
                Message = "Cấu trúc file không đúng định dạng. Vui lòng tải file mẫu để kiểm tra."
            });
        }

        var roles = await _db.VaiTros.ToListAsync();
        var khoas = await _db.Khoas.AsNoTracking().ToListAsync();
        var defaultKhoa = khoas.FirstOrDefault(k => k.MaKhoa.Equals("CNTT", StringComparison.OrdinalIgnoreCase)) ?? khoas.FirstOrDefault();
        var defaultKhoaId = defaultKhoa?.KhoaId ?? 1;

        int successCount = 0;
        int failedCount = 0;
        var errors = new List<string>();

        foreach (var item in request.Users)
        {
            var username = item.TenDangNhap?.Trim();
            if (string.IsNullOrWhiteSpace(username))
            {
                // Dòng trống xen kẽ -> tự động bỏ qua an toàn
                continue;
            }

            if (username.Length > 100)
            {
                failedCount++;
                errors.Add($"Tài khoản '{username}': Tên đăng nhập tối đa 100 ký tự.");
                continue;
            }

            var email = item.Email?.Trim();
            if (string.IsNullOrWhiteSpace(email))
            {
                failedCount++;
                errors.Add($"Dòng '{username}': Thiếu email.");
                continue;
            }

            if (email.Length > 150 || !System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                failedCount++;
                errors.Add($"Dòng '{username}': Email '{email}' không hợp lệ.");
                continue;
            }

            var exists = await _db.NguoiDungs.AnyAsync(u => u.TenDangNhap == username || u.Email == email);
            if (exists)
            {
                failedCount++;
                errors.Add($"Tài khoản '{username}' hoặc email '{email}' đã tồn tại.");
                continue;
            }

            var rawRoleCode = !string.IsNullOrWhiteSpace(item.MaVaiTro) ? item.MaVaiTro : item.VaiTro;
            var roleCode = (string.IsNullOrWhiteSpace(rawRoleCode) ? "SINHVIEN" : rawRoleCode).Trim().ToUpperInvariant();
            var role = roles.FirstOrDefault(r => r.MaVaiTro.ToUpper() == roleCode || r.TenVaiTro.ToUpper().Contains(roleCode));
            if (role is null)
            {
                failedCount++;
                errors.Add($"Tài khoản '{username}': Vai trò '{roleCode}' không hợp lệ.");
                continue;
            }

            string? phone = null;
            if (!string.IsNullOrWhiteSpace(item.SoDienThoai))
            {
                var p = item.SoDienThoai.Trim();
                if (!System.Text.RegularExpressions.Regex.IsMatch(p, @"^[0-9]{10,11}$"))
                {
                    failedCount++;
                    errors.Add($"Tài khoản '{username}': Số điện thoại phải từ 10-11 chữ số.");
                    continue;
                }
                phone = p;
            }

            string? studentMssv = null;
            if (role.MaVaiTro.Equals("SINHVIEN", StringComparison.OrdinalIgnoreCase))
            {
                studentMssv = !string.IsNullOrWhiteSpace(item.MSSV) ? item.MSSV.Trim() : username;
                if (studentMssv.Length > 30)
                {
                    failedCount++;
                    errors.Add($"Tài khoản '{username}': MSSV tối đa 30 ký tự.");
                    continue;
                }

                var mssvExists = await _db.SinhViens.AnyAsync(s => s.MSSV == studentMssv);
                if (mssvExists)
                {
                    failedCount++;
                    errors.Add($"Tài khoản '{username}': MSSV '{studentMssv}' đã tồn tại trong hệ thống.");
                    continue;
                }
            }

            var user = new NguoiDung
            {
                TenDangNhap = username,
                MatKhauHash = BCrypt.Net.BCrypt.HashPassword(string.IsNullOrWhiteSpace(item.MatKhau) ? "123456aA@" : item.MatKhau.Trim()),
                Email = email,
                HoTen = string.IsNullOrWhiteSpace(item.HoTen) ? username : item.HoTen.Trim(),
                SoDienThoai = phone,
                VaiTroId = role.VaiTroId,
                TrangThai = item.TrangThai,
                CreatedAt = DateTime.Now
            };

            _db.NguoiDungs.Add(user);
            await _db.SaveChangesAsync();

            var targetKhoa = defaultKhoa;
            if (!string.IsNullOrWhiteSpace(item.Khoa))
            {
                var kw = item.Khoa.Trim();
                targetKhoa = khoas.FirstOrDefault(k =>
                    k.MaKhoa.Equals(kw, StringComparison.OrdinalIgnoreCase) ||
                    k.TenKhoa.Contains(kw, StringComparison.OrdinalIgnoreCase)) ?? defaultKhoa;
            }
            var targetKhoaId = targetKhoa?.KhoaId ?? defaultKhoaId;

            if (role.MaVaiTro.Equals("SINHVIEN", StringComparison.OrdinalIgnoreCase))
            {
                _db.SinhViens.Add(new SinhVien
                {
                    NguoiDungId = user.NguoiDungId,
                    MSSV = studentMssv!,
                    KhoaId = targetKhoaId,
                    CreatedAt = DateTime.Now
                });
            }
            else if (role != null && role.MaVaiTro.Equals("GIANGVIEN", StringComparison.OrdinalIgnoreCase))
            {
                var gv = new GiangVien
                {
                    NguoiDungId = user.NguoiDungId,
                    MaGiangVien = !string.IsNullOrWhiteSpace(item.MaGiangVien) ? item.MaGiangVien.Trim() : "GV_" + username,
                    KhoaId = targetKhoaId,
                    HocVi = !string.IsNullOrWhiteSpace(item.HocVi) ? item.HocVi.Trim() : "ThS.",
                    ChuyenMon = !string.IsNullOrWhiteSpace(item.ChuyenMon) ? item.ChuyenMon.Trim() : "Công nghệ phần mềm",
                    CreatedAt = DateTime.Now
                };
                _db.GiangViens.Add(gv);
                await _db.SaveChangesAsync();

                var gvkIds = await _db.NguoiDungs.AsNoTracking()
                    .Where(u => u.TrangThai && u.VaiTro != null && u.VaiTro.MaVaiTro == "GIAOVUKHOA")
                    .Select(u => u.NguoiDungId)
                    .ToListAsync();
                foreach (var gvkId in gvkIds)
                {
                    _db.ThongBaos.Add(new ThongBao
                    {
                        NguoiDungId = gvkId,
                        TieuDe = "Bổ sung giảng viên mới",
                        NoiDung = $"Tài khoản Giảng viên {user.HoTen} vừa được kích hoạt thuộc {targetKhoa?.TenKhoa ?? "Khoa"}.",
                        LoaiThongBao = "Hệ thống",
                        LienKetId = gv.GiangVienId,
                        LoaiLienKet = "GiangVien",
                        DaDoc = false,
                        CreatedAt = DateTime.Now
                    });
                }
            }

            await _db.SaveChangesAsync();
            successCount++;
        }

        return Ok(new ImportUsersResponse
        {
            Success = successCount > 0,
            Total = successCount + failedCount,
            SuccessCount = successCount,
            FailedCount = failedCount,
            Errors = errors,
            Message = $"Thành công: {successCount}, Thất bại: {failedCount}"
        });
    }
}
