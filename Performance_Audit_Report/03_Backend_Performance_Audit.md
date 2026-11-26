# 03. Kiểm toán Hiệu năng ASP.NET Core Web API

**Thư mục dự án:** `D:\TRONGNGUYEN_HK7\PhatTrienUngDungDiDong\ProGroup_AI\ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API`

---

## 1. Cấu hình Pipeline & Middleware (`Program.cs`)

### Hiện trạng trước tối ưu
- **Không bật Response Compression:** Toàn bộ payload JSON lớn trả về nguyên dạng không nén (`application/json` thuần), ví dụ:
  - `/api/admin/users` (264 bản ghi): **`101,154 bytes`**
  - `/api/governance/students` (252 bản ghi): **`64,126 bytes`**
  - `/api/de-tai` (52 bản ghi): **`58,367 bytes`**
  - `/api/groups` (28 bản ghi): **`27,109 bytes`**
  - `/api/student/topics` (20 bản ghi): **`21,561 bytes`**
- **Thiếu đo thời gian xử lý API (`ApiTiming`):** Không có middleware ghi nhận endpoint chậm (`>= 300ms`) hay header `X-Response-Time-Ms`.
- **Cảnh báo HTTPS Redirection:** `UseHttpsRedirection()` được gọi unconditionally dù môi trường dev đang chạy HTTP port `5094` (`http://0.0.0.0:5094`), phát sinh warning ở `HttpsRedirectionMiddleware`.
- **Background Auto Backup (`DatabaseAutoBackupService`):** Lên lịch chạy `BACKUP DATABASE` chỉ **1 phút sau khi API khởi động**, trùng thời điểm người dùng vừa mở app và đăng nhập.

---

## 2. Kiểm toán EF Core Queries theo Controller

| Controller | Endpoint / Method | Vấn đề hiệu năng tìm thấy | Tác động |
| --- | --- | --- | --- |
| `StudentController` | `GetMyGroups()` | Dùng 4 `.Include(...)` lồng nhau (kèm `ThanhVienNhoms`, `LopHocPhan`, `HocPhan`, `GiangVien`...) tạo Cartesian join rộng | Kích hoạt truy vấn nặng và tranh chấp memory grant trong SQL Server (`cold_ms = 25,093.56 ms` ở baseline). |
| `StudentController` | `GetCourses()`, `GetAvailableTopics()` | `GetCourses()` chứa `.Include()` dư thừa khi đã `.Select()` projection; `GetAvailableTopics()` đẩy `OrderByDescending(CreatedAt)` vào SQL trên bảng có cột `NVARCHAR(MAX)` | Phát sinh toán tử `Sort` tiêu tốn Memory Grant trong SQL Server. |
| `DeTaiController` | `GetAll`, `GetLecturerTopics`, `GetStudentProposedTopics`, `GetTopicProposals` | Sắp xếp `OrderByDescending` trên tập kết quả có nhiều cột `NVARCHAR(MAX)` (mô tả, mục tiêu, yêu cầu) | Plan SQL Server có `AvgRowSize = 15,756 bytes` tại toán tử `Sort`, kích hoạt `RESOURCE_SEMAPHORE` (`cold_ms = 25,077.34 ms` ở bản chạy trước khi sửa `DeTaiController`). |
| `BaoCaoTienDoController` | Danh sách báo cáo theo nhóm / giảng viên | Tương tự `DeTaiController`, giữ `OrderByDescending` trên SQL kết hợp các cột text dài | Có nguy cơ yêu cầu Memory Grant lớn khi bộ nhớ SQL thấp. |
| `GroupsController` | `GetAll()`, `Mine()` | Truy vấn entity kèm `.Include()` đầy đủ trước khi map DTO | Dư thừa cột tải từ SQL; lặp code mapping giữa `GetAll` và `Mine`. |
| `LecturerController` | `GetCourses()`, `GetStatistics()`, `GetTopicRegistrations()` | `.Include()` toàn bộ tập con (`NhomDoAns`, `DangKyDeTais`, `SinhVienLopHocPhans`) về bộ nhớ rồi mới `.Count()` | Tốn RAM .NET và I/O SQL thay vì aggregate trực tiếp bằng SQL `.Count()` / `.GroupBy()`. |
| `AdminController` | `GetOverview()`, `GetUsers()`, `GetActivityLogs()` | `GetOverview()` tách nhiều query đếm riêng lẻ trên `DeTaiDoAns` và `DangKyDeTais`; `GetUsers()`/`GetActivityLogs()` có `.Include()` dư thừa khi đã `.Select(...)`; `GetUsers()` luôn trả cả 264 bản ghi không có phân trang tùy chọn | Baseline `Admin_Overview`: `cold_ms = 389.84 ms`, `avg_ms = 148.29 ms`; `Admin_ActivityLogs`: `cold_ms = 341.47 ms`. |
| `GovernanceController` | `GetCourses()`, `GetAssignments()`, `GetStudents()`, `GetLecturers()` | Nhiều `.Include()` dư thừa kết hợp `.Select(...)`; `GetStudents()` luôn trả toàn bộ 252 bản ghi | Tăng chi phí tracking/query compilation nếu không projection gọn. |
| `LopHocPhanController` | `GetCourseStudents()`, `GetCourseDetails()` | Truy vấn `DotDangKyDoAns` và `NhomDoAns` lặp lại 2 lần cho cùng logic lấy danh sách sinh viên lớp học phần | Gấp đôi round-trip SQL không cần thiết. |
| `NotificationsController` | `GET /api/notifications/unread-count` | Gọi `GenerateNotificationsAsync()` dựng đầy đủ object thông báo (string chi tiết, link, metadata) chỉ để lấy `.Count()` | Baseline `Notifications_Unread_SV` trả `18 bytes` (`{"unreadCount":...}`) nhưng tốn CPU/SQL gần tương đương tải list. |

---

## 3. Bảo mật & Xác thực (`AuthController`)

- `POST /api/auth/login` sử dụng `BCrypt.Verify` (CPU-bound theo thiết kế bảo mật, ~114–364 ms/lần ở baseline cho 1 request đơn lẻ, không được bỏ hay giảm work factor).
- Vấn đề không nằm ở tốc độ của `BCrypt.Verify` đơn lẻ mà ở việc Flutter gửi nhiều request login trùng nhau khi re-auth đồng thời -> cần giải quyết ở client concurrency lock để không làm yếu hash mật khẩu ở server.
