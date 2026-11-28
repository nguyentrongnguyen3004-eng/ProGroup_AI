using Microsoft.EntityFrameworkCore;
using ProGroup_AI.API.Data;

namespace ProGroup_AI.API.Services;

/// <summary>
/// Dịch vụ chạy ngầm tự động sao lưu Cơ sở dữ liệu định kỳ (mỗi 12 tiếng) trong lúc hệ thống vận hành.
/// </summary>
public class DatabaseAutoBackupService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<DatabaseAutoBackupService> _logger;
    private readonly IWebHostEnvironment _env;

    public DatabaseAutoBackupService(
        IServiceProvider serviceProvider,
        ILogger<DatabaseAutoBackupService> logger,
        IWebHostEnvironment env)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
        _env = env;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // Chờ 15 phút sau khi server khởi động xong để tránh tranh chấp I/O và bộ nhớ lúc khởi động
        try
        {
            await Task.Delay(TimeSpan.FromMinutes(15), stoppingToken);
        }
        catch (OperationCanceledException)
        {
            return;
        }

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await PerformBackupAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "[Auto-Backup] Lỗi trong quá trình sao lưu tự động định kỳ.");
            }

            // Định kỳ sao lưu mỗi 12 giờ một lần
            try
            {
                await Task.Delay(TimeSpan.FromHours(12), stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }
    }

    private async Task PerformBackupAsync(CancellationToken ct)
    {
        using var scope = _serviceProvider.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var contentRoot = _env.ContentRootPath;
        var dir = new DirectoryInfo(contentRoot);
        while (dir != null && !File.Exists(Path.Combine(dir.FullName, "start_full_system.bat")))
        {
            dir = dir.Parent;
        }
        var repoRoot = dir?.FullName ?? contentRoot;
        var backupDir = Path.Combine(repoRoot, "backups");

        if (!Directory.Exists(backupDir))
        {
            Directory.CreateDirectory(backupDir);
        }

        var timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        var backupPath = Path.Combine(backupDir, $"ProjectRegistrationDB_backup_{timestamp}.bak");

        var sql = $"BACKUP DATABASE [ProjectRegistrationDB] TO DISK = N'{backupPath}' WITH FORMAT, INIT, STATS = 10";
        await db.Database.ExecuteSqlRawAsync(sql, ct);

        _logger.LogInformation("[Auto-Backup] Sao lưu cơ sở dữ liệu định kỳ thành công: {BackupPath}", backupPath);

        // Xoay vòng bản sao lưu: Giữ lại tối đa 7 bản gần nhất (chỉ xoay vòng file có timestamp, bảo toàn file ProjectRegistrationDB_latest.bak)
        try
        {
            var dirInfo = new DirectoryInfo(backupDir);
            var oldFiles = dirInfo.GetFiles("ProjectRegistrationDB_backup_*.bak")
                                  .OrderByDescending(f => f.CreationTime)
                                  .Skip(7)
                                  .ToList();

            foreach (var file in oldFiles)
            {
                file.Delete();
            }
        }
        catch { }
    }
}
