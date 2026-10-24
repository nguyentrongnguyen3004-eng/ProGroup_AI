using System.ComponentModel.DataAnnotations;

namespace ProGroup_AI.API.DTOs.DangKyDeTai;

public sealed class CreateDangKyDeTaiRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "NhomId không hợp lệ.")]
    public int NhomId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "DeTaiId không hợp lệ.")]
    public int DeTaiId { get; set; }
}
