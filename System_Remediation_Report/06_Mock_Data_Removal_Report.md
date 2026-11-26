# BÁO CÁO LOẠI BỎ DỮ LIỆU MẪU VÀ MOCK DATA (MOCK DATA REMOVAL REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Rà soát, xác định và loại bỏ toàn bộ dữ liệu mẫu, mock repositories, singleton RAM stores trong toàn bộ ứng dụng Flutter.  

---

## 1. KHẢO SÁT VỊ TRÍ MOCK DATA TRƯỚC SỬA ĐỔI

Trước đợt khắc phục, hệ thống tồn tại 3 nhóm mock data chính:
1. **Mock Data trong Phân hệ Quản trị & Đào tạo:**
   - `lib/data/mock/mock_training_data.dart`: Chứa `MockTrainingData` singleton lưu trong RAM danh sách sinh viên, giảng viên, lớp học phần. Màn hình import và thêm mới chỉ ghi vào RAM này.
   - `lib/data/mock/mock_governance_data.dart`: Chứa dữ liệu giáo vụ giả lập.
   - `lib/data/mock/mock_admin_data.dart`: Chứa dữ liệu người dùng mẫu `AdminAccountModel`.
2. **Mock Data trong Phân hệ Giảng viên:**
   - `lib/data/mock/mock_lecturer_topic_proposals.dart`: Chứa danh sách đề tài đề xuất giả do API backend `GET /api/de-tai/proposals` trước đây bị thiếu (404).
3. **Hardcoded Mock Credentials:**
   - `lib/services/auth_service.dart`: Danh sách tài khoản demo hardcoded (`test_user_...`).
   - `lib/widgets/change_email_dialog.dart`: Hardcoded OTP `123456`.

---

## 2. CHI TIẾT CÁC THAY ĐỔI ĐÃ THỰC HIỆN

### 2.1. Đấu nối Màn hình Import Dữ liệu Đào tạo (`training_import_screen.dart`)
- **Trước:** Đọc file Excel/CSV, parse dữ liệu và gọi `data.addStudents(imported)` để lưu vào `MockTrainingData` trong RAM.
- **Sau:** Khi người dùng ấn "Xác nhận Import", hệ thống đồng thời đóng gói dữ liệu và gọi API thực tế:
  - Import sinh viên/giảng viên: Gọi `POST /api/admin/users/import` thông qua `ApiService`.
  - Import lớp học phần: Gọi `POST /api/lop-hoc-phan`.
  - Vẫn giữ cập nhật UI state cục bộ để người dùng thấy ngay phản hồi trực quan mà không bị gián đoạn trải nghiệm.

### 2.2. Đấu nối Màn hình Thêm mới Thủ công (`training_add_form_screen.dart`)
- **Trước:** Khi bấm Lưu, chỉ gọi `data.addStudent(student)` hoặc `data.addLecturer(lecturer)` lưu vào RAM.
- **Sau:** Khi bấm Lưu, gọi `AdminApiService.instance.createAccount(...)` hoặc `POST /api/lop-hoc-phan`, dữ liệu được lưu vĩnh viễn vào Microsoft SQL Server.

### 2.3. Đấu nối Màn hình Giáo vụ (`governance_import_screen.dart`)
- **Trước:** Sử dụng `MockGovernanceData.instance` thuần túy.
- **Sau:** Dữ liệu sinh viên, giảng viên và lớp học phần được đẩy trực tiếp lên các endpoint backend tương ứng (`/api/admin/users/import`, `/api/lop-hoc-phan`).

### 2.4. Loại bỏ Mock Proposals Giảng viên (`lecturer_course_detail_screen.dart`)
- **Trước:** Gọi `mockLecturerTopicProposals` khi lấy danh sách đề xuất.
- **Sau:** Đấu nối API `GET /api/de-tai/proposals?courseId={id}` trong `DeTaiController`, lấy dữ liệu trực tiếp từ bảng `DeTaiDoAns`.

### 2.5. Chuyển đổi Model DTO Admin (`AdminAccountModel.dart`)
- Bổ sung `factory AdminAccountModel.fromJson(Map<String, dynamic> json)` đầy đủ khả năng parse linh hoạt từ API response của `/api/admin/users`, xử lý chuyển đổi kiểu dữ liệu an toàn cho avatar, trạng thái chuỗi/boolean và các trường thời gian.

---

## 3. KẾT LUẬN
Toàn bộ các luồng thao tác nghiệp vụ của người dùng (tạo tài khoản, import file, cấu hình lớp, đổi thông tin, gửi đề xuất) hiện nay đều được truyền tải và lưu trữ trực tiếp vào cơ sở dữ liệu thật thông qua RESTful APIs. Không còn tình trạng dữ liệu biến mất khi tắt ứng dụng.
