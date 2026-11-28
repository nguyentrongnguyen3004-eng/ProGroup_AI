# BÁO CÁO KHẮC PHỤC TÍCH HỢP VÀ HỢP ĐỒNG API (API FIX REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Đồng bộ hóa toàn bộ HTTP Methods, Endpoints và Data Transfer Objects (DTO) giữa Flutter Frontend và ASP.NET Core Backend.  

---

## 1. CÁC ĐIỂM BẤT ĐỒNG BỘ VÀ GIẢI PHÁP KHẮC PHỤC

### 1.1. Sửa lỗi HTTP 405 Method Not Allowed tại API Đổi mật khẩu
- **Hiện trạng:**
  - Backend `AuthController` trước đây chỉ định nghĩa duy nhất `[HttpPut("change-password")]`.
  - Một số service phía Frontend và kịch bản test gọi HTTP `POST /api/auth/change-password`, dẫn đến phản hồi lỗi `405 Method Not Allowed`.
  - Tên thuộc tính mật khẩu cũ không đồng nhất: Frontend có chỗ gửi `oldPassword`, chỗ gửi `currentPassword`.
- **Giải pháp xử lý:**
  1. Trong `ChangePasswordRequest.cs`, hỗ trợ cả hai thuộc tính và cung cấp phương thức giải quyết tương thích ngược:
     ```csharp
     public class ChangePasswordRequest
     {
         public string? CurrentPassword { get; set; }
         public string? OldPassword { get; set; }
         public string NewPassword { get; set; } = string.Empty;
         public string GetEffectiveCurrentPassword() => CurrentPassword ?? OldPassword ?? string.Empty;
     }
     ```
  2. Trong [AuthController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/AuthController.cs), hỗ trợ song song cả hai HTTP Method:
     ```csharp
     [HttpPut("change-password")]
     [HttpPost("change-password")]
     public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
     ```
  3. Cập nhật các service Frontend (`admin_api_service.dart`, `governance_api_service.dart`, `lecturer_api_service.dart`, `StudentApiService.dart`) gửi đúng payload và sử dụng HTTP PUT chuẩn RESTful.

---

### 1.2. Sửa lỗi HTTP 404 Not Found tại API Đề xuất Đề tài Giảng viên
- **Hiện trạng:**
  - Phân hệ Giảng viên khi truy cập màn hình duyệt đề xuất đề tài cần gọi `GET /api/de-tai/proposals`.
  - Backend `DeTaiController` chưa có route này, khiến request trả về HTTP `404 Not Found`, buộc giao diện phải fallback sang mock proposal data.
- **Giải pháp xử lý:**
  - Bổ sung endpoint thực tế trong [DeTaiController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/DeTaiController.cs):
    ```csharp
    [HttpGet("proposals")]
    [Authorize(Roles = "GIANGVIEN,ADMIN")]
    public async Task<IActionResult> GetTopicProposals([FromQuery] int? courseId)
    {
        var query = _db.DeTaiDoAns.AsNoTracking().Where(d => d.TrangThai == "Chờ duyệt");
        if (courseId.HasValue) query = query.Where(d => d.LopHocPhanId == courseId.Value);
        // Map sang DTO chuẩn và trả về danh sách đề tài đang chờ phê duyệt
    }
    ```

---

### 1.3. Bổ sung API Lưu Cấu hình Lớp Học phần
- **Hiện trạng:**
  - Giảng viên điều chỉnh cấu hình lớp học phần (số thành viên tối đa/tối thiểu, thời hạn đăng ký nhóm, hạn đăng ký đề tài), nhưng Frontend chỉ lưu tạm vào state cục bộ hoặc Singleton do Backend thiếu endpoint cập nhật cấu hình.
- **Giải pháp xử lý:**
  1. Định nghĩa DTO `UpdateCourseSettingsRequest` trong Backend:
     ```csharp
     public sealed class UpdateCourseSettingsRequest
     {
         public int? SoThanhVienToiDa { get; set; }
         public int? SoThanhVienToiThieu { get; set; }
         public DateTime? HanDangKyNhom { get; set; }
         public DateTime? HanDangKyDeTai { get; set; }
         public string? TieuChiPhanNhom { get; set; }
     }
     ```
  2. Bổ sung endpoint `PUT /api/lop-hoc-phan/{id}/cau-hinh` trong [LopHocPhanController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/LopHocPhanController.cs).
  3. Bổ sung phương thức `updateCourseSettings(int courseId, Map<String, dynamic> settings)` trong [lecturer_api_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/lecturer_api_service.dart) và đấu nối với `lecturer_course_detail_screen.dart`.

---

### 1.4. Bổ sung API Truy vấn Nhật ký Hoạt động Quản trị (Activity Logs)
- **Hiện trạng:**
  - Màn hình `AdminActivityLogScreen` hiển thị mock items do thiếu API backend.
- **Giải pháp xử lý:**
  - Bổ sung endpoint `GET /api/admin/activity-logs` trong [AdminController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/AdminController.cs).
  - Bổ sung `fetchActivityLogs()` trong `admin_api_service.dart` và đấu nối vào `admin_activity_log_screen.dart`.

---

## 2. BẢNG TỔNG HỢP CÁC ENDPOINT ĐÃ KHẮC PHỤC / BỔ SUNG MỚI

| Endpoint | HTTP Method | Quyền truy cập | Mục đích |
|---|:---:|:---:|---|
| `/api/auth/change-email/send-otp` | POST | Authenticated | Gửi OTP 6 chữ số đến email mới |
| `/api/auth/change-email` | PUT, POST | Authenticated | Xác thực OTP và đổi email chính thức |
| `/api/auth/change-password` | PUT, POST | Authenticated | Đổi mật khẩu tài khoản |
| `/api/de-tai/proposals` | GET | GIANGVIEN, ADMIN | Lấy danh sách đề tài sinh viên đề xuất chờ duyệt |
| `/api/lop-hoc-phan/{id}/cau-hinh` | PUT | GIANGVIEN, ADMIN | Cập nhật thông số cấu hình lớp học phần |
| `/api/admin/users/import` | POST | ADMIN, PHONGDAOTAO, GIAOVUKHOA | Nhập người dùng hàng loạt |
| `/api/admin/activity-logs` | GET | ADMIN | Xem nhật ký hoạt động hệ thống |
