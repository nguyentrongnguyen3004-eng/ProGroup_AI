namespace ProGroup_AI.API.DTOs.Auth;

public class LoginResponse
{
    public bool Success { get; set; }

    public string Message { get; set; } = string.Empty;

    public string Token { get; set; } = string.Empty;

    public DateTime ExpiresAt { get; set; }

    public UserInfoResponse? User { get; set; }
}