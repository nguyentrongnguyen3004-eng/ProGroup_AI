# 07. Chi tiết Triển khai Tối ưu (Optimization Implementation)

Toàn bộ tối ưu tuân thủ 13 nguyên tắc bắt buộc: **không thay đổi nghiệp vụ, không xóa validation/RBAC, không giảm toàn vẹn dữ liệu, không dùng mock thay dữ liệu thật, cache có TTL rõ ràng và tự hủy theo tài khoản / thao tác ghi**.

---

## 1. Tầng SQL Server ([optimize_sql_indexes.sql](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/scripts/optimize_sql_indexes.sql))

Tạo **8 composite & covering indexes** nhắm đúng các điều kiện `WHERE`, `JOIN` và `ORDER BY` thực tế (không thêm index bừa bãi; tổng cộng sau triển khai có 37 nonclustered/clustered `IX_*` trên schema, không xóa dữ liệu):

1. `IX_ThongBaos_User_LoaiLienKet_CreatedAt` trên `ThongBaos (NguoiDungId, LoaiLienKet, CreatedAt DESC) INCLUDE (DaDoc)`
2. `IX_ThanhVienNhoms_SinhVienId_TrangThai` trên `ThanhVienNhoms (SinhVienId, TrangThai)`
3. `IX_ThanhVienNhoms_NhomId_TrangThai` trên `ThanhVienNhoms (NhomId, TrangThai)`
4. `IX_DangKyDeTais_TrangThai` trên `DangKyDeTais (TrangThai) INCLUDE (NhomId, DeTaiId, NgayDangKy)`
5. `IX_DeTaiDoAns_CreatedAt` trên `DeTaiDoAns (CreatedAt DESC)`
6. `IX_DotDangKyDoAns_LopHocPhanId_TrangThai` trên `DotDangKyDoAns (LopHocPhanId, TrangThai)`
7. `IX_SinhVienLopHocPhans_SinhVienId_TrangThai` trên `SinhVienLopHocPhans (SinhVienId, TrangThai)`
8. `IX_PhanCongGiangViens_GiangVienId_TrangThai` trên `PhanCongGiangViens (GiangVienId, TrangThai)`

---

## 2. Tầng ASP.NET Core Web API

1. **HTTP Response Compression & Timing Middleware ([Program.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Program.cs)):**
   - Bật `AddResponseCompression` / `UseResponseCompression` hỗ trợ Brotli & Gzip cho JSON/HTTPS.
   - Thêm middleware gắn header `X-Response-Time-Ms` và log cảnh báo `Slow API` (`>= 300ms`, không log token/password/payload nhạy cảm).
   - Bọc `UseHttpsRedirection()` theo biến `ASPNETCORE_HTTPS_PORT` để tránh warning thừa trên dev HTTP `5094`.
2. **Dịch chuyển lịch Auto Backup ([DatabaseAutoBackupService.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Services/DatabaseAutoBackupService.cs)):**
   - Đổi delay lần backup đầu tiên sau khi khởi động API từ **1 phút** lên **15 phút** để tránh tranh chấp I/O và memory ngay lúc app/client vừa kết nối.
3. **Loại bỏ SQL `Sort` trên bảng có `NVARCHAR(MAX)` (triệt tiêu `RESOURCE_SEMAPHORE`):**
   - [DeTaiController.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/DeTaiController.cs) (`GetAll`, `GetLecturerTopics`, `GetStudentProposedTopics`, `GetTopicProposals`), [StudentController.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/StudentController.cs) (`GetAvailableTopics`), và [BaoCaoTienDoController.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/BaoCaoTienDoController.cs): chuyển `.OrderByDescending(...)` sang sắp xếp trong bộ nhớ .NET ngay sau `ToListAsync()`. Kết quả JSON trả về giữ nguyên thứ tự tuyệt đối, nhưng loại bỏ toán tử `Sort` có `AvgRowSize = 15,756` trong SQL Server.
