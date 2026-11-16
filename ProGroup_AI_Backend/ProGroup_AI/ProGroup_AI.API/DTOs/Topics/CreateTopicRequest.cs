using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ProGroup_AI.API.DTOs.Topics;

public sealed class CreateTopicRequest
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
    public int? LopHocPhanId { get; set; }
    public string? TrangThai { get; set; }

    [JsonPropertyName("nguonDeTai")]
    public string? NguonDeTai { get; set; }

    [JsonPropertyName("source")]
    public string? Source { get; set; }

    [JsonPropertyName("nguon_de_tai")]
    public string? NguonDeTaiSnake { get; set; }

    [JsonIgnore]
    public string ResolvedNguonDeTai => !string.IsNullOrWhiteSpace(NguonDeTai)
        ? NguonDeTai.Trim()
        : !string.IsNullOrWhiteSpace(Source)
            ? Source.Trim()
            : !string.IsNullOrWhiteSpace(NguonDeTaiSnake)
                ? NguonDeTaiSnake.Trim()
                : "Giảng viên";
}
