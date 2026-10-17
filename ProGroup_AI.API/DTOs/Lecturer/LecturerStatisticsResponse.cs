namespace ProGroup_AI.API.DTOs.Lecturer;

public sealed class LecturerStatisticsResponse
{
    public int TongLopHocPhan { get; set; }
    public int TongNhom { get; set; }
    public int TongDeTai { get; set; }
    public int SoDeTaiDaDangKy { get; set; }
    public double PhanTramDaDangKy { get; set; }
    public int SoDeTaiChoDuyet { get; set; }
    public int SoDangKyChoDuyet { get; set; }
}