4. **Thay `.Include()` dư thừa bằng SQL Projection & Aggregation gọn:**
   - `StudentController.GetMyGroups()` & `GetCourses()`: bỏ 4 `.Include()` nhân chéo, chuyển sang `.Select(...)` trực tiếp.
   - `GroupsController` (`GetAll`, `Mine`): thống nhất qua `ToGroupProjection()` + `FinalizeGroupResponse()`.
   - `LecturerController` (`GetCourses`, `GetStatistics`, `GetTopicRegistrations`): đếm và group trực tiếp trong SQL thay vì tải toàn bộ entity con về RAM.
   - `AdminController` (`GetOverview`, `GetUsers`, `GetActivityLogs`): gộp nhiều query đếm thành `GroupBy`, bỏ `.Include()` dư, thêm phân trang tùy chọn `page`/`pageSize` cho `GetUsers` (vẫn giữ tương thích ngược khi không truyền param).
   - `GovernanceController` (`GetCourses`, `GetAssignments`, `GetStudents`, `GetLecturers`): bỏ `.Include()` thừa, thêm phân trang tùy chọn `page`/`pageSize` cho `GetStudents`.
   - `LopHocPhanController` (`GetCourseStudents`, `GetCourseDetails`): dùng helper `BuildCourseStudentsListAsync` tránh truy vấn lặp `DotDangKyDoAns` và `NhomDoAns`.
   - `NotificationsController`: thêm tham số `bool countOnly = false` vào `GenerateNotificationsAsync` cho endpoint `/api/notifications/unread-count`, thay `.Include()` bằng `.Select()`.

---

## 3. Tầng Flutter Client

1. **Short-lived User-Scoped Cache & Request Coalescing ([data_cache_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/data_cache_service.dart)):**
   - TTL mặc định **20 giây**, khóa theo `_userScope` (`setUserScope(...)`) để cô lập dữ liệu tuyệt đối giữa các tài khoản.
   - Gom các request `GET` trùng key đang chạy song song (`_inFlight`) thành **1 HTTP call** duy nhất.
   - Hỗ trợ `forceRefresh`, `invalidateKey`, `invalidatePrefix`, `invalidateAll`.
2. **Mạng, Hủy Cache & Khóa đồng thời (`ApiService`, `AuthService`):**
   - [api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/api_service.dart): `autoDetectServer()` dò song song các URL ứng viên với timeout ngắn `1–2s` và lock `_detectingFuture`; mọi `POST`/`PUT`/`DELETE` thành công tự động gọi hủy cache phù hợp.
   - [auth_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/auth_service.dart): thêm `_reAuthFuture` chặn login stampede khi gặp 401 đồng thời; cập nhật `setUserScope` / `invalidateAll()` và `LecturerApiService.instance.clearCache()` khi `login()` / `logout()`; bỏ `syncAllData()` thừa lúc đăng nhập; tái sử dụng `ApiService.client`.
3. **Khởi động Non-blocking ([main.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/main.dart), [splash_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/common/splash/splash_screen.dart)):**
   - Song song hóa `initCustomUrl()` + `loadSavedToken()`, đẩy `FirebaseService.instance.initialize()` chạy bất đồng bộ sau `runApp()`, rút `SplashScreen` từ 2 giây xuống `450ms` song song với `autoDetectServer().timeout(1800ms)`.
4. **Lazy Tab Mounting cho cả 5 `*MainScreen`:**
   - [student_main_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/sinh_vien/home/student_main_screen.dart), [lecturer_main_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/giang_vien/main/lecturer_main_screen.dart), [governance_main_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/giao_vu/main/governance_main_screen.dart), [training_main_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/phong_dao_tao/main/training_main_screen.dart), [admin_main_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/admin/main/admin_main_screen.dart): chỉ mount tab `{0}` ban đầu trong `IndexedStack`, chỉ build các tab còn lại khi người dùng thực sự chuyển tab (`_initializedTabs.contains(i) ? builder() : const SizedBox.shrink()`), giữ nguyên state khi đã mở.
5. **Giảm Over-fetching trên Màn hình & Decode Avatar:**
   - [home_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/sinh_vien/home/home_screen.dart): chuyển sang `fetchAvailableTopics()` (`/api/student/topics`) thay vì `/api/de-tai`, dùng `forceRefresh: true` khi pull-to-refresh.
   - [group_detail_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/sinh_vien/group/group_detail_screen.dart): dùng `fetchTopicById(deTaiId)` thay vì tải toàn bộ 52 đề tài.
   - [governance_overview_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/giao_vu/home/governance_overview_screen.dart) & [training_overview_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/phong_dao_tao/home/training_overview_screen.dart): bỏ gọi `fetchStudents`, `fetchLecturers`, `fetchGroups` dư thừa, đọc số liệu từ `/api/admin/overview`.
   - [student_api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/student_api_service.dart), [lecturer_api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/lecturer_api_service.dart), [admin_api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/admin_api_service.dart), [governance_api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/governance_api_service.dart): tích hợp `DataCacheService` + `forceRefresh`.
   - [avatar_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/avatar_service.dart): cache `Uint8List` sau `base64Decode` theo chuỗi gốc và truyền `cacheWidth`/`cacheHeight` cho `Image.memory`.
