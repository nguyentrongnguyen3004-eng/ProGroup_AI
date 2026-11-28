using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.DTOs.Academic;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/lop-hoc-phan")]
[Authorize]
public sealed class LopHocPhanController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public LopHocPhanController(ApplicationDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<LopHocPhanResponse>>> GetAll([FromQuery] int? hocKyId, [FromQuery] int? khoaId)
    {
        var query = _db.LopHocPhans.AsNoTracking()
            .Where(x => x.TrangThai && x.HocPhan != null && x.HocPhan.TrangThai && x.HocKy != null);

        if (hocKyId.HasValue) query = query.Where(x => x.HocKyId == hocKyId.Value);
        if (khoaId.HasValue) query = query.Where(x => x.KhoaId == khoaId.Value);

        var rows = await query.OrderBy(x => x.MaLopHocPhan).Select(x => new LopHocPhanResponse
        {
            LopHocPhanId = x.LopHocPhanId,
            MaLopHocPhan = x.MaLopHocPhan,
            TenLopHocPhan = x.TenLopHocPhan,
            HocPhanId = x.HocPhanId,
            MaHocPhan = x.HocPhan!.MaHocPhan,
            TenHocPhan = x.HocPhan.TenHocPhan,
            SoTinChi = x.HocPhan.SoTinChi,
            HocKyId = x.HocKyId,
            TenHocKy = x.HocKy!.TenHocKy,
            NamHoc = x.HocKy.NamHoc,
            KhoaId = x.KhoaId,
            TenKhoa = x.Khoa == null ? string.Empty : x.Khoa.TenKhoa,
            SoLuongToiDa = x.SoLuongToiDa,
            SoSinhVien = x.SinhVienLopHocPhans.Count(s => s.TrangThai),
            SoLuongSinhVien = x.SinhVienLopHocPhans.Count(s => s.TrangThai),
            GiangVienId = x.PhanCongGiangViens
                .Where(p => p.TrangThai && p.GiangVien != null)
                .OrderByDescending(p => p.NgayPhanCong)
                .Select(p => (int?)p.GiangVienId)
                .FirstOrDefault(),
            MaGiangVien = x.PhanCongGiangViens
                .Where(p => p.TrangThai && p.GiangVien != null)
                .OrderByDescending(p => p.NgayPhanCong)
                .Select(p => p.GiangVien!.MaGiangVien)
                .FirstOrDefault(),
            GiangVienTen = x.PhanCongGiangViens
                .Where(p => p.TrangThai && p.GiangVien != null && p.GiangVien.NguoiDung != null)
                .OrderByDescending(p => p.NgayPhanCong)
                .Select(p => p.GiangVien!.NguoiDung!.HoTen)
                .FirstOrDefault() ?? "Chưa phân công",
            TrangThaiDotDangKy = x.DotDangKyDoAns
                .OrderByDescending(d => d.NgayBatDau)
                .Select(d => d.TrangThai)
                .FirstOrDefault() ?? "Chưa mở",
            TenDotDangKy = x.DotDangKyDoAns
                .OrderByDescending(d => d.NgayBatDau)
                .Select(d => d.TenDot)
                .FirstOrDefault(),
            SoNhom = x.DotDangKyDoAns.SelectMany(d => d.NhomDoAns).Count(n => n.TrangThai != "Đã hủy"),
            SoDeTai = x.DotDangKyDoAns.SelectMany(d => d.DeTaiDoAns).Count()
        }).ToListAsync();

        return Ok(rows);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<LopHocPhanResponse>> GetById(int id)
    {
        var row = await _db.LopHocPhans.AsNoTracking()
            .Where(x => x.LopHocPhanId == id && x.TrangThai && x.HocPhan != null && x.HocKy != null)
            .Select(x => new LopHocPhanResponse
            {
                LopHocPhanId = x.LopHocPhanId,
                MaLopHocPhan = x.MaLopHocPhan,
                TenLopHocPhan = x.TenLopHocPhan,
                HocPhanId = x.HocPhanId,
                MaHocPhan = x.HocPhan == null ? string.Empty : x.HocPhan.MaHocPhan,
                TenHocPhan = x.HocPhan == null ? string.Empty : x.HocPhan.TenHocPhan,
                SoTinChi = x.HocPhan == null ? 3 : x.HocPhan.SoTinChi,
                HocKyId = x.HocKyId,
                TenHocKy = x.HocKy == null ? string.Empty : x.HocKy.TenHocKy,
                NamHoc = x.HocKy == null ? string.Empty : x.HocKy.NamHoc,
                KhoaId = x.KhoaId,
                TenKhoa = x.Khoa == null ? string.Empty : x.Khoa.TenKhoa,
                SoLuongToiDa = x.SoLuongToiDa,
                SoSinhVien = x.SinhVienLopHocPhans.Count(s => s.TrangThai),
                SoLuongSinhVien = x.SinhVienLopHocPhans.Count(s => s.TrangThai),
                GiangVienId = x.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => (int?)p.GiangVienId)
                    .FirstOrDefault(),
                MaGiangVien = x.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => p.GiangVien!.MaGiangVien)
                    .FirstOrDefault(),
                GiangVienTen = x.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null && p.GiangVien.NguoiDung != null)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => p.GiangVien!.NguoiDung!.HoTen)
                    .FirstOrDefault() ?? "Chưa phân công",
                TrangThaiDotDangKy = x.DotDangKyDoAns
                    .OrderByDescending(d => d.NgayBatDau)
                    .Select(d => d.TrangThai)
                    .FirstOrDefault() ?? "Chưa mở",
                TenDotDangKy = x.DotDangKyDoAns
                    .OrderByDescending(d => d.NgayBatDau)
                    .Select(d => d.TenDot)
                    .FirstOrDefault(),
                SoNhom = x.DotDangKyDoAns.SelectMany(d => d.NhomDoAns).Count(n => n.TrangThai != "Đã hủy"),
                SoDeTai = x.DotDangKyDoAns.SelectMany(d => d.DeTaiDoAns).Count()
            }).FirstOrDefaultAsync();
        return row is null ? NotFound() : Ok(row);
    }

    [HttpGet("{id:int}/sinh-vien")]
    public async Task<IActionResult> GetCourseStudents(int id)
    {
        var periodIds = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(d => d.LopHocPhanId == id)
            .Select(d => d.DotDangKyId)
            .ToListAsync();

        var groups = await _db.NhomDoAns.AsNoTracking()
            .Where(n => periodIds.Contains(n.DotDangKyId) && n.TrangThai != "Đã hủy")
            .Select(n => new
            {
                n.TenNhom,
                Members = n.ThanhVienNhoms
                    .Where(tv => tv.TrangThai == "Đã tham gia" || tv.TrangThai == "Trưởng nhóm")
                    .Select(tv => tv.SinhVienId)
                    .ToList(),
                ApprovedTopic = n.DangKyDeTais
                    .Where(dk => dk.TrangThai == "Đã duyệt" || dk.TrangThai == "Chờ duyệt")
                    .Select(dk => dk.DeTai != null ? dk.DeTai.TenDeTai : null)
                    .FirstOrDefault()
            })
            .ToListAsync();

        var studentGroupMap = new Dictionary<int, (string TenNhom, string? TenDeTai)>();
        foreach (var g in groups)
        {
            foreach (var sid in g.Members)
            {
                studentGroupMap[sid] = (g.TenNhom, g.ApprovedTopic);
            }
        }

        var result = await BuildCourseStudentsListAsync(id, studentGroupMap);
        return Ok(result);
    }

    private async Task<List<object>> BuildCourseStudentsListAsync(int id, Dictionary<int, (string TenNhom, string? TenDeTai)> studentGroupMap)
    {
        var enrolled = await _db.SinhVienLopHocPhans.AsNoTracking()
            .Where(s => s.LopHocPhanId == id && s.TrangThai && s.SinhVien != null)
            .OrderBy(s => s.SinhVien!.MSSV)
            .Select(s => new
            {
                s.SinhVien!.SinhVienId,
                s.SinhVien.MSSV,
                HoTen = s.SinhVien.NguoiDung != null ? s.SinhVien.NguoiDung.HoTen : string.Empty,
                Email = s.SinhVien.NguoiDung != null ? s.SinhVien.NguoiDung.Email : string.Empty,
                SoDienThoai = s.SinhVien.NguoiDung != null ? s.SinhVien.NguoiDung.SoDienThoai : string.Empty
            })
            .ToListAsync();

        return enrolled.Select(sv =>
        {
            var hasGroup = studentGroupMap.TryGetValue(sv.SinhVienId, out var gInfo);
            return (object)new
            {
                sinhVienId = sv.SinhVienId,
                mssv = sv.MSSV,
                hoTen = sv.HoTen,
                email = sv.Email,
                soDienThoai = sv.SoDienThoai ?? string.Empty,
                daCoNhom = hasGroup,
                tenNhom = hasGroup ? gInfo.TenNhom : "Chưa có nhóm",
                daCoDeTai = hasGroup && !string.IsNullOrEmpty(gInfo.TenDeTai),
                tenDeTai = hasGroup && !string.IsNullOrEmpty(gInfo.TenDeTai) ? gInfo.TenDeTai : "Chưa đăng ký đề tài"
            };
        }).ToList();
    }

    [HttpGet("{id:int}/chi-tiet")]
    public async Task<IActionResult> GetCourseDetails(int id)
    {
        var periodIds = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(d => d.LopHocPhanId == id)
            .Select(d => d.DotDangKyId)
            .ToListAsync();

        var groups = await _db.NhomDoAns.AsNoTracking()
            .Where(n => periodIds.Contains(n.DotDangKyId) && n.TrangThai != "Đã hủy")
            .OrderBy(n => n.TenNhom)
            .Select(n => new
            {
                n.NhomId,
                n.TenNhom,
                TruongNhom = n.TruongNhom != null && n.TruongNhom.NguoiDung != null ? n.TruongNhom.NguoiDung.HoTen : "Trưởng nhóm",
                Members = n.ThanhVienNhoms
                    .Where(tv => tv.TrangThai == "Đã tham gia" || tv.TrangThai == "Trưởng nhóm")
                    .Select(tv => new
                    {
                        sinhVienId = tv.SinhVienId,
                        mssv = tv.SinhVien != null ? tv.SinhVien.MSSV : string.Empty,
                        hoTen = tv.SinhVien != null && tv.SinhVien.NguoiDung != null ? tv.SinhVien.NguoiDung.HoTen : string.Empty,
                        vaiTro = tv.VaiTro
                    })
                    .ToList(),
                ActiveReg = n.DangKyDeTais
                    .OrderByDescending(dk => dk.TrangThai == "Đã duyệt" ? 2 : (dk.TrangThai == "Chờ duyệt" ? 1 : 0))
                    .Select(dk => new
                    {
                        dk.DeTaiId,
                        TenDeTai = dk.DeTai != null ? dk.DeTai.TenDeTai : null,
                        dk.TrangThai
                    })
                    .FirstOrDefault()
            })
            .ToListAsync();

        var studentGroupMap = new Dictionary<int, (string TenNhom, string? TenDeTai)>();
        var groupDtos = groups.Select(g =>
        {
            var approvedTopic = (g.ActiveReg != null && (g.ActiveReg.TrangThai == "Đã duyệt" || g.ActiveReg.TrangThai == "Chờ duyệt"))
                ? g.ActiveReg.TenDeTai
                : null;
            foreach (var m in g.Members)
            {
                studentGroupMap[m.sinhVienId] = (g.TenNhom, approvedTopic);
            }

            return new
            {
                nhomId = g.NhomId,
                tenNhom = g.TenNhom,
                truongNhom = g.TruongNhom,
                soThanhVien = g.Members.Count,
                thanhViens = g.Members,
                deTaiId = g.ActiveReg?.DeTaiId,
                tenDeTai = g.ActiveReg?.TenDeTai ?? "Chưa đăng ký đề tài",
                trangThaiDeTai = g.ActiveReg?.TrangThai ?? "Chưa đăng ký"
            };
        }).ToList();

        var students = await BuildCourseStudentsListAsync(id, studentGroupMap);
        return Ok(new
        {
            lopHocPhanId = id,
            sinhViens = students,
            nhoms = groupDtos
        });
    }

    [HttpGet("hoc-ky")]
    [HttpGet("/api/semesters")]
    public async Task<IActionResult> GetSemesters()
    {
        var list = await _db.HocKys.AsNoTracking()
            .OrderByDescending(h => h.HocKyId)
            .Select(h => new
            {
                h.HocKyId,
                h.TenHocKy,
                h.NamHoc,
                TenDayDu = $"{h.TenHocKy} ({h.NamHoc})",
                h.NgayBatDau,
                h.NgayKetThuc,
                h.TrangThai,
                TrangThaiText = h.TrangThai ? "Đang mở" : "Đã đóng"
            })
            .ToListAsync();
        return Ok(list);
    }

    [Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]
    [HttpPut("hoc-ky/{id:int}/active")]
    [HttpPut("/api/semesters/{id:int}/active")]
    public async Task<IActionResult> SetActiveSemester(int id)
    {
        var target = await _db.HocKys.FindAsync(id);
        if (target == null) return NotFound(new { message = "Không tìm thấy học kỳ." });

        var all = await _db.HocKys.ToListAsync();
        foreach (var hk in all)
        {
            hk.TrangThai = (hk.HocKyId == id);
        }
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            hocKyId = target.HocKyId,
            tenHocKy = $"{target.TenHocKy} ({target.NamHoc})",
            message = $"Đã thiết lập '{target.TenHocKy} ({target.NamHoc})' làm Học kỳ hiện tại áp dụng toàn trường."
        });
    }

    [Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateClassRequest request)
    {
        var code = request.MaLopHocPhan?.Trim() ?? string.Empty;
        if (string.IsNullOrEmpty(code)) return BadRequest(new { message = "Mã lớp học phần không được để trống." });

        if (await _db.LopHocPhans.AnyAsync(x => x.MaLopHocPhan == code))
        {
            return Conflict(new { message = "Mã lớp học phần đã tồn tại." });
        }

        var hocPhanCode = request.MaHocPhan?.Trim() ?? "HP001";
        var hocPhan = await _db.HocPhans.FirstOrDefaultAsync(h => h.MaHocPhan == hocPhanCode);
        if (hocPhan == null)
        {
            hocPhan = new HocPhan
            {
                MaHocPhan = hocPhanCode,
                TenHocPhan = !string.IsNullOrWhiteSpace(request.TenHocPhan) ? request.TenHocPhan.Trim() : hocPhanCode,
                SoTinChi = request.SoTinChi ?? 3,
                TrangThai = true
            };
            _db.HocPhans.Add(hocPhan);
            await _db.SaveChangesAsync();
        }

        HocKy? hocKy = null;
        if (request.HocKyId.HasValue)
        {
            hocKy = await _db.HocKys.FirstOrDefaultAsync(k => k.HocKyId == request.HocKyId.Value);
        }
        if (hocKy == null && !string.IsNullOrWhiteSpace(request.TenHocKy))
        {
            var tenHk = request.TenHocKy.Trim();
            var namHoc = request.NamHoc?.Trim();
            hocKy = await _db.HocKys.FirstOrDefaultAsync(k =>
                k.TenHocKy == tenHk && (string.IsNullOrEmpty(namHoc) || k.NamHoc == namHoc));
        }
        hocKy ??= await _db.HocKys.Where(k => k.TrangThai).OrderByDescending(k => k.HocKyId).FirstOrDefaultAsync()
            ?? await _db.HocKys.OrderByDescending(k => k.HocKyId).FirstOrDefaultAsync();
        if (hocKy == null)
        {
            hocKy = new HocKy
            {
                TenHocKy = request.TenHocKy ?? "Học kỳ 1",
                NamHoc = request.NamHoc ?? "2026-2027",
                NgayBatDau = DateTime.Today,
                NgayKetThuc = DateTime.Today.AddMonths(4),
                TrangThai = true
            };
            _db.HocKys.Add(hocKy);
            await _db.SaveChangesAsync();
        }

        var defaultKhoa = await _db.Khoas.FirstOrDefaultAsync(k => k.MaKhoa == "CNTT") ?? await _db.Khoas.FirstOrDefaultAsync();
        var khoaId = request.KhoaId ?? defaultKhoa?.KhoaId ?? 2;

        var lopHocPhan = new LopHocPhan
        {
            MaLopHocPhan = code,
            TenLopHocPhan = !string.IsNullOrWhiteSpace(request.TenLopHocPhan) ? request.TenLopHocPhan.Trim() : hocPhan.TenHocPhan,
            HocPhanId = hocPhan.HocPhanId,
            HocKyId = hocKy.HocKyId,
            KhoaId = khoaId,
            SoLuongToiDa = request.SoLuongToiDa ?? 50,
            TrangThai = true
        };

        _db.LopHocPhans.Add(lopHocPhan);
        await _db.SaveChangesAsync();

        return Ok(new { success = true, lopHocPhanId = lopHocPhan.LopHocPhanId, message = "Tạo lớp học phần thành công." });
    }

    [Authorize(Roles = "ADMIN,GIAOVUKHOA,PHONGDAOTAO")]
    [HttpPost("{id:int}/students")]
    public async Task<IActionResult> EnrollStudents(int id, [FromBody] List<int> studentIds)
    {
        var lhp = await _db.LopHocPhans.FindAsync(id);
        if (lhp == null) return NotFound(new { message = "Lớp học phần không tồn tại." });

        int added = 0;
        foreach (var sid in studentIds)
        {
            var exists = await _db.SinhVienLopHocPhans.AnyAsync(s => s.LopHocPhanId == id && s.SinhVienId == sid);
            if (!exists)
            {
                _db.SinhVienLopHocPhans.Add(new SinhVienLopHocPhan
                {
                    LopHocPhanId = id,
                    SinhVienId = sid,
                    TrangThai = true,
                    NgayThamGia = DateTime.Now
                });
                added++;
            }
        }
        await _db.SaveChangesAsync();
        return Ok(new { success = true, addedCount = added, message = $"Đã ghi danh {studentIds.Count} sinh viên vào lớp học phần." });
    }

    [Authorize(Roles = "GIANGVIEN,ADMIN,GIAOVUKHOA")]
    [HttpPut("{id:int}/cau-hinh")]
    public async Task<IActionResult> UpdateCourseSettings(int id, [FromBody] UpdateCourseSettingsRequest request)
    {
        var course = await _db.LopHocPhans
            .Include(l => l.DotDangKyDoAns)
            .Include(l => l.HocKy)
            .FirstOrDefaultAsync(l => l.LopHocPhanId == id);

        if (course == null) return NotFound(new { message = "Không tìm thấy lớp học phần." });

        if (request.MinMembers.HasValue && request.MinMembers.Value <= 0)
            return BadRequest(new { message = "Số thành viên tối thiểu phải lớn hơn 0." });
        if (request.MinMembers.HasValue && request.MaxMembers.HasValue && request.MaxMembers.Value < request.MinMembers.Value)
            return BadRequest(new { message = "Số thành viên tối đa phải lớn hơn hoặc bằng số tối thiểu." });

        if (request.SoLuongToiDa.HasValue && request.SoLuongToiDa.Value > 0)
        {
            course.SoLuongToiDa = request.SoLuongToiDa.Value;
        }

        var groupStart = TryParseDate(request.GroupRegistrationStart);
        var groupEnd = TryParseDate(request.GroupRegistrationEnd);
        var topicStart = TryParseDate(request.TopicRegistrationStart);
        var topicEnd = TryParseDate(request.TopicRegistrationEnd);

        var period = course.DotDangKyDoAns.OrderByDescending(d => d.DotDangKyId).FirstOrDefault();
        var isNewPeriod = period == null;
        var previousStatus = period?.TrangThai;

        var effectiveStart = groupStart ?? topicStart ?? period?.NgayBatDau ?? DateTime.Today;
        var effectiveEnd = topicEnd ?? period?.NgayKetThuc ?? DateTime.Today.AddMonths(1);

        // Chỉ chặn ngày quá khứ khi thực sự thay đổi ngày bắt đầu
        var startChanged = isNewPeriod || (period != null && effectiveStart.Date != period.NgayBatDau.Date);
        var scheduleError = DotDangKyController.ValidateSchedule(
            effectiveStart, effectiveEnd, groupEnd, topicStart, course.HocKy?.NgayKetThuc,
            allowPastStart: !startChanged);
        if (scheduleError is not null) return BadRequest(new { message = scheduleError });

        if (period == null)
        {
            period = new DotDangKyDoAn
            {
                LopHocPhanId = id,
                TenDot = $"Đợt đăng ký - {course.TenLopHocPhan ?? course.MaLopHocPhan}",
                NgayBatDau = effectiveStart,
                NgayKetThuc = effectiveEnd,
                MinMembers = request.MinMembers ?? 2,
                MaxMembers = request.MaxMembers ?? 5,
                TrangThai = "Đang mở",
                CreatedAt = DateTime.Now
            };
            _db.DotDangKyDoAns.Add(period);
        }
        else
        {
            var newMin = request.MinMembers ?? period.MinMembers;
            var newMax = request.MaxMembers ?? period.MaxMembers;
            if (newMax < newMin)
                return BadRequest(new { message = "Số thành viên tối đa phải lớn hơn hoặc bằng số tối thiểu." });
            period.MinMembers = newMin;
            period.MaxMembers = newMax;
            period.NgayBatDau = effectiveStart;
            period.NgayKetThuc = effectiveEnd;
            if (period.NgayKetThuc <= period.NgayBatDau)
                return BadRequest(new { message = "Ngày kết thúc phải sau ngày bắt đầu." });
            period.TrangThai = "Đang mở";
        }

        await _db.SaveChangesAsync();

        // Gửi thông báo cho PHONGDAOTAO + GIAOVUKHOA khi đợt mới được tạo hoặc vừa chuyển sang Đang mở
        if (period.TrangThai == "Đang mở" && (isNewPeriod || previousStatus != "Đang mở"))
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
            if (staffUserIds.Count > 0) await _db.SaveChangesAsync();
        }

        return Ok(new
        {
            success = true,
            lopHocPhanId = course.LopHocPhanId,
            minMembers = period.MinMembers,
            maxMembers = period.MaxMembers,
            topicRegistrationStart = period.NgayBatDau.ToString("yyyy-MM-dd"),
            topicRegistrationEnd = period.NgayKetThuc.ToString("yyyy-MM-dd"),
            message = "Đã lưu cấu hình lớp học phần thành công vào cơ sở dữ liệu."
        });
    }

    private static DateTime? TryParseDate(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return null;
        var trimmed = raw.Trim();
        if (DateTime.TryParseExact(trimmed, new[] { "dd/MM/yyyy", "d/M/yyyy", "yyyy-MM-dd", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-ddTHH:mm:ss.fffZ" },
            System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out var parsed))
        {
            return parsed;
        }
        return DateTime.TryParse(trimmed, out var fallback) ? fallback : null;
    }
}

public class UpdateCourseSettingsRequest
{
    public int? MinMembers { get; set; }
    public int? MaxMembers { get; set; }
    public string? GroupRegistrationStart { get; set; }
    public string? GroupRegistrationEnd { get; set; }
    public string? TopicRegistrationStart { get; set; }
    public string? TopicRegistrationEnd { get; set; }
    public int? SoLuongToiDa { get; set; }
}
