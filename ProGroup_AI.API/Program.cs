using System.Text;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using ProGroup_AI.API.Data;
using ProGroup_AI.API.Services;
using Microsoft.OpenApi;

var builder = WebApplication.CreateBuilder(args);

// ========================================
// Controllers
// ========================================

builder.Services.AddControllers();
builder.Services.AddProblemDetails();


// ========================================
// Swagger
// ========================================

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "ProGroup_AI.API",
        Version = "v1"
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Nhập access token JWT."
    });

    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("Bearer", document)] = []
    });
});


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

if (Encoding.UTF8.GetByteCount(jwtKey) < 32)
{
    throw new InvalidOperationException(
        "Jwt:Key phải có tối thiểu 32 byte để ký token bằng HS256."
    );
}

var jwtIssuer = builder.Configuration["Jwt:Issuer"];
var jwtAudience = builder.Configuration["Jwt:Audience"];
var jwtExpireMinutes = builder.Configuration.GetValue<int?>("Jwt:ExpireMinutes") ?? 120;

if (string.IsNullOrWhiteSpace(jwtIssuer) || string.IsNullOrWhiteSpace(jwtAudience))
{
    throw new InvalidOperationException(
        "Jwt:Issuer và Jwt:Audience phải được cấu hình."
    );
}

if (jwtExpireMinutes <= 0)
{
    throw new InvalidOperationException(
        "Jwt:ExpireMinutes phải lớn hơn 0."
    );
}

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

            NameClaimType = ClaimTypes.Name,
            RoleClaimType = ClaimTypes.Role,

            ValidateLifetime = true,

            ClockSkew = TimeSpan.Zero
        };
    });


// ========================================
// Authorization
// ========================================

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("ADMIN"));
    options.AddPolicy("StudentOnly", policy => policy.RequireRole("SINHVIEN"));
    options.AddPolicy("LecturerOnly", policy => policy.RequireRole("GIANGVIEN"));
    options.AddPolicy("FacultyStaffOnly", policy => policy.RequireRole("GIAOVUKHOA"));
    options.AddPolicy("AcademicOfficeOnly", policy => policy.RequireRole("PHONGDAOTAO"));
});


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

app.UseExceptionHandler();
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
