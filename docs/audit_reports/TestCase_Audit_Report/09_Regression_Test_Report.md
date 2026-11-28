# 09. BÁO CÁO KIỂM THỬ HỒI QUY (REGRESSION TEST REPORT)

Sau khi áp dụng các thay đổi trong source code, một đợt kiểm thử hồi quy toàn diện đã được tiến hành nhằm bảo đảm không làm phát sinh lỗi mới (Zero Side-effects):

| STT | Luồng nghiệp vụ kiểm thử hồi quy | Kết quả kiểm thử | Tình trạng |
|---|---|---|---|
| 1 | Đăng nhập tài khoản Sinh viên / Giảng viên / Quản trị viên | Thành công, lưu token vào SharedPreferences an toàn | **PASS** |
| 2 | Chuyển đổi qua lại giữa các màn hình danh sách đề tài và chi tiết đề tài | Mượt mà, hiển thị đúng nhóm đại diện của môn học tương ứng | **PASS** |
| 3 | Tải ảnh đại diện mới từ thư viện máy ảnh (kích thước < 10MB, định dạng PNG) | Tải thành công, hiển thị tức thì, không rò rỉ sang tài khoản khác | **PASS** |
| 4 | Tải thử tệp tin giả mạo (> 10MB hoặc tệp đuôi lạ .exe) | Bị chặn ngay từ Client với SnackBar cảnh báo đỏ | **PASS** |
| 5 | Mở màn hình Dashboard Quản trị viên (Admin Overview) | Hiển thị đầy đủ 4 thẻ thống kê và biểu đồ phân bổ 5 vai trò chuẩn 100% | **PASS** |
| 6 | Chấm điểm đồ án của Giảng viên với điểm hợp lệ (8.5) và điểm quá ngưỡng (15.0) | Điểm 8.5 lưu thành công; điểm 15.0 bị chặn nhập liệu ngay trên TextField | **PASS** |
| 7 | Kiểm tra tĩnh Static Analysis bằng `flutter analyze` | Đạt 0 lỗi cú pháp / 0 lỗi kiểu dữ liệu | **PASS** |
| 8 | Biên dịch C# Backend bằng `dotnet build` | Biên dịch thành công với 0 Error | **PASS** |
