using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Services;

public class JwtService : IJwtService
{
    private readonly IConfiguration _configuration;

    public JwtService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public JwtTokenResult GenerateToken(NguoiDung user)
    {
        var jwtKey = _configuration["Jwt:Key"];

        if (string.IsNullOrWhiteSpace(jwtKey))
        {
            throw new InvalidOperationException(
                "JWT Key chưa được cấu hình trong appsettings.json."
            );
        }

        var issuer = _configuration["Jwt:Issuer"];
        var audience = _configuration["Jwt:Audience"];

        var expireMinutes = _configuration.GetValue<int?>("Jwt:ExpireMinutes") ?? 120;

        var roleCode = user.VaiTro?.MaVaiTro ?? string.Empty;

        var claims = new List<Claim>
        {
            new Claim(
                ClaimTypes.NameIdentifier,
                user.NguoiDungId.ToString()
            ),

            new Claim(
                ClaimTypes.Name,
                user.HoTen
            ),

            new Claim(
                ClaimTypes.Email,
                user.Email
            ),

            new Claim(
                ClaimTypes.Role,
                roleCode
            ),

            new Claim(
                "TenDangNhap",
                user.TenDangNhap
            )
        };

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtKey)
        );

        var credentials = new SigningCredentials(
            key,
            SecurityAlgorithms.HmacSha256
        );

        if (expireMinutes <= 0)
        {
            throw new InvalidOperationException(
                "Jwt:ExpireMinutes phải lớn hơn 0."
            );
        }

        var expiresAt = DateTimeOffset.UtcNow
            .AddMinutes(expireMinutes)
            .ToUnixTimeSeconds();
        var expires = DateTimeOffset.FromUnixTimeSeconds(expiresAt).UtcDateTime;

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: expires,
            signingCredentials: credentials
        );

        return new JwtTokenResult(
            new JwtSecurityTokenHandler().WriteToken(token),
            expires
        );
    }
}
