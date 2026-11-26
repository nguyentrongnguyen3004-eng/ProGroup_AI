# 10. BÁO CÁO NỢ KỸ THUẬT & KIẾN TRÚC MÃ NGUỒN (TECHNICAL DEBT AUDIT)

## 1. TỔNG QUAN NỢ KỸ THUẬT
Dự án ProGroup_AI có nền tảng ban đầu khá tốt về mặt giao diện và tổ chức thư mục. Tuy nhiên, trong quá trình phát triển nhanh, việc copy-paste mã nguồn và giữ lại các giải pháp tạm thời đã tạo ra một lượng nợ kỹ thuật (Technical Debt) rất lớn, gây khó khăn cho việc bảo trì và mở rộng hệ thống.

---

## 2. CÁC ĐIỂM NỢ KỸ THUẬT NẶNG NHẤT

### 2.1. Trùng Lặp Mã Nguồn Nghiêm Trọng (Code Duplication - "Copy-Paste Architecture")
1. **3 Màn hình Hồ sơ Cá nhân (Profile Screens) giống nhau 90%:**
   - `screens/admin/profile/admin_profile_screen.dart` (650 dòng)
   - `screens/giao_vu/profile/governance_profile_screen.dart` (650 dòng)
   - `screens/phong_dao_tao/profile/training_profile_screen.dart` (650 dòng)
   - Cả 3 file này gần như sao chép y nguyên logic tải thông tin, form đổi mật khẩu, form đổi email và giao diện. Khi có một lỗi phát sinh (ví dụ bug Fake OTP), lập trình viên phải sửa ở cả 3 nơi riêng biệt!
2. **Trùng lặp các hàm API Client trong các Service:**
   - `AdminApiService`, `GovernanceApiService`, `LecturerApiService` đều tự viết lại các hàm `getNotifications()`, `markAsRead()`, `changeEmail()`, `changePassword()`.

---

### 2.2. Lạm Dụng `Map<String, dynamic>` Thiếu Type Safety
- Trên ứng dụng Flutter, nhiều màn hình thay vì parse dữ liệu về các class Model cụ thể (`UserModel`, `TopicModel`) thì lại truyền và truy cập trực tiếp qua `Map<String, dynamic>` (ví dụ `item['tenDeTai']`, `data['lopHocPhanId']`).
- **Hậu quả:** Chỉ cần Backend đổi tên một trường hoặc trả về kiểu dữ liệu hơi khác (ví dụ số nguyên thay vì chuỗi), ứng dụng sẽ bị văng lỗi runtime `type 'Null' is not a subtype of type 'String'` mà trình biên dịch không thể phát hiện trước.

---

### 2.3. Tồn Tại Song Song Hai Kiến Trúc Mock Data và Real API
- Thư mục `lib/data/` chứa hàng loạt file mock đồ sộ nhưng không còn được sử dụng ở các luồng chính, gây nhầm lẫn cho các lập trình viên mới tham gia dự án.
- Thiếu cờ cấu hình môi trường chuẩn (`kDebugMode`, `Environment.isDevelopment`) để phân tách giữa mock và production.
