using System.Collections.Concurrent;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public sealed class NotificationsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private static readonly ConcurrentDictionary<int, HashSet<int>> _userReadNotifications = new();

    public NotificationsController(ApplicationDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var userId = GetCurrentUserId();
        var notifications = await GenerateNotificationsAsync(userId);
        return Ok(notifications);
    }

    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        var userId = GetCurrentUserId();
        var notifications = await GenerateNotificationsAsync(userId, countOnly: true);
        var unreadCount = notifications.Count(n => !n.isRead);
        return Ok(new { unreadCount });
    }

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        var userId = GetCurrentUserId();
        var set = _userReadNotifications.GetOrAdd(userId, _ => new HashSet<int>());
        lock (set)
        {
            set.Add(id);
        }

        if (id < 100000)
        {
            var dbNotif = await _db.ThongBaos.FirstOrDefaultAsync(t => t.ThongBaoId == id && t.NguoiDungId == userId);
            if (dbNotif != null)
            {
                dbNotif.DaDoc = true;
                await _db.SaveChangesAsync();
            }
        }
        else
        {
            // Bền vững hóa trạng thái đã đọc của thông báo hệ thống tự sinh vào CSDL
            var alreadyMarked = await _db.ThongBaos.AnyAsync(t => t.NguoiDungId == userId && t.LienKetId == id && t.LoaiLienKet == "VirtualRead");
            if (!alreadyMarked)
            {
                _db.ThongBaos.Add(new ThongBao
                {
                    NguoiDungId = userId,
                    TieuDe = "Virtual Read Marker",
                    NoiDung = $"Read marker for notification {id}",
                    LoaiThongBao = "HeThong",
                    DaDoc = true,
                    LienKetId = id,
                    LoaiLienKet = "VirtualRead",
                    CreatedAt = DateTime.UtcNow
                });
                await _db.SaveChangesAsync();
            }
        }

        return Ok(new { success = true, message = "Đã đánh dấu thông báo đã đọc.", id });
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var userId = GetCurrentUserId();
        var notifications = await GenerateNotificationsAsync(userId);
        var unreadIds = notifications.Where(n => !n.isRead && n.id >= 100000).Select(n => n.id).Distinct().ToList();
        var set = _userReadNotifications.GetOrAdd(userId, _ => new HashSet<int>());
        lock (set)
        {
            foreach (var n in notifications)
            {
                set.Add(n.id);
            }
        }

        var existingVirtualReads = await _db.ThongBaos
            .Where(t => t.NguoiDungId == userId && t.LoaiLienKet == "VirtualRead" && t.LienKetId != null)
            .Select(t => t.LienKetId!.Value)
            .ToListAsync();
        var existingSet = existingVirtualReads.ToHashSet();
        foreach (var vid in unreadIds)
        {
            if (!existingSet.Contains(vid))
            {
                _db.ThongBaos.Add(new Models.ThongBao
                {
                    NguoiDungId = userId,
                    TieuDe = "System Read Sync",
                    NoiDung = "Đã đọc",
                    LoaiThongBao = "System",
                    LienKetId = vid,
                    LoaiLienKet = "VirtualRead",
                    DaDoc = true,
                    CreatedAt = DateTime.Now
                });
            }
        }

        var dbNotifs = await _db.ThongBaos.Where(t => t.NguoiDungId == userId && !t.DaDoc).ToListAsync();
        foreach (var tb in dbNotifs)
        {
            tb.DaDoc = true;
        }
        if (dbNotifs.Any() || unreadIds.Any(id => !existingSet.Contains(id)))
        {
            await _db.SaveChangesAsync();
        }

        return Ok(new { success = true, message = "Đã đánh dấu tất cả thông báo đã đọc." });
    }

    private int GetCurrentUserId()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idClaim, out var id) ? id : 0;
    }

    private async Task<List<NotificationItem>> GenerateNotificationsAsync(int userId, bool countOnly = false)
    {
        var notifications = new List<NotificationItem>();

        _userReadNotifications.TryGetValue(userId, out var inMemReadSet);

        // Nạp các ID thông báo đã đọc được lưu vĩnh viễn trong CSDL
        var persistedReadIds = await _db.ThongBaos.AsNoTracking()
            .Where(t => t.NguoiDungId == userId && t.LoaiLienKet == "VirtualRead" && t.LienKetId != null)
            .Select(t => t.LienKetId!.Value)
            .ToListAsync();

        var readSet = new HashSet<int>(persistedReadIds);
        if (inMemReadSet != null)
        {
            foreach (var r in inMemReadSet) readSet.Add(r);
        }

        // 0. Thông báo thực tế gửi riêng cho người dùng từ DB (Bảng ThongBaos, loại trừ marker đọc nội bộ)
        var userDbNotifs = await _db.ThongBaos.AsNoTracking()
            .Where(t => t.NguoiDungId == userId && t.LoaiLienKet != "VirtualRead")
            .OrderByDescending(t => t.CreatedAt)
            .Take(40)
            .Select(t => new
            {
                t.ThongBaoId,
                t.LoaiThongBao,
                t.TieuDe,
                t.NoiDung,
                t.DaDoc,
                t.LienKetId,
                t.LoaiLienKet,
                t.CreatedAt
            })
            .ToListAsync();

        foreach (var tb in userDbNotifs)
        {
            var isRead = tb.DaDoc || readSet.Contains(tb.ThongBaoId);
            var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, tb.CreatedAt) : CalculateTimeDifference(tb.CreatedAt);

            string? rejReason = null;
            if (!countOnly && !string.IsNullOrEmpty(tb.NoiDung) && tb.NoiDung.Contains("Lý do:"))
            {
                var parts = tb.NoiDung.Split("Lý do:", 2);
                if (parts.Length > 1) rejReason = parts[1].Trim();
            }

            notifications.Add(new NotificationItem
            {
                id = tb.ThongBaoId,
                type = tb.LoaiThongBao ?? "Hệ thống",
                title = tb.TieuDe,
                content = tb.NoiDung,
                time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated,
                rejectionReason = rejReason,
                lyDoTuChoi = rejReason
            });
        }

        // 0.5 Thông báo thời gian thực trực tiếp cho sinh viên về đăng ký đề tài và đề xuất đề tài
        var currentStudentId = await _db.SinhViens.AsNoTracking()
            .Where(s => s.NguoiDungId == userId)
            .Select(s => (int?)s.SinhVienId)
            .FirstOrDefaultAsync();
        if (currentStudentId.HasValue)
        {
            var myGroupIds = await _db.NhomDoAns.AsNoTracking()
                .Where(g => g.TruongNhomId == currentStudentId.Value || g.ThanhVienNhoms.Any(m => m.SinhVienId == currentStudentId.Value && m.TrangThai != "Đã rời nhóm" && m.TrangThai != "Từ chối"))
                .Select(g => g.NhomId)
                .ToListAsync();

            if (myGroupIds.Any())
            {
                var myDecidedRegs = await _db.DangKyDeTais.AsNoTracking()
                    .Where(r => myGroupIds.Contains(r.NhomId) && (r.TrangThai == "Từ chối" || r.TrangThai == "Đã duyệt"))
                    .OrderByDescending(r => r.NgayDuyet ?? r.NgayDangKy)
                    .Take(10)
                    .Select(r => new
                    {
                        r.DangKyDeTaiId,
                        r.TrangThai,
                        r.GhiChu,
                        r.NgayDuyet,
                        r.NgayDangKy,
                        TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : null,
                        TenNhom = r.Nhom != null ? r.Nhom.TenNhom : null
                    })
                    .ToListAsync();

                foreach (var reg in myDecidedRegs)
                {
                    var isRej = reg.TrangThai == "Từ chối";
                    var tenDeTai = reg.TenDeTai ?? "đề tài";
                    var tenNhom = reg.TenNhom ?? "Nhóm";
                    var reason = !string.IsNullOrWhiteSpace(reg.GhiChu) ? reg.GhiChu : "Đề tài đã đủ số lượng / Cần chọn đề tài khác";
                    var title = isRej ? "Đăng ký đề tài bị từ chối" : "Đăng ký đề tài được duyệt";
                    var content = isRej
                        ? $"Giảng viên từ chối đăng ký đề tài '{tenDeTai}' của nhóm '{tenNhom}'. Lý do: {reason}"
                        : $"Giảng viên đã duyệt đăng ký đề tài '{tenDeTai}' cho nhóm '{tenNhom}'.";

                    var notifId = 150000 + reg.DangKyDeTaiId;
                    if (!notifications.Any(n => n.id == notifId || (n.content != null && n.content.Contains(tenDeTai) && n.content.Contains(isRej ? "từ chối" : "duyệt"))))
                    {
                        var eventTime = reg.NgayDuyet ?? reg.NgayDangKy;
                        var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, eventTime) : CalculateTimeDifference(eventTime);
                        var isRead = readSet.Contains(notifId);
                        notifications.Add(new NotificationItem
                        {
                            id = notifId,
                            type = "Đề tài",
                            title = title,
                            content = content,
                            time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                            isRead = isRead,
                            read = isRead,
                            createdAt = localCreated,
                            rejectionReason = isRej ? reason : null,
                            lyDoTuChoi = isRej ? reason : null
                        });
                    }
                }
            }

            // Đề xuất của chính sinh viên này
            var myProposals = await _db.DeTaiDoAns.AsNoTracking()
                .Where(t => t.SinhVienDeXuatId == currentStudentId.Value && (t.TrangThaiDuyet == "Từ chối" || t.TrangThaiDuyet == "Đã duyệt"))
                .OrderByDescending(t => t.UpdatedAt ?? t.CreatedAt)
                .Take(10)
                .Select(t => new
                {
                    t.DeTaiId,
                    t.TenDeTai,
                    t.TrangThaiDuyet,
                    t.LyDoTuChoi,
                    t.UpdatedAt,
                    t.CreatedAt
                })
                .ToListAsync();

            foreach (var prop in myProposals)
            {
                var isRej = prop.TrangThaiDuyet == "Từ chối";
                var reason = !string.IsNullOrWhiteSpace(prop.LyDoTuChoi) ? prop.LyDoTuChoi : "Phạm vi đề tài quá rộng, cần thu hẹp lại";
                var title = isRej ? $"Đề xuất đề tài bị từ chối: {prop.TenDeTai}" : $"Đề xuất đề tài được duyệt: {prop.TenDeTai}";
                var content = isRej
                    ? $"Đề xuất đề tài '{prop.TenDeTai}' bị từ chối. Lý do: {reason}"
                    : $"Đề xuất đề tài '{prop.TenDeTai}' đã được giảng viên phê duyệt thành đề tài chính thức của nhóm.";

                var notifId = 350000 + prop.DeTaiId;
                if (!notifications.Any(n => n.id == notifId || (n.content != null && n.content.Contains(prop.TenDeTai) && n.content.Contains(isRej ? "từ chối" : "phê duyệt"))))
                {
                    var eventTime = prop.UpdatedAt ?? prop.CreatedAt;
                    var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, eventTime) : CalculateTimeDifference(eventTime);
                    var isRead = readSet.Contains(notifId);
                    notifications.Add(new NotificationItem
                    {
                        id = notifId,
                        type = "Đề tài",
                        title = title,
                        content = content,
                        time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                        isRead = isRead,
                        read = isRead,
                        createdAt = localCreated,
                        rejectionReason = isRej ? reason : null,
                        lyDoTuChoi = isRej ? reason : null
                    });
                }
            }
        }

        // 1. Đăng ký đề tài gần đây (Bảng DangKyDeTais)
        var recentRegistrations = await _db.DangKyDeTais.AsNoTracking()
            .OrderByDescending(r => r.NgayDangKy)
            .Take(12)
            .Select(r => new
            {
                r.DangKyDeTaiId,
                r.TrangThai,
                r.GhiChu,
                r.NgayDangKy,
                TenNhom = r.Nhom != null ? r.Nhom.TenNhom : null,
                TenDeTai = r.DeTai != null ? r.DeTai.TenDeTai : null
            })
            .ToListAsync();

        foreach (var reg in recentRegistrations)
        {
            var tenNhom = reg.TenNhom ?? "Nhóm";
            var tenDeTai = reg.TenDeTai ?? "Đề tài";
            var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, reg.NgayDangKy) : CalculateTimeDifference(reg.NgayDangKy);
            var id = 100000 + reg.DangKyDeTaiId;
            var isRead = readSet.Contains(id) || reg.TrangThai == "Đã duyệt";

            var isRejected = string.Equals(reg.TrangThai, "Từ chối", StringComparison.OrdinalIgnoreCase);
            var title = isRejected ? $"Đăng ký đề tài bị từ chối: {tenDeTai}" : $"Đăng ký đề tài: {tenDeTai}";
            var reason = !string.IsNullOrWhiteSpace(reg.GhiChu) ? reg.GhiChu : "Không có lý do cụ thể";
            var content = isRejected
                ? $"{tenNhom} đã bị từ chối đăng ký đề tài '{tenDeTai}'. Lý do: {reason}"
                : $"{tenNhom} đã đăng ký đề tài và đang ở trạng thái '{reg.TrangThai}'.";

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Đăng ký",
                title = title,
                content = content,
                time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        // 2. Nhóm đồ án mới thành lập (Bảng NhomDoAns)
        var recentGroups = await _db.NhomDoAns.AsNoTracking()
            .OrderByDescending(g => g.CreatedAt)
            .Take(10)
            .Select(g => new
            {
                g.NhomId,
                g.TenNhom,
                g.CreatedAt,
                TenLopHocPhan = g.DotDangKy != null && g.DotDangKy.LopHocPhan != null ? g.DotDangKy.LopHocPhan.TenLopHocPhan : null,
                Leader = g.TruongNhom != null && g.TruongNhom.NguoiDung != null ? g.TruongNhom.NguoiDung.HoTen : null
            })
            .ToListAsync();

        foreach (var group in recentGroups)
        {
            var lhp = group.TenLopHocPhan ?? "Lớp học phần";
            var leader = group.Leader ?? "Trưởng nhóm";
            var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, group.CreatedAt) : CalculateTimeDifference(group.CreatedAt);
            var id = 200000 + group.NhomId;
            var isRead = readSet.Contains(id);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Nhóm",
                title = $"Nhóm mới: {group.TenNhom}",
                content = $"{leader} đã thành lập nhóm '{group.TenNhom}' thuộc {lhp}.",
                time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        // 3. Đề tài mới được phê duyệt (Bảng DeTaiDoAns)
        var recentTopics = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.TrangThaiDuyet == "Đã duyệt")
            .OrderByDescending(t => t.UpdatedAt ?? t.CreatedAt)
            .Take(10)
            .Select(t => new
            {
                t.DeTaiId,
                t.TenDeTai,
                t.NguonDeTai,
                t.UpdatedAt,
                t.CreatedAt
            })
            .ToListAsync();

        foreach (var topic in recentTopics)
        {
            var eventTime = topic.UpdatedAt ?? topic.CreatedAt;
            var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, eventTime) : CalculateTimeDifference(eventTime);
            var id = 300000 + topic.DeTaiId;
            var isRead = readSet.Contains(id);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Đề tài",
                title = $"Đề tài đã duyệt: {topic.TenDeTai}",
                content = $"Đề tài '{topic.TenDeTai}' nguồn {topic.NguonDeTai} đã sẵn sàng cho sinh viên đăng ký.",
                time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        // 3.5 Đề xuất đề tài bị từ chối: chỉ hiển thị với tài khoản quản lý/giảng viên (sinh viên đã có myProposals riêng ở trên)
        if (!currentStudentId.HasValue)
        {
            var rejectedTopics = await _db.DeTaiDoAns.AsNoTracking()
                .Where(t => t.TrangThaiDuyet == "Từ chối" && t.SinhVienDeXuatId != null)
                .OrderByDescending(t => t.UpdatedAt ?? t.CreatedAt)
                .Take(10)
                .Select(t => new
                {
                    t.DeTaiId,
                    t.TenDeTai,
                    t.LyDoTuChoi,
                    t.UpdatedAt,
                    t.CreatedAt
                })
                .ToListAsync();

            foreach (var topic in rejectedTopics)
            {
                var eventTime = topic.UpdatedAt ?? topic.CreatedAt;
                var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, eventTime) : CalculateTimeDifference(eventTime);
                var id = 350000 + topic.DeTaiId;
                var isRead = readSet.Contains(id);
                var reason = !string.IsNullOrWhiteSpace(topic.LyDoTuChoi) ? topic.LyDoTuChoi : "Không có lý do cụ thể";

                notifications.Add(new NotificationItem
                {
                    id = id,
                    type = "Đề tài",
                    title = $"Đề xuất đề tài bị từ chối: {topic.TenDeTai}",
                    content = $"Đề xuất đề tài '{topic.TenDeTai}' bị từ chối. Lý do: {reason}",
                    time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                    isRead = isRead,
                    read = isRead,
                    createdAt = localCreated,
                    rejectionReason = reason,
                    lyDoTuChoi = reason
                });
            }
        }

        // 4. Đợt đăng ký đồ án (Bảng DotDangKyDoAns)
        var periods = await _db.DotDangKyDoAns.AsNoTracking()
            .Where(p => p.TrangThai == "Đang mở")
            .OrderByDescending(p => p.CreatedAt)
            .Take(5)
            .Select(p => new
            {
                p.DotDangKyId,
                p.TenDot,
                p.NgayBatDau,
                p.NgayKetThuc,
                p.CreatedAt,
                TenLopHocPhan = p.LopHocPhan != null ? p.LopHocPhan.TenLopHocPhan : null
            })
            .ToListAsync();

        var dbPeriodIds = userDbNotifs
            .Where(tb => tb.LoaiLienKet == "DotDangKyDoAn" && tb.LienKetId.HasValue)
            .Select(tb => tb.LienKetId!.Value)
            .ToHashSet();

        foreach (var period in periods)
        {
            if (dbPeriodIds.Contains(period.DotDangKyId)) continue;
            var lhp = period.TenLopHocPhan ?? "học phần";
            var eventTime = period.CreatedAt != default ? period.CreatedAt : period.NgayBatDau;
            var (timeDiff, localCreated) = countOnly ? (TimeSpan.Zero, eventTime) : CalculateTimeDifference(eventTime);
            var id = 400000 + period.DotDangKyId;
            var isRead = readSet.Contains(id);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Hệ thống",
                title = $"Đợt đăng ký đang mở: {period.TenDot}",
                content = $"Đợt đăng ký đồ án cho LHP {lhp} vừa được kích hoạt (tiếp nhận đến {period.NgayKetThuc:dd/MM/yyyy}).",
                time = countOnly ? string.Empty : FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        if (countOnly)
        {
            return notifications;
        }

        // Sắp xếp thống nhất 100% theo thời gian thực tế trong SQL giảm dần
        return notifications.OrderByDescending(n => n.createdAt).ToList();
    }

    private static (TimeSpan diff, DateTime localDate) CalculateTimeDifference(DateTime dbDate)
    {
        if (dbDate == default)
        {
            return (TimeSpan.Zero, DateTime.Now);
        }

        var now = DateTime.Now;

        // If explicitly stored as UTC
        if (dbDate.Kind == DateTimeKind.Utc)
        {
            var local = dbDate.ToLocalTime();
            var diff = now - local;
            return (diff < TimeSpan.Zero ? TimeSpan.Zero : diff, local);
        }

        // If unspecified kind (from SQL Server datetime2 column)
        var diffUtc = DateTime.UtcNow - dbDate;
        var diffNow = now - dbDate;

        if (diffUtc >= TimeSpan.Zero && diffUtc.TotalHours < 12 && diffNow.TotalHours >= 5)
        {
            // Was recorded with DateTime.UtcNow
            var local = DateTime.SpecifyKind(dbDate, DateTimeKind.Utc).ToLocalTime();
            var diff = now - local;
            return (diff < TimeSpan.Zero ? TimeSpan.Zero : diff, local);
        }

        return (diffNow < TimeSpan.Zero ? TimeSpan.Zero : diffNow, dbDate);
    }

    private static string FormatTimeAgo(TimeSpan span)
    {
        if (span.TotalSeconds < 0) span = TimeSpan.Zero;
        if (span.TotalMinutes < 1) return "Vừa xong";
        if (span.TotalMinutes < 60) return $"{(int)span.TotalMinutes} phút trước";
        if (span.TotalHours < 24) return $"{(int)span.TotalHours} giờ trước";
        if (span.TotalDays < 7) return $"{(int)span.TotalDays} ngày trước";
        if (span.TotalDays < 30) return $"{(int)(span.TotalDays / 7)} tuần trước";
        if (span.TotalDays < 365) return $"{(int)(span.TotalDays / 30)} tháng trước";
        return $"{(int)(span.TotalDays / 365)} năm trước";
    }

    public sealed class NotificationItem
    {
        public int id { get; set; }
        public string type { get; set; } = string.Empty;
        public string title { get; set; } = string.Empty;
        public string content { get; set; } = string.Empty;
        public string time { get; set; } = string.Empty;
        public bool isRead { get; set; }
        public bool read { get; set; }
        public DateTime createdAt { get; set; }
        public string? rejectionReason { get; set; }
        public string? lyDoTuChoi { get; set; }
    }
}
