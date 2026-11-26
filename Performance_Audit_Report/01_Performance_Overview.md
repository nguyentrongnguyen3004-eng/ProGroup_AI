# 01. Tổng quan Kiểm toán & Tối ưu Hiệu năng Hệ thống ProGroup_AI

**Ngày thực hiện:** 2026-11-26  
**Phạm vi kiểm toán:** Toàn bộ luồng **Flutter Mobile Client → ASP.NET Core Web API → Microsoft SQL Server (`ProjectRegistrationDB` trên `LAPTOP-3RHN15E2\SQLEXPRESS`) → Android Emulator (`Pixel_7_Pro_API_34`, `emulator-5554`)**.

---

## 1. Hiện tượng ban đầu & Kết luận gốc

Người dùng phản ánh dữ liệu tải trên Android Emulator chậm, đặc biệt ở một số màn hình và lúc đăng nhập/khởi động ứng dụng mất nhiều thời gian mới hiển thị dữ liệu.

Qua đo đạc thực nghiệm ở tầng HTTP/API, truy vấn SQL Server (`sys.dm_exec_requests`, `sys.dm_exec_query_resource_semaphores`, `sys.dm_os_wait_stats`, `SET STATISTICS PROFILE ON`), mã nguồn Flutter và cấu hình Android Emulator, nguyên nhân không đến từ băng thông mạng máy ảo (`10.0.2.2` ping avg `3.064 ms`–`5.541 ms`, `adb reverse tcp:5094 tcp:5094` kết nối 5 lần TCP trong `0.15s`), mà là **chuỗi cộng hưởng nghẽn cổ chai ở 3 tầng**:

1. **Tầng SQL Server (`RESOURCE_SEMAPHORE` starvation – tắc 14.6s–25.1s):**  
   Máy chủ host chỉ còn `HostAvailMB = 775` trên tổng `15676 MB` RAM, khiến SQL Server bật cờ `process_physical_memory_low = 1` (`SqlMemInUseMB = 104`). Semaphore cấp phát bộ nhớ truy vấn (`resource_semaphore_id = 0`) bị thu hẹp còn `target_memory_kb = 8040`–`8160` (~8 MB). Khi ASP.NET Core gửi các truy vấn có nhiều `.Include()` nhân chéo hoặc `ORDER BY` trên bảng có cột `NVARCHAR(MAX)` (`AvgRowSize = 15756` ở `DeTaiDoAns`), SQL Server yêu cầu Memory Grant nhiều MB và buộc truy vấn phải chờ `RESOURCE_SEMAPHORE` tới **`25,015 ms` (`max_wait_time_ms`)** với `forced_grant_count = 30`, `waiting_tasks_count = 83`, tổng `wait_time_ms = 1,430,892 ms`.
2. **Tầng Flutter ("Thundering Herd" khi mở màn hình chính & block trước `runApp`):**  
   - Cả 5 `*MainScreen` theo vai trò (`StudentMainScreen`, `LecturerMainScreen`, `GovernanceMainScreen`, `TrainingMainScreen`, `AdminMainScreen`) dùng `IndexedStack` mount toàn bộ 4–5 tab ngay khi vừa đăng nhập.  
   - Màn hình Sinh viên bắn **10 request song song** lúc startup (trùng 3x `/api/student/courses`, 2x `/api/student/groups`, 2x `/api/profile`, kèm `/api/de-tai` `58,367 bytes`).  
   - `AuthService.reAuthenticate()` và `ApiService.autoDetectServer()` thiếu khóa chống chạy song song (`concurrency lock`), từng gây bão 12 `POST /api/auth/login` (`BCrypt.Verify`) song song mất `5.2s–7.1s/request`.  
   - `main.dart` await tuần tự `autoDetectServer()` và `FirebaseService.instance.initialize()` trước `runApp()`, cộng thêm delay cứng 2 giây tại `SplashScreen`.
3. **Tầng ASP.NET Core Web API:**  
   - Thiếu Response Compression (Brotli/Gzip), truyền nguyên JSON tới `101,154 bytes` (`/api/admin/users`), `64,126 bytes` (`/api/governance/students`), `58,367 bytes` (`/api/de-tai`).  
   - Một số controller giữ nhiều `.Include()` dư thừa hoặc `OrderByDescending` trên cột `NVARCHAR(MAX)` trong SQL; `NotificationsController` tính toàn bộ thông báo ngay cả khi chỉ cần `/unread-count`; `DatabaseAutoBackupService` chạy `BACKUP DATABASE` sau 1 phút khởi động.

---

## 2. Tóm tắt Chỉ số Trước → Sau Tối ưu (Đo thực tế)

