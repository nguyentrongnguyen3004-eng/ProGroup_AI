# 06. BÁO CÁO XÁC THỰC, PHÂN QUYỀN & KIỂM SOÁT TRUY CẬP (AUTH & RBAC AUDIT)

## 1. KIẾN TRÚC XÁC THỰC HIỆN TẠI
Hệ thống sử dụng cơ chế xác thực **JSON Web Token (JWT Bearer Token)**:
- Token được phát hành bởi Backend tại `POST /api/Auth/login`.
- Thời hạn hiệu lực: **7 ngày** (cấu hình trong `TokenService.cs`).
- Lưu trữ trên Client: `SharedPreferences` (dưới dạng chuỗi không mã hóa trên thiết bị di động).

---

## 2. CÁC LỖ HỔNG XÁC THỰC (AUTHENTICATION FLAWS)

### 2.1. Cấu Hình JWT Secret Key Mặc Định Không An Toàn
- **File:** `ProGroup_AI.API/appsettings.json`, dòng 7:
  ```json
  "Jwt": {
    "Key": "ProGroupAI_Development_Key_2026_Change_This_To_A_Strong_Key",
    "Issuer": "ProGroupAI",
    "Audience": "ProGroupAI_Users"
  }
  ```
- **Rủi ro:** Khóa bí mật JWT được công khai trong mã nguồn Git. Kẻ tấn công có thể sử dụng chuỗi bí mật này để tự ký (forge) bất kỳ JWT token nào với quyền `Admin` hoặc `PhongDaoTao` mà không cần biết mật khẩu tài khoản!

---

### 2.2. Bypass Kiểm Tra Tài Khoản Test Trong Mã Nguồn Client
- **File:** `lib/services/auth_service.dart`, dòng 106-107:
  ```dart
  if (cleanUsername == 'test_user_1792849805122' || 
      cleanUsername == 'test_user_1792849965466') {
    // Logic bypass xác thực cục bộ
  }
  ```
- **Rủi ro:** Đoạn code backdoor để phục vụ việc test tự động bị bỏ quên trong môi trường chạy ứng dụng, vi phạm nghiêm trọng tiêu chuẩn an toàn thông tin.

---

### 2.3. Thiếu Cơ Chế Refresh Token Chuẩn (Chỉ Dùng Re-Authenticate Tạm Bợ)
- Hệ thống không cấp phát `RefreshToken` có lưu trong CSDL.
- Khi Access Token hết hạn, `ApiService.dart:226` gọi `AuthService.reAuthenticate()` dựa trên thông tin `username` và `password` được lưu tạm trong RAM. Nếu người dùng tắt ứng dụng mở lại sau 7 ngày, phiên đăng nhập bị văng đột ngột mà không thể refresh ngầm một cách mượt mà.

---

## 3. CÁC LỖ HỔNG PHÂN QUYỀN & KIỂM SOÁT TRUY CẬP (AUTHORIZATION & RBAC)

### 3.1. Lỗ Hổng IDOR (Insecure Direct Object Reference)
Nhiều endpoint trong hệ thống chỉ kiểm tra quyền vai trò chung chung (`[Authorize(Roles = "GiangVien")]`) mà **không kiểm tra quyền sở hữu thực tế của đối tượng**:

1. **Chấm điểm báo cáo tiến độ:**
   - Endpoint: `PUT /api/bao-cao/{id}/cham-diem` trong `BaoCaoTienDoController.cs`.
   - Giảng viên A có thể gửi request chấm điểm cho Báo cáo của sinh viên thuộc Lớp học phần do Giảng viên B phụ trách, chỉ cần thay đổi `{id}` trên URL!
2. **Cập nhật đề tài:**
   - Endpoint: `PUT /api/de-tai/{id}` trong `DeTaiController.cs`.
   - Kiểm tra `User.Identity` sơ sài, cho phép giảng viên sửa đổi mô tả đề tài của đồng nghiệp nếu biết được `id`.

---

### 3.2. Màn Hình Quản Lý Role Của Admin Là Giao Diện Tĩnh (Static RBAC Screen)
- **File:** `screens/admin/role/admin_role_screen.dart`.
- Màn hình hiển thị danh sách quyền chi tiết cho từng vai trò (Sinh viên, Giảng viên, Giáo vụ, Phòng đào tạo, Admin) với các checkbox giao diện.
- **Thực tế Backend:** Phân quyền trong hệ thống được code cứng qua các hằng số chuỗi trong enum `VaiTro` (`"Admin"`, `"GiangVien"`, `"SinhVien"`,...). CSDL không có bảng `Permissions` hay bảng quan hệ nhiều-nhiều `RolePermissions`.
- **Hậu quả:** Admin tưởng rằng mình có thể bật/tắt quyền của các vai trò trên app, nhưng việc tích/bỏ tích checkbox trên màn hình hoàn toàn vô nghĩa và không có tác dụng gì lên hệ thống.
