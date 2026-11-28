# 06. Phân tích Nguyên nhân Gốc (Bottleneck & Root Cause Analysis)

Báo cáo này liên kết từng triệu chứng người dùng gặp phải trên Android Emulator với bằng chứng đo được ở 4 tầng để chỉ ra nguyên nhân gốc (Root Cause), thay vì phỏng đoán.

---

## 1. Bảng Chuỗi Nguyên nhân – Bằng chứng

| Triệu chứng quan sát | Nguyên nhân gốc (Root Cause) | Bằng chứng định lượng |
| --- | --- | --- |
| **Một số màn hình treo ~15–25 giây mới hiện dữ liệu** (`Nhóm`, `Đề tài`, lúc mới vào `HomeScreen`) | **SQL Server `RESOURCE_SEMAPHORE` starvation:** RAM máy host còn `775 MB / 15,676 MB`, SQL Server vào trạng thái `process_physical_memory_low = 1` làm semaphore bộ nhớ truy vấn (`resource_semaphore_id = 0`) co về `8,040–8,160 KB` (~8 MB). Các query có `.Include()` Cartesian rộng (`GetMyGroups`) hoặc `ORDER BY` trên bảng chứa `NVARCHAR(MAX)` (`AvgRowSize = 15,756` ở `DeTaiDoAns`) yêu cầu Memory Grant lớn, buộc phải nằm chờ `RESOURCE_SEMAPHORE` tới 25 giây trước khi SQL cấp `forced_grant`. | - `Student_Groups` cold: **`25,093.56 ms`**, avg `9,588.94 ms`, median `26.33 ms`.<br>- `DeTai_All` bản trước khi bỏ SQL Sort: cold **`25,077.34 ms`**.<br>- `sys.dm_os_wait_stats`: `RESOURCE_SEMAPHORE` có `waiting_tasks_count = 83`, `max_wait_time_ms = 25,015`, `wait_time_ms = 1,430,892`. |
| **Vừa đăng nhập vào app đã đơ / mất hàng chục giây mới tải xong** | **"Thundering Herd" từ Flutter `IndexedStack` + trùng request + không coalescing:** Cả 5 `*MainScreen` khởi tạo cả 4–5 tab ngay lúc đăng nhập. `StudentMainScreen` bắn **10 request song song** (3x `/api/student/courses`, 2x `/api/student/groups`, 2x `/api/profile`, kèm `/api/de-tai` `58,367 B`), đẩy thẳng vào SQL Server đang thiếu Memory Grant -> tạo đỉnh treo đồng loạt **`26,071.55 ms`**. | - `STUDENT_STARTUP_BURST (10 calls)`: `wall = 26,071.55 ms`, `max_call = 25,887.17 ms`, `total_bytes = 89,941`.<br>- `TRAINING_STARTUP_BURST (8 calls)`: `total_bytes = 134,793`.<br>- `Lecturer` startup + `syncAllData()`: ~16 calls. |
| **Đăng nhập / hết phiên thỉnh thoảng chậm 5–7 giây** | **Login stampede khi `reAuthenticate()` thiếu lock:** Khi nhiều request đang bay song song cùng gặp `401`, `AuthService.reAuthenticate()` chưa dùng single-flight `Future` nên bắn tới **12 `POST /api/auth/login` song song**, buộc backend chạy `BCrypt.Verify` tuần tự/cạnh tranh CPU. | - Log `task-1112.log` ghi nhận 12 `POST /api/auth/login` đồng thời với độ trễ **`5.2s–7.1s`**. |
| **Mở app tới màn hình Đăng nhập chậm (~2–4 giây)** | **Block trước `runApp()` + Splash delay cố định:** `main()` await tuần tự `ApiService.autoDetectServer()` và `FirebaseService.instance.initialize()` trước `runApp()`, sau đó `SplashScreen` chờ thêm `2 giây` cứng. | - Kiểm tra source `lib/main.dart` và `lib/screens/common/splash/splash_screen.dart`. |
| **Chuyển tab hoặc mở danh sách dài (Admin Users, Sinh viên, Đề tài) tốn băng thông & lag UI** | **Thiếu HTTP Compression + Over-fetching + Re-decode Base64:** Backend chưa nén Gzip/Brotli (`Admin_Users` `101,154 B`, `Governance_Students` `64,126 B`, `DeTai_All` `58,367 B`). Các màn Overview tải danh sách hàng trăm bản ghi chỉ để lấy `.length`. `GroupDetailScreen` tải cả 52 đề tài chỉ để tìm 1 đề tài. `AvatarService` chạy `base64Decode` lại ở mỗi lần `build()`. | - Đo payload baseline: `101,154 B` -> sau nén Gzip chỉ còn `11,785 B` (giảm **88.3%**).<br>- `Governance_Students`: `64,126 B` -> `8,928 B` (giảm **86.1%**). |

---

## 2. Những Giả thuyết Đã Bị Loại trừ bằng Bằng chứng

1. **Emulator network (`10.0.2.2` / `adb reverse`) không phải nút thắt cổ chai chính:** `ping 10.0.2.2` chỉ `3.064–5.541 ms`, 5 lần TCP connect `127.0.0.1:5094` chỉ mất `0.15s`.
2. **Kích thước dữ liệu SQL không lớn:** Bảng nhiều nhất mới có `451` dòng (`SinhVienLopHocPhans`), `264` người dùng, `52` đề tài. Truy vấn bình thường chỉ mất `4–35 ms` khi không vướng Memory Grant hoặc Cartesian `.Include()`.
3. **N+1 HTTP ở một số màn hình phụ không lớn bằng Thundering Herd + `RESOURCE_SEMAPHORE`:** Việc loại bỏ `RESOURCE_SEMAPHORE` và cắt 50% số API startup + gom duplicate đã kéo burst 10-call / 5-call từ **26,071 ms xuống dưới 90 ms**.
