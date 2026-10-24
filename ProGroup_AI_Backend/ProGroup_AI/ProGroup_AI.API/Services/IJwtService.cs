using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Services;

public interface IJwtService
{
    JwtTokenResult GenerateToken(NguoiDung user);
}

public sealed record JwtTokenResult(string Token, DateTime ExpiresAt);
