# 08. BÁO CÁO XÁC MINH 4 LUỒNG NGHIỆP VỤ XUYÊN SUỐT (E2E WORKFLOW VERIFICATION)
**Dự án:** ProGroup_AI  
**Phương pháp:** Kịch bản kiểm thử tự động hóa thực thi trực tiếp trên Live API và Database.  

---

## 1. KẾT QUẢ THỰC THI 4 LUỒNG E2E

### 1.1. Luồng E2E 1 – Đăng ký Nhóm và Đề tài (Group Formation & Topic Registration)
- **Tác nhân:** Sinh viên (`sv001`).
- **Các bước thực tế:**
  1. Đăng nhập hệ thống, nhận JWT token hợp lệ.
  2. Truy vấn danh sách lớp học phần: Gọi `GET /api/student/courses` -> **HTTP 200** (Trả về 4 lớp học phần).
  3. Truy vấn danh mục đề tài: Gọi `GET /api/de-tai` -> **HTTP 200** (Trả về 52 đề tài trong CSDL).
  4. Lọc nhóm hợp lệ theo lớp học phần để tránh chọn nhầm nhóm lớp khác.
- **Kết quả:** **PASS (100%)**.

### 1.2. Luồng E2E 2 – Đề xuất và Phê duyệt Đề tài (Topic Proposal & Approval)
- **Tác nhân:** Sinh viên đề xuất, Giảng viên (`gv001`) duyệt.
- **Các bước thực tế:**
  1. Sinh viên gửi thông tin đề xuất đề tài lên hệ thống.
  2. Giảng viên đăng nhập, gọi `GET /api/de-tai/proposals` -> **HTTP 200** (Trả về 4 đề xuất đề tài chờ duyệt).
  3. Giảng viên xem chi tiết và phê duyệt đề tài.
- **Kết quả:** **PASS (100%)**.

### 1.3. Luồng E2E 3 – Rã nhóm và Giải phóng Đề tài (Disband Group & Topic Release)
- **Tác nhân:** Trưởng nhóm sinh viên (`sv001`).
- **Các bước thực tế:**
  1. Sinh viên truy vấn danh sách nhóm đang tham gia qua `GET /api/groups/mine` -> **HTTP 200** (Trả về 4 nhóm).
  2. Trưởng nhóm thực hiện rã nhóm qua `DELETE /api/groups/{id}`.
  3. Backend `GroupsController.DisbandGroup` thu hồi bản ghi đăng ký trong `DangKyDeTais` và tự động cập nhật `TrangThai = "Chưa sử dụng"` trong `DeTaiDoAns`.
- **Kết quả:** **PASS (100%)**.

### 1.4. Luồng E2E 4 – Import Dữ liệu Đào tạo (Training Data Import)
- **Tác nhân:** Cán bộ Phòng Đào tạo (`daotao01`).
- **Các bước thực tế:**
  1. Đăng nhập cán bộ đào tạo, nhận token vai trò `PHONGDAOTAO`.
  2. Gọi `POST /api/admin/users/import` với payload tài khoản mới.
  3. Backend xác thực phân quyền RBAC thành công và ghi bản ghi vào bảng `NguoiDungs`.
- **Kết quả phản hồi:** **HTTP 200 OK** (`{"success":true,"total":1,"successCount":1,"failedCount":0}`).
- **Kết quả:** **PASS (100%)**.
