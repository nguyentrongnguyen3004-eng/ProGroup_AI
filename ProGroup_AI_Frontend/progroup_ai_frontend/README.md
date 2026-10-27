# 📱 ProGroup AI - Mobile Frontend (Flutter)

Ứng dụng di động đa nền tảng thuộc hệ thống **ProGroup AI** được xây dựng bằng **Flutter SDK (Dart 3)** với giao diện hiện đại tuân thủ **Material Design 3**.

---

## 🚀 Công nghệ Sử dụng

- **Flutter 3.x & Dart 3.x**: Giao diện responsive, hỗ trợ chế độ Sáng / Tối (Dark & Light Mode).
- **Google Gemini AI**: Tích hợp trợ lý trí tuệ nhân tạo tư vấn đề tài và dự báo phân tích học vụ.
- **Auto-Detect Máy chủ**: Tự động dò tìm và kết nối với Backend API qua USB (ADB Reverse) hoặc LAN Wi-Fi.
- **Xác thực & Bảo mật**: JWT Bearer token lưu trữ trong `AuthService`, lưu phiên qua `SharedPreferences`.
- **Quản lý Dữ liệu**: Hỗ trợ bộ chọn tệp `file_picker`, nhập dữ liệu CSV/Excel, tải ảnh đại diện đa vai trò.
- **Đa ngôn ngữ (i18n)**: Hỗ trợ linh hoạt Tiếng Việt và Tiếng Anh (`AppLocalizations`).

---

## 🛠️ Hướng dẫn Cài đặt & Khởi chạy

### 1. Di chuyển vào thư mục dự án
Mở Terminal và trỏ tới thư mục:
```bash
cd ProGroup_AI_Frontend/progroup_ai_frontend
```

### 2. Tải các gói thư viện (Dependencies)
```bash
flutter pub get
```

### 3. Kiểm tra thiết bị khả dụng
```bash
flutter devices
```

### 4. Khởi chạy ứng dụng
```bash
flutter run
```
*(Nếu muốn chỉ định thiết bị cụ thể: `flutter run -d <device_id>`)*.

### 5. Đóng gói file cài đặt APK (Tùy chọn)
```bash
flutter build apk --debug
```
Tệp APK đầu ra sẽ được tạo tại: `build/app/outputs/flutter-apk/app-debug.apk`.

---

## 📁 Cấu trúc Thư mục

- `lib/core/`: Bảng màu theme, định tuyến (`app_routes.dart`), cài đặt cấu hình (`app_settings.dart`) và đa ngôn ngữ.
- `lib/models/`: Định nghĩa các thực thể dữ liệu (User, Course, Group, Topic, Notification...).
- `lib/screens/`: Màn hình giao diện phân theo 5 phân hệ vai trò người dùng:
  - `sinh_vien/`: Trang chủ, LHP, Nhóm đồ án, Đề tài, Trợ lý AI, Báo cáo tiến độ, Hồ sơ cá nhân.
  - `giang_vien/`: Trang chủ, LHP, Ngân hàng đề tài, Duyệt đăng ký, Chấm báo cáo, Hồ sơ.
  - `giao_vu/`: Tổng quan khoa, Phân công giảng viên, Quản lý LHP, Sinh viên, Hồ sơ.
  - `phong_dao_tao/`: Tổng quan toàn trường, Quản lý dữ liệu đào tạo, Hồ sơ.
  - `admin/`: Quản trị người dùng, Import người dùng từ Excel/CSV, Biểu đồ phân bổ vai trò, Hồ sơ.
  - `common/auth/login/`: Màn hình đăng nhập bảo mật và tự động hóa kết nối.
- `lib/services/`: Dịch vụ kết nối API (`ApiService`, `StudentApiService`, `LecturerApiService`...), gọi Gemini AI và xử lý upload avatar.
- `lib/widgets/`: Hệ thống các UI components tái sử dụng (Buttons, TextFields, StatCards, BottomNavBar...).
