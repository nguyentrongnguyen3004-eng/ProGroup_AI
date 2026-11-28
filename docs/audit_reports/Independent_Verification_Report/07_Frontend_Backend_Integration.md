# 07. BÁO CÁO XÁC MINH TÍCH HỢP FRONTEND - BACKEND (FRONTEND & BACKEND INTEGRATION REPORT)
**Dự án:** ProGroup_AI  
**Frontend:** Flutter 3.29.0 / Dart 3.7.0  
**Backend:** ASP.NET Core 10.0 Web API  

---

## 1. PHÂN TÍCH TĨNH FRONTEND (STATIC ANALYSIS)

- Lệnh thực thi: `flutter analyze` tại `ProGroup_AI_Frontend/progroup_ai_frontend/`.
- Kết quả ghi nhận:
  - **Errors:** **0**
  - **Warnings:** **0** (Đã giải quyết sạch sẽ các cảnh báo unused field và async gaps).
  - **Lints / Deprecations:** 53 thông báo info từ thư viện Flutter framework (`withOpacity` -> `withValues`, `Radio` -> `RadioGroup`).
- **Đánh giá:** Mã nguồn Flutter đạt chuẩn biên dịch sạch sẽ, không có lỗi runtime tiềm ẩn do cú pháp hoặc type-mismatch.

---

## 2. XÁC MINH CÁC SERVICE GỌI API TRÊN FLUTTER

| Tên Service | Trạng thái Mock Data | Kết nối API Backend | Ghi chú kiểm tra |
|---|:---:|:---:|---|
| `auth_service.dart` | **Đã loại bỏ 100%** | Kết nối `POST /api/auth/login` | Đã xóa bỏ các tài khoản hardcoded `test_user_...` |
| `StudentApiService.dart` | **Đã loại bỏ 100%** | Kết nối đầy đủ các API Sinh viên | Đã bổ sung `changeEmail` (kèm OTP) và `changePassword` |
| `lecturer_api_service.dart` | **Đã loại bỏ 100%** | Kết nối đầy đủ các API Giảng viên | Đã bổ sung `updateCourseSettings` và duyệt đề xuất đề tài |
| `admin_api_service.dart` | **Đã loại bỏ 100%** | Kết nối API Quản trị | Đã kết nối `fetchActivityLogs()` và `createAccount` |
| `governance_api_service.dart` | **Đã loại bỏ 100%** | Kết nối API Giáo vụ | Dữ liệu đẩy trực tiếp lên SQL Server |

---

## 3. LƯU Ý VỀ BỘ TEST WIDGET HIỆN TẠI

Khi thực thi lệnh `flutter test` trên bộ test widget có sẵn, xuất hiện thông báo:
`Warning: At least one test in this suite creates an HttpClient... all HTTP requests will return status code 400.`
- **Nguyên nhân:** Các widget test cũ được viết trong giai đoạn còn dùng mock repositories offline. Khi các màn hình được chuyển đổi sang gọi API thật qua HTTP, Flutter Test framework mặc định chặn kết nối mạng socket thực tế nếu không có Mock HTTP Adapter.
- **Giải pháp khuyến nghị:** Bổ sung lớp `MockHttpClient` hoặc `HttpOverrides` trong thư mục `test/` để bộ test giao diện có thể chạy offline độc lập trong CI/CD pipeline.
