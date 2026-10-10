using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.Groups;

public sealed class CreateGroupRequest
{
    [Range(1, int.MaxValue)]
    public int DotDangKyId { get; set; }

    [Required, StringLength(200, MinimumLength = 1)]
    public string TenNhom { get; set; } = string.Empty;
}

public sealed class AddGroupMemberRequest
{
    [Range(1, int.MaxValue)]
    public int SinhVienId { get; set; }
}

public sealed class GroupResponse
{
    public int NhomId { get; set; }
    public int DotDangKyId { get; set; }
    public int LopHocPhanId { get; set; }
    public string TenNhom { get; set; } = string.Empty;
    public string TrangThai { get; set; } = string.Empty;
    public int MinMembers { get; set; }
    public int MaxMembers { get; set; }
    public int TruongNhomId { get; set; }
    public string TruongNhom { get; set; } = string.Empty;
    public List<GroupMemberResponse> ThanhViens { get; set; } = new();
}

public sealed class GroupMemberResponse
{
    public int SinhVienId { get; set; }
    public string MSSV { get; set; } = string.Empty;
    public string HoTen { get; set; } = string.Empty;
    public string VaiTro { get; set; } = string.Empty;
    public string TrangThai { get; set; } = string.Empty;
}
