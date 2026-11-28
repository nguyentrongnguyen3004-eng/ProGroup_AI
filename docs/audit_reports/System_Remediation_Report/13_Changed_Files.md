# DANH SÁCH TOÀN BỘ CÁC TỆP TIN ĐÃ THAY ĐỔI (CHANGED FILES INVENTORY)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Liệt kê đầy đủ và minh bạch mọi file mã nguồn đã được chỉnh sửa hoặc tạo mới kèm theo đường dẫn liên kết và tóm tắt nội dung thay đổi.  

---

## 1. BACKEND (ASP.NET CORE 10)

| STT | Đường dẫn tệp tin | Loại thay đổi | Tóm tắt thay đổi |
|:---:|---|:---:|---|
| 1 | [ChangePasswordRequest.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Models/Requests/ChangePasswordRequest.cs) | Chỉnh sửa | Bổ sung `OldPassword` và phương thức `GetEffectiveCurrentPassword()` tương thích ngược |
| 2 | [ChangeEmailRequest.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Models/Requests/ChangeEmailRequest.cs) | Chỉnh sửa | Bổ sung trường `Otp` (nullable string) cho luồng xác thực |
| 3 | [AuthController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/AuthController.cs) | Chỉnh sửa | Thêm `[HttpPost("change-email/send-otp")]`, thêm `[HttpPost("change-password")]`, tích hợp xác thực OTP qua `PasswordResetOtps` |
| 4 | [EmailService.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Services/EmailService.cs) | Chỉnh sửa | Xóa bỏ password hardcode, đọc cấu hình từ biến môi trường (`SMTP_PASSWORD`,...) |
| 5 | [CloudflareR2Service.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Services/CloudflareR2Service.cs) | Chỉnh sửa | Đọc credentials R2 từ biến môi trường (`R2_ACCESS_KEY_ID`,...) |
| 6 | [Program.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Program.cs) | Chỉnh sửa | Đọc `JWT_KEY` từ biến môi trường, fallback an toàn |
| 7 | [appsettings.json](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/appsettings.json) | Chỉnh sửa | Làm sạch mật khẩu Gmail App Password (`"Password": ""`) |
| 8 | [appsettings.example.json](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/appsettings.example.json) | Tạo mới | Cung cấp file cấu hình mẫu không chứa thông tin nhạy cảm |
| 9 | [DeTaiController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/DeTaiController.cs) | Chỉnh sửa | Bổ sung endpoint `[HttpGet("proposals")]` lọc theo `courseId` |
| 10 | [GroupsController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/GroupsController.cs) | Chỉnh sửa | Cập nhật logic `DisbandGroup`: Khôi phục `TrangThai = "Chưa sử dụng"` của đề tài khi rã nhóm |
| 11 | [LopHocPhanController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/LopHocPhanController.cs) | Chỉnh sửa | Xóa hardcode phone, thêm `UpdateCourseSettingsRequest` và `[HttpPut("{id:int}/cau-hinh")]` |
| 12 | [AdminController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/AdminController.cs) | Chỉnh sửa | Mở rộng quyền `ImportUsers` cho `PHONGDAOTAO` và `GIAOVUKHOA`, thay thế hardcode stats bằng live dynamic queries, thêm `[HttpGet("activity-logs")]` |
| 13 | [NotificationsController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/NotificationsController.cs) | Chỉnh sửa | Lưu trữ trạng thái đọc thông báo vào cơ sở dữ liệu `ThongBaos` (VirtualRead marker) |

---

## 2. FRONTEND (FLUTTER)

| STT | Đường dẫn tệp tin | Loại thay đổi | Tóm tắt thay đổi |
|:---:|---|:---:|---|
| 14 | [auth_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/auth_service.dart) | Chỉnh sửa | Loại bỏ hoàn toàn test users hardcoded (`test_user_...`) |
| 15 | [api_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/api_service.dart) | Chỉnh sửa | Xóa bỏ dead URL variable `currentCloudflareUrl` |
| 16 | [change_email_dialog.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/widgets/change_email_dialog.dart) | Chỉnh sửa | Xóa bỏ backdoor `123456`, triển khai quy trình 2 bước chuẩn qua OTP email thực tế |
| 17 | [StudentApiService.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/StudentApiService.dart) | Chỉnh sửa | Bổ sung `changeEmail(newEmail, [otp])` và `changePassword(currentPassword, newPassword)` |
| 18 | [profile_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/sinh_vien/profile/profile_screen.dart) | Chỉnh sửa | Đấu nối `ChangeEmailDialog` với `StudentApiService.instance.changeEmail` |
| 19 | [admin_api_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/admin_api_service.dart) | Chỉnh sửa | Chuyển `changePassword` sang `PUT`, thêm `otp` vào `changeEmail`, thêm `fetchActivityLogs()` |
| 20 | [governance_api_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/governance_api_service.dart) | Chỉnh sửa | Chuyển `changePassword` sang `PUT`, thêm `otp` vào `changeEmail` |
| 21 | [lecturer_api_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/lecturer_api_service.dart) | Chỉnh sửa | Chuyển `changePassword` sang `PUT`, thêm `otp` vào `changeEmail`, thêm `updateCourseSettings()` |
| 22 | [AdminAccountModel.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/models/AdminAccountModel.dart) | Chỉnh sửa | Thêm `factory AdminAccountModel.fromJson` chuyển đổi an toàn cho API |
| 23 | [lecturer_course_detail_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/giang_vien/course/lecturer_course_detail_screen.dart) | Chỉnh sửa | Đấu nối lưu cấu hình khóa học qua `LecturerApiService.instance.updateCourseSettings` |
| 24 | [training_import_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/phong_dao_tao/management/training_import_screen.dart) | Chỉnh sửa | Gửi dữ liệu import tới `POST /api/admin/users/import` và `POST /api/lop-hoc-phan`, sửa async gap |
| 25 | [training_add_form_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/phong_dao_tao/management/training_add_form_screen.dart) | Chỉnh sửa | Lưu dữ liệu thêm mới tới API backend, sửa async gap |
| 26 | [governance_import_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/giao_vu/management/governance_import_screen.dart) | Chỉnh sửa | Gửi dữ liệu import giáo vụ tới các API backend |
| 27 | [admin_activity_log_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/admin/activity/admin_activity_log_screen.dart) | Chỉnh sửa | Lấy dữ liệu hoạt động thời gian thực từ `AdminApiService.instance.fetchActivityLogs()` và xử lý loading state |
