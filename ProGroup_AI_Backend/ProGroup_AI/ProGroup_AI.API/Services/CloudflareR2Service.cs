using Amazon.Runtime;
using Amazon.S3;
using Amazon.S3.Model;

namespace ProGroup_AI.API.Services;

public class CloudflareR2Service : ICloudflareR2Service
{
    private readonly ILogger<CloudflareR2Service> _logger;
    private readonly IAmazonS3? _s3Client;
    private readonly string _bucketName;
    private readonly string _publicUrl;
    private readonly bool _isConfigured;

    public bool IsConfigured => _isConfigured;

    public CloudflareR2Service(IConfiguration configuration, ILogger<CloudflareR2Service> logger)
    {
        _logger = logger;
        var section = configuration.GetSection("CloudflareR2");

        var accountId = section["AccountId"]?.Trim() ?? string.Empty;
        _bucketName = section["BucketName"]?.Trim() ?? "progroup-avatars";
        _publicUrl = (section["PublicUrl"]?.Trim() ?? string.Empty).TrimEnd('/');
        var accessKeyId = section["AccessKeyId"]?.Trim() ?? string.Empty;
        var secretAccessKey = section["SecretAccessKey"]?.Trim() ?? string.Empty;

        if (!string.IsNullOrWhiteSpace(accountId) &&
            !string.IsNullOrWhiteSpace(_bucketName) &&
            !string.IsNullOrWhiteSpace(accessKeyId) &&
            !string.IsNullOrWhiteSpace(secretAccessKey))
        {
            try
            {
                var credentials = new BasicAWSCredentials(accessKeyId, secretAccessKey);
                var config = new AmazonS3Config
                {
                    ServiceURL = $"https://{accountId}.r2.cloudflarestorage.com",
                    ForcePathStyle = true
                };

                _s3Client = new AmazonS3Client(credentials, config);
                _isConfigured = true;
                _logger.LogInformation("Cloudflare R2 Service đã được khởi tạo thành công (Bucket: {Bucket}).", _bucketName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi khởi tạo Cloudflare R2 S3 Client.");
                _isConfigured = false;
            }
        }
        else
        {
            _logger.LogWarning("Cloudflare R2 chưa được cấu hình đầy đủ (Thiếu AccessKeyId hoặc SecretAccessKey). Tạm thời sử dụng Local Storage.");
            _isConfigured = false;
        }
    }

    public async Task<string?> UploadAvatarAsync(byte[] imageBytes, string fileName, string contentType)
    {
        if (!_isConfigured || _s3Client == null)
        {
            return null;
        }

        try
        {
            var key = $"avatars/{fileName}";
            using var stream = new MemoryStream(imageBytes);

            var putRequest = new PutObjectRequest
            {
                BucketName = _bucketName,
                Key = key,
                InputStream = stream,
                ContentType = contentType,
                DisablePayloadSigning = true
            };

            var response = await _s3Client.PutObjectAsync(putRequest);

            if (response.HttpStatusCode is System.Net.HttpStatusCode.OK or System.Net.HttpStatusCode.Created or System.Net.HttpStatusCode.Accepted)
            {
                var cdnUrl = !string.IsNullOrWhiteSpace(_publicUrl)
                    ? $"{_publicUrl}/{key}"
                    : $"https://{_bucketName}.r2.cloudflarestorage.com/{key}";

                _logger.LogInformation("Upload ảnh đại diện lên Cloudflare R2 thành công: {Url}", cdnUrl);
                return cdnUrl;
            }

            _logger.LogWarning("Upload ảnh lên Cloudflare R2 không nhận được mã OK. Mã phản hồi: {StatusCode}", response.HttpStatusCode);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi trong quá trình upload ảnh đại diện lên Cloudflare R2.");
            return null;
        }
    }

    public async Task<bool> DeleteAvatarAsync(string fileUrl)
    {
        if (!_isConfigured || _s3Client == null || string.IsNullOrWhiteSpace(fileUrl))
        {
            return false;
        }

        try
        {
            // Lấy key từ URL (ví dụ: .../avatars/user_1_123.jpg => avatars/user_1_123.jpg)
            var uri = new Uri(fileUrl);
            var key = uri.AbsolutePath.TrimStart('/');

            var deleteRequest = new DeleteObjectRequest
            {
                BucketName = _bucketName,
                Key = key
            };

            await _s3Client.DeleteObjectAsync(deleteRequest);
            _logger.LogInformation("Đã xóa ảnh trên Cloudflare R2: {Key}", key);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Không thể xóa ảnh trên Cloudflare R2 URL: {Url}", fileUrl);
            return false;
        }
    }
}
