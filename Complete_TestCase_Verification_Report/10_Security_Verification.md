# BÁO CÁO 10: KIỂM ĐỊNH AN TOÀN BẢO MẬT HỆ THỐNG (SECURITY VERIFICATION)

## 1. TỔNG QUAN TIÊU CHUẨN ĐÁNH GIÁ
Đợt kiểm định bảo mật được thực hiện dựa trên các danh mục rủi ro của **OWASP Top 10 API Security Risks** và **OWASP Mobile Security Testing Guide (MSTG)**.

---

## 2. KẾT QUẢ KIỂM ĐỊNH CÁC HẠNG MỤC BẢO MẬT

### 2.1. Xác thực và Quản lý Phiên (Authentication & Session Management)
- **Kiểm thử yêu cầu không kèm Token (`TC_NFR_001`):**
  - Gửi yêu cầu `GET /api/student/courses` không có Header Authorization -> Trả về **HTTP 401 Unauthorized** (ĐẠT).
- **Kiểm thử Token giả mạo hoặc hết hạn (`TC_NFR_002`):**
  - Gửi yêu cầu với chuỗi JWT vô nghĩa `Bearer eyJhbGci...invalid` -> Trả về **HTTP 401 Unauthorized** (ĐẠT).
- **Thu hồi phiên khi Đăng xuất:**
  - Client gọi `AuthService.logout()` xóa sạch JWT Token khỏi local storage, ngăn chặn việc sử dụng lại token trên thiết bị dùng chung (ĐẠT).

### 2.2. Phân quyền và Kiểm soát Truy cập (Authorization & RBAC)
- **Kiểm thử Leo quyền (Privilege Escalation) (`TC_NFR_003`, `TC_NFR_004`, `TC_PDT_020`):**
  - Sinh viên gọi API tạo đề tài của Giảng viên (`POST /api/de-tai`) -> Trả về **HTTP 403 Forbidden** (ĐẠT).
  - Giảng viên gọi API quản lý tài khoản của Admin (`POST /api/admin/users`) -> Trả về **HTTP 403 Forbidden** (ĐẠT).
  - Phòng đào tạo gọi API quản lý tài khoản của Admin -> Trả về **HTTP 403 Forbidden** (ĐẠT).
- **Kiểm soát Tham chiếu Đối tượng Trực tiếp (IDOR Prevention):**
  - Sinh viên B gửi lệnh đổi tên Nhóm đồ án của Sinh viên A (`PUT /api/groups/{id}/name`) -> Trả về **HTTP 403 Forbidden** (ĐẠT).
  - Giảng viên phụ trách lớp A xem báo cáo tiến độ của lớp B -> Danh sách trả về rỗng, cách ly dữ liệu triệt để (ĐẠT).

### 2.3. Chống Tấn công Tiêm nhiễm (Injection Prevention)
- **Kiểm thử SQL Injection qua Form Đăng nhập (`TC_AUTH_012`):**
  - Dữ liệu đầu vào: `admin' OR '1'='1` với mật khẩu bất kỳ.
  - Kết quả: Entity Framework Core sử dụng tham số hóa hoàn toàn (`@p0, @p1`), câu lệnh SQL được biên dịch an toàn; API từ chối đăng nhập với **HTTP 401 Unauthorized** (ĐẠT).

### 2.4. An toàn Tải lên Tệp tin (File Upload Security)
- **Kiểm thử Tải lên Tệp tin Độc hại Giả mạo Đuôi (`TC_NFR_012`):**
  - Tạo tệp tin nhị phân có đuôi `.exe.jpg` với header không phải hình ảnh.
  - Kết quả: Hàm `DetectImageFormat` phát hiện magic bytes không hợp lệ, lập tức từ chối với **HTTP 400 Bad Request** (`Nội dung tệp không phải hình ảnh hợp lệ (chỉ hỗ trợ JPG, PNG, WEBP, GIF)`).

---

## 3. CÁC PHÁT HIỆN BẢO MẬT CẦN LƯU Ý TRƯỚC KHI DEPLOY PRODUCTION

> [!WARNING]
> **Khuyến nghị xử lý Secrets trên Repository:**
> 1. Trong tệp tin `appsettings.json`, các thông số `Jwt:Key`, `CloudflareR2` và chuỗi kết nối `DefaultConnection` hiện đang nằm trực tiếp trong mã nguồn. Cần chuyển sang sử dụng biến môi trường (Environment Variables) hoặc Azure Key Vault / AWS Secrets Manager khi đưa lên máy chủ Production.
> 2. Trong tệp tin `AppConstants.dart` trên Flutter, chuỗi `geminiApiKey` đang chứa khóa API Base64. Khuyến nghị chuyển toàn bộ các lệnh gọi Gemini API về Backend thông qua Proxy Controller để giấu hoàn toàn khóa API khỏi ứng dụng mobile.