using System.Text.Json.Serialization;

namespace ProGroup_AI.API.DTOs.Topics;

public sealed class ApproveTopicRequest
{
    [JsonPropertyName("chap_nhan")]
    public bool? ChapNhanSnake { get; set; }

    public bool? ChapNhan { get; set; }

    [JsonPropertyName("isApproved")]
    public bool? IsApprovedField { get; set; }

    [JsonIgnore]
    public bool IsApproved => ChapNhanSnake ?? ChapNhan ?? IsApprovedField ?? false;

    [JsonPropertyName("lyDoTuChoi")]
    public string? LyDoTuChoi { get; set; }

    [JsonPropertyName("lyDo")]
    public string? LyDo { get; set; }

    [JsonIgnore]
    public string? Reason => !string.IsNullOrWhiteSpace(LyDoTuChoi) ? LyDoTuChoi : LyDo;
}
