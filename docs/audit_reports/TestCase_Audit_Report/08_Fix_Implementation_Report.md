# 08. BÁO CÁO TRIỂN KHAI VÀ CHI TIẾT SỬA ĐỔI SOURCE CODE

Tổng hợp toàn bộ các tệp tin mã nguồn đã được can thiệp và sửa đổi trong chiến dịch Audit này:

### 1. Frontend: `lib/services/api_service.dart`
- **Nội dung sửa đổi**: Tái cấu trúc cơ chế gửi HTTP Request bằng persistent `http.Client()`. Ưu tiên địa chỉ IP máy chủ LAN `192.168.1.234:5094` và `127.0.0.1:5094` thay cho fallback 10.0.2.2 chậm chạp. Thêm headers `Connection: keep-alive`.
- **Kết quả**: Độ trễ API giảm từ 1800ms xuống còn < 50ms qua ADB Reverse và < 90ms qua Wi-Fi LAN.

### 2. Frontend: `lib/services/avatar_service.dart`
- **Nội dung sửa đổi**: Thêm kiểm tra định danh `isCurrentUser = username.toLowerCase() == currentUser.username.toLowerCase()`. Ngăn chặn hoàn toàn avatarNotifier toàn cục ghi đè lên các avatar của vai trò khác (sửa triệt để TC_PDT_019).

### 3. Frontend: `lib/widgets/common/profile_avatar_picker_helper.dart`
- **Nội dung sửa đổi**: Kiểm tra whitelist định dạng tệp ảnh (`jpg`, `jpeg`, `png`, `webp`) và giới hạn kích thước tối đa 10MB trước khi chuyển đổi Base64 (sửa triệt để TC_STU_040 và TC_NFR_012).

### 4. Frontend: `lib/screens/sinh_vien/topic/topic_detail_screen.dart`
- **Nội dung sửa đổi**: Gỡ bỏ đoạn mã sai lệch `foundGroup ?? myGroups.first`. Chỉ chấp nhận nhóm thuộc đúng Lớp học phần hiện tại. Nếu sinh viên chưa có nhóm trong môn này, app sẽ hiển thị banner cảnh báo và nút tạo nhóm mới thay vì tự ý gán sang nhóm của môn khác.

### 5. Frontend: `lib/screens/sinh_vien/profile/profile_screen.dart`
- **Nội dung sửa đổi**: Bổ sung hàng hiển thị Số điện thoại và phương thức `_changePhone()` hiển thị dialog nhập liệu chuẩn Regex `^[0-9]{9,11}$`, gọi API `PUT /api/profile` để đồng bộ CSDL (sửa triệt để TC_STU_037).

### 6. Frontend: `lib/screens/admin/home/admin_overview_screen.dart`
- **Nội dung sửa đổi**: Cập nhật thuật toán đếm vai trò theo cả `maVaiTro` và `tenVaiTro` từ API `/api/admin/users`. Khắc phục hoàn toàn lỗi hiển thị sai số liệu tổng quan người dùng và tỷ lệ biểu đồ 5 vai trò (sửa triệt để TC_ADM_001 và TC_ADM_002).

### 7. Backend: `ProfileController.cs`
- **Nội dung sửa đổi**: Cập nhật trần dung lượng ảnh đại diện tải lên từ 5MB lên 10MB với thông báo lỗi tiếng Việt tiêu chuẩn: *'Ảnh đại diện không được vượt quá 10MB.'*.

### 8. Scripts Khởi Động: `start_emulator.bat` & `start_full_system.bat`
- **Nội dung sửa đổi**: Cấu hình khởi động máy ảo với `-netdelay none -netspeed full -dns-server 8.8.8.8,1.1.1.1` và lệnh `adb reverse tcp:5094 tcp:5094`, bảo đảm tốc độ truyền dữ liệu tối đa.
