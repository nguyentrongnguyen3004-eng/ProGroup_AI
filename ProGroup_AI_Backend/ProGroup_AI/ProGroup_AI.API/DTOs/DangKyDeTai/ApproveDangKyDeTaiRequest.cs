using System.Text.Json.Serialization;

namespace ProGroup_AI.API.DTOs.DangKyDeTai;

public sealed class ApproveDangKyDeTaiRequest
{
    [JsonPropertyName("chap_nhan")]
    public bool? ChapNhanSnake { get; set; }

    public bool? ChapNhan { get; set; }

    [JsonPropertyName("dongY")]
    public bool? DongY { get; set; }

    [JsonPropertyName("approve")]
    public bool? Approve { get; set; }

    [JsonIgnore]
    public bool IsApproved => ChapNhanSnake ?? ChapNhan ?? DongY ?? Approve ?? false;

    [JsonPropertyName("ghiChu")]
    public string? GhiChu { get; set; }

    [JsonPropertyName("note")]
    public string? Note { get; set; }

    [JsonIgnore]
    public string? ResolvedGhiChu => GhiChu ?? Note;
}
