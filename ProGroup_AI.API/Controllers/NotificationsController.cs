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
public class NotificationsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public NotificationsController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyNotifications()
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
            return Unauthorized();

        var list = await _db.ThongBaos.AsNoTracking()
            .Where(x => x.NguoiDungId == userId)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new
            {
                id = x.ThongBaoId,
                title = x.TieuDe,
                content = x.NoiDung,
                type = x.LoaiThongBao,
                isRead = x.DaDoc,
                read = x.DaDoc,
                createdAt = x.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss"),
                linkId = x.LienKetId,
                linkType = x.LoaiLienKet
            })
            .ToListAsync();

        return Ok(list);
    }

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
            return Unauthorized();

        var notification = await _db.ThongBaos.FirstOrDefaultAsync(x => x.ThongBaoId == id && x.NguoiDungId == userId);
        if (notification == null) return NotFound(new { message = "Không tìm thấy thông báo." });

        notification.DaDoc = true;
        await _db.SaveChangesAsync();
        return Ok(new { success = true, message = "Đã đánh dấu đã đọc." });
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
            return Unauthorized();

        var unread = await _db.ThongBaos.Where(x => x.NguoiDungId == userId && !x.DaDoc).ToListAsync();
        foreach (var item in unread)
        {
            item.DaDoc = true;
        }

        await _db.SaveChangesAsync();
        return Ok(new { success = true, message = "Đã đánh dấu tất cả thông báo là đã đọc." });
    }

    [HttpPost]
    public async Task<IActionResult> SendNotification([FromBody] CreateNotificationRequest request)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var senderId))
            return Unauthorized();

        var notif = new ThongBao
        {
            NguoiDungId = request.NguoiDungId,
            TieuDe = request.TieuDe,
            NoiDung = request.NoiDung,
            LoaiThongBao = request.LoaiThongBao ?? "Hệ thống",
            DaDoc = false,
            CreatedAt = DateTime.Now,
            LienKetId = request.LienKetId,
            LoaiLienKet = request.LoaiLienKet
        };

        _db.ThongBaos.Add(notif);
        await _db.SaveChangesAsync();

        return Ok(new { success = true, id = notif.ThongBaoId });
    }
}

public class CreateNotificationRequest
{
    public int NguoiDungId { get; set; }
    public string TieuDe { get; set; } = string.Empty;
    public string NoiDung { get; set; } = string.Empty;
    public string? LoaiThongBao { get; set; }
    public int? LienKetId { get; set; }
    public string? LoaiLienKet { get; set; }
}
