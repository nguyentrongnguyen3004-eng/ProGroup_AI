using System.Text.Json.Serialization;

namespace ProGroup_AI.API.DTOs.Topics;

public sealed class ApproveTopicRequest
{
    [JsonPropertyName("chap_nhan")]
    public bool? ChapNhanSnake { get; set; }

    public bool? ChapNhan { get; set; }

    [JsonIgnore]
    public bool IsApproved => ChapNhanSnake ?? ChapNhan ?? false;

    [JsonPropertyName("lyDoTuChoi")]
    public string? LyDoTuChoi { get; set; }
}
