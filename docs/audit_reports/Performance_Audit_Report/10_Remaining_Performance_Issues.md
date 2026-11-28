# 10. Các Vấn đề Hiệu năng Còn tồn đọng & Khuyến nghị (Remaining Performance Issues)

Mặc dù các nút thắt gây treo 25 giây (`RESOURCE_SEMAPHORE`) và bão 10–16 request lúc startup đã được xử lý triệt để ở tầng mã nguồn & SQL index, vẫn còn **5 giới hạn hạ tầng / cấu trúc** cần người dùng hoặc đội ngũ phát triển xử lý ở bước vận hành tiếp theo:

---

## 1. Bộ nhớ máy host cạn kiệt khiến SQL Server vẫn giữ `process_physical_memory_low = 1`
- **Bằng chứng:** Máy host có `15,676 MB` RAM nhưng chỉ còn `775 MB` trống; `sys.dm_os_process_memory` của `SQLEXPRESS` vẫn báo `process_physical_memory_low = 1` và `resource_semaphore_id = 0` có `target_memory_kb = 8,160 KB` (~8 MB).
- **Rủi ro:** Hiện tại các query đã tránh được Memory Grant lớn nên chạy nhanh (~5–146 ms), nhưng nếu sau này dữ liệu tăng lên hàng chục nghìn dòng hoặc mở thêm IDE/Docker/Chrome ngốn RAM hơn nữa, SQL Server vẫn có nguy cơ gặp lại áp lực bộ nhớ.
- **Khuyến nghị:** Đóng bớt tiến trình nền không cần thiết hoặc giới hạn `max server memory (MB)` hợp lý (ví dụ `1024–2048 MB`) cho `SQLEXPRESS` để ổn định cấp phát bộ nhớ khi host ít RAM trống.

## 2. Phân vùng `/data` trên Android Emulator (`Pixel_7_Pro_API_34`) sắp đầy (`638M` free / 89%)
- **Bằng chứng:** `adb install -r` thất bại với `INSTALL_FAILED_INSUFFICIENT_STORAGE`; `adb shell df -h /data` báo `5.0G / 5.8G` (`89%`).
- **Hành động cần làm:** Trên Android Studio Device Manager, **Wipe Data** (hoặc nâng `Internal Storage` của AVD từ `~6 GB` lên `12–16 GB`), sau đó gỡ bản cũ và cài lại APK mới vừa build tại `ProGroup_AI_Frontend/progroup_ai_frontend/build/app/outputs/flutter-apk/app-debug.apk`.

## 3. Lần `POST /api/auth/login` đầu tiên sau khi khởi động API (Cold Start JIT + EF Model + BCrypt)
- **Bằng chứng:** Lần login đầu tiên sau khi khởi động lại server (`sv001`) mất `3,293.72 ms` (server log `3129 ms`), các lần ngay sau đó giảm về `197.62–672.16 ms`.
- **Nguyên nhân:** JIT compilation của .NET, khởi tạo model EF Core đầu tiên và độ trễ hash `BCrypt.Verify`.
- **Khuyến nghị:** Có thể thêm một `IHostedService` warmup nhẹ chạy query `SELECT TOP 1` trên `NguoiDungs` ngay khi API start (không chặn port listen) để lần đăng nhập đầu tiên của user đạt mức ~200–500 ms.

## 4. Các Màn hình Danh sách còn Tải Toàn bộ Bản ghi khi Dữ liệu Tăng Trưởng
- **Bằng chứng:** Các endpoint `/api/admin/users` (`264` bản ghi = `101,154 B` raw / `11,785 B` gzip), `/api/governance/students` (`252` bản ghi = `64,126 B` raw / `8,928 B` gzip), `/api/de-tai` (`52` bản ghi = `58,367 B` raw / `13,981 B` gzip).
- **Khuyến nghị:** Backend đã bổ sung tùy chọn phân trang (`page`/`pageSize`) ở `AdminController.GetUsers` và `GovernanceController.GetStudents`; khi dữ liệu vượt ngưỡng >1,000 bản ghi, cần nâng cấp các màn hình danh sách Flutter từ tìm kiếm local toàn bộ sang tải theo trang (infinite scroll / pagination).

## 5. Bộ Widget Test Flutter Cũ Cần Cập nhật Sang HTTP Fake / Mock Interceptor
- **Bằng chứng:** `flutter test --no-pub` còn **17 test cũ thất bại** ở `admin_management_test.dart`, `ai_topic_screen_test.dart`, `governance_widget_test.dart`, `widget_test.dart` do giả lập login trực tiếp qua API trong môi trường `TestWidgetsFlutterBinding` (nơi mọi request HTTP tự động trả `400`).
- **Khuyến nghị:** Inject `http.Client` mock qua `MockClient` hoặc interface `AuthService` trong các file test cũ để CI/CD Flutter chạy xanh 100% offline.

## 6. Trạng thái Đo Interactive UI / Flutter DevTools Timeline
- **Trạng thái:** **BLOCKED** đối với thao tác kéo/cuộn trực tiếp trên màn hình APK mới do máy ảo `emulator-5554` báo lỗi `INSTALL_FAILED_INSUFFICIENT_STORAGE` khi cài đặt bản debug APK mới nhất. Tuy nhiên, tầng static analysis, unit test cache và APK build đều đã hoàn thành kiểm chứng đầy đủ.
