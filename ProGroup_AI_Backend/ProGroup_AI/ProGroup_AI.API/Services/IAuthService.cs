using ProGroup_AI.API.DTOs.Auth;

namespace ProGroup_AI.API.Services;

public interface IAuthService
{
    Task<LoginResponse> LoginAsync(LoginRequest request);
}