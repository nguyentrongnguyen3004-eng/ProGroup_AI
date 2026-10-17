namespace ProGroup_AI.API.DTOs.Profile;

public sealed class ProfileResponse
{
    public int NguoiDungId { get; set; }
    public string TenDangNhap { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string HoTen { get; set; } = string.Empty;
    public string? SoDienThoai { get; set; }
    public string? AvatarUrl { get; set; }
    public int VaiTroId { get; set; }
    public string MaVaiTro { get; set; } = string.Empty;
    public string TenVaiTro { get; set; } = string.Empty;
    public bool TrangThai { get; set; }
    public DateTime CreatedAt { get; set; }

    // Sinh viên info
    public StudentProfileInfo? SinhVien { get; set; }

    // Giảng viên info
    public LecturerProfileInfo? GiangVien { get; set; }
}

public sealed class StudentProfileInfo
{
    public int SinhVienId { get; set; }
    public string MSSV { get; set; } = string.Empty;
    public int KhoaId { get; set; }
    public string? TenKhoa { get; set; }
    public string? MaKhoa { get; set; }
    public DateTime? NgaySinh { get; set; }
    public string? GioiTinh { get; set; }
    public List<StudentCourseInfo> LopHocPhans { get; set; } = new();
}

public sealed class StudentCourseInfo
{
    public int LopHocPhanId { get; set; }
    public string MaLopHocPhan { get; set; } = string.Empty;
    public string TenLopHocPhan { get; set; } = string.Empty;
    public string? TenHocPhan { get; set; }
}

public sealed class LecturerProfileInfo
{
    public int GiangVienId { get; set; }
    public string MaGiangVien { get; set; } = string.Empty;
    public int KhoaId { get; set; }
    public string? TenKhoa { get; set; }
    public string? MaKhoa { get; set; }
    public string? HocVi { get; set; }
    public string? ChuyenMon { get; set; }
}
