namespace ProGroup_AI.API.DTOs.Auth;

public class ChangeEmailRequest
{
    public string Email { get; set; } = string.Empty;
    public string? Otp { get; set; }
}

