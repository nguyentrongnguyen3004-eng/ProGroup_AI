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

    [JsonPropertyName("ly_do_tu_choi")]
    public string? LyDoTuChoiSnake { get; set; }

    [JsonPropertyName("lyDo")]
    public string? LyDo { get; set; }

    [JsonPropertyName("ly_do")]
    public string? LyDoSnake { get; set; }

    [JsonPropertyName("ghiChu")]
    public string? GhiChu { get; set; }

    [JsonPropertyName("note")]
    public string? Note { get; set; }

    [JsonPropertyName("reason")]
    public string? ReasonField { get; set; }

    [JsonPropertyName("gopY")]
    public string? GopY { get; set; }

    [JsonPropertyName("feedback")]
    public string? Feedback { get; set; }

    [JsonPropertyName("comment")]
    public string? Comment { get; set; }

    [JsonIgnore]
    public string? Reason => !string.IsNullOrWhiteSpace(LyDoTuChoi)
        ? LyDoTuChoi
        : !string.IsNullOrWhiteSpace(LyDoTuChoiSnake)
            ? LyDoTuChoiSnake
            : !string.IsNullOrWhiteSpace(LyDo)
                ? LyDo
                : !string.IsNullOrWhiteSpace(LyDoSnake)
                    ? LyDoSnake
                    : !string.IsNullOrWhiteSpace(GhiChu)
                        ? GhiChu
                        : !string.IsNullOrWhiteSpace(Note)
                            ? Note
                            : !string.IsNullOrWhiteSpace(ReasonField)
                                ? ReasonField
                                : !string.IsNullOrWhiteSpace(GopY)
                                    ? GopY
                                    : !string.IsNullOrWhiteSpace(Feedback)
                                        ? Feedback
                                        : Comment;
}
