# 02. BÁO CÁO KIỂM TOÁN MÃ NGUỒN (SOURCE CODE AUDIT)
## KIẾN TRÚC HỆ THỐNG, TỔ CHỨC DỰ ÁN & CHẤT LƯỢNG MÃ NGUỒN

---

### 1. KIẾN TRÚC TỔNG THỂ
Hệ thống ProGroup_AI áp dụng kiến trúc phân tầng Client - Server hiện đại:
```
+-------------------------------------------------------------+
|                Flutter Mobile Client (Dart)                 |
|  - UI Screens & Custom Responsive Widgets                   |
|  - State Management: Provider & ValueNotifier               |
|  - API Services & Secure Local Storage (Shared Preferences) |
+------------------------------+------------------------------+
                               | HTTPS / JSON REST API
+------------------------------v------------------------------+
|             ASP.NET Core 10.0 Web API (C#)                  |
|  - Presentation Layer: Controllers & Action Filters         |
|  - Security: JWT Bearer Middleware, Role-Based Policies     |
|  - Business & Service Layer: Domain Services & DTOs         |
|  - Persistence: Entity Framework Core 10 ORM               |
+------------------------------+------------------------------+
                               | TDS Protocol (Port 1433)
+------------------------------v------------------------------+
|            Microsoft SQL Server 2022 Express                |
|  - Database: ProjectRegistrationDB (17 Tables, Relational)   |
|  - Indexing: Clustered PKs, Non-Clustered Foreign Keys      |
+-------------------------------------------------------------+
```

---

### 2. KIỂM TOÁN BACKEND (ASP.NET CORE 10.0)

#### 2.1. Phân tầng và Trách nhiệm
Mã nguồn Backend tại `ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API` được tổ chức chặt chẽ:
- **Controllers:** 12 Controllers đảm nhiệm routing RESTful:
  - `AuthController.cs`: Xử lý đăng nhập, cấp JWT Token, đổi mật khẩu, quên mật khẩu (OTP).
  - `DeTaiController.cs`: Quản lý danh mục đề tài, sinh viên đề xuất, đăng ký đề tài (có serializable locking).
  - `NhomDoAnController.cs`: Quản lý nhóm, lời mời gia nhập, phê duyệt thành viên.
  - `BaoCaoTienDoController.cs`: Nộp báo cáo định kỳ, phản hồi, chấm điểm tiến độ.
  - `ProfileController.cs`: Xem/sửa thông tin cá nhân, cập nhật số điện thoại, upload ảnh đại diện (Cloudflare R2).
  - `AdminController.cs`: Dashboard quản trị toàn diện, quản lý tài khoản, phân quyền.
  - `GiaoVuKhoaController.cs`: Quản lý đợt đăng ký, lớp học phần theo khoa.
  - `PhongDaoTaoController.cs`: Thống kê toàn trường, quản lý niên khóa, học kỳ.
  - `NotificationController.cs`: Quản lý thông báo người dùng, đánh dấu đã đọc.
  - `ChatController.cs` & `AiChatController.cs`: Tích hợp trao đổi nhóm và AI tư vấn đề tài.

#### 2.2. Đánh giá Chất lượng Code Backend
- **Data Validation:** Sử dụng Data Annotations (`[Required]`, `[MaxLength]`, `[EmailAddress]`) trên Request DTOs.
- **ORM & SQL Injection Defense:** Sử dụng 100% LINQ với Entity Framework Core, ngăn chặn hoàn toàn nguy cơ SQL Injection dạng chuỗi ghép.
- **Concurrency Control:** Áp dụng `using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);` tại các điểm nhạy cảm về tranh chấp (đăng ký đề tài).
- **Asynchronous Execution:** 100% các thao tác I/O với database đều sử dụng `async/await` (`ToListAsync()`, `FirstOrDefaultAsync()`, `SaveChangesAsync()`), không gây nghẽn ThreadPool.

---

### 3. KIỂM TOÁN FRONTEND (FLUTTER 3.29.0)

#### 3.1. Cấu trúc Thư mục Frontend
Mã nguồn Frontend tại `ProGroup_AI_Frontend/progroup_ai_frontend/lib`:
- `screens/`: Phân nhóm theo vai trò và chức năng:
  - `auth/`: Màn hình Đăng nhập, Quên mật khẩu, OTP.
  - `student/`: Trang chủ sinh viên, tổng quan đồ án.
  - `group/`: Danh sách nhóm, tạo nhóm, chi tiết nhóm, quản lý thành viên.
  - `topic/`: Khám phá đề tài, chi tiết đề tài, đề xuất đề tài mới.
  - `teacher/`: Danh sách đề tài hướng dẫn, duyệt đề xuất, chấm điểm báo cáo.
  - `progress_report/`: Nộp báo cáo định kỳ, lịch sử phản hồi giảng viên.
  - `profile/`: Thông tin cá nhân, cập nhật SĐT, đổi avatar.
  - `admin/`: Overview thống kê, quản lý người dùng, phân quyền.
  - `faculty_admin/` & `training_department/`: Quản lý học vụ khoa và phòng đào tạo.
- `services/`: Đóng gói các lời gọi API REST (`api_service.dart`, `auth_service.dart`, `group_service.dart`, `topic_service.dart`, `teacher_service.dart`, `profile_service.dart`).
- `models/`: Chuyển đổi JSON sang Typed Dart Object (`NguoiDung`, `NhomDoAn`, `DeTai`, `BaoCao`).
- `widgets/`: Các thành phần giao diện tái sử dụng (`custom_button.dart`, `avatar_view.dart`, `status_badge.dart`).

#### 3.2. Đánh giá Chất lượng Code Frontend
- **Không có compilation error:** Toàn bộ project Flutter biên dịch sạch, không thiếu thư viện hoặc class.
- **Tách biệt Logic và UI:** Các màn hình sử dụng `Service` để tải dữ liệu, không nhúng logic HTTP thô vào Widget build method.
- **Responsive Layout:** Hỗ trợ kích thước màn hình điện thoại đa dạng với `LayoutBuilder`, `SingleChildScrollView` tránh lỗi RenderFlex Overflow.
- **Quản lý Cache:** Đã phân lập Cache Key cho `UserAvatarView` dựa trên User ID, triệt tiêu hiện tượng dính avatar giữa các tài khoản đăng nhập trên cùng thiết bị.
