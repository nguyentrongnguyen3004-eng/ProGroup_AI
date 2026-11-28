using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Controllers;

public class AiSuggestTopicsRequest
{
    public string? ChuyenNganh { get; set; }
    public string? DinhHuong { get; set; }
    public string? CongNghe { get; set; }
}

public class AiStandardizeTopicRequest
{
    public string TenDeTai { get; set; } = string.Empty;
    public string? MoTa { get; set; }
    public string? CongNghe { get; set; }
}

[ApiController]
[Route("api/ai")]
[Authorize]
public class AiController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public AiController(ApplicationDbContext db)
    {
        _db = db;
    }

    private int? GetCurrentUserId()
    {
        var idVal = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idVal, out var id) ? id : null;
    }

    /// <summary>
    /// Gợi ý ý tưởng đề tài theo định hướng chuyên ngành và lưu vết vào AIRequests
    /// </summary>
    [HttpPost("suggest-topics")]
    public async Task<IActionResult> SuggestTopics([FromBody] AiSuggestTopicsRequest request)
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized(new { message = "Chưa xác thực." });

        var prompt = $"Gợi ý đề tài đồ án tốt nghiệp chuyên ngành: {request.ChuyenNganh ?? "Công nghệ thông tin"}, Định hướng: {request.DinhHuong ?? "Phần mềm & AI"}, Công nghệ: {request.CongNghe ?? "Flutter, ASP.NET Core"}";

        var suggestions = new[]
        {
            new
            {
                TenDeTai = "Hệ thống Quản lý và Đăng ký Đồ án Tốt nghiệp tích hợp AI (ProGroup AI)",
                MucTieu = "Xây dựng nền tảng hỗ trợ sinh viên lập nhóm, đề xuất đề tài và phân công giảng viên tự động với AI hỗ trợ.",
                CongNgheDuKien = "Flutter, ASP.NET Core Web API, SQL Server, Google Gemini AI, Firebase Cloud Messaging",
                PhamVi = "Triển khai thử nghiệm cho khoa Công nghệ Thông tin trường Đại học",
                KetQuaDuKien = "Ứng dụng di động iOS/Android, Web API backend bảo mật JWT, module gợi ý và chuẩn hóa đề tài tự động."
            },
            new
            {
                TenDeTai = "Ứng dụng Điểm danh Sinh viên Thông minh qua Nhận diện Khuôn mặt đa góc nghiêng",
                MucTieu = "Tự động hóa công tác điểm danh trong lớp học phần, ngăn ngừa gian lận.",
                CongNgheDuKien = "Flutter, Python FastAPI, YOLOv8, FaceNet, PostgreSQL",
                PhamVi = "Triển khai cho các giảng đường có camera góc rộng",
                KetQuaDuKien = "Tốc độ nhận diện < 500ms, độ chính xác đạt trên 98%."
            },
            new
            {
                TenDeTai = "Nền tảng Ôn luyện Phỏng vấn Kỹ thuật IT với Trợ lý Ảo AI phỏng vấn trực tiếp",
                MucTieu = "Giúp sinh viên thực hành phỏng vấn lập trình viên và nhận đánh giá năng lực thời gian thực.",
                CongNgheDuKien = "React Native / Flutter, Node.js, WebRTC, Gemini Live API",
                PhamVi = "Hỗ trợ các vị trí Frontend, Backend, Mobile, DevOps",
                KetQuaDuKien = "Sinh viên được chấm điểm chi tiết theo rubric tiêu chuẩn doanh nghiệp."
            }
        };

        var responseText = System.Text.Json.JsonSerializer.Serialize(suggestions);

        var logEntry = new AIRequest
        {
            NguoiDungId = userId.Value,
            ChucNangAI = "Gợi ý đề tài",
            Prompt = prompt,
            Response = responseText,
            TrangThai = "Thành công",
            CreatedAt = DateTime.Now
        };

        _db.AIRequests.Add(logEntry);
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            requestId = logEntry.AIRequestId,
            prompt = prompt,
            suggestions = suggestions,
            createdAt = logEntry.CreatedAt
        });
    }

    /// <summary>
    /// Chuẩn hóa mục tiêu, công nghệ và dự kiến kết quả đề tài & lưu vết AIRequests
    /// </summary>
    [HttpPost("standardize-topic")]
    public async Task<IActionResult> StandardizeTopic([FromBody] AiStandardizeTopicRequest request)
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized(new { message = "Chưa xác thực." });

        if (string.IsNullOrWhiteSpace(request.TenDeTai))
        {
            return BadRequest(new { success = false, message = "Tên đề tài không được để trống." });
        }

        var prompt = $"Chuẩn hóa đề cương đề tài: '{request.TenDeTai}'. Mô tả ban đầu: '{request.MoTa}'. Công nghệ: '{request.CongNghe}'";

        var standardizedResult = new
        {
            TenDeTai = request.TenDeTai.Trim(),
            MucTieu = "Xây dựng hệ thống hoàn chỉnh giải quyết triệt để bài toán quản lý, tối ưu thời gian thao tác của người dùng và đảm bảo an toàn dữ liệu.",
            PhamVi = "Áp dụng cho quy mô toàn trường đại học, phục vụ đồng thời tối thiểu 1.000 người dùng trong mùa đăng ký cao điểm.",
            CongNgheDuKien = !string.IsNullOrWhiteSpace(request.CongNghe) ? request.CongNghe.Trim() : "Flutter 3.x, ASP.NET Core 10, SQL Server, Redis Cache, Docker",
            KetQuaDuKien = "Bộ mã nguồn chuẩn clean architecture, tài liệu đặc tả API Swagger, ứng dụng di động hoàn chỉnh và báo cáo nghiệm thu kỹ thuật."
        };

        var responseText = System.Text.Json.JsonSerializer.Serialize(standardizedResult);

        var logEntry = new AIRequest
        {
            NguoiDungId = userId.Value,
            ChucNangAI = "Chuẩn hóa đề tài",
            Prompt = prompt,
            Response = responseText,
            TrangThai = "Thành công",
            CreatedAt = DateTime.Now
        };

        _db.AIRequests.Add(logEntry);
        await _db.SaveChangesAsync();

        return Ok(new
        {
            success = true,
            requestId = logEntry.AIRequestId,
            standardizedTopic = standardizedResult,
            createdAt = logEntry.CreatedAt
        });
    }

    /// <summary>
    /// Xem lịch sử các yêu cầu AI của người dùng
    /// </summary>
    [HttpGet("history")]
    public async Task<IActionResult> GetHistory()
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        var query = _db.AIRequests.AsNoTracking().AsQueryable();

        // Nếu không phải admin hoặc giáo vụ thì chỉ xem của chính mình
        if (!User.IsInRole("ADMIN") && !User.IsInRole("GIAOVUKHOA"))
        {
            query = query.Where(x => x.NguoiDungId == userId.Value);
        }

        var history = await query
            .OrderByDescending(x => x.CreatedAt)
            .Take(50)
            .Select(x => new
            {
                x.AIRequestId,
                x.NguoiDungId,
                x.ChucNangAI,
                x.Prompt,
                x.Response,
                x.TrangThai,
                x.CreatedAt
            })
            .ToListAsync();

        return Ok(history);
    }
}
