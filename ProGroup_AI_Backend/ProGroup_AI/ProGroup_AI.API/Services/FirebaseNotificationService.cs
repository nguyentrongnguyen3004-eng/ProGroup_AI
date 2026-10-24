using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;

namespace ProGroup_AI.API.Services;

public interface IFirebaseNotificationService
{
    Task<string?> SendPushNotificationAsync(string fcmToken, string title, string body, Dictionary<string, string>? data = null);
    Task<int> SendPushNotificationToTopicAsync(string topic, string title, string body, Dictionary<string, string>? data = null);
}

public class FirebaseNotificationService : IFirebaseNotificationService
{
    private readonly ILogger<FirebaseNotificationService> _logger;
    private readonly bool _isConfigured;

    public FirebaseNotificationService(IConfiguration configuration, ILogger<FirebaseNotificationService> logger)
    {
        _logger = logger;
        try
        {
            var credentialPath = configuration["Firebase:CredentialPath"] ?? "Properties/firebase-admin-sdk.json";
            if (File.Exists(credentialPath))
            {
                if (FirebaseApp.DefaultInstance == null)
                {
                    FirebaseApp.Create(new AppOptions
                    {
                        Credential = GoogleCredential.FromFile(credentialPath)
                    });
                }
                _isConfigured = true;
                _logger.LogInformation("Firebase Admin SDK đã được khởi tạo thành công từ {Path}.", credentialPath);
            }
            else
            {
                _logger.LogWarning("Không tìm thấy file Firebase Service Account tại {Path}. Push notification tạm thời chưa khả dụng.", credentialPath);
                _isConfigured = false;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi khởi tạo Firebase Admin SDK.");
            _isConfigured = false;
        }
    }

    public async Task<string?> SendPushNotificationAsync(string fcmToken, string title, string body, Dictionary<string, string>? data = null)
    {
        if (!_isConfigured || string.IsNullOrWhiteSpace(fcmToken)) return null;

        try
        {
            var message = new FirebaseAdmin.Messaging.Message
            {
                Token = fcmToken,
                Notification = new FirebaseAdmin.Messaging.Notification
                {
                    Title = title,
                    Body = body
                },
                Data = data
            };

            var response = await FirebaseAdmin.Messaging.FirebaseMessaging.DefaultInstance.SendAsync(message);
            _logger.LogInformation("Gửi FCM thành công tới thiết bị. Message ID: {MessageId}", response);
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi gửi FCM notification tới token {Token}", fcmToken);
            return null;
        }
    }

    public async Task<int> SendPushNotificationToTopicAsync(string topic, string title, string body, Dictionary<string, string>? data = null)
    {
        if (!_isConfigured || string.IsNullOrWhiteSpace(topic)) return 0;

        try
        {
            var message = new FirebaseAdmin.Messaging.Message
            {
                Topic = topic,
                Notification = new FirebaseAdmin.Messaging.Notification
                {
                    Title = title,
                    Body = body
                },
                Data = data
            };

            var response = await FirebaseAdmin.Messaging.FirebaseMessaging.DefaultInstance.SendAsync(message);
            _logger.LogInformation("Gửi FCM thành công tới topic {Topic}. Message ID: {MessageId}", topic, response);
            return 1;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi gửi FCM notification tới topic {Topic}", topic);
            return 0;
        }
    }
}
