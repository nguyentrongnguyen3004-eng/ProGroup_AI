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
    public IActionResult MarkAsRead(int id)
    {
        var userId = GetCurrentUserId();
        var set = _userReadNotifications.GetOrAdd(userId, _ => new HashSet<int>());
        lock (set)
        {
            set.Add(id);
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
        int idCounter = 1;

        _userReadNotifications.TryGetValue(userId, out var readSet);

        // 1. Đăng ký đề tài gần đây
        var recentRegistrations = await _db.DangKyDeTais.AsNoTracking()
            .Include(r => r.Nhom)
            .Include(r => r.DeTai)
            .OrderByDescending(r => r.NgayDangKy)
            .Take(10)
            .ToListAsync();

        foreach (var reg in recentRegistrations)
        {
            var tenNhom = reg.Nhom?.TenNhom ?? "Nhóm";
            var tenDeTai = reg.DeTai?.TenDeTai ?? "Đề tài";
            var timeDiff = DateTime.Now - reg.NgayDangKy;
            var timeStr = FormatTimeAgo(timeDiff);
            var id = idCounter++;
            var isRead = (readSet != null && readSet.Contains(id)) || reg.TrangThai == "Đã duyệt";

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Đăng ký",
                title = $"Đăng ký đề tài: {tenDeTai}",
                content = $"{tenNhom} đã đăng ký đề tài và đang ở trạng thái '{reg.TrangThai}'.",
                time = timeStr,
                isRead = isRead,
                read = isRead,
                createdAt = reg.NgayDangKy
            });
        }

        // 2. Nhóm đồ án mới thành lập
        var recentGroups = await _db.NhomDoAns.AsNoTracking()
            .Include(g => g.DotDangKy).ThenInclude(d => d!.LopHocPhan)
            .Include(g => g.TruongNhom).ThenInclude(s => s!.NguoiDung)
            .OrderByDescending(g => g.NhomId)
            .Take(8)
            .ToListAsync();

        foreach (var group in recentGroups)
        {
            var lhp = group.DotDangKy?.LopHocPhan?.TenLopHocPhan ?? "Lớp học phần";
            var leader = group.TruongNhom?.NguoiDung?.HoTen ?? "Trưởng nhóm";
            var id = idCounter++;
            var isRead = (readSet != null && readSet.Contains(id)) || (id % 2 == 0);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Nhóm",
                title = $"Nhóm mới: {group.TenNhom}",
                content = $"{leader} đã thành lập nhóm '{group.TenNhom}' thuộc {lhp}.",
                time = "Gần đây",
                isRead = isRead,
                read = isRead,
                createdAt = DateTime.Now.AddHours(-id)
            });
        }

        // 3. Đề tài mới được phê duyệt
        var recentTopics = await _db.DeTaiDoAns.AsNoTracking()
            .Where(t => t.TrangThaiDuyet == "Đã duyệt")
            .OrderByDescending(t => t.DeTaiId)
            .Take(6)
            .ToListAsync();

        foreach (var topic in recentTopics)
        {
            var id = idCounter++;
            var isRead = (readSet != null && readSet.Contains(id)) || true;

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Đề tài",
                title = $"Đề tài đã duyệt: {topic.TenDeTai}",
                content = $"Đề tài '{topic.TenDeTai}' nguồn {topic.NguonDeTai} đã sẵn sàng cho sinh viên đăng ký.",
                time = "1 ngày trước",
                isRead = isRead,
                read = isRead,
                createdAt = DateTime.Now.AddDays(-1)
            });
        }

        // 4. Đợt đăng ký đồ án
        var periods = await _db.DotDangKyDoAns.AsNoTracking()
            .Include(p => p.LopHocPhan)
            .Where(p => p.TrangThai == "Đang mở")
            .Take(5)
            .ToListAsync();

        foreach (var period in periods)
        {
            var lhp = period.LopHocPhan?.TenLopHocPhan ?? "học phần";
            var id = idCounter++;
            var isRead = readSet != null && readSet.Contains(id);

            notifications.Add(new NotificationItem
            {
                id = id,
                type = "Hệ thống",
                title = $"Đợt đăng ký đang mở: {period.TenDot}",
                content = $"Đợt đăng ký {period.TenDot} cho {lhp} đang tiếp nhận đăng ký đến {period.NgayKetThuc:dd/MM/yyyy}.",
                time = "Hôm nay",
                isRead = isRead,
                read = isRead,
                createdAt = period.NgayBatDau
            });
        }

        return notifications;
    }

    private static string FormatTimeAgo(TimeSpan span)
    {
        if (span.TotalMinutes < 1) return "Vừa xong";
        if (span.TotalMinutes < 60) return $"{(int)span.TotalMinutes} phút trước";
        if (span.TotalHours < 24) return $"{(int)span.TotalHours} giờ trước";
        if (span.TotalDays < 7) return $"{(int)span.TotalDays} ngày trước";
        return $"{(int)(span.TotalDays / 7)} tuần trước";
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
