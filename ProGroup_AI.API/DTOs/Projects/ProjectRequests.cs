using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Projects;

public sealed class RegisterProjectRequest
{
    [Range(1, int.MaxValue)]
    public int NhomId { get; set; }

    [Range(1, int.MaxValue)]
    public int DeTaiId { get; set; }
}

public sealed class ProjectResponse
{
    public int DeTaiId { get; set; }
    public int DotDangKyId { get; set; }
    public string TenDeTai { get; set; } = string.Empty;
    public string? MoTa { get; set; }
    public string? MucTieu { get; set; }
    public string? PhamVi { get; set; }
    public string? CongNgheDuKien { get; set; }
    public string NguonDeTai { get; set; } = string.Empty;
    public string TrangThai { get; set; } = string.Empty;
    public string TrangThaiDuyet { get; set; } = string.Empty;
}
