# 09. Báo cáo Kiểm thử Hồi quy (Regression Test Report)

Toàn bộ các bài kiểm tra bên dưới được chạy lại **sau lần chỉnh sửa code cuối cùng** (SQL indexes + Backend API + Flutter Client).

---

## 1. Backend Integration & Concurrency Tests (`scripts/integration_api_tests.py`)

**Kết quả:** **13 / 13 PASS (0 Failed)** — ghi kết quả chi tiết tại [integration_test_results.json](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/integration_test_results.json).

| Test ID | Trạng thái | Kết quả xác minh thực tế |
| --- | --- | --- |
| `API_HEALTH_CHECK` | `PASS` | HTTP 200 healthy |
| `AUTH_STUDENT_LOGIN` | `PASS` | Đăng nhập `SV001` thành công |
| `AUTH_LECTURER_LOGIN` | `PASS` | Đăng nhập `GV001` thành công |
| `AUTH_ADMIN_LOGIN` | `PASS` | Đăng nhập `ADMIN` thành công |
| `AUTH_GIAOVU_LOGIN` | `PASS` | Đăng nhập `GIAOVUKHOA` thành công |
| `AUTH_DAOTAO_LOGIN` | `PASS` | Đăng nhập `PHONGDAOTAO` thành công |
| `AUTH_INVALID_PASSWORD` | `PASS` | Chặn HTTP 401 Unauthorized |
| `PROFILE_FETCH_STUDENT` | `PASS` | Đọc profile `Trần Minh An (SV001)` |
| `PROFILE_UPDATE_PHONE` | `PASS` | Cập nhật SĐT `0987654321` trong SQL Server |
| `SECURITY_AVATAR_OVERSIZED_LIMIT` | `PASS` | Từ chối ảnh > 10MB với HTTP 400 |
| `SECURITY_RBAC_STUDENT_TO_ADMIN` | `PASS` | Sinh viên truy cập API Admin bị chặn HTTP 403 |
| `ADMIN_OVERVIEW_DATA` | `PASS` | Trả về số liệu thật: `264` users, `252` sinh viên, `6` giảng viên |
| `CONCURRENCY_TOPIC_REGISTRATION` | `PASS` | Chống race condition khi đăng ký đồng thời (`409` conflict cho cả 2 request không hợp lệ) |

---

## 2. Backend Build & Endpoint Benchmark (`dotnet build` + `perf_after.py`)

- **`dotnet build`:** Thành công với **0 errors**, 6 warnings pre-existing (`NU1902`/`NU1903` từ `System.Security.Cryptography.Pkcs` 9.0.11, `CS0618` ở `FirebaseNotificationService.cs`).
- **`perf_after.py` (30/30 endpoint + 3 burst scenarios):** Toàn bộ trả **HTTP 200**, JSON hợp lệ sau nén `gzip`.
- **`sys.dm_exec_query_resource_semaphores` sau stress:** `forced_grant_count` giữ nguyên ở `30`, `waiter_count = 0`.

---

## 3. Flutter Static Analysis, Unit Tests & Debug APK Build

| Hạng mục kiểm thử | Lệnh chạy | Kết quả thực tế | Ghi chú |
| --- | --- | --- | --- |
| Static Analysis trên các file tối ưu / mới | `flutter analyze --no-pub lib/services/data_cache_service.dart test/data_cache_service_test.dart` | **No issues found!** | Sạch lỗi trên toàn bộ file chỉnh sửa của đợt tối ưu |
| Static Analysis toàn dự án Flutter | `flutter analyze --no-pub` | **0 errors, 53 pre-existing `info` lints** | Toàn bộ 53 `info` là deprecated API (`withOpacity`, `Radio.groupValue`, v.v.) có sẵn ở các file chưa đụng |
| Unit tests Cache & Chat Persistence | `flutter test --no-pub test/data_cache_service_test.dart test/chat_persistence_test.dart` | **6 / 6 PASS** | Kiểm chứng cache TTL, `forceRefresh`, request coalescing, `userScope` isolation, `invalidatePrefix` và chat storage |
| Toàn bộ bộ `flutter test --no-pub` | `flutter test --no-pub` | **16 PASSED, 17 FAILED (pre-existing stale mock widget tests)** | 17 test thất bại nằm ở `admin_management_test.dart`, `ai_topic_screen_test.dart`, `governance_widget_test.dart`, `widget_test.dart` do `TestWidgetsFlutterBinding` chặn HTTP trả HTTP `400` khiến luồng đăng nhập API thật thất bại (các test này viết cho `MockAdminData` / mock auth cũ) |
| Build APK Android Debug | `flutter build apk --debug --no-pub` | **PASS (50.2s)** | Xuất thành công `build/app/outputs/flutter-apk/app-debug.apk` |
| Cài & chạy trực tiếp trên `emulator-5554` | `adb install -r ...` & `adb shell am start -S -W ...` | **BLOCKED bởi bộ nhớ máy ảo** | `INSTALL_FAILED_INSUFFICIENT_STORAGE` (phân vùng `/data` chỉ còn `638M` trống, dùng `89%`); lệnh start APK cũ (`14:51:11`) bị `timeout` (`WaitTime: 11279 ms`) |
