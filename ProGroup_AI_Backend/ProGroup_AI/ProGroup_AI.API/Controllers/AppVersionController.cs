using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace ProGroup_AI.API.Controllers;

[ApiController]
[Route("api/app")]
[AllowAnonymous]
public class AppVersionController : ControllerBase
{
    private readonly IWebHostEnvironment _env;

    public AppVersionController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpGet("version")]
    public IActionResult GetLatestVersion()
    {
        var wwwroot = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
        var downloadsDir = Path.Combine(wwwroot, "downloads");
        if (!Directory.Exists(downloadsDir))
        {
            Directory.CreateDirectory(downloadsDir);
        }

        var apkPath = Path.Combine(downloadsDir, "app-latest.apk");
        long apkSize = 0;
        string apkSizeFormatted = "165 MB";

        if (System.IO.File.Exists(apkPath))
        {
            var fileInfo = new FileInfo(apkPath);
            apkSize = fileInfo.Length;
            if (apkSize > 0)
            {
                apkSizeFormatted = $"{apkSize / (1024 * 1024)} MB";
            }
        }

        var scheme = Request.Headers["X-Forwarded-Proto"].FirstOrDefault() ?? Request.Scheme;
        var host = Request.Host.Value ?? "";
        if (host.Contains("trycloudflare.com"))
        {
            scheme = "https";
        }
        var downloadUrl = $"{scheme}://{host}/downloads/app-latest.apk";

        string version = "1.0.2";
        int versionCode = 2;
        string minSupportedVersion = "1.0.0";
        string changelog = "• Tự động đồng bộ Avatar theo từng vai trò (Cá nhân -> Trang chủ)\n• Hỗ trợ cập nhật ứng dụng tự động 1-chạm (In-App Auto Update)\n• Tối ưu hóa hiệu năng và kết nối Backend";
        bool isForceUpdate = false;
        string releaseDate = DateTime.Now.ToString("dd/MM/yyyy HH:mm");

        var metaPath = Path.Combine(downloadsDir, "version.json");
        if (System.IO.File.Exists(metaPath))
        {
            try
            {
                var jsonStr = System.IO.File.ReadAllText(metaPath);
                using var doc = System.Text.Json.JsonDocument.Parse(jsonStr);
                var root = doc.RootElement;
                if (root.TryGetProperty("version", out var v)) version = v.GetString() ?? version;
                if (root.TryGetProperty("versionCode", out var vc)) versionCode = vc.GetInt32();
                if (root.TryGetProperty("minSupportedVersion", out var mv)) minSupportedVersion = mv.GetString() ?? minSupportedVersion;
                if (root.TryGetProperty("changelog", out var cl)) changelog = cl.GetString() ?? changelog;
                if (root.TryGetProperty("isForceUpdate", out var fu)) isForceUpdate = fu.GetBoolean();
                if (root.TryGetProperty("releaseDate", out var rd)) releaseDate = rd.GetString() ?? releaseDate;
            }
            catch { }
        }

        return Ok(new
        {
            success = true,
            version = version,
            versionCode = versionCode,
            minSupportedVersion = minSupportedVersion,
            changelog = changelog,
            downloadUrl = downloadUrl,
            fileSize = apkSizeFormatted,
            isForceUpdate = isForceUpdate,
            releaseDate = releaseDate
        });
    }
}
