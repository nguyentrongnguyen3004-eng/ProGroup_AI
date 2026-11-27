using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
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

    private static string ResolveKhoaHoc(string? mssv, DateTime? ngaySinh)
    {
        if (!string.IsNullOrWhiteSpace(mssv))
        {
            var m = mssv.Trim();
            if (m.Length >= 2 && char.IsDigit(m[0]) && char.IsDigit(m[1]))
            {
                return $"K{m[..2]}";
            }
            var digitMatch = Regex.Match(m, @"(?:^|\D)(\d{2})\d+");
            if (digitMatch.Success && int.TryParse(digitMatch.Groups[1].Value, out var prefixNum) && prefixNum is >= 18 and <= 30)
            {
                return $"K{prefixNum}";
            }
        }

        if (ngaySinh.HasValue)
        {
            var cohortNum = ngaySinh.Value.Year - 1982;
            if (cohortNum is >= 18 and <= 30)
            {
                return $"K{cohortNum}";
            }
        }

        return "K21";
    }

    private static string ResolveLopNienChe(string? mssv, DateTime? ngaySinh, string? maKhoa)
    {
        var khoaCode = string.IsNullOrWhiteSpace(maKhoa) ? "CNTT" : maKhoa.Trim().ToUpperInvariant();
        var khoaHoc = ResolveKhoaHoc(mssv, ngaySinh);
        return $"{khoaCode}_{khoaHoc}";
    }

    private static string NormalizeVietnamese(string? input)
    {
        if (string.IsNullOrWhiteSpace(input)) return string.Empty;
        var formD = input.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(formD.Length);
        foreach (var ch in formD)
        {
            var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
            if (cat != UnicodeCategory.NonSpacingMark)
            {
                sb.Append(ch == 'đ' ? 'd' : ch);
            }
        }
        return sb.ToString().Normalize(NormalizationForm.FormC);
    }

    private static bool IsMeaningfulResearchField(string? chuyenMon)
    {
        var norm = NormalizeVietnamese(chuyenMon);
        if (string.IsNullOrWhiteSpace(norm)) return false;
        return norm is not ("-" or "—" or "n/a" or "na" or "chua cap nhat" or "khong" or "none");
    }

    private static bool IsLecturerProposedTopic(string? nguonDeTai, int? giangVienId, int? sinhVienDeXuatId)
    {
        if (sinhVienDeXuatId.HasValue) return false;
        if (!string.IsNullOrWhiteSpace(nguonDeTai))
        {
            var src = nguonDeTai.Trim().ToLowerInvariant();
            if (src.Contains("sinh viên") || src.Contains("sinhvien") || src.Contains("aide"))
                return false;
            if (src.Contains("giảng viên") || src.Contains("giangvien"))
                return true;
        }
        return giangVienId.HasValue;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // THỐNG KÊ TỔNG QUAN GIÁO VỤ (số liệu thực tế từ CSDL)
    // ─────────────────────────────────────────────────────────────────────────
    [HttpGet("overview")]
    public async Task<IActionResult> GetOverview()
    {
        var activeGroups = await _db.NhomDoAns.AsNoTracking()
            .Where(g => g.TrangThai != "Đã hủy")
            .Select(g => new
            {
                g.NhomId,
                g.TenNhom,
                g.TrangThai,
                g.TruongNhomId,
                LopHocPhanId = g.DotDangKy != null ? g.DotDangKy.LopHocPhanId : 0,
                MaLop = g.DotDangKy != null && g.DotDangKy.LopHocPhan != null
                    ? g.DotDangKy.LopHocPhan.MaLopHocPhan : string.Empty,
                TenLop = g.DotDangKy != null && g.DotDangKy.LopHocPhan != null
                    ? (g.DotDangKy.LopHocPhan.TenLopHocPhan ?? g.DotDangKy.LopHocPhan.MaLopHocPhan) : string.Empty,
                TruongNhom = g.TruongNhom != null && g.TruongNhom.NguoiDung != null
                    ? g.TruongNhom.NguoiDung.HoTen : string.Empty,
                Email = g.TruongNhom != null && g.TruongNhom.NguoiDung != null
                    ? g.TruongNhom.NguoiDung.Email : string.Empty,
                MemberIds = g.ThanhVienNhoms
                    .Where(m => m.TrangThai == "Đã tham gia" || m.TrangThai == "Trưởng nhóm")
                    .Select(m => m.SinhVienId)
                    .ToList(),
                HasReport = g.BaoCaoTienDos.Any(),
                Regs = g.DangKyDeTais.Select(r => new
                {
                    r.TrangThai,
                    TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : null
                }).ToList()
            })
            .ToListAsync();

        var totalGroups = activeGroups.Count;
        var approvedGroups = activeGroups.Count(g => g.Regs.Any(r => r.TrangThai == "Đã duyệt"));
        var pendingGroups = activeGroups.Count(g =>
            !g.Regs.Any(r => r.TrangThai == "Đã duyệt") &&
            g.Regs.Any(r => r.TrangThai == "Chờ duyệt"));
        var groupsWithoutTopic = activeGroups.Count(g =>
            !g.Regs.Any(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt"));

        // Thống kê đề tài: GV đề xuất vs SV đề xuất
        var allTopics = await _db.DeTaiDoAns.AsNoTracking()
            .Select(t => new
            {
                t.NguonDeTai,
                t.GiangVienId,
                t.SinhVienDeXuatId,
                t.TrangThaiDuyet
            })
            .ToListAsync();

        var totalTopics = allTopics.Count;
        var gvTopics = allTopics.Count(t => IsLecturerProposedTopic(t.NguonDeTai, t.GiangVienId, t.SinhVienDeXuatId));
        var svTopics = totalTopics - gvTopics;
        var gvPercent = totalTopics > 0 ? Math.Round(gvTopics * 100.0 / totalTopics, 1) : 0.0;
        var svPercent = totalTopics > 0 ? Math.Round(100.0 - gvPercent, 1) : 0.0;

        // Tỷ lệ duyệt thành công thực tế (dựa trên DangKyDeTais hoạt động hoặc đề tài)
        var allRegs = await _db.DangKyDeTais.AsNoTracking()
            .Select(r => new { r.TrangThai })
            .ToListAsync();
        var activeRegs = allRegs.Where(r => r.TrangThai != "Đã hủy").ToList();
        var approvedRegCount = activeRegs.Count(r => r.TrangThai == "Đã duyệt");
        var pendingRegCount = activeRegs.Count(r => r.TrangThai == "Chờ duyệt");
        var rejectedRegCount = activeRegs.Count(r => r.TrangThai == "Từ chối");
        var approvedTopicsCount = allTopics.Count(t => t.TrangThaiDuyet == "Đã duyệt");

        var approveRate = activeRegs.Count > 0
            ? Math.Round(approvedRegCount * 100.0 / activeRegs.Count, 1)
            : (totalTopics > 0 ? Math.Round(approvedTopicsCount * 100.0 / totalTopics, 1) : 0.0);

        // Sinh viên chưa đăng ký nhóm & chưa có đề tài
        var allActiveStudents = await _db.SinhViens.AsNoTracking()
            .Where(s => s.NguoiDung != null && s.NguoiDung.TrangThai)
            .Select(s => s.SinhVienId)
            .ToListAsync();

        var studentsInAnyGroup = new HashSet<int>();
        var studentsWithTopic = new HashSet<int>();
        foreach (var g in activeGroups)
        {
            var groupMembers = new HashSet<int>(g.MemberIds) { g.TruongNhomId };
            foreach (var sid in groupMembers)
            {
                studentsInAnyGroup.Add(sid);
            }
            if (g.Regs.Any(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt"))
            {
                foreach (var sid in groupMembers)
                {
                    studentsWithTopic.Add(sid);
                }
            }
        }

        var svNotInGroup = allActiveStudents.Count(sid => !studentsInAnyGroup.Contains(sid));
        var svWithoutTopic = allActiveStudents.Count(sid => !studentsWithTopic.Contains(sid));

        // Danh sách nhóm chưa nộp báo cáo tiến độ
        var groupsNotSubmitted = activeGroups
            .Where(g => !g.HasReport)
            .Select(g =>
            {
                var members = new HashSet<int>(g.MemberIds) { g.TruongNhomId };
                var topic = g.Regs.FirstOrDefault(r => r.TrangThai == "Đã duyệt")
                    ?? g.Regs.FirstOrDefault(r => r.TrangThai == "Chờ duyệt");
                return new
                {
                    g.NhomId,
                    g.TenNhom,
                    g.LopHocPhanId,
                    g.MaLop,
                    g.TenLop,
                    g.TruongNhom,
                    g.Email,
                    ThanhVienCount = members.Count,
                    TenDeTai = topic?.TenDeTai ?? "Chưa có đề tài",
                    TrangThaiDeTai = topic?.TrangThai ?? "Chưa đăng ký"
                };
            })
            .OrderBy(g => g.MaLop)
            .ThenBy(g => g.TenNhom)
            .ToList();

        // Thống kê theo từng lớp học phần (môn học)
        var courses = await _db.LopHocPhans.AsNoTracking()
            .Where(c => c.TrangThai)
            .OrderBy(c => c.MaLopHocPhan)
            .Select(c => new
            {
                c.LopHocPhanId,
                c.MaLopHocPhan,
                c.TenLopHocPhan,
                TenHocPhan = c.HocPhan != null ? c.HocPhan.TenHocPhan : string.Empty,
                TenKhoa = c.Khoa != null ? c.Khoa.TenKhoa : string.Empty,
                MaKhoa = c.Khoa != null ? c.Khoa.MaKhoa : string.Empty,
                EnrolledStudentIds = c.SinhVienLopHocPhans
                    .Where(s => s.TrangThai)
                    .Select(s => s.SinhVienId)
                    .ToList(),
                HasLecturer = c.PhanCongGiangViens.Any(p => p.TrangThai),
                GiangVienTen = c.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null && p.GiangVien.NguoiDung != null)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => p.GiangVien!.NguoiDung!.HoTen)
                    .FirstOrDefault() ?? "Chưa phân công"
            })
            .ToListAsync();

        var courseStats = courses.Select(c =>
        {
            var classGroups = activeGroups.Where(g => g.LopHocPhanId == c.LopHocPhanId).ToList();
            var classApproved = classGroups.Count(g => g.Regs.Any(r => r.TrangThai == "Đã duyệt"));
            var classPending = classGroups.Count(g =>
                !g.Regs.Any(r => r.TrangThai == "Đã duyệt") &&
                g.Regs.Any(r => r.TrangThai == "Chờ duyệt"));
            var classNoTopic = classGroups.Count(g =>
                !g.Regs.Any(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt"));

            var classStudentsInGroup = new HashSet<int>();
            foreach (var g in classGroups)
            {
                classStudentsInGroup.Add(g.TruongNhomId);
                foreach (var mid in g.MemberIds) classStudentsInGroup.Add(mid);
            }
            var svChuaCoNhom = c.EnrolledStudentIds.Count(sid => !classStudentsInGroup.Contains(sid));

            return new
            {
                c.LopHocPhanId,
                c.MaLopHocPhan,
                c.TenLopHocPhan,
                c.TenHocPhan,
                c.TenKhoa,
                c.MaKhoa,
                c.HasLecturer,
                c.GiangVienTen,
                SoSinhVien = c.EnrolledStudentIds.Count,
                SoNhom = classGroups.Count,
                SoNhomDaDuyet = classApproved,
                SoNhomChoDuyet = classPending,
                SoNhomChuaCoDeTai = classNoTopic,
                SoSinhVienChuaCoNhom = svChuaCoNhom
            };
        }).ToList();

        return Ok(new
        {
            totalClasses = courses.Count,
            assignedClasses = courses.Count(c => c.HasLecturer),
            unassignedClasses = courses.Count(c => !c.HasLecturer),
            totalStudents = allActiveStudents.Count,
            totalLecturers = await _db.GiangViens.CountAsync(g => g.NguoiDung != null && g.NguoiDung.TrangThai),
            totalGroups,
            approvedGroups,
            pendingGroups,
            groupsWithoutTopic,
            svNotInGroup,
            svWithoutTopic,
            totalTopics,
            approvedTopics = approvedTopicsCount,
            gvTopics,
            svTopics,
            gvPercent,
            svPercent,
            totalRegs = activeRegs.Count,
            approvedRegs = approvedRegCount,
            pendingRegs = pendingRegCount,
            rejectedRegs = rejectedRegCount,
            approveRate,
            groupsNotSubmitted,
            courseStats
        });
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DANH SÁCH SINH VIÊN TRONG LỚP HỌC PHẦN (đầy đủ thông tin + nhóm/đề tài)
    // ─────────────────────────────────────────────────────────────────────────
    [HttpGet("class-students")]
    public async Task<IActionResult> GetClassStudents([FromQuery] int lopHocPhanId)
    {
        var rawStudents = await _db.SinhVienLopHocPhans
            .AsNoTracking()
            .Where(sl => sl.LopHocPhanId == lopHocPhanId && sl.TrangThai && sl.SinhVien != null)
            .Select(sl => new
            {
                sl.SinhVien!.SinhVienId,
                sl.SinhVien.MSSV,
                sl.SinhVien.NgaySinh,
                MaKhoa = sl.SinhVien.Khoa != null ? sl.SinhVien.Khoa.MaKhoa : "CNTT",
                TenKhoa = sl.SinhVien.Khoa != null ? sl.SinhVien.Khoa.TenKhoa : string.Empty,
                HoTen = sl.SinhVien.NguoiDung != null ? sl.SinhVien.NguoiDung.HoTen : string.Empty,
                Email = sl.SinhVien.NguoiDung != null ? sl.SinhVien.NguoiDung.Email : string.Empty,
                SoDienThoai = sl.SinhVien.NguoiDung != null ? sl.SinhVien.NguoiDung.SoDienThoai : null,
                IsActive = sl.SinhVien.NguoiDung != null && sl.SinhVien.NguoiDung.TrangThai
            })
            .OrderBy(s => s.MSSV)
            .ToListAsync();

        var classGroups = await _db.NhomDoAns.AsNoTracking()
            .Where(g => g.DotDangKy != null && g.DotDangKy.LopHocPhanId == lopHocPhanId && g.TrangThai != "Đã hủy")
            .Select(g => new
            {
                g.NhomId,
                g.TenNhom,
                g.TruongNhomId,
                MemberIds = g.ThanhVienNhoms
                    .Where(m => m.TrangThai == "Đã tham gia" || m.TrangThai == "Trưởng nhóm")
                    .Select(m => m.SinhVienId)
                    .ToList(),
                ActiveTopic = g.DangKyDeTais
                    .Where(r => r.TrangThai != "Đã hủy")
                    .OrderByDescending(r => r.TrangThai == "Đã duyệt" ? 2 : (r.TrangThai == "Chờ duyệt" ? 1 : 0))
                    .Select(r => new
                    {
                        TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : null,
                        r.TrangThai
                    })
                    .FirstOrDefault()
            })
            .ToListAsync();

        var studentGroupMap = new Dictionary<int, (int NhomId, string TenNhom, string? TenDeTai, string TrangThaiDeTai)>();
        foreach (var g in classGroups)
        {
            var memberIds = new HashSet<int>(g.MemberIds) { g.TruongNhomId };
            foreach (var sid in memberIds)
            {
                studentGroupMap[sid] = (
                    g.NhomId,
                    g.TenNhom,
                    g.ActiveTopic?.TenDeTai,
                    g.ActiveTopic?.TrangThai ?? "Chưa đăng ký"
                );
            }
        }

        // Bổ sung các SV thuộc nhóm trong lớp nhưng chưa có bản ghi SinhVienLopHocPhan
        var enrolledIds = rawStudents.Select(s => s.SinhVienId).ToHashSet();
        var missingGroupStudentIds = studentGroupMap.Keys.Where(id => !enrolledIds.Contains(id)).ToList();
        if (missingGroupStudentIds.Count > 0)
        {
            var extraStudents = await _db.SinhViens.AsNoTracking()
                .Where(sv => missingGroupStudentIds.Contains(sv.SinhVienId))
                .Select(sv => new
                {
                    sv.SinhVienId,
                    sv.MSSV,
                    sv.NgaySinh,
                    MaKhoa = sv.Khoa != null ? sv.Khoa.MaKhoa : "CNTT",
                    TenKhoa = sv.Khoa != null ? sv.Khoa.TenKhoa : string.Empty,
                    HoTen = sv.NguoiDung != null ? sv.NguoiDung.HoTen : string.Empty,
                    Email = sv.NguoiDung != null ? sv.NguoiDung.Email : string.Empty,
                    SoDienThoai = sv.NguoiDung != null ? sv.NguoiDung.SoDienThoai : null,
                    IsActive = sv.NguoiDung != null && sv.NguoiDung.TrangThai
                })
                .ToListAsync();
            rawStudents.AddRange(extraStudents);
            rawStudents = rawStudents.OrderBy(s => s.MSSV).ToList();
        }

        var students = rawStudents.Select(s =>
        {
            var hasGroup = studentGroupMap.TryGetValue(s.SinhVienId, out var gInfo);
            var khoaHoc = ResolveKhoaHoc(s.MSSV, s.NgaySinh);
            var lopNienChe = ResolveLopNienChe(s.MSSV, s.NgaySinh, s.MaKhoa);
            var topicPendingOrApproved = hasGroup &&
                !string.IsNullOrWhiteSpace(gInfo.TenDeTai) &&
                (gInfo.TrangThaiDeTai == "Đã duyệt" || gInfo.TrangThaiDeTai == "Chờ duyệt");
            var tenDeTaiDisplay = !hasGroup || string.IsNullOrWhiteSpace(gInfo.TenDeTai)
                ? "Chưa đăng ký đề tài"
                : (gInfo.TrangThaiDeTai == "Từ chối" ? $"{gInfo.TenDeTai} (Bị từ chối)" : gInfo.TenDeTai);

            return new
            {
                s.SinhVienId,
                s.MSSV,
                s.HoTen,
                s.Email,
                s.SoDienThoai,
                KhoaHoc = khoaHoc,
                LopNienChe = lopNienChe,
                s.TenKhoa,
                TrangThai = s.IsActive ? "Đang học" : "Đã nghỉ",
                DaCoNhom = hasGroup,
                NhomId = hasGroup ? (int?)gInfo.NhomId : null,
                TenNhom = hasGroup ? gInfo.TenNhom : "Chưa có nhóm",
                DaCoDeTai = topicPendingOrApproved,
                TenDeTai = tenDeTaiDisplay,
                TrangThaiDeTai = hasGroup ? gInfo.TrangThaiDeTai : "Chưa có nhóm"
            };
        }).ToList();

        return Ok(students);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DANH SÁCH NHÓM CỦA LỚP HỌC PHẦN KÈM THÀNH VIÊN & ĐỀ TÀI TƯƠNG ỨNG
    // ─────────────────────────────────────────────────────────────────────────
    [HttpGet("class-groups")]
    public async Task<IActionResult> GetClassGroups([FromQuery] int lopHocPhanId)
    {
        var rawGroups = await _db.NhomDoAns
            .AsNoTracking()
            .Where(g => g.DotDangKy != null && g.DotDangKy.LopHocPhanId == lopHocPhanId && g.TrangThai != "Đã hủy")
            .Select(g => new
            {
                g.NhomId,
                g.TenNhom,
                g.TrangThai,
                g.TruongNhomId,
                TruongNhom = g.TruongNhom != null && g.TruongNhom.NguoiDung != null
                    ? g.TruongNhom.NguoiDung.HoTen : string.Empty,
                MSSVTruong = g.TruongNhom != null ? g.TruongNhom.MSSV : string.Empty,
                Members = g.ThanhVienNhoms
                    .Where(m => m.TrangThai == "Đã tham gia" || m.TrangThai == "Trưởng nhóm")
                    .Select(m => new
                    {
                        m.SinhVienId,
                        MSSV = m.SinhVien != null ? m.SinhVien.MSSV : string.Empty,
                        HoTen = m.SinhVien != null && m.SinhVien.NguoiDung != null
                            ? m.SinhVien.NguoiDung.HoTen : string.Empty,
                        m.VaiTro
                    })
                    .ToList(),
                Regs = g.DangKyDeTais
                    .Where(r => r.TrangThai != "Đã hủy")
                    .OrderByDescending(r => r.NgayDangKy)
                    .Select(r => new
                    {
                        r.DeTaiId,
                        r.TrangThai,
                        TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : string.Empty,
                        NguonDeTai = r.DeTai != null ? r.DeTai.NguonDeTai : string.Empty,
                        GiangVienId = r.DeTai != null ? r.DeTai.GiangVienId : null,
                        SinhVienDeXuatId = r.DeTai != null ? r.DeTai.SinhVienDeXuatId : null,
                        GiangVien = r.DeTai != null && r.DeTai.GiangVien != null && r.DeTai.GiangVien.NguoiDung != null
                            ? r.DeTai.GiangVien.NguoiDung.HoTen : string.Empty
                    })
                    .ToList()
            })
            .OrderBy(g => g.NhomId)
            .ToListAsync();

        var groups = rawGroups.Select(g =>
        {
            var members = g.Members
                .GroupBy(m => m.SinhVienId)
                .Select(grp => grp.First())
                .ToList();

            if (!members.Any(m => m.SinhVienId == g.TruongNhomId))
            {
                members.Insert(0, new
                {
                    SinhVienId = g.TruongNhomId,
                    MSSV = g.MSSVTruong,
                    HoTen = g.TruongNhom,
                    VaiTro = "Trưởng nhóm"
                });
            }

            var approvedReg = g.Regs.FirstOrDefault(r => r.TrangThai == "Đã duyệt");
            var pendingReg = g.Regs.FirstOrDefault(r => r.TrangThai == "Chờ duyệt");
            var rejectedReg = g.Regs.FirstOrDefault(r => r.TrangThai == "Từ chối");

            var effectiveReg = approvedReg ?? pendingReg ?? rejectedReg;

            return new
            {
                g.NhomId,
                g.TenNhom,
                g.TrangThai,
                g.TruongNhom,
                g.MSSVTruong,
                ThanhVienCount = members.Count,
                ThanhViens = members,
                DeTai = approvedReg == null ? null : new
                {
                    approvedReg.DeTaiId,
                    approvedReg.TenDeTai,
                    approvedReg.NguonDeTai,
                    DoGiangVienDeXuat = IsLecturerProposedTopic(
                        approvedReg.NguonDeTai, approvedReg.GiangVienId, approvedReg.SinhVienDeXuatId),
                    approvedReg.GiangVien
                },
                PendingDeTai = pendingReg == null ? null : new
                {
                    pendingReg.DeTaiId,
                    pendingReg.TenDeTai,
                    pendingReg.NguonDeTai,
                    DoGiangVienDeXuat = IsLecturerProposedTopic(
                        pendingReg.NguonDeTai, pendingReg.GiangVienId, pendingReg.SinhVienDeXuatId),
                    pendingReg.GiangVien
                },
                TenDeTai = effectiveReg?.TenDeTai,
                TrangThaiDeTai = effectiveReg?.TrangThai ?? "Chưa đăng ký",
                CoDeTai = approvedReg != null || pendingReg != null
            };
        }).ToList();

        return Ok(groups);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DANH SÁCH SV CHƯA ĐĂNG KÝ NHÓM VÀ CHƯA CÓ ĐỀ TÀI
    // ─────────────────────────────────────────────────────────────────────────
    [HttpGet("students-without-group")]
    public async Task<IActionResult> GetStudentsWithoutGroup(
        [FromQuery] int? lopHocPhanId,
        [FromQuery] bool includeWithoutTopic = true)
    {
        List<int> scopeStudentIds;
        if (lopHocPhanId.HasValue)
        {
            scopeStudentIds = await _db.SinhVienLopHocPhans.AsNoTracking()
                .Where(sl => sl.LopHocPhanId == lopHocPhanId.Value && sl.TrangThai)
                .Select(sl => sl.SinhVienId)
                .Distinct()
                .ToListAsync();
        }
        else
        {
            scopeStudentIds = await _db.SinhViens.AsNoTracking()
                .Where(s => s.NguoiDung != null && s.NguoiDung.TrangThai)
                .Select(s => s.SinhVienId)
                .ToListAsync();
        }

        var groupQuery = _db.NhomDoAns.AsNoTracking()
            .Where(g => g.TrangThai != "Đã hủy");

        if (lopHocPhanId.HasValue)
        {
            groupQuery = groupQuery.Where(g => g.DotDangKy != null && g.DotDangKy.LopHocPhanId == lopHocPhanId.Value);
        }

        var activeGroups = await groupQuery
            .Select(g => new
            {
                g.NhomId,
                g.TenNhom,
                g.TruongNhomId,
                MemberIds = g.ThanhVienNhoms
                    .Where(m => m.TrangThai == "Đã tham gia" || m.TrangThai == "Trưởng nhóm")
                    .Select(m => m.SinhVienId)
                    .ToList(),
                HasTopic = g.DangKyDeTais.Any(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt")
            })
            .ToListAsync();

        var studentStatusMap = new Dictionary<int, (bool HasGroup, bool HasTopic, string? TenNhom)>();
        foreach (var g in activeGroups)
        {
            var members = new HashSet<int>(g.MemberIds) { g.TruongNhomId };
            foreach (var sid in members)
            {
                if (!studentStatusMap.TryGetValue(sid, out var cur) || (!cur.HasTopic && g.HasTopic))
                {
                    studentStatusMap[sid] = (true, g.HasTopic, g.TenNhom);
                }
            }
        }

        var targetIds = scopeStudentIds.Where(sid =>
        {
            if (!studentStatusMap.TryGetValue(sid, out var st)) return true; // Chưa đăng ký nhóm
            return includeWithoutTopic && !st.HasTopic; // Có nhóm nhưng chưa có đề tài
        }).ToList();

        var rawStudents = await _db.SinhViens
            .AsNoTracking()
            .Where(s => targetIds.Contains(s.SinhVienId))
            .Select(s => new
            {
                s.SinhVienId,
                s.MSSV,
                s.NgaySinh,
                MaKhoa = s.Khoa != null ? s.Khoa.MaKhoa : "CNTT",
                TenKhoa = s.Khoa != null ? s.Khoa.TenKhoa : string.Empty,
                HoTen = s.NguoiDung != null ? s.NguoiDung.HoTen : string.Empty,
                Email = s.NguoiDung != null ? s.NguoiDung.Email : string.Empty,
                SoDienThoai = s.NguoiDung != null ? s.NguoiDung.SoDienThoai : null
            })
            .OrderBy(s => s.MSSV)
            .ToListAsync();

        var students = rawStudents.Select(s =>
        {
            var hasStatus = studentStatusMap.TryGetValue(s.SinhVienId, out var st);
            var hasGroup = hasStatus && st.HasGroup;
            return new
            {
                s.SinhVienId,
                s.MSSV,
                s.HoTen,
                s.Email,
                s.SoDienThoai,
                KhoaHoc = ResolveKhoaHoc(s.MSSV, s.NgaySinh),
                LopNienChe = ResolveLopNienChe(s.MSSV, s.NgaySinh, s.MaKhoa),
                s.TenKhoa,
                DaCoNhom = hasGroup,
                TenNhom = hasGroup ? st.TenNhom : null,
                TrangThaiDangKy = hasGroup ? "Đã có nhóm · Chưa có đề tài" : "Chưa đăng ký nhóm & chưa có đề tài"
            };
        }).ToList();

        return Ok(students);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // NHÓM CHƯA NỘP BÁO CÁO TIẾN ĐỘ & GỬI THÔNG BÁO ĐÔN ĐỐC
    // ─────────────────────────────────────────────────────────────────────────
    [HttpGet("groups-not-submitted")]
    public async Task<IActionResult> GetGroupsNotSubmitted([FromQuery] int? lopHocPhanId)
    {
        var query = _db.NhomDoAns
            .AsNoTracking()
            .Where(g => g.TrangThai != "Đã hủy" && !g.BaoCaoTienDos.Any());

        if (lopHocPhanId.HasValue)
            query = query.Where(g => g.DotDangKy != null && g.DotDangKy.LopHocPhanId == lopHocPhanId.Value);

        var rawGroups = await query
            .Select(g => new
            {
                g.NhomId,
                g.TenNhom,
                g.TruongNhomId,
                LopHocPhanId = g.DotDangKy != null ? g.DotDangKy.LopHocPhanId : 0,
                MaLop = g.DotDangKy != null && g.DotDangKy.LopHocPhan != null
                    ? g.DotDangKy.LopHocPhan.MaLopHocPhan : string.Empty,
                TenLop = g.DotDangKy != null && g.DotDangKy.LopHocPhan != null
                    ? (g.DotDangKy.LopHocPhan.TenLopHocPhan ?? g.DotDangKy.LopHocPhan.MaLopHocPhan) : string.Empty,
                TruongNhom = g.TruongNhom != null && g.TruongNhom.NguoiDung != null
                    ? g.TruongNhom.NguoiDung.HoTen : string.Empty,
                Email = g.TruongNhom != null && g.TruongNhom.NguoiDung != null
                    ? g.TruongNhom.NguoiDung.Email : string.Empty,
                MemberIds = g.ThanhVienNhoms
                    .Where(m => m.TrangThai == "Đã tham gia" || m.TrangThai == "Trưởng nhóm")
                    .Select(m => m.SinhVienId)
                    .ToList(),
                Topic = g.DangKyDeTais
                    .Where(r => r.TrangThai == "Đã duyệt" || r.TrangThai == "Chờ duyệt")
                    .OrderByDescending(r => r.TrangThai == "Đã duyệt" ? 2 : 1)
                    .Select(r => new
                    {
                        TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : null,
                        r.TrangThai
                    })
                    .FirstOrDefault()
            })
            .OrderBy(g => g.MaLop)
            .ThenBy(g => g.TenNhom)
            .ToListAsync();

        var groups = rawGroups.Select(g =>
        {
            var members = new HashSet<int>(g.MemberIds) { g.TruongNhomId };
            return new
            {
                g.NhomId,
                g.TenNhom,
                g.LopHocPhanId,
                g.MaLop,
                g.TenLop,
                g.TruongNhom,
                g.Email,
                ThanhVienCount = members.Count,
                TenDeTai = g.Topic?.TenDeTai ?? "Chưa có đề tài",
                TrangThaiDeTai = g.Topic?.TrangThai ?? "Chưa đăng ký"
            };
        }).ToList();

        return Ok(groups);
    }

    public sealed class RemindGroupsRequest
    {
        public List<int>? NhomIds { get; set; }
        public int? LopHocPhanId { get; set; }
        public string? Message { get; set; }
    }

    [HttpPost("remind-groups")]
    public async Task<IActionResult> RemindGroups([FromBody] RemindGroupsRequest? request)
    {
        var query = _db.NhomDoAns
            .Include(g => g.DotDangKy).ThenInclude(d => d!.LopHocPhan)
            .Include(g => g.TruongNhom)
            .Include(g => g.ThanhVienNhoms).ThenInclude(m => m.SinhVien)
            .Where(g => g.TrangThai != "Đã hủy" && !g.BaoCaoTienDos.Any());

        if (request?.NhomIds != null && request.NhomIds.Count > 0)
        {
            query = query.Where(g => request.NhomIds.Contains(g.NhomId));
        }
        else if (request?.LopHocPhanId != null && request.LopHocPhanId > 0)
        {
            query = query.Where(g => g.DotDangKy != null && g.DotDangKy.LopHocPhanId == request.LopHocPhanId.Value);
        }

        var targetGroups = await query.ToListAsync();
        if (targetGroups.Count == 0)
        {
            return Ok(new
            {
                success = true,
                groupsNotified = 0,
                studentsNotified = 0,
                message = "Không có nhóm nào chưa nộp báo cáo tiến độ."
            });
        }

        var customMessage = string.IsNullOrWhiteSpace(request?.Message) ? null : request!.Message!.Trim();
        var notifiedUserIds = new HashSet<int>();

        foreach (var g in targetGroups)
        {
            var userIds = new HashSet<int>();
            if (g.TruongNhom?.NguoiDungId > 0) userIds.Add(g.TruongNhom.NguoiDungId);
            foreach (var m in g.ThanhVienNhoms.Where(tv => tv.TrangThai == "Đã tham gia" || tv.TrangThai == "Trưởng nhóm"))
            {
                if (m.SinhVien?.NguoiDungId > 0) userIds.Add(m.SinhVien.NguoiDungId);
            }

            var className = g.DotDangKy?.LopHocPhan?.MaLopHocPhan ?? string.Empty;
            var content = customMessage ??
                $"Nhóm '{g.TenNhom}'{(string.IsNullOrEmpty(className) ? "" : $" ({className})")} hiện chưa nộp báo cáo tiến độ. Vui lòng hoàn thành và nộp báo cáo đúng hạn.";

            foreach (var uid in userIds)
            {
                notifiedUserIds.Add(uid);
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = uid,
                    TieuDe = $"Nhắc nhở nộp báo cáo tiến độ - {g.TenNhom}",
                    NoiDung = content,
                    LoaiThongBao = "Tiến độ",
                    LienKetId = g.NhomId,
                    LoaiLienKet = "NhomDoAn",
                    DaDoc = false,
                    CreatedAt = DateTime.Now
                });
            }
        }

        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            groupsNotified = targetGroups.Count,
            studentsNotified = notifiedUserIds.Count,
            message = $"Đã gửi thông báo đôn đốc thành công tới {targetGroups.Count} nhóm ({notifiedUserIds.Count} sinh viên)."
        });
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LỌC GIẢNG VIÊN THEO HƯỚNG NGHIÊN CỨU (đảm bảo logic, hỗ trợ không dấu)
    // ─────────────────────────────────────────────────────────────────────────
    [HttpGet("lecturers-by-research")]
    public async Task<IActionResult> GetLecturersByResearch([FromQuery] string? keyword)
    {
        var rawLecturers = await _db.GiangViens.AsNoTracking()
            .Where(g => g.NguoiDung != null && g.NguoiDung.TrangThai && !string.IsNullOrWhiteSpace(g.ChuyenMon))
            .OrderBy(g => g.MaGiangVien)
            .Select(g => new
            {
                g.GiangVienId,
                g.MaGiangVien,
                HoTen = g.NguoiDung != null ? g.NguoiDung.HoTen : string.Empty,
                Email = g.NguoiDung != null ? g.NguoiDung.Email : string.Empty,
                SoDienThoai = g.NguoiDung != null ? g.NguoiDung.SoDienThoai : null,
                g.HocVi,
                g.ChuyenMon,
                TenKhoa = g.Khoa != null ? g.Khoa.TenKhoa : string.Empty,
                SoLopPhuTrach = g.PhanCongGiangViens.Count(p => p.TrangThai),
                SoDeTaiDangHuong = g.DeTaiDoAns.Count()
            })
            .ToListAsync();

        var kwNorm = NormalizeVietnamese(keyword);
        var result = rawLecturers
            .Where(g => IsMeaningfulResearchField(g.ChuyenMon))
            .Where(g =>
                string.IsNullOrEmpty(kwNorm) ||
                NormalizeVietnamese(g.ChuyenMon).Contains(kwNorm) ||
                NormalizeVietnamese(g.HocVi).Contains(kwNorm) ||
                NormalizeVietnamese(g.HoTen).Contains(kwNorm))
            .ToList();

        return Ok(result);
    }

    [HttpGet("courses")]
    public async Task<IActionResult> GetCourses([FromQuery] int? khoaId)
    {
        var query = _db.LopHocPhans.AsNoTracking().Where(c => c.TrangThai);
        if (khoaId.HasValue)
        {
            query = query.Where(c => c.KhoaId == khoaId.Value);
        }

        var courses = await query
            .OrderBy(c => c.MaLopHocPhan)
            .Select(c => new
            {
                c.LopHocPhanId,
                c.MaLopHocPhan,
                c.TenLopHocPhan,
                c.HocPhanId,
                MaHocPhan = c.HocPhan != null ? c.HocPhan.MaHocPhan : string.Empty,
                TenHocPhan = c.HocPhan != null ? c.HocPhan.TenHocPhan : string.Empty,
                SoTinChi = c.HocPhan != null ? c.HocPhan.SoTinChi : 3,
                c.HocKyId,
                TenHocKy = c.HocKy != null ? c.HocKy.TenHocKy : string.Empty,
                NamHoc = c.HocKy != null ? c.HocKy.NamHoc : string.Empty,
                c.KhoaId,
                MaKhoa = c.Khoa != null ? c.Khoa.MaKhoa : string.Empty,
                TenKhoa = c.Khoa != null ? c.Khoa.TenKhoa : string.Empty,
                c.SoLuongToiDa,
                SoSinhVien = c.SinhVienLopHocPhans.Count(s => s.TrangThai),
                SoLuongSinhVien = c.SinhVienLopHocPhans.Count(s => s.TrangThai),
                GiangVienId = c.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => (int?)p.GiangVienId)
                    .FirstOrDefault(),
                MaGiangVien = c.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => p.GiangVien!.MaGiangVien)
                    .FirstOrDefault(),
                GiangVienTen = c.PhanCongGiangViens
                    .Where(p => p.TrangThai && p.GiangVien != null && p.GiangVien.NguoiDung != null)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => p.GiangVien!.NguoiDung!.HoTen)
                    .FirstOrDefault() ?? "Chưa phân công",
                GiangViens = c.PhanCongGiangViens
                    .Where(p => p.TrangThai)
                    .OrderByDescending(p => p.NgayPhanCong)
                    .Select(p => new
                    {
                        p.GiangVienId,
                        MaGiangVien = p.GiangVien != null ? p.GiangVien.MaGiangVien : string.Empty,
                        HoTen = p.GiangVien != null && p.GiangVien.NguoiDung != null ? p.GiangVien.NguoiDung.HoTen : string.Empty,
                        p.VaiTro
                    }).ToList(),
                TrangThaiDotDangKy = c.DotDangKyDoAns
                    .OrderByDescending(d => d.NgayBatDau)
                    .Select(d => d.TrangThai)
                    .FirstOrDefault() ?? "Chưa mở",
                TenDotDangKy = c.DotDangKyDoAns
                    .OrderByDescending(d => d.NgayBatDau)
                    .Select(d => d.TenDot)
                    .FirstOrDefault(),
                SoNhom = c.DotDangKyDoAns.SelectMany(d => d.NhomDoAns).Count(n => n.TrangThai != "Đã hủy"),
                SoDeTai = c.DotDangKyDoAns.SelectMany(d => d.DeTaiDoAns).Count(),
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

        // Chặn phân công trùng lặp cùng 1 giảng viên đang phụ trách lớp này (TC_GVK_008)
        var existingAssignment = await _db.PhanCongGiangViens
            .FirstOrDefaultAsync(p => p.LopHocPhanId == request.LopHocPhanId && p.GiangVienId == request.GiangVienId);

        if (existingAssignment is not null && existingAssignment.TrangThai)
        {
            return Conflict(new { message = "Giảng viên này đã được phân công cho lớp học phần từ trước." });
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

            return Ok(new
            {
                success = true,
                phanCongId = existingAssignment.PhanCongId,
                lopHocPhanId = existingAssignment.LopHocPhanId,
                giangVienId = existingAssignment.GiangVienId,
                hoTen = lecturer.NguoiDung?.HoTen ?? string.Empty,
                trangThai = true,
                message = "Đã phân công giảng viên phụ trách lớp học phần thành công."
            });
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

        var newLecturer = await _db.GiangViens.AsNoTracking()
            .Include(g => g.NguoiDung)
            .FirstOrDefaultAsync(g => g.GiangVienId == request.GiangVienId);
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
        return Ok(new
        {
            success = true,
            lopHocPhanId = request.LopHocPhanId,
            giangVienId = request.GiangVienId,
            hoTen = newLecturer.NguoiDung?.HoTen ?? string.Empty,
            message = "Đã cập nhật giảng viên phụ trách lớp học phần."
        });
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

    [HttpGet("khoas")]
    public async Task<IActionResult> GetKhoas()
    {
        var list = await _db.Khoas.AsNoTracking()
            .Where(k => k.TrangThai)
            .OrderBy(k => k.KhoaId)
            .Select(k => new
            {
                k.KhoaId,
                k.MaKhoa,
                k.TenKhoa,
                SoSinhVien = k.SinhViens.Count(),
                SoGiangVien = k.GiangViens.Count(),
                SoLopHocPhan = k.LopHocPhans.Count(l => l.TrangThai)
            })
            .ToListAsync();
        return Ok(list);
    }

    [HttpGet("students")]
    public async Task<IActionResult> GetStudents(
        [FromQuery] int? khoaId,
        [FromQuery] string? khoaCode,
        [FromQuery] string? search,
        [FromQuery] int? page = null,
        [FromQuery] int? pageSize = null)
    {
        var query = _db.SinhViens.AsNoTracking().AsQueryable();

        if (khoaId.HasValue)
        {
            query = query.Where(s => s.KhoaId == khoaId.Value);
        }

        if (!string.IsNullOrWhiteSpace(khoaCode))
        {
            var kc = khoaCode.Trim().ToUpperInvariant();
            query = query.Where(s => s.Khoa != null && s.Khoa.MaKhoa.ToUpper() == kc);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(sv =>
                sv.MSSV.Contains(s) ||
                (sv.NguoiDung != null && (
                    sv.NguoiDung.HoTen.Contains(s) ||
                    sv.NguoiDung.Email.Contains(s) ||
                    (sv.NguoiDung.SoDienThoai != null && sv.NguoiDung.SoDienThoai.Contains(s)))));
        }

        IQueryable<SinhVien> orderedQuery = query.OrderBy(s => s.MSSV);
        if (page.HasValue && page.Value > 0 && pageSize.HasValue && pageSize.Value > 0)
        {
            var size = Math.Min(pageSize.Value, 200);
            orderedQuery = orderedQuery.Skip((page.Value - 1) * size).Take(size);
        }

        var rawStudents = await orderedQuery
            .Select(s => new
            {
                s.SinhVienId,
                s.MSSV,
                s.NguoiDungId,
                HoTen = s.NguoiDung != null ? s.NguoiDung.HoTen : string.Empty,
                Email = s.NguoiDung != null ? s.NguoiDung.Email : string.Empty,
                SoDienThoai = s.NguoiDung != null ? s.NguoiDung.SoDienThoai : null,
                s.KhoaId,
                HasKhoa = s.Khoa != null,
                MaKhoa = s.Khoa != null ? s.Khoa.MaKhoa : string.Empty,
                TenKhoa = s.Khoa != null ? s.Khoa.TenKhoa : string.Empty,
                s.NgaySinh,
                s.GioiTinh,
                TrangThai = s.NguoiDung != null && s.NguoiDung.TrangThai
            })
            .ToListAsync();

        var students = rawStudents.Select(s => new
        {
            s.SinhVienId,
            s.MSSV,
            s.NguoiDungId,
            s.HoTen,
            s.Email,
            s.SoDienThoai,
            s.KhoaId,
            CoKhoaHopLe = s.HasKhoa && s.KhoaId > 0,
            s.MaKhoa,
            s.TenKhoa,
            KhoaHoc = ResolveKhoaHoc(s.MSSV, s.NgaySinh),
            LopNienChe = s.HasKhoa && !string.IsNullOrWhiteSpace(s.MaKhoa)
                ? ResolveLopNienChe(s.MSSV, s.NgaySinh, s.MaKhoa)
                : "Chưa gán khoa",
            s.NgaySinh,
            s.GioiTinh,
            s.TrangThai
        }).ToList();

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
                (gv.HocVi != null && gv.HocVi.Contains(s)) ||
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
                MaKhoa = g.Khoa != null ? g.Khoa.MaKhoa : string.Empty,
                TenKhoa = g.Khoa != null ? g.Khoa.TenKhoa : string.Empty,
                g.HocVi,
                g.ChuyenMon,
                SoLopPhuTrach = g.PhanCongGiangViens.Count(p => p.TrangThai),
                TrangThai = g.NguoiDung != null && g.NguoiDung.TrangThai
            })
            .ToListAsync();

        return Ok(lecturers);
    }

    public sealed class CreateGovernanceStudentRequest
    {
        public string Mssv { get; set; } = string.Empty;
        public string HoTen { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? SoDienThoai { get; set; }
        public string? Khoa { get; set; }
        public string? MaLopHocPhan { get; set; }
        public string? MatKhau { get; set; }
        public bool? TrangThai { get; set; }
    }

    public sealed class CreateGovernanceLecturerRequest
    {
        public string MaGiangVien { get; set; } = string.Empty;
        public string HoTen { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? SoDienThoai { get; set; }
        public string? Khoa { get; set; }
        public string? HocVi { get; set; }
        public string? ChuyenMon { get; set; }
        public string? MatKhau { get; set; }
        public bool? TrangThai { get; set; }
    }

    private async Task<Khoa?> ResolveKhoaAsync(string? khoaInput)
    {
        if (!string.IsNullOrWhiteSpace(khoaInput))
        {
            var kw = khoaInput.Trim();
            var matched = await _db.Khoas.AsNoTracking()
                .FirstOrDefaultAsync(k => k.MaKhoa.ToUpper() == kw.ToUpper() || k.TenKhoa.Contains(kw));
            if (matched != null) return matched;
        }
        return await _db.Khoas.AsNoTracking().FirstOrDefaultAsync(k => k.MaKhoa == "CNTT")
            ?? await _db.Khoas.AsNoTracking().FirstOrDefaultAsync();
    }

    private static (bool Valid, string? Phone) TryNormalizePhone(string? rawPhone)
    {
        if (string.IsNullOrWhiteSpace(rawPhone)) return (true, null);
        var trimmed = rawPhone.Trim();
        return Regex.IsMatch(trimmed, @"^[0-9]{10,11}$")
            ? (true, trimmed)
            : (false, null);
    }

    [HttpPost("students")]
    public async Task<IActionResult> CreateStudent([FromBody] CreateGovernanceStudentRequest request)
    {
        var mssv = request.Mssv?.Trim() ?? string.Empty;
        var hoTen = request.HoTen?.Trim() ?? string.Empty;
        var email = request.Email?.Trim() ?? string.Empty;

        if (string.IsNullOrWhiteSpace(mssv) || string.IsNullOrWhiteSpace(hoTen) || string.IsNullOrWhiteSpace(email))
            return BadRequest(new { message = "Vui lòng nhập đầy đủ MSSV, Họ tên và Email." });

        var (phoneOk, phone) = TryNormalizePhone(request.SoDienThoai);
        if (!phoneOk)
            return BadRequest(new { message = "Số điện thoại phải từ 10-11 chữ số và không chứa ký tự chữ." });

        if (await _db.NguoiDungs.AnyAsync(u => u.TenDangNhap == mssv || u.Email == email))
            return Conflict(new { message = "MSSV hoặc Email đã tồn tại trong hệ thống." });

        if (await _db.SinhViens.AnyAsync(s => s.MSSV == mssv))
            return Conflict(new { message = "Mã số sinh viên đã tồn tại." });

        var role = await _db.VaiTros.FirstOrDefaultAsync(v => v.MaVaiTro == "SINHVIEN");
        if (role is null) return BadRequest(new { message = "Vai trò SINHVIEN không tồn tại." });

        var khoa = await ResolveKhoaAsync(request.Khoa);
        var password = string.IsNullOrWhiteSpace(request.MatKhau) ? "123456aA@" : request.MatKhau.Trim();

        var user = new NguoiDung
        {
            TenDangNhap = mssv,
            MatKhauHash = BCrypt.Net.BCrypt.HashPassword(password),
            Email = email,
            HoTen = hoTen,
            SoDienThoai = phone,
            VaiTroId = role.VaiTroId,
            TrangThai = request.TrangThai ?? true,
            CreatedAt = DateTime.Now
        };
        _db.NguoiDungs.Add(user);
        await _db.SaveChangesAsync();

        var sinhVien = new SinhVien
        {
            NguoiDungId = user.NguoiDungId,
            MSSV = mssv,
            KhoaId = khoa?.KhoaId ?? 1,
            CreatedAt = DateTime.Now
        };
        _db.SinhViens.Add(sinhVien);
        await _db.SaveChangesAsync();

        if (!string.IsNullOrWhiteSpace(request.MaLopHocPhan))
        {
            var code = request.MaLopHocPhan.Trim();
            var lhp = await _db.LopHocPhans.FirstOrDefaultAsync(l => l.MaLopHocPhan == code && l.TrangThai);
            if (lhp != null)
            {
                _db.SinhVienLopHocPhans.Add(new SinhVienLopHocPhan
                {
                    SinhVienId = sinhVien.SinhVienId,
                    LopHocPhanId = lhp.LopHocPhanId,
                    TrangThai = true
                });
                await _db.SaveChangesAsync();
            }
        }

        return Ok(new
        {
            success = true,
            sinhVienId = sinhVien.SinhVienId,
            mssv = sinhVien.MSSV,
            hoTen = user.HoTen,
            email = user.Email,
            message = "Thêm sinh viên thành công."
        });
    }

    [HttpPost("lecturers")]
    public async Task<IActionResult> CreateLecturer([FromBody] CreateGovernanceLecturerRequest request)
    {
        var maGv = request.MaGiangVien?.Trim() ?? string.Empty;
        var hoTen = request.HoTen?.Trim() ?? string.Empty;
        var email = request.Email?.Trim() ?? string.Empty;

        if (string.IsNullOrWhiteSpace(maGv) || string.IsNullOrWhiteSpace(hoTen) || string.IsNullOrWhiteSpace(email))
            return BadRequest(new { message = "Vui lòng nhập đầy đủ Mã giảng viên, Họ tên và Email." });

        var (phoneOk, phone) = TryNormalizePhone(request.SoDienThoai);
        if (!phoneOk)
            return BadRequest(new { message = "Số điện thoại phải từ 10-11 chữ số và không chứa ký tự chữ." });

        if (await _db.NguoiDungs.AnyAsync(u => u.TenDangNhap == maGv || u.Email == email))
            return Conflict(new { message = "Mã giảng viên hoặc Email đã tồn tại trong hệ thống." });

        if (await _db.GiangViens.AnyAsync(g => g.MaGiangVien == maGv))
            return Conflict(new { message = "Mã giảng viên đã tồn tại." });

        var role = await _db.VaiTros.FirstOrDefaultAsync(v => v.MaVaiTro == "GIANGVIEN");
        if (role is null) return BadRequest(new { message = "Vai trò GIANGVIEN không tồn tại." });

        var khoa = await ResolveKhoaAsync(request.Khoa);
        var password = string.IsNullOrWhiteSpace(request.MatKhau) ? "123456aA@" : request.MatKhau.Trim();

        var user = new NguoiDung
        {
            TenDangNhap = maGv,
            MatKhauHash = BCrypt.Net.BCrypt.HashPassword(password),
            Email = email,
            HoTen = hoTen,
            SoDienThoai = phone,
            VaiTroId = role.VaiTroId,
            TrangThai = request.TrangThai ?? true,
            CreatedAt = DateTime.Now
        };
        _db.NguoiDungs.Add(user);
        await _db.SaveChangesAsync();

        var giangVien = new GiangVien
        {
            NguoiDungId = user.NguoiDungId,
            MaGiangVien = maGv,
            KhoaId = khoa?.KhoaId ?? 1,
            HocVi = string.IsNullOrWhiteSpace(request.HocVi) ? "ThS." : request.HocVi.Trim(),
            ChuyenMon = string.IsNullOrWhiteSpace(request.ChuyenMon) ? null : request.ChuyenMon.Trim(),
            CreatedAt = DateTime.Now
        };
        _db.GiangViens.Add(giangVien);
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
                NoiDung = $"Tài khoản Giảng viên {user.HoTen} vừa được kích hoạt thuộc {khoa?.TenKhoa ?? "Khoa"}.",
                LoaiThongBao = "Hệ thống",
                LienKetId = giangVien.GiangVienId,
                LoaiLienKet = "GiangVien",
                DaDoc = false,
                CreatedAt = DateTime.Now
            });
        }
        if (gvkIds.Count > 0) await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            giangVienId = giangVien.GiangVienId,
            maGiangVien = giangVien.MaGiangVien,
            hoTen = user.HoTen,
            email = user.Email,
            message = "Thêm giảng viên thành công."
        });
    }
}
