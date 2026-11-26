# 10. BÁO CÁO KIỂM THỬ ĐẦU CUỐI THEO VAI TRÒ (ROLE-BASED E2E TEST REPORT)

### 1. Hành trình Sinh viên (Student Journey)
- **Bước 1**: Đăng nhập bằng tài khoản `sv001` / `123456`.
- **Bước 2**: Truy cập lớp học phần Đồ án tốt nghiệp -> Mở màn hình nhóm đồ án.
- **Bước 3**: Tạo nhóm mới -> Kiểm tra nhóm có 1 thành viên -> Thử đăng ký đề tài -> Hệ thống chặn và yêu cầu đủ tối thiểu 2 thành viên (**TC_STU_019 - PASS**).
- **Bước 4**: Mời thêm thành viên `sv002` -> Đủ 2 thành viên -> Đăng ký đề tài thành công -> Hiển thị đúng nhóm hiện tại (**TC_BUG_CROSS_GROUP - PASS**).
- **Bước 5**: Vào mục Nộp báo cáo tiến độ -> Nhập URL GitHub và file báo cáo -> Kiểm tra validation URL -> Nộp thành công (**TC_STU_025, TC_STU_027 - PASS**).

### 2. Hành trình Giảng viên (Lecturer Journey)
- **Bước 1**: Đăng nhập tài khoản `gv001` / `123456`.
- **Bước 2**: Mở màn hình Đánh giá & Chấm điểm báo cáo tiến độ đồ án.
- **Bước 3**: Nhìn thấy danh sách báo cáo kèm các nút liên kết file báo cáo, GitHub repo (**TC_LEC_016 - PASS**).
- **Bước 4**: Thử chấm điểm 12 -> Hệ thống chặn nhập; nhập 9.0 -> Lưu đánh giá thành công (**TC_LEC_018 - PASS**).

### 3. Hành trình Quản trị viên (Admin Journey)
- **Bước 1**: Đăng nhập tài khoản `admin` / `123456`.
- **Bước 2**: Mở màn hình Trung tâm Kiểm soát -> Quan sát các thẻ thống kê tổng quan và Biểu đồ thanh ngang phân bổ 5 vai trò hiển thị chính xác các tỷ lệ (%) đạt 100% (**TC_ADM_001, TC_ADM_002 - PASS**).
- **Bước 3**: Mở form tạo người dùng mới -> Nhập số điện thoại có chữ cái -> Bị chặn; nhập đủ 10 số -> Tạo thành công (**TC_ADM_019 - PASS**).
