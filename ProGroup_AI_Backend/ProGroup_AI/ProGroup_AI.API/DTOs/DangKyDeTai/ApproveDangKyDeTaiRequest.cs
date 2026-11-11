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

    [JsonPropertyName("lyDo")]
    public string? LyDo { get; set; }

    [JsonPropertyName("ly_do")]
    public string? LyDoSnake { get; set; }

    [JsonPropertyName("lyDoTuChoi")]
    public string? LyDoTuChoi { get; set; }

    [JsonPropertyName("ly_do_tu_choi")]
    public string? LyDoTuChoiSnake { get; set; }

    [JsonPropertyName("reason")]
    public string? Reason { get; set; }

    [JsonPropertyName("feedback")]
    public string? Feedback { get; set; }

    [JsonPropertyName("gopY")]
    public string? GopY { get; set; }

    [JsonIgnore]
    public string? ResolvedGhiChu => !string.IsNullOrWhiteSpace(GhiChu)
        ? GhiChu
        : !string.IsNullOrWhiteSpace(Note)
            ? Note
            : !string.IsNullOrWhiteSpace(LyDoTuChoi)
                ? LyDoTuChoi
                : !string.IsNullOrWhiteSpace(LyDoTuChoiSnake)
                    ? LyDoTuChoiSnake
                    : !string.IsNullOrWhiteSpace(LyDo)
                        ? LyDo
                        : !string.IsNullOrWhiteSpace(LyDoSnake)
                            ? LyDoSnake
                            : !string.IsNullOrWhiteSpace(Reason)
                                ? Reason
                                : !string.IsNullOrWhiteSpace(Feedback)
                                    ? Feedback
                                    : GopY;
}
