# 10. BẢNG TỔNG HỢP CÁC LỖI VÀ KHIẾM KHUYẾT CÒN TỒN ĐỌNG (REMAINING DEFECTS PUNCH-LIST)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Liệt kê các vấn đề kỹ thuật cần xử lý trước và sau khi triển khai hệ thống.  

---

## 1. DANH SÁCH DEFECTS & VẤN ĐỀ TỒN ĐỌNG

| Mã Defect | Phân loại | Mức độ | Mô tả chi tiết | Vị trí phát hiện | Biện pháp khắc phục khuyến nghị |
|:---:|---|:---:|---|---|---|
| **SEC-DEF-01** | Security | **CRITICAL** | Mật khẩu Gmail App Password vẫn còn lưu trong lịch sử Git commit | Commit `fde6239` & `7a354ba` | Dùng `git filter-repo` xóa sạch commit lịch sử trước khi push repo công khai |
| **SEC-DEF-02** | Security | **HIGH** | Thuật toán sinh OTP sử dụng `Random.Shared` (PRNG) thông thường | `AuthController.cs` (Dòng 127, 246) | Đổi sang `RandomNumberGenerator.GetInt32(100000, 1000000)` |
| **SEC-DEF-03** | Security | **MEDIUM** | Thiếu Rate Limiting trên API gửi OTP (`send-otp`) | `AuthController.cs` | Bổ sung middleware giới hạn tần suất gửi OTP theo IP/User |
| **DAT-DEF-01** | Data Integrity | **HIGH** | Tồn tại 2 bản ghi OTP cũ lưu dạng plaintext trong cột `OtpCodeHash` | Bảng `PasswordResetOtps` (Id 1, 2) | Chạy SQL: `DELETE FROM PasswordResetOtps WHERE LEN(OtpCodeHash) < 20` |
| **TST-DEF-01** | Test Automation | **MEDIUM** | Bộ test widget Flutter cũ bị chặn mạng 400 khi chạy `flutter test` | `test/widget_test.dart` | Cung cấp `MockHttpClient` cho widget test suite |
| **FEAT-BL-01** | Backlog Scope | **LOW** | 17 Test Case về module AI dự báo học vụ và Cây bộ môn chưa có backend | Sheet 5 (5 TCs) & Sheet 6 (11 TCs) | Đưa vào lộ trình nâng cấp phiên bản 2.0 (Phase 2 Roadmap) |
