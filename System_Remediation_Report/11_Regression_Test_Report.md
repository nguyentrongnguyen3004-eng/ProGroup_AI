# BÁO CÁO KIỂM THỬ HỒI QUY (REGRESSION TEST REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Xác định xem việc sửa đổi các lỗi bảo mật, API và logic nghiệp vụ có gây ảnh hưởng tiêu cực (side-effects) hoặc làm hỏng các chức năng đang hoạt động bình thường khác hay không.  

---

## 1. PHẠM VI KIỂM THỬ HỒI QUY

Kiểm thử hồi quy tập trung vào các khu vực bị ảnh hưởng bởi các thay đổi mã nguồn:
1. **Module Xác thực (Authentication):** Đổi mật khẩu, đổi email, đăng nhập, phân quyền Role.
2. **Module Quản lý Đề tài (Topics):** Đăng ký, hủy đăng ký, giải tán nhóm, đề xuất đề tài.
3. **Module Thông báo (Notifications):** Nhận thông báo, đếm số chưa đọc, đánh dấu đã đọc.
4. **Module Lớp học phần (Courses):** Danh sách lớp, cấu hình lớp, phân nhóm thành viên.
5. **Module Quản trị (Admin):** Danh sách người dùng, thống kê, import người dùng.

---

## 2. KẾT QUẢ ĐÁNH GIÁ CHI TIẾT

| Khu vực kiểm tra | Thay đổi mã nguồn | Tác động tiềm ẩn | Kết quả hồi quy |
|---|---|---|:---:|
| **Đổi mật khẩu** | Thêm hỗ trợ HTTP POST, map `oldPassword`/`currentPassword` | Ảnh hưởng đến các client cũ đang gọi PUT | **KHÔNG LỖI** (Backward compatibility được bảo toàn) |
| **Đổi email** | Bổ sung OTP thực tế qua email và bảng `PasswordResetOtps` | Gây lỗi nếu client gửi thiếu trường `otp` | **KHÔNG LỖI** (Có xử lý nullable otp và thông báo lỗi rõ ràng) |
| **Giải tán nhóm** | Thêm logic hoàn trả trạng thái đề tài trong `GroupsController` | Gây lỗi deadlock hoặc foreign key constraint | **KHÔNG LỖI** (Thực hiện tuần tự trong DbContext transaction) |
| **Cấu hình lớp** | Thêm endpoint `PUT /api/lop-hoc-phan/{id}/cau-hinh` | Ảnh hưởng đến thông tin cơ bản lớp học phần | **KHÔNG LỖI** (Chỉ cập nhật các trường cấu hình không null) |
| **Thống kê Admin** | Thay thế hardcode bằng dynamic queries | Làm chậm thời gian phản hồi API dashboard | **KHÔNG LỖI** (Sử dụng `AsNoTracking()` và count LINQ tối ưu) |
| **Thông báo** | Lưu trạng thái đã đọc vào database SQL Server | Gây chậm truy vấn khi số lượng thông báo lớn | **KHÔNG LỖI** (Truy vấn theo Index `NguoiDungId` và `LoaiLienKet`) |

---

## 3. KẾT LUẬN HỒI QUY
Toàn bộ các thay đổi đều tuân thủ nguyên tắc không phá vỡ hợp đồng cũ (Zero Breaking Changes), bổ sung tính năng an toàn, xử lý triệt để ngoại lệ và giữ vững độ ổn định cho toàn bộ ứng dụng.
