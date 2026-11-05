namespace ProGroup_AI.API.Services;

public interface ICloudflareR2Service
{
    bool IsConfigured { get; }
    Task<string?> UploadAvatarAsync(byte[] imageBytes, string fileName, string contentType);
    Task<bool> DeleteAvatarAsync(string fileUrl);
}
