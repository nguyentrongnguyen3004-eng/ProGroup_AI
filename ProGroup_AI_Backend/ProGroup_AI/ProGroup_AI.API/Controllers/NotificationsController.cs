using System.Collections.Concurrent;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;

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
        var notifications = await GenerateNotificationsAsync(userId);
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

        return Ok(new { success = true, message = "Đã đánh dấu thông báo đã đọc.", id });
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var userId = GetCurrentUserId();
        var notifications = await GenerateNotificationsAsync(userId);
        var set = _userReadNotifications.GetOrAdd(userId, _ => new HashSet<int>());
        lock (set)
        {
            foreach (var n in notifications)
            {
                set.Add(n.id);
            }
        }

        var dbNotifs = await _db.ThongBaos.Where(t => t.NguoiDungId == userId && !t.DaDoc).ToListAsync();
        if (dbNotifs.Any())
        {
            foreach (var tb in dbNotifs)
            {
                tb.DaDoc = true;
            }
            await _db.SaveChangesAsync();
        }

        return Ok(new { success = true, message = "Đã đánh dấu tất cả thông báo đã đọc." });
    }

    private int GetCurrentUserId()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idClaim, out var id) ? id : 0;
    }

    private async Task<List<NotificationItem>> GenerateNotificationsAsync(int userId)
    {
        var notifications = new List<NotificationItem>();

        _userReadNotifications.TryGetValue(userId, out var readSet);

        // 0. Thông báo thực tế gửi riêng cho người dùng từ DB (Bảng ThongBaos)
        var userDbNotifs = await _db.ThongBaos.AsNoTracking()
            .Where(t => t.NguoiDungId == userId)
            .OrderByDescending(t => t.CreatedAt)
            .Take(40)
            .ToListAsync();

        foreach (var tb in userDbNotifs)
        {
            var isRead = tb.DaDoc || (readSet != null && readSet.Contains(tb.ThongBaoId));
            var (timeDiff, localCreated) = CalculateTimeDifference(tb.CreatedAt);

            notifications.Add(new NotificationItem
            {
                id = tb.ThongBaoId,
                type = tb.LoaiThongBao ?? "Hệ thống",
                title = tb.TieuDe,
                content = tb.NoiDung,
                time = FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        // 1. Đăng ký đề tài gần đây (Bảng DangKyDeTais)
        var recentRegistrations = await _db.DangKyDeTais.AsNoTracking()
            .Include(r => r.Nhom)
            .Include(r => r.DeTai)
            .OrderByDescending(r => r.NgayDangKy)
            .Take(12)
            .ToListAsync();

        foreach (var reg in recentRegistrations)
        {
            var tenNhom = reg.Nhom?.TenNhom ?? "Nhóm";
            var tenDeTai = reg.DeTai?.TenDeTai ?? "Đề tài";
            var (timeDiff, localCreated) = CalculateTimeDifference(reg.NgayDangKy);
            var id = 100000 + reg.DangKyDeTaiId;
            var isRead = (readSet != null && readSet.Contains(id)) || reg.TrangThai == "Đã duyệt";

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
                time = FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        // 2. Nhóm đồ án mới thành lập (Bảng NhomDoAns)
        var recentGroups = await _db.NhomDoAns.AsNoTracking()
            .Include(g => g.DotDangKy).ThenInclude(d => d!.LopHocPhan)
            .Include(g => g.TruongNhom).ThenInclude(s => s!.NguoiDung)
            .OrderByDescending(g => g.CreatedAt)
            .Take(10)
            .ToListAsync();

        foreach (var group in recentGroups)
        {
            var lhp = group.DotDangKy?.LopHocPhan?.TenLopHocPhan ?? "Lớp học phần";
            var leader = group.TruongNhom?.NguoiDung?.HoTen ?? "Trưởng nhóm";
            var (timeDiff, localCreated) = CalculateTimeDifference(group.CreatedAt);
            var id = 200000 + group.NhomId;
            var isRead = readSet != null && readSet.Contains(id);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Nhóm",
                title = $"Nhóm mới: {group.TenNhom}",
                content = $"{leader} đã thành lập nhóm '{group.TenNhom}' thuộc {lhp}.",
                time = FormatTimeAgo(timeDiff),
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
            .ToListAsync();

        foreach (var topic in recentTopics)
        {
            var eventTime = topic.UpdatedAt ?? topic.CreatedAt;
            var (timeDiff, localCreated) = CalculateTimeDifference(eventTime);
            var id = 300000 + topic.DeTaiId;
            var isRead = readSet != null && readSet.Contains(id);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Đề tài",
                title = $"Đề tài đã duyệt: {topic.TenDeTai}",
                content = $"Đề tài '{topic.TenDeTai}' nguồn {topic.NguonDeTai} đã sẵn sàng cho sinh viên đăng ký.",
                time = FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        // 3.5 Đề xuất đề tài bị từ chối (Bảng DeTaiDoAns)
        var rejectedTopics = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.TrangThaiDuyet == "Từ chối" && t.SinhVienDeXuatId != null)
            .OrderByDescending(t => t.UpdatedAt ?? t.CreatedAt)
            .Take(10)
            .ToListAsync();

        foreach (var topic in rejectedTopics)
        {
            var eventTime = topic.UpdatedAt ?? topic.CreatedAt;
            var (timeDiff, localCreated) = CalculateTimeDifference(eventTime);
            var id = 350000 + topic.DeTaiId;
            var isRead = readSet != null && readSet.Contains(id);
            var reason = !string.IsNullOrWhiteSpace(topic.LyDoTuChoi) ? topic.LyDoTuChoi : "Không có lý do cụ thể";

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Đề tài",
                title = $"Đề xuất đề tài bị từ chối: {topic.TenDeTai}",
                content = $"Đề xuất đề tài '{topic.TenDeTai}' bị từ chối. Lý do: {reason}",
                time = FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
        }

        // 4. Đợt đăng ký đồ án (Bảng DotDangKyDoAns)
        var periods = await _db.DotDangKyDoAns.AsNoTracking()
            .Include(p => p.LopHocPhan)
            .Where(p => p.TrangThai == "Đang mở")
            .OrderByDescending(p => p.CreatedAt)
            .Take(5)
            .ToListAsync();

        foreach (var period in periods)
        {
            var lhp = period.LopHocPhan?.TenLopHocPhan ?? "học phần";
            var eventTime = period.CreatedAt != default ? period.CreatedAt : period.NgayBatDau;
            var (timeDiff, localCreated) = CalculateTimeDifference(eventTime);
            var id = 400000 + period.DotDangKyId;
            var isRead = readSet != null && readSet.Contains(id);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Hệ thống",
                title = $"Đợt đăng ký đang mở: {period.TenDot}",
                content = $"Đợt đăng ký {period.TenDot} cho {lhp} đang tiếp nhận đăng ký đến {period.NgayKetThuc:dd/MM/yyyy}.",
                time = FormatTimeAgo(timeDiff),
                isRead = isRead,
                read = isRead,
                createdAt = localCreated
            });
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
    }
}
