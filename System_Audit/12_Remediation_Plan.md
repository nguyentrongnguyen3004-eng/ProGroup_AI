# 12. KẾ HOẠCH KHẮC PHỤC & LỘ TRÌNH ĐƯA HỆ THỐNG VÀO HOẠT ĐỘNG (REMEDIATION PLAN)

## 1. MỤC TIÊU LỘ TRÌNH
Chuyển đổi toàn diện hệ thống **ProGroup_AI** từ trạng thái Prototype / Chưa hoàn thiện (72.5% tích hợp, nhiều dữ liệu mẫu và lỗ hổng bảo mật) thành một hệ thống **Sẵn sàng triển khai Production (Production-Ready)** đạt chuẩn an toàn thông tin và tính toàn vẹn dữ liệu.

---

## 2. LỘ TRÌNH TRIỂN KHAI 4 GIAI ĐOẠN

### GIAI ĐOẠN 1: HOTFIX BẢO MẬT & CÁC LỖI TẮC NGHẼN NGHIÊM TRỌNG (NGÀY 1 - NGÀY 3)
*Mục tiêu: Đóng toàn bộ lỗ hổng an ninh cấp bách và thông luồng các chức năng bị lỗi HTTP Method / 404.*

1. **Thu hồi và đổi mới toàn bộ Khóa bảo mật (Security Credentials Rotation):**
   - Đổi mật khẩu ứng dụng Gmail và tạo mật khẩu mới.
   - Xoay vòng cặp khóa Cloudflare R2 Access Key / Secret Key trên Cloudflare Dashboard.
   - Tạo mới Service Account Key cho Firebase Admin và xóa key cũ.
   - Tạo chuỗi bí mật JWT ngẫu nhiên 256-bit mới.
   - Chuyển toàn bộ bí mật ra biến môi trường (`Environment Variables` / `User Secrets`), không commit vào Git.
2. **Khắc phục lỗi HTTP 405 Đổi mật khẩu:**
   - Cập nhật các service trên Frontend (`admin_api_service`, `governance_api_service`, `lecturer_api_service`) đổi từ `ApiService.instance.post` sang `ApiService.instance.put`.
3. **Bổ sung Endpoint 404:**
   - Thêm action `[HttpGet("proposals")]` vào `DeTaiController.cs` để trả về danh sách đề tài sinh viên đề xuất cho giảng viên.
4. **Loại bỏ Backdoor & Dead URL:**
   - Xóa bỏ kiểm tra hardcode OTP `123456` trong `change_email_dialog.dart`.
   - Xóa bỏ bypass test user trong `auth_service.dart`.
   - Xóa URL trycloudflare chết trong `api_service.dart`.

---

### GIAI ĐOẠN 2: TÍCH HỢP TOÀN DIỆN CÁC PHÂN HỆ MOCK DATA (TUẦN 1 - TUẦN 2)
*Mục tiêu: Đưa phân hệ Phòng Đào tạo và Giáo vụ Khoa vào hoạt động trên CSDL thật 100%.*

1. **Tích hợp tính năng Import Excel thật:**
   - Chuyển đổi `TrainingImportScreen` và `GovernanceImportScreen` để đọc file Excel qua thư viện `excel` và đóng gói `multipart/form-data` gửi tới `POST /api/admin/users/import` và `POST /api/lop-hoc-phan/import`.
   - Xóa bỏ hoàn toàn lớp dữ liệu ảo `MockTrainingData` và `MockGovernanceData`.
2. **Lưu trữ Cấu hình Lớp học phần cho Giảng viên:**
   - Viết endpoint `PUT /api/lop-hoc-phan/{id}/cau-hinh` trên Backend.
   - Sửa `LecturerCourseDetailScreen` gọi API cập nhật khi giảng viên lưu cấu hình.
3. **Kết nối Nhật ký Hoạt động (Activity Logs):**
   - Viết endpoint `GET /api/admin/activity-logs` phân trang, đọc từ bảng `LichSuHeThong`.
   - Cập nhật `AdminActivityLogScreen` đọc dữ liệu động từ API.

---

### GIAI ĐOẠN 3: BẢO TOÀN DỮ LIỆU & TỐI ƯU HÓA KIẾN TRÚC (TUẦN 3 - TUẦN 4)
*Mục tiêu: Đảm bảo tính toàn vẹn dữ liệu dưới tải cao và dọn dẹp nợ kỹ thuật.*

1. **Bền vững hóa trạng thái Thông báo (Persist Notifications):**
   - Tạo bảng `NguoiDungThongBao (NguoiDungId, ThongBaoId, DaDoc, ThoiGianDoc)` trong CSDL.
   - Thay thế hoàn toàn bộ nhớ RAM `ConcurrentDictionary` trong `NotificationsController.cs`.
2. **Kiểm soát Tranh chấp Dữ liệu (Concurrency Control):**
   - Thêm cột `[Timestamp] byte[] RowVersion` vào thực thể `DeTai`.
   - Bọc logic duyệt/đăng ký đề tài trong Transaction `IsolationLevel.Serializable` để chống đăng ký quá số lượng nhóm.
3. **Giải phóng Đề tài khi Giải tán Nhóm:**
   - Bổ sung logic trong `GroupsController.DisbandGroup` để cập nhật trạng thái đề tài liên quan về `ChuaDangKy`.
4. **Tái cấu trúc Mã nguồn Trùng lặp (Refactoring):**
   - Hợp nhất 3 màn hình Profile riêng biệt thành một component dùng chung `UnifiedProfileScreen`.
   - Chuẩn hóa DTO và loại bỏ việc lạm dụng `Map<String, dynamic>`.

---

### GIAI ĐOẠN 4: KIỂM THỬ E2E & TRIỂN KHAI PRODUCTION (TUẦN 5)
*Mục tiêu: Đảm bảo hệ thống đạt 100% tỷ lệ PASS trên bộ kiểm thử 211 Test Cases.*

1. Chạy toàn bộ 211 Test Cases trên môi trường Staging.
2. Kiểm thử tải (Load Testing) mô phỏng 500 sinh viên cùng đăng ký đề tài trong 1 khung giờ cao điểm.
3. Cấu hình HTTPS, Firewall và phân quyền CORS cho tên miền chính thức.
4. Bàn giao và nghiệm thu hệ thống.
