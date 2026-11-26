# 02. Kiểm toán Hiệu năng Flutter Client

**Thư mục dự án:** `D:\TRONGNGUYEN_HK7\PhatTrienUngDungDiDong\ProGroup_AI\ProGroup_AI_Frontend\progroup_ai_frontend`

---

## 1. Luồng Khởi động (`main.dart` & `SplashScreen`)

### Vấn đề phát hiện trước tối ưu
- Trong [main.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/main.dart), app await tuần tự `ApiService.autoDetectServer()` và `FirebaseService.instance.initialize()` **trước khi gọi `runApp()`**, khiến màn hình trắng kéo dài trên emulator nếu kết nối chậm hoặc host chưa sẵn sàng.
- Trong [splash_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/common/splash/splash_screen.dart), ứng dụng đặt `Future.delayed(const Duration(seconds: 2))` cứng trước khi chuyển sang `LoginScreen`.
- Trong [api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/api_service.dart), `autoDetectServer()` không có cơ chế khóa đồng thời (`_detectingFuture`) và không giới hạn timeout ngắn khi dò tuần tự các URL ứng viên.

---

## 2. Kiểm kê API Startup & Màn hình theo 5 Vai trò

| Vai trò & Shell | Số tab gắn sẵn (`IndexedStack`) | API gọi khi vừa vào Shell (Trước tối ưu) | Vấn đề gốc |
| --- | --- | --- | --- |
| **Sinh viên** (`StudentMainScreen`) | 5 tab (`HomeScreen`, `CourseScreen`, `GroupScreen`, `NotificationScreen`, `ProfileScreen`) | **10 calls đồng thời**: 3x `/api/student/courses`, 2x `/api/student/groups`, 2x `/api/profile`, 1x `/api/de-tai` (`58,367 B`), 1x `/api/notifications/unread-count`, 1x `/api/notifications` (`17,905 B`) | `IndexedStack` build cả 5 tab cùng lúc; nhiều màn hình tự gọi lại API đã tải; `HomeScreen` kéo toàn bộ 52 đề tài `/api/de-tai` thay vì `/api/student/topics`. |
| **Giảng viên** (`LecturerMainScreen`) | 4 tab (`LecturerHomeScreen`, `LecturerCourseScreen`, `LecturerGroupScreen`, `LecturerProfileScreen`) + `AuthService._loginViaApi` | **~16 calls**: `syncAllData()` trong `AuthService` tải thừa dữ liệu ngay sau đăng nhập + `LecturerMainScreen` mount sẵn 4 tab | Trùng lặp tải courses, statistics, notifications, profile ngay lúc đăng nhập. |
| **Giáo vụ khoa** (`GovernanceMainScreen`) | 4 tab | Đọc `/api/governance/students` (`64,126 B`, 252 records), `/api/governance/lecturers`, `/api/groups` (`27,109 B`) ở `GovernanceOverviewScreen` chỉ để lấy `.length` | Gọi cả danh sách chi tiết dù `/api/admin/overview` (`997 B`) đã có sẵn toàn bộ số đếm tổng quan. |
| **Phòng đào tạo** (`TrainingMainScreen`) | 4 tab | **8 calls**: `/api/notifications` (trùng), `/api/admin/overview`, `/api/lop-hoc-phan`, `/api/governance/students` (`64,126 B`), `/api/governance/lecturers`, `/api/groups` (`27,109 B`), `/api/profile` (`134,793 B` tổng cộng) | `TrainingOverviewScreen` cũng gọi các danh sách đầy đủ chỉ để đếm `.length` và lặp notification/profile. |
| **Admin** (`AdminMainScreen`) | 4 tab (`AdminOverviewScreen`, `AdminUserScreen`, `AdminDataManagementScreen`, `AdminProfileScreen`) | Mount cả 4 tab đồng thời -> gọi `/api/admin/overview`, `/api/admin/users` (`101,154 B`), `/api/notifications`, `/api/profile` ngay lúc mở | Màn hình chưa được người dùng bấm vào đã tải `264` user records (`101 KB`). |

---

## 3. Kiểm toán Chi tiết các Màn hình Chức năng Chính

1. **Đăng nhập (`LoginScreen` & `AuthService`):**  
   - `AuthService.reAuthenticate()` không có single-flight lock (`_reAuthFuture`). Trong log backend trước tối ưu (`task-1112.log`), khi nhiều request nhận `401` cùng lúc, client bắn **12 request `POST /api/auth/login` song song**, buộc server chạy `BCrypt.Verify` liên tiếp làm thời gian login phình lên **`5.2s–7.1s`**.
   - `AuthService` tạo `http.Client()` mới thay vì tái sử dụng connection pool của `ApiService`.
2. **Chi tiết nhóm Sinh viên (`GroupDetailScreen`):**  
   - Khi xem chi tiết nhóm đã có `deTaiId`, màn hình gọi `fetchAllTopics()` (`/api/de-tai`, 52 bản ghi = `58,367 B`) rồi mới lọc theo ID ở client.
3. **Danh sách & Đề xuất Đề tài Giảng viên (`LecturerApiService.fetchTopicProposals`):**  
   - Chưa ưu tiên gọi endpoint chuyên biệt `/api/de-tai/proposals` (`4` bản ghi = `4,884 B`), gây nguy cơ rơi về danh sách lớn hơn.
4. **Render UI & Media (`AvatarService`):**  
   - [avatar_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/avatar_service.dart) thực hiện `base64Decode(...)` trực tiếp bên trong `buildAvatarContent` ở mỗi lần widget rebuild, không lưu bộ đệm `Uint8List` đã giải mã và không giới hạn `cacheWidth`/`cacheHeight` cho `Image.memory`, gây tốn CPU UI thread & memory khi scroll danh sách dài.
5. **Danh sách dài & Thống kê:**  
   - Các màn hình bảng điều khiển (`GovernanceOverviewScreen`, `TrainingOverviewScreen`) chưa tận dụng số đếm tổng hợp từ `/api/admin/overview`, làm tăng kích thước payload không cần thiết ở cả tab đầu tiên.
6. **Cache & Coalescing:**  
   - Trước tối ưu, `StudentApiService`, `AdminApiService`, `GovernanceApiService` hoàn toàn không có TTL cache ngắn hạn hoặc gom request trùng lặp (`in-flight request coalescing`); `LecturerApiService` có cache nhưng không ràng buộc `userScope` chặt chẽ với sự kiện đổi tài khoản / `logout()`.
