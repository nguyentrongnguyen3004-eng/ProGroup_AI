using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Topics;

public sealed class UpdateTopicRequest
{
    [Required(ErrorMessage = "Tên đề tài không được để trống.")]
    [MaxLength(500, ErrorMessage = "Tên đề tài tối đa 500 ký tự.")]
    public string TenDeTai { get; set; } = string.Empty;

    public string? MoTa { get; set; }

    public string? MucTieu { get; set; }

    public string? PhamVi { get; set; }

    [MaxLength(1000, ErrorMessage = "Công nghệ dự kiến tối đa 1000 ký tự.")]
    public string? CongNgheDuKien { get; set; }

    public int? DotDangKyId { get; set; }
}
