using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Services;

public interface IJwtService
{
    string GenerateToken(NguoiDung user);
}