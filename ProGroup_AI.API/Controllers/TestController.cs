using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    [HttpGet("public")]
    public IActionResult Public()
    {
        return Ok(new
        {
            message = "API public hoạt động."
        });
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