# BÁO CÁO TOÀN VẸN CƠ SỞ DỮ LIỆU (DATABASE INTEGRITY REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Đảm bảo toàn vẹn dữ liệu, ràng buộc quan hệ, đồng bộ schema và loại bỏ nguy cơ mâu thuẫn trạng thái giữa các bảng trong Microsoft SQL Server.  

---

## 1. PHÂN TÍCH RÀNG BUỘC VÀ QUAN HỆ BẢNG

Hệ thống ProGroup_AI sử dụng Entity Framework Core Code-First với cơ sở dữ liệu Microsoft SQL Server. Cấu trúc quan hệ chính bao gồm:
- `NguoiDungs` (1) <---> (N) `ThanhVienLopHocs` (N) <---> (1) `LopHocPhans`
- `LopHocPhans` (1) <---> (N) `NhomSinhViens` (1) <---> (N) `ThanhVienNhoms`
- `LopHocPhans` (1) <---> (N) `DeTaiDoAns`
- `NhomSinhViens` (1) <---> (1) `DangKyDeTais` (N) <---> (1) `DeTaiDoAns`
- `DangKyDeTais` (1) <---> (N) `BaoCaoTienDos`
- `NguoiDungs` (1) <---> (N) `ThongBaos`
- `NguoiDungs` (1) <---> (N) `PasswordResetOtps`

---

## 2. CÁC NGUY CƠ MẤT TOÀN VẸN DỮ LIỆU ĐÃ ĐƯỢC XỬ LÝ

### 2.1. Ràng buộc trạng thái giữa Nhóm và Đề tài (`DeTaiDoAns` <---> `DangKyDeTais`)
- **Vấn đề trước đây:** Khi một nhóm bị giải tán (`DisbandGroup`), bản ghi trong `DangKyDeTais` bị xóa nhưng trường `TrangThai` trong `DeTaiDoAns` vẫn giữ nguyên là `"Đã sử dụng"`. Điều này gây ra mâu thuẫn dữ liệu: không có nhóm nào đang nhận đề tài nhưng đề tài lại không sẵn sàng để đăng ký.
- **Biện pháp:** Thêm transaction logic kiểm tra và khôi phục trạng thái `"Chưa sử dụng"` của `DeTaiDoAns` khi hủy đăng ký do rã nhóm.

### 2.2. Xóa và Giải phóng Thành viên Nhóm (`ThanhVienNhoms`)
- **Vấn đề:** Khi sinh viên rời nhóm hoặc bị mời ra khỏi nhóm, cần kiểm tra đảm bảo nếu là nhóm trưởng thì phải chuyển quyền hoặc giải tán nhóm nếu không còn thành viên nào.
- **Biện pháp:** Luồng xử lý trong `GroupsController` được bổ sung các điều kiện guard clauses kiểm tra số lượng thành viên và cập nhật vai trò trưởng nhóm nếu người rời đi là nhóm trưởng hiện tại.

### 2.3. Tính Toàn Vẹn Của Mã OTP (`PasswordResetOtps`)
- **Vấn đề:** Mã OTP chỉ được sử dụng một lần và có thời hạn nhất định.
- **Biện pháp:** Cột `DaSuDung` (boolean) và `ThoiGianHetHan` (datetime) được kiểm tra chặt chẽ. Khi người dùng xác thực thành công trong luồng đổi email, cờ `DaSuDung` được set thành `true` ngay trong cùng transaction.
