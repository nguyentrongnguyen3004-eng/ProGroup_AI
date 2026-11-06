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
            .Include(n => n.ThanhVienNhoms)
            .Include(n => n.DangKyDeTais).ThenInclude(dk => dk.DeTai)
            .ToListAsync();

        var studentGroupMap = new Dictionary<int, (string TenNhom, string? TenDeTai)>();
        foreach (var g in groups)
        {
            var approvedTopic = g.DangKyDeTais
                .FirstOrDefault(dk => dk.TrangThai == "Đã duyệt" || dk.TrangThai == "Chờ duyệt")?.DeTai?.TenDeTai;
            foreach (var m in g.ThanhVienNhoms.Where(tv => tv.TrangThai == "Đã tham gia" || tv.TrangThai == "Trưởng nhóm"))
            {
                studentGroupMap[m.SinhVienId] = (g.TenNhom, approvedTopic);
            }
        }

        var enrolled = await _db.SinhVienLopHocPhans.AsNoTracking()
            .Where(s => s.LopHocPhanId == id && s.TrangThai && s.SinhVien != null)
            .Include(s => s.SinhVien).ThenInclude(sv => sv!.NguoiDung)
            .OrderBy(s => s.SinhVien!.MSSV)
            .ToListAsync();

        var result = enrolled.Select(s =>
        {
            var sv = s.SinhVien!;
            var hasGroup = studentGroupMap.TryGetValue(sv.SinhVienId, out var gInfo);
            return new
            {
                sinhVienId = sv.SinhVienId,
                mssv = sv.MSSV,
                hoTen = sv.NguoiDung?.HoTen ?? string.Empty,
                email = sv.NguoiDung?.Email ?? string.Empty,
                soDienThoai = sv.NguoiDung?.SoDienThoai ?? "0909123456",
                daCoNhom = hasGroup,
                tenNhom = hasGroup ? gInfo.TenNhom : "Chưa có nhóm",
                daCoDeTai = hasGroup && !string.IsNullOrEmpty(gInfo.TenDeTai),
                tenDeTai = hasGroup && !string.IsNullOrEmpty(gInfo.TenDeTai) ? gInfo.TenDeTai : "Chưa đăng ký đề tài"
            };
        }).ToList();

        return Ok(result);
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
            .Include(n => n.TruongNhom).ThenInclude(sv => sv!.NguoiDung)
            .Include(n => n.ThanhVienNhoms).ThenInclude(tv => tv.SinhVien).ThenInclude(sv => sv!.NguoiDung)
            .Include(n => n.DangKyDeTais).ThenInclude(dk => dk.DeTai)
            .OrderBy(n => n.TenNhom)
            .ToListAsync();

        var groupDtos = groups.Select(g =>
        {
            var activeReg = g.DangKyDeTais
                .OrderByDescending(dk => dk.TrangThai == "Đã duyệt" ? 2 : (dk.TrangThai == "Chờ duyệt" ? 1 : 0))
                .FirstOrDefault();
            var members = g.ThanhVienNhoms
                .Where(tv => tv.TrangThai == "Đã tham gia" || tv.TrangThai == "Trưởng nhóm")
                .Select(tv => new
                {
                    sinhVienId = tv.SinhVienId,
                    mssv = tv.SinhVien?.MSSV ?? string.Empty,
                    hoTen = tv.SinhVien?.NguoiDung?.HoTen ?? string.Empty,
                    vaiTro = tv.VaiTro
                }).ToList();

            return new
            {
                nhomId = g.NhomId,
                tenNhom = g.TenNhom,
                truongNhom = g.TruongNhom?.NguoiDung?.HoTen ?? "Trưởng nhóm",
                soThanhVien = members.Count,
                thanhViens = members,
                deTaiId = activeReg?.DeTaiId,
                tenDeTai = activeReg?.DeTai?.TenDeTai ?? "Chưa đăng ký đề tài",
                trangThaiDeTai = activeReg?.TrangThai ?? "Chưa đăng ký"
            };
        }).ToList();

        var studentsRes = await GetCourseStudents(id) as OkObjectResult;
        return Ok(new
        {
            lopHocPhanId = id,
            sinhViens = studentsRes?.Value ?? Array.Empty<object>(),
            nhoms = groupDtos
        });
    }

    [HttpGet("hoc-ky")]
    public async Task<IActionResult> GetSemesters()
    {
        var list = await _db.HocKys.AsNoTracking()
            .OrderByDescending(h => h.HocKyId)
            .Select(h => new
            {
                h.HocKyId,
                h.TenHocKy,
                h.NamHoc,
                h.NgayBatDau,
                h.NgayKetThuc,
                h.TrangThai
            })
            .ToListAsync();
        return Ok(list);
    }

    [Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]
    [HttpPut("hoc-ky/{id:int}/active")]
    public async Task<IActionResult> SetActiveSemester(int id)
    {
        var target = await _db.HocKys.FindAsync(id);
        if (target == null) return NotFound(new { message = "Không tìm thấy học kỳ." });

        var all = await _db.HocKys.ToListAsync();
        foreach (var hk in all)
        {
            hk.TrangThai = true; // giữ hiệu lực hiển thị các lớp học phần
        }
        target.TrangThai = true;
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            hocKyId = target.HocKyId,
            tenHocKy = $"{target.TenHocKy} ({target.NamHoc})",
            message = $"Đã thiết lập '{target.TenHocKy} - {target.NamHoc}' làm Học kỳ hiện tại áp dụng toàn trường."
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

        var hocKy = await _db.HocKys.OrderByDescending(k => k.HocKyId).FirstOrDefaultAsync();
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
}
