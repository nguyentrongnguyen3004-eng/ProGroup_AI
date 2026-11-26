# 07. BÁO CÁO KIỂM THỬ END-TO-END VÀ ĐỐI CHIẾU TEST CASES (E2E TEST REPORT)

## 1. TỔNG QUAN ĐỐI CHIẾU TEST SUITE
Đội ngũ kiểm thử đã đối chiếu toàn bộ **211 Kịch bản kiểm thử (Test Cases)** được định nghĩa trong file `PROGROUP_AI_TESTCASES.xlsx` (8 sheets) với mã nguồn triển khai thực tế của hệ thống ProGroup_AI.

---

## 2. KẾT QUẢ ĐỐI CHIẾU THEO TỪNG PHÂN HỆ

```
+------------------------------------+----------+--------+--------+----------+------------+
| Sheet / Phân hệ                    | Tổng TC  |  PASS  |  FAIL  | BLOCKED  | Tỷ lệ PASS |
+------------------------------------+----------+--------+--------+----------+------------+
| 2. Xác thực & Cài đặt hệ thống     |    28    |   22   |    6   |    0     |   78.6%    |
| 3. Phân hệ Sinh viên               |    57    |   46   |    6   |    5     |   80.7%    |
| 4. Phân hệ Giảng viên              |    30    |   19   |    7   |    4     |   63.3%    |
| 5. Phân hệ Giáo vụ khoa            |    25    |   10   |    3   |   12     |   40.0%    |
| 6. Phân hệ Phòng đào tạo           |    20    |    5   |    2   |   13     |   25.0%    |
| 7. Quản trị hệ thống (Admin)       |    24    |   15   |    3   |    6     |   62.5%    |
| 8. Phi chức năng & Bảo mật         |    16    |    5   |   11   |    0     |   31.3%    |
+------------------------------------+----------+--------+--------+----------+------------+
| TỔNG CỘNG TOÀN HỆ THỐNG            |   200    |  122   |   38   |   40     |   61.0%    |
+------------------------------------+----------+--------+--------+----------+------------+
```

---

## 3. DANH SÁCH TEST CASES THẤT BẠI TIÊU BIỂU (FAILED TEST CASES)

### Phân hệ 2: Xác thực & Hệ thống
- **TC_AUTH_012 (Đổi mật khẩu):** ❌ **FAIL** - Frontend gửi `POST /api/auth/change-password` nhưng Backend chỉ nhận `PUT`, API trả về `405 Method Not Allowed`.
- **TC_AUTH_018 (Đổi email):** ❌ **FAIL** - Nhập mã OTP thật không chạy được vì client hardcode `if (otp != '123456')`.

### Phân hệ 3: Sinh viên
- **TC_STUDENT_035 (Đề xuất đề tài mới):** ❌ **FAIL** - Sinh viên tạo đề xuất thành công nhưng giảng viên không thể xem được do endpoint proposals bị 404.
- **TC_STUDENT_042 (Hủy đăng ký đề tài):** ⚠️ **FAIL** - Khi hủy đăng ký đề tài đã duyệt, trạng thái nhóm không được reset về ban đầu đúng quy trình.

### Phân hệ 4: Giảng viên
- **TC_LECTURER_008 (Cấu hình lớp học phần):** ❌ **FAIL** - Thay đổi số lượng SV tối đa và thời hạn đợt đăng ký bị mất sạch khi reload trang.
- **TC_LECTURER_019 (Duyệt đề tài sinh viên đề xuất):** ❌ **FAIL** - Màn hình gọi `GET /api/de-tai/proposals` bị lỗi 404 Not Found từ server.

### Phân hệ 5 & 6: Giáo vụ khoa & Phòng đào tạo
- **TC_GOV_004 & TC_TRAIN_006 (Import danh sách sinh viên bằng Excel):** ⛔ **BLOCKED** - Dữ liệu chỉ ghi vào biến RAM `MockGovernanceData` / `MockTrainingData`, không hề lưu vào SQL Server!
- **TC_GOV_009 & TC_TRAIN_011 (Thêm mới Lớp học phần):** ⛔ **BLOCKED** - Bấm lưu báo thành công nhưng tắt app mở lại thì mất toàn bộ.

### Phân hệ 7: Quản trị hệ thống
- **TC_ADMIN_015 (Xem nhật ký hoạt động hệ thống):** ⛔ **BLOCKED** - Màn hình render danh sách 6 item tĩnh, không đọc từ bảng `LichSuHeThong`.
- **TC_ADMIN_020 (Cấu hình phân quyền vai trò):** ⛔ **BLOCKED** - Giao diện tĩnh, bấm lưu không có tác dụng.

### Phân hệ 8: Phi chức năng & Bảo mật
- **TC_SEC_001 (Bảo vệ thông tin bí mật):** ❌ **FAIL** - Private key Google Firebase, Cloudflare R2 Keys và Google App Password bị lộ trong mã nguồn Git.
- **TC_SEC_005 (Chống tấn công Brute-force OTP):** ❌ **FAIL** - Endpoint gửi và xác thực OTP không có Rate Limiting.
