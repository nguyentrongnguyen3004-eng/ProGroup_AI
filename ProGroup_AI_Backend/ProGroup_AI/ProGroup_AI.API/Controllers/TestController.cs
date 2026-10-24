using System.Security.Claims;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly IWebHostEnvironment _environment;

    public TestController(ApplicationDbContext db, IWebHostEnvironment environment)
    {
        _db = db;
        _environment = environment;
    }

    [HttpGet("public")]
    public IActionResult Public()
    {
        return Ok(new
        {
            message = "API public hoạt động."
        });
    }

    [HttpGet("database")]
    public async Task<IActionResult> Database(CancellationToken cancellationToken)
    {
        if (!_environment.IsDevelopment()) return NotFound();

        var connection = _db.Database.GetDbConnection();
        try
        {
            await _db.Database.OpenConnectionAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = """
                SELECT
                    DB_NAME() AS DatabaseName,
                    CASE WHEN OBJECT_ID(N'dbo.NguoiDungs', N'U') IS NOT NULL
                              AND OBJECT_ID(N'dbo.VaiTros', N'U') IS NOT NULL THEN 1 ELSE 0 END AS TablesExist,
                    CASE WHEN COL_LENGTH(N'dbo.NguoiDungs', N'TenDangNhap') IS NOT NULL
                              AND COL_LENGTH(N'dbo.NguoiDungs', N'MatKhauHash') IS NOT NULL
                              AND COL_LENGTH(N'dbo.NguoiDungs', N'VaiTroId') IS NOT NULL
                              AND COL_LENGTH(N'dbo.NguoiDungs', N'TrangThai') IS NOT NULL
                              AND COL_LENGTH(N'dbo.NguoiDungs', N'AvatarUrl') IS NOT NULL
                              AND COL_LENGTH(N'dbo.NguoiDungs', N'CreatedAt') IS NOT NULL
                              AND COL_LENGTH(N'dbo.NguoiDungs', N'UpdatedAt') IS NOT NULL
                              AND COL_LENGTH(N'dbo.VaiTros', N'MaVaiTro') IS NOT NULL
                              AND COL_LENGTH(N'dbo.VaiTros', N'TenVaiTro') IS NOT NULL THEN 1 ELSE 0 END AS LoginColumnsExist;
                """;

            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            await reader.ReadAsync(cancellationToken);
            var databaseName = reader.IsDBNull(0) ? null : reader.GetString(0);
            var tablesExist = reader.GetInt32(1) == 1;
            var loginColumnsExist = reader.GetInt32(2) == 1;

            return Ok(new
            {
                status = !tablesExist ? "schema_tables_missing_or_hidden" :
                    !loginColumnsExist ? "schema_columns_mismatch" : "connected",
                database = databaseName,
                tablesExist,
                loginColumnsExist,
                message = !tablesExist ? "Kết nối được database nhưng không thấy đủ bảng xác thực (thiếu bảng hoặc tài khoản không thấy metadata)."
                    : !loginColumnsExist ? "Kết nối được database nhưng thiếu cột cần cho mapping đăng nhập hiện tại."
                    : "Kết nối database và các bảng/cột xác thực thành công."
            });
        }
        catch (SqlException exception)
        {
            var (category, message) = ClassifySqlException(exception);
            return StatusCode(StatusCodes.Status503ServiceUnavailable, new
            {
                status = "connection_failed",
                category,
                message,
                traceId = HttpContext.TraceIdentifier
            });
        }
        catch (Exception)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, new
            {
                status = "diagnostic_failed",
                message = "Không thể hoàn tất kiểm tra database. Xem log ứng dụng theo traceId.",
                traceId = HttpContext.TraceIdentifier
            });
        }
        finally
        {
            if (connection.State == System.Data.ConnectionState.Open)
                await _db.Database.CloseConnectionAsync();
        }
    }

    private static (string Category, string Message) ClassifySqlException(SqlException exception)
    {
        if (exception.Number == 18456)
            return ("authentication_failed", "SQL Server từ chối thông tin xác thực của tiến trình backend.");

        if (exception.Number is 4060 or 4064)
            return ("database_unavailable_or_access_denied", "Không mở được database được cấu hình; database có thể không tồn tại hoặc tài khoản không có quyền truy cập.");

        if (exception.Number is 229 or 297 or 916)
            return ("database_access_denied", "Tài khoản kết nối không có quyền cần thiết trên database.");

        if (exception.Number is -2 or 2 or 26 or 40 or 53 or 258 or 10060 or 10061 or 11001)
            return ("server_instance_or_network_unavailable", "Không liên lạc được SQL Server instance; kiểm tra service, tên instance, SQL Browser/protocol và mạng.");

        return ("sql_server_error", "SQL Server trả lỗi trong lúc kiểm tra. Xem log ứng dụng theo traceId.");
    }


    [Authorize]
    [HttpGet("private")]
    public IActionResult Private()
    {
        var userId =
            User.FindFirstValue(
                ClaimTypes.NameIdentifier
            );

        var username =
            User.FindFirstValue(
                "TenDangNhap"
            );

        var role =
            User.FindFirstValue(
                ClaimTypes.Role
            );

        var name =
            User.FindFirstValue(
                ClaimTypes.Name
            );

        return Ok(new
        {
            message = "JWT xác thực thành công.",

            userId,

            username,

            name,

            role
        });
    }
}
