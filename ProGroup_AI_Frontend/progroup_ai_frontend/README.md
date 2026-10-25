# ProGroup AI - Mobile Frontend (Flutter)

Ứng dụng di động đa nền tảng thuộc hệ thống **ProGroup AI** được xây dựng bằng **Flutter SDK (Dart 3)**.

## 🚀 Công nghệ sử dụng
- **Flutter & Dart 3**: Hỗ trợ Material Design 3, Responsive Layout, Dark/Light Mode.
- **Google Gemini AI**: Tích hợp mô hình AI tư vấn đề tài và dự báo phân tích học vụ.
- **In-App Auto Update (OTA)**: Tích hợp thư viện `ota_update` hỗ trợ tải và cài đặt cập nhật 1-chạm không mất dữ liệu.
- **Xác thực & Bảo mật**: JWT Bearer, SharedPreferences lưu phiên an toàn.
- **Quản lý dữ liệu**: Hỗ trợ nhập/xuất file CSV và Excel (.xlsx), bộ chọn ảnh đại diện `image_picker`.
- **Đa ngôn ngữ**: Hỗ trợ Tiếng Việt và Tiếng Anh (`AppLocalizations`).

## 📁 Cấu trúc thư mục
- `lib/core/`: Theme, bảng màu gradient, định tuyến (`app_routes.dart`), cài đặt và đa ngôn ngữ.
- `lib/models/`: Định nghĩa các thực thể dữ liệu (User, Course, Group, Topic, Notification, UpdateInfo).
- `lib/screens/`: Màn hình giao diện phân theo 5 vai trò người dùng:
  - `sinh_vien/`: Trang chủ, LHP, Nhóm đồ án, Đề tài, Trợ lý AI, Báo cáo tiến độ, Cá nhân.
  - `giang_vien/`: Trang chủ, LHP, Duyệt đề tài, Chấm báo cáo, Cá nhân.
  - `giao_vu/`: Tổng quan khoa, Phân công giảng viên, Quản lý LHP, Sinh viên.
  - `phong_dao_tao/`: Tổng quan toàn trường, Quản lý dữ liệu đào tạo.
  - `admin/`: Quản trị người dùng, Import Excel/CSV, Biểu đồ phân bổ vai trò.
- `lib/services/`: Các dịch vụ kết nối API backend, xử lý AI Gemini, quản lý cập nhật OTA và đồng bộ avatar.
- `lib/widgets/`: Hệ thống các widget dùng chung (Buttons, TextFields, StatCards, BottomNavigationBar).
