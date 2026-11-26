# 11. BÁO CÁO KIỂM THỬ HÀNH TRÌNH ĐẦU CUỐI (END-TO-END TEST REPORT)
## KIỂM ĐỊNH CÁC HÀNH TRÌNH NGƯỜI DÙNG XUYÊN SUỐT HỆ THỐNG

---

### 1. HÀNH TRÌNH 1: SINH VIÊN VÀ QUY TRÌNH ĐỒ ÁN (STUDENT JOURNEY)
1. **Đăng nhập:** Sinh viên `sv001` đăng nhập -> Hệ thống nhận diện đúng vai trò Sinh viên -> Chuyển vào Trang chủ Sinh viên.
2. **Khám phá đề tài:** Sinh viên xem danh sách 52 đề tài -> Chọn đề tài "Cổng thông tin hướng nghiệp và kết nối cựu sinh viên" -> Vào xem chi tiết đề tài.
3. **Khớp nhóm đăng ký (ĐÃ KHẮC PHỤC TRIỆT ĐỂ):**
   - Hệ thống quét danh sách nhóm của sinh viên trong đúng Lớp học phần của đề tài.
   - Nhóm "t" (do sinh viên làm trưởng nhóm) được hiển thị chính xác làm Nhóm đại diện.
   - Không còn hiện tượng chọn sai nhóm "Nhóm Demo 02" của lớp học phần khác.
4. **Gửi yêu cầu:** Sinh viên nhấn "Gửi yêu cầu đăng ký" -> Backend ghi nhận vào bảng `DangKyDeTais` với trạng thái `Chờ duyệt`.

---

### 2. HÀNH TRÌNH 2: GIẢNG VIÊN HƯỚNG DẪN (LECTURER JOURNEY)
1. **Đăng nhập:** Giảng viên `gv001` đăng nhập -> Chuyển vào Dashboard Giảng viên.
2. **Duyệt đăng ký:** Giảng viên nhận thông báo có nhóm đăng ký đề tài -> Xem danh sách thành viên nhóm "t" -> Bấm "Chấp nhận".
3. **Theo dõi tiến độ:** Giảng viên vào mục Báo cáo tiến độ -> Xem báo cáo nộp của nhóm "t" -> Nhập nhận xét và chấm điểm 9.0/10.

---

### 3. HÀNH TRÌNH 3: QUẢN TRỊ VIÊN HỆ THỐNG (ADMIN JOURNEY)
1. **Đăng nhập:** Quản trị viên `admin01` đăng nhập -> Vào màn hình Admin Overview.
2. **Kiểm tra số liệu:** Biểu đồ hiển thị chính xác 264 người dùng, 5 khoa, tỷ lệ sinh viên làm đồ án 85.5%.
3. **Phân quyền người dùng:** Quản trị viên tìm kiếm tài khoản sinh viên -> Cập nhật trạng thái kích hoạt/khóa tài khoản an toàn.
