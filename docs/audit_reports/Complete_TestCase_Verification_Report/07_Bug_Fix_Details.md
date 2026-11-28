# BÁO CÁO 07: CHI TIẾT CÁC BẢN VÁ MÃ NGUỒN (BUG FIX DETAILS)

## 1. TỔNG HỢP CÁC TỆP TIN ĐÃ SỬA ĐỔI
- **Backend ASP.NET Core (`ProGroup_AI.API`):** 13 tệp tin
- **Frontend Flutter (`progroup_ai_frontend`):** 26 tệp tin
- **Tổng số dòng mã đã chỉnh sửa/bổ sung:** +850 dòng, -210 dòng
- **Kết quả biên dịch:** `dotnet build` đạt 0 lỗi; `flutter analyze` đạt 0 lỗi.

---

## 2. DANH MỤC BẢN VÁ BACKEND (ASP.NET CORE WEB API)

### 2.1. `DTOs/Auth/UserInfoResponse.cs` & `Services/EmailService.cs`
- Bổ sung trường `SoDienThoai` vào `UserInfoResponse` để trả về số điện thoại người dùng trong `/api/auth/me`.
- Mở rộng `EmailService.SendOtpEmailAsync` nhận tham số mục đích email (`purpose = "đổi địa chỉ email"`), hỗ trợ linh hoạt cả quên mật khẩu lẫn đổi email.

### 2.2. `Controllers/AuthController.cs`
- **Hàm `ChangeEmail`:** Bắt buộc kiểm tra `string.IsNullOrWhiteSpace(request.Otp)`, truy vấn bảng `PasswordResetOtps`, kiểm tra thời hạn và đánh dấu OTP đã sử dụng. Nếu không có OTP trả về HTTP 400.
- **Hàm `ChangePassword`:** Bổ sung kiểm tra độ dài mật khẩu mới `request.NewPassword.Length < 6` trả về HTTP 400; xác thực mật khẩu hiện tại bằng `BCrypt.Verify`.

### 2.3. `Controllers/ProfileController.cs`
- Thêm hàm `DetectImageFormat(Stream stream)` kiểm tra binary magic bytes (`FF D8 FF`, `89 50 4E 47`, `47 49 46 38`, `RIFF...WEBP`). Từ chối tải lên tệp tin giả mạo đuôi mở rộng.

### 2.4. `Controllers/GroupsController.cs`
- **Hàm `Mine`:** Bổ sung điều kiện lọc `TrangThai != "Đã hủy"`, ẩn các nhóm đã bị giải tán.
- **Hàm `UpdateGroupName`:** Thêm route `PUT /api/groups/{id}/name`, xác thực quyền Trưởng nhóm trước khi cập nhật tên nhóm, chặn IDOR.
- **Hàm `InviteMember`:** Thiết lập `VaiTro = "Thành viên"` và `TrangThai = "Chờ tham gia"` để tuân thủ check constraint `CK_ThanhVienNhoms_VaiTro`. Tự động tạo thông báo gửi tới sinh viên được mời.
- **Endpoint Lời mời:** Bổ sung `GET /api/groups/invitations/me` và `PUT /api/groups/invitations/{id}` xử lý đồng ý/từ chối lời mời.

### 2.5. `Controllers/DangKyDeTaiController.cs`
- **Hàm `RegisterTopic`:**
  - Khi nhóm đăng ký lại đề tài từng bị từ chối hoặc hủy, tìm bản ghi `DangKyDeTai` cũ và tái sử dụng: đặt lại `TrangThai = "Chờ duyệt"`, `NgayDangKy = DateTime.Now`, đồng thời xóa trắng `NgayDuyet = null`, `GiangVienDuyetId = null`, `GhiChu = null` để thỏa mãn check constraint `CK_DangKyDeTais_TrangThai`.
  - Bọc `SaveChangesAsync()` trong `try ... catch (Exception)` trả về HTTP 409 Conflict khi có xung đột khóa duy nhất `UQ_DangKyDeTai`.

### 2.6. `Controllers/DeTaiController.cs`
- Điều chỉnh số thành viên tối thiểu mặc định `MinMembers = 2`.
- **Hàm `Propose`:** Cho phép `DotDangKyId = 0`, tự động match đợt đăng ký đang mở của lớp học phần và gửi thông báo cho giảng viên phụ trách.

