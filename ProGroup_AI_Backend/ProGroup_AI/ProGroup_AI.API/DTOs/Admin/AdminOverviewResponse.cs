namespace ProGroup_AI.API.DTOs.Admin;

public sealed class AdminOverviewResponse
{
    public int TongNguoiDung { get; set; }
    public int TongSinhVien { get; set; }
    public int TongGiangVien { get; set; }
    public int TongLopHocPhan { get; set; }
    public int TongDeTai { get; set; }
    public int TongNhom { get; set; }
    public int TongDangKyDeTai { get; set; }
    public int DotDangKyDangMo { get; set; }
}