| Kịch bản / Chỉ số | Trước tối ưu (Baseline) | Sau tối ưu (Final Build) | Ghi chú |
| --- | --- | --- | --- |
| `Student_Groups` (`GET /api/student/groups`) | cold `25,093.56 ms`, avg `9,588.94 ms` | cold `146.47 ms`, avg `43.54 ms`, median `19.77 ms` | Thoát tắc `RESOURCE_SEMAPHORE`, payload wire `795 B` (`gzip`) |
| `DeTai_All` (`GET /api/de-tai`) | cold `30.60 ms` (trước khi dính wait) / `25,077.34 ms` (khi dính `Sort` semaphore) | cold `48.05 ms`, avg `22.23 ms`, median `12.00 ms` | Bỏ SQL Sort `NVARCHAR(MAX)`, wire `13,981 B` (raw `58,367 B`, giảm ~76%) |
| `STUDENT_STARTUP_BURST` | 10 calls, wall `26,071.55 ms`, max `25,887.17 ms`, `89,941 B` | 5 calls, wall `83.35 ms`, max `73.20 ms`, wire `7,461 B` (`raw 27,315 B`) | Giảm 50% số API startup, thoát treo 26s |
| `TRAINING_STARTUP_BURST` | 8 calls, wall `76.50 ms`, `134,793 B` | 4 calls, wall `61.17 ms`, wire `6,087 B` (`raw 26,005 B`) | Giảm 50% số API, giảm ~95.5% dung lượng truyền wire |
| `STRESS_10_CALL_BURST` (cùng 10 calls như baseline) | wall `26,071.55 ms`, max `25,887.17 ms` | wall `88.11 ms`, max `83.35 ms`, wire `23,088 B` | Chịu tải đồng thời không còn dính `RESOURCE_SEMAPHORE` |
| `Admin_Overview` (`GET /api/admin/overview`) | cold `389.84 ms`, avg `148.29 ms` | cold `185.54 ms`, avg `56.09 ms`, median `31.06 ms` | Gom `GroupBy` trong SQL |
| `Admin_Users` wire size (`264` records) | `101,154 B` | `11,785 B` (`gzip`) | Giảm ~88.3% băng thông truyền |
| `Governance_Students` wire size (`252` records) | `64,126 B` | `8,928 B` (`gzip`) | Giảm ~86.1% băng thông truyền |
| `Sql forced_grant_count` sau tái kiểm tra | Tăng lên `30` trong lúc nghẽn | Duy trì `30` (không phát sinh forced grant mới) | Kiểm chứng bằng `sys.dm_exec_query_resource_semaphores` |

---

## 3. Bộ Báo cáo Chi tiết (10 Tài liệu)

1. [01_Performance_Overview.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/01_Performance_Overview.md) — Tổng quan toàn hệ thống và tóm tắt kết quả.
2. [02_Flutter_Performance_Audit.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/02_Flutter_Performance_Audit.md) — Audit khởi động, màn hình theo vai trò, mạng, cache và render UI Flutter.
3. [03_Backend_Performance_Audit.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/03_Backend_Performance_Audit.md) — Audit middleware, controller, EF Core queries, compression và background jobs.
4. [04_SQL_Server_Performance_Audit.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/04_SQL_Server_Performance_Audit.md) — Audit bảng, chỉ mục, wait stats, `RESOURCE_SEMAPHORE` và query plan.
5. [05_Emulator_Environment_Audit.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/05_Emulator_Environment_Audit.md) — Audit máy ảo `Pixel_7_Pro_API_34`, RAM/heap, độ phân giải, GPU và mạng `adb reverse`.
6. [06_Bottleneck_Analysis.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/06_Bottleneck_Analysis.md) — Phân tích nguyên nhân gốc (Root Cause Analysis) có bằng chứng từng tầng.
7. [07_Optimization_Implementation.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/07_Optimization_Implementation.md) — Danh sách chi tiết từng thay đổi đã áp dụng ở SQL, Backend và Flutter.
8. [08_Performance_Before_After.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/08_Performance_Before_After.md) — Bảng đối chiếu đầy đủ 30 endpoints và startup bursts Trước / Sau.
9. [09_Regression_Test_Report.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/09_Regression_Test_Report.md) — Kết quả kiểm thử hồi quy (Integration API tests, Unit tests, `dotnet build`, `flutter analyze`, APK build).
10. [10_Remaining_Performance_Issues.md](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Performance_Audit_Report/10_Remaining_Performance_Issues.md) — Các giới hạn hạ tầng / phần cứng và khuyến nghị tiếp theo.
