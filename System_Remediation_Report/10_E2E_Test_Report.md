# BÁO CÁO KIỂM THỬ XUYÊN SUỐT HỆ THỐNG (END-TO-END WORKFLOW TEST REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Đánh giá tính toàn vẹn và thông suốt của các luồng nghiệp vụ end-to-end từ giao diện người dùng qua API đến lưu trữ cơ sở dữ liệu.  

---

## 1. LUỒNG 1: KHỞI TẠO VÀ NHẬP LIỆU HỆ THỐNG (TRAINING / GOVERNANCE ONBOARDING)
- **Tác nhân:** Chuyên viên Phòng Đào tạo / Giáo vụ khoa.
- **Kịch bản thực hiện:**
  1. Người dùng truy cập màn hình Import dữ liệu (`/training/import` hoặc `/governance/import`).
  2. Chọn tệp tin Excel/CSV danh sách sinh viên hoặc lớp học phần.
  3. Giao diện hiển thị bảng xem trước (preview) dữ liệu đã được chuẩn hóa.
  4. Người dùng bấm "Xác nhận Import".
  5. **Hành vi hệ thống:** Gửi request `POST /api/admin/users/import` hoặc `POST /api/lop-hoc-phan`. Backend tiếp nhận, hash mật khẩu mặc định an toàn, ghi nhận các bản ghi vào bảng `NguoiDungs` và `LopHocPhans` trong SQL Server.
  6. **Kết quả:** Dữ liệu được ghi nhận vào database thật. Khi đăng xuất và đăng nhập lại, toàn bộ danh sách vẫn tồn tại nguyên vẹn.
- **Đánh giá:** **PASSED (100%)**

---

## 2. LUỒNG 2: PHÂN NHÓM VÀ QUẢN LÝ THÀNH VIÊN (GROUP FORMATION & LIFECYCLE)
- **Tác nhân:** Sinh viên (Nhóm trưởng và Thành viên).
- **Kịch bản thực hiện:**
  1. Sinh viên A tạo nhóm mới cho môn Đồ án chuyên ngành.
  2. Sinh viên A mời sinh viên B và C tham gia nhóm qua mã sinh viên.
  3. Sinh viên B nhận thông báo và chấp thuận lời mời.
  4. Nhóm tiến hành đăng ký một đề tài trong danh mục đề tài của giảng viên (`POST /api/dang-ky-de-tai`). Trạng thái đề tài chuyển thành `"Đã sử dụng"`.
  5. Nhóm phát sinh mâu thuẫn, nhóm trưởng A bấm "Rã nhóm" (Disband Group).
  6. **Hành vi hệ thống:** Backend gọi `GroupsController.DisbandGroup`:
     - Xóa các bản ghi thành viên trong `ThanhVienNhoms`.
     - Xóa bản ghi nhóm trong `NhomSinhViens`.
     - Tìm kiếm và giải phóng bản ghi `DangKyDeTais`.
     - **Tự động hoàn trả trạng thái đề tài trong `DeTaiDoAns` về `"Chưa sử dụng"`**.
  7. **Kết quả:** Đề tài lập tức xuất hiện trở lại trên danh sách đề tài sẵn sàng cho các nhóm khác đăng ký. Không còn lỗi đề tài bị khóa chết.
- **Đánh giá:** **PASSED (100%)**

---

## 3. LUỒNG 3: ĐỀ XUẤT VÀ PHÊ DUYỆT ĐỀ TÀI (TOPIC PROPOSAL & APPROVAL)
- **Tác nhân:** Sinh viên & Giảng viên phụ trách.
- **Kịch bản thực hiện:**
  1. Nhóm sinh viên không chọn đề tài có sẵn mà tự đề xuất đề tài mới hoặc nhận gợi ý từ AI Topic Assistant.
  2. Nhóm gửi đề xuất đề tài lên hệ thống (`POST /api/de-tai/propose`). Trạng thái đề tài là `"Chờ duyệt"`.
  3. Giảng viên đăng nhập, vào màn hình chi tiết lớp học phần và tab "Đề xuất đề tài".
  4. Hệ thống gọi `GET /api/de-tai/proposals?courseId={id}` lấy danh sách đề xuất từ database.
  5. Giảng viên xem chi tiết, góp ý và bấm "Phê duyệt". Trạng thái đề tài chuyển thành `"Đã duyệt"` và gán cho nhóm đăng ký.
- **Đánh giá:** **PASSED (100%)**

---

## 4. LUỒNG 4: BẢO MẬT TÀI KHOẢN VÀ XÁC THỰC OTP (SECURITY LIFECYCLE)
- **Tác nhân:** Người dùng mọi vai trò.
- **Kịch bản thực hiện:**
  1. Người dùng vào trang cá nhân, chọn "Đổi địa chỉ Email".
  2. Nhập email mới và bấm "Gửi mã xác nhận".
  3. Hệ thống sinh mã OTP ngẫu nhiên 6 chữ số lưu vào database và gửi email thực tế đến hòm thư mới.
  4. Người dùng nhập mã OTP nhận được trong email.
  5. Hệ thống xác thực mã OTP, kiểm tra thời hạn và cờ đã sử dụng. Nếu hợp lệ, cập nhật email mới và vô hiệu hóa mã OTP.
- **Đánh giá:** **PASSED (100%)**
