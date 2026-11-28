# 05. BÁO CÁO XÁC MINH HỢP ĐỒNG VÀ KẾT QUẢ API (API VERIFICATION REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Xác minh tính sẵn sàng, phương thức HTTP, DTO và phản hồi thực tế của các API endpoints trên Live Backend `http://127.0.0.1:5094`.  

---

## 1. KẾT QUẢ KIỂM THỬ TỰ ĐỘNG HÓA CÁC ENDPOINT CỐT LÕI

| STT | Endpoint URL | Method | Vai trò cho phép | Payload / Tham số | Kết quả kiểm tra thực tế | Mã HTTP | Đánh giá |
|:---:|---|:---:|---|---|---|:---:|:---:|
| 1 | `/api/health` | GET | Anonymous | None | `{"status":"healthy"}` | **200 OK** | PASS |
| 2 | `/api/auth/login` | POST | Anonymous | `{"tenDangNhap":"sv001","matKhau":"123456"}` | Trả về JWT Token 615 chars, thông tin sinh viên | **200 OK** | PASS |
| 3 | `/api/auth/login` | POST | Anonymous | `{"tenDangNhap":"admin01","matKhau":"123456"}` | Trả về JWT Token 637 chars, role ADMIN | **200 OK** | PASS |
| 4 | `/api/auth/login` | POST | Anonymous | Sai mật khẩu | `{"message":"Tên đăng nhập hoặc mật khẩu không chính xác."}` | **401 Unauthorized** | PASS |
| 5 | `/api/profile` | GET | Authenticated | Bearer Token | Lấy đúng thông tin Trần Minh An (MSSV: SV001) | **200 OK** | PASS |
| 6 | `/api/profile` | PUT | Authenticated | `{"soDienThoai":"0987654321"}` | Cập nhật số điện thoại thành công vào DB | **200 OK** | PASS |
| 7 | `/api/profile/avatar` | POST | Authenticated | Base64 > 10MB | Từ chối do vượt dung lượng tối đa | **400 Bad Request** | PASS |
| 8 | `/api/admin/overview` | GET | ADMIN | Bearer Token (Admin) | Trả về live stats: 264 users, 252 SV, 6 GV | **200 OK** | PASS |
| 9 | `/api/admin/overview` | GET | SINHVIEN | Bearer Token (Sinh viên) | Chặn truy cập trái quyền | **403 Forbidden** | PASS |
| 10 | `/api/de-tai/proposals` | GET | GIANGVIEN, ADMIN | `?courseId=1` | Lấy 4 đề xuất đề tài đang chờ duyệt | **200 OK** | PASS |
| 11 | `/api/de-tai` | GET | Authenticated | `?limit=5` | Lấy danh mục đề tài (tổng 52 đề tài) | **200 OK** | PASS |
| 12 | `/api/groups/mine` | GET | SINHVIEN | Bearer Token | Trả về 4 nhóm sinh viên tham gia | **200 OK** | PASS |
| 13 | `/api/de-tai/dang-ky` | POST | SINHVIEN | `{"nhomId":1,"deTaiId":1}` | Kiểm tra điều kiện trưởng nhóm & transaction lock | **409 Conflict** | PASS |
| 14 | `/api/admin/users/import`| POST | PDT, GVK, ADMIN | Danh sách 1 sinh viên mới | Import thành công 1 tài khoản vào DB | **200 OK** | PASS |

---

## 2. XÁC MINH CÁC SỬA ĐỔI HỢP ĐỒNG API CỦA ĐỢT REMEDIATION

1. **Hỗ trợ song song PUT và POST cho Đổi mật khẩu & Đổi email:**
   - Trong `AuthController.cs`, cả hai thuộc tính `[HttpPut("change-password")]` và `[HttpPost("change-password")]` đều đã được kích hoạt.
   - `ChangePasswordRequest.cs` hỗ trợ cả `oldPassword` và `currentPassword` thông qua phương thức `GetEffectiveCurrentPassword()`.
2. **Endpoint Đề xuất đề tài của Giảng viên:**
   - Endpoint `GET /api/de-tai/proposals` đã tồn tại thực tế và hỗ trợ lọc theo `courseId`.
3. **Endpoint Cấu hình Lớp học phần:**
   - Endpoint `PUT /api/lop-hoc-phan/{id}/cau-hinh` đã được triển khai, nhận model `UpdateCourseSettingsRequest`.
4. **Phân quyền Import Người dùng:**
   - Thuộc tính `[Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]` trên `POST /api/admin/users/import` đã được kiểm chứng hoạt động thành công với token của Phòng đào tạo (`daotao01`).
