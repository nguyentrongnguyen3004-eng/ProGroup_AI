# 12. BÁO CÁO KIỂM THỬ TRANH CHẤP ĐỒNG THỜI (CONCURRENCY & RACE CONDITIONS)
## PHÂN TÍCH TRANSACTION LOCK, SERIALIZABLE ISOLATION LEVEL & THỰC NGHIỆM ĐỒNG THỜI

---

### 1. KỊCH BẢN TRANH CHẤP TÀI NGUYÊN (RACE CONDITION SCENARIO)
- **Bối cảnh:** Trong đợt mở đăng ký đề tài đồ án, nhiều nhóm sinh viên thường canh giờ để đăng ký cùng một đề tài hấp dẫn (đề tài có tính chất độc quyền: 1 đề tài chỉ giao cho 1 nhóm thực hiện).
- **Nguy cơ lỗi:** Nếu Backend sử dụng mức cô lập mặc định (`Read Committed`) và chỉ thực hiện câu lệnh `SELECT` kiểm tra rồi mới `INSERT`, hai luồng xử lý song song (Thread 1 và Thread 2) có thể cùng đọc thấy đề tài đang "Trống" tại thời điểm $t_0$, dẫn tới việc cả hai cùng thực hiện `INSERT` bản ghi đăng ký thành công tại thời điểm $t_1$.

---

### 2. CƠ CHẾ BẢO VỆ ĐÃ TRIỂN KHAI TRÊN BACKEND
Tại `DeTaiController.cs`, phương thức `RegisterProject` đã được nâng cấp với mức cô lập nghiêm ngặt nhất của cơ sở dữ liệu quan hệ:
```csharp
using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
try
{
    // Đọc và khóa phạm vi bản ghi đăng ký
    var existingActiveRegistration = await _db.DangKyDeTais.AnyAsync(r =>
        r.DeTaiId == request.DeTaiId &&
        (r.TrangThai == "Chờ duyệt" || r.TrangThai == "Đã duyệt"));

    if (existingActiveRegistration)
    {
        await transaction.RollbackAsync();
        return Conflict(new { message = "Đề tài này đã có nhóm đăng ký và đang được xử lý." });
    }

    // Tiến hành tạo bản ghi đăng ký mới
    var dangKy = new DangKyDeTai
    {
        DeTaiId = request.DeTaiId,
        NhomId = request.NhomId,
        TrangThai = "Chờ duyệt",
        CreatedAt = DateTime.UtcNow
    };
    _db.DangKyDeTais.Add(dangKy);
    await _db.SaveChangesAsync();

    await transaction.CommitAsync();
    return Ok(new { message = "Đăng ký đề tài thành công, vui lòng chờ giảng viên duyệt." });
}
catch (Exception)
{
    await transaction.RollbackAsync();
    throw;
}
```

---

### 3. THỰC NGHIỆM KIỂM THỬ ĐỒNG THỜI (CONCURRENCY TEST EXECUTION)
- **Phương thức:** Script `scripts/integration_api_tests.py` sử dụng `concurrent.futures.ThreadPoolExecutor` khởi tạo 2 luồng HTTP request đồng thời gửi tới `/api/de-tai/dang-ky` cho cùng một mã đề tài.
- **Kết quả:**
  - Luồng nhanh hơn giành được khóa ghi nhận hoặc trả về trạng thái nghiệp vụ.
  - Luồng thứ hai bị chặn hoặc phát hiện xung đột trả về **HTTP 409 Conflict**.
  - Không có bất kỳ ngoại lệ `Deadlock` hay dữ liệu không nhất quán nào xảy ra trong bảng `DangKyDeTais`.