### 2.7. `Controllers/BaoCaoTienDoController.cs`
- **Hàm `GetReportsForLecturer`:** Giới hạn phạm vi chỉ trả về báo cáo thuộc các lớp học phần và đề tài do chính giảng viên đó phụ trách.
- Bổ sung endpoint `GET /api/bao-cao/lop-hoc-phan/{lopHocPhanId}/bang-diem` tổng hợp điểm trung bình và xếp loại của từng nhóm đồ án.

### 2.8. `Controllers/LopHocPhanController.cs`
- **Hàm `SetActiveSemester`:** Khi kích hoạt học kỳ được chọn (`TrangThai = true`), tự động cập nhật toàn bộ các học kỳ khác thành `TrangThai = false`.
- **Hàm `UpdateCourseSettings`:** Bổ sung `TryParseDate` hỗ trợ định dạng ngày tháng `dd/MM/yyyy`.

### 2.9. `Controllers/GovernanceController.cs`
- Tự động tạo thông báo cho giảng viên khi được phân công phụ trách lớp học phần.
- Bổ sung `PUT /api/governance/assignments` (thay đổi giảng viên) và `DELETE /api/governance/assignments` (hủy phân công).
- Bổ sung tìm kiếm giảng viên theo `ChuyenMon` và tính toán số lớp đang phụ trách.

### 2.10. `Controllers/AdminController.cs`
- Chặn xóa tài khoản người dùng nếu đã có dữ liệu ràng buộc khóa ngoại (báo lỗi HTTP 400 kèm thông báo hướng dẫn khóa tài khoản).
- Sắp xếp nhật ký hoạt động giảm dần theo thời gian và lưu địa chỉ IP của client.
- Tự động gửi thông báo cho `GIAOVUKHOA` khi tạo mới giảng viên.

---

## 3. DANH MỤC BẢN VÁ FRONTEND (FLUTTER)

1. `change_email_dialog.dart`: Sửa callback arity để luôn truyền đủ cặp tham số `(newEmail, otp)`.
2. `login_screen.dart`: Tách biệt 2 thông báo lỗi validation khi bỏ trống tên đăng nhập (`'Vui lòng nhập tên đăng nhập'`) và mật khẩu (`'Vui lòng nhập mật khẩu'`).
3. `profile_screen.dart`, `lecturer_profile_screen.dart`, `admin_profile_screen.dart`, `governance_profile_screen.dart`, `training_profile_screen.dart`:
   - Gắn callback `onConfirm` gọi API Backend đổi mật khẩu và đổi email có OTP.
   - Gọi `AuthService.logout()` khi đăng xuất để hủy JWT token.
4. `lecturer_topic_detail_screen.dart`: Bổ sung trạng thái `'Chưa sử dụng'` vào danh sách dropdown trạng thái đề tài.
5. `lecturer_review_reports_screen.dart`: Sửa lỗi hiển thị chuỗi nhận xét của giảng viên.
6. `topic_screen.dart`: Xóa bỏ fallback gây rò rỉ đề tài giữa các lớp khác nhau; bổ sung chuẩn hóa tìm kiếm không dấu `_normalizeVi`.
7. `governance_course_screen.dart`: Map đúng key `soThanhVien` và `trangThaiDeTai`; loại bỏ hoàn toàn mock data tĩnh.
8. `training_overview_screen.dart`: Hiển thị số liệu so sánh khoa và phân bổ điểm số từ API thật; loại bỏ thông báo fake; thêm cờ `forceRefresh: true`.
9. `admin_overview_screen.dart`: Sửa lỗi đếm trùng lặp vai trò bằng so sánh chuỗi chính xác; loại bỏ mock fallback.
10. `admin_user_import_screen.dart`: Thêm kiểm tra định dạng header file Excel và gọi API `importUsersBatch`.
11. `propose_topic_screen.dart`: Bổ sung `PopScope` hiển thị hộp thoại xác nhận khi người dùng bấm nút back trên form đang nhập dở.
12. `student_api_service.dart`: Xóa cache dữ liệu khi người dùng gọi `markAsRead` hoặc `markAllAsRead`.
13. `auth_service.dart`: Thêm hàm `restoreSession()` gọi `/api/auth/me` khi mở app; xóa bỏ việc lưu mật khẩu thô trong SharedPreferences.
14. `splash_screen.dart`: Gọi `AuthService.restoreSession()` để điều hướng tự động vào đúng màn hình theo vai trò đã lưu.
15. `ai_topic_screen.dart`: Bổ sung các chip chọn số lượng đề tài gợi ý `1` và `2`.