using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.Services;

var builder = WebApplication.CreateBuilder(args);

// ========================================
// Controllers
// ========================================

builder.Services.AddControllers();


// ========================================
// Swagger
// ========================================

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


// ========================================
// Entity Framework Core - SQL Server
// ========================================

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")
    )
);


// ========================================
// JWT Authentication
// ========================================

var jwtKey = builder.Configuration["Jwt:Key"];

if (string.IsNullOrWhiteSpace(jwtKey))
{
    throw new InvalidOperationException(
        "Jwt:Key chưa được cấu hình trong appsettings.json."
    );
}

var jwtIssuer = builder.Configuration["Jwt:Issuer"];
var jwtAudience = builder.Configuration["Jwt:Audience"];

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,

            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey)
            ),

            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,

            ValidateAudience = true,
            ValidAudience = jwtAudience,

            ValidateLifetime = true,

            ClockSkew = TimeSpan.Zero
        };
    });


// ========================================
// Authorization
// ========================================

builder.Services.AddAuthorization();


// ========================================
// Dependency Injection
// ========================================

builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IAuthService, AuthService>();


// ========================================
// Build
// ========================================

var app = builder.Build();


// ========================================
// Swagger
// ========================================

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


// ========================================
// HTTPS
// ========================================

app.UseHttpsRedirection();


// ========================================
// Authentication
// ========================================

app.UseAuthentication();


// ========================================
// Authorization
// ========================================

app.UseAuthorization();


// ========================================
// Controllers
// ========================================

app.MapControllers();


// ========================================
// Run
// ========================================

app.Run();