namespace ProGroup_AI.API.DTOs.Auth;

public class ChangePasswordRequest
{
    public string CurrentPassword { get; set; } = string.Empty;
    public string? OldPassword { get; set; }
    public string NewPassword { get; set; } = string.Empty;

    public string GetEffectiveCurrentPassword() =>
        !string.IsNullOrWhiteSpace(CurrentPassword) ? CurrentPassword : (OldPassword ?? string.Empty);
}

