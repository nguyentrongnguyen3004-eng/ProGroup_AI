# 02. BÁO CÁO RÀ SOÁT DỮ LIỆU MẪU & HARDCODE DATA (MOCK DATA AUDIT)

## 1. TỔNG QUAN PHÁT HIỆN
Trong đợt audit hệ thống, chúng tôi đã phát hiện **20 vị trí vi phạm nghiêm trọng** liên quan đến dữ liệu mẫu (Mock Data), dữ liệu cố định trong mã nguồn (Hardcode Data), dữ liệu giả lập trong bộ nhớ RAM (In-Memory Singletons) và logic bypass xác thực.

Đặc biệt, hệ thống tồn tại **hai phân hệ lớn (Phòng Đào tạo và Giáo vụ Khoa) gần như chạy tách rời khỏi Backend API**, thao tác trên danh sách ảo trong bộ nhớ RAM, dẫn đến việc dữ liệu bị mất hoàn toàn khi tắt ứng dụng.

---

## 2. BẢNG TỔNG HỢP RÀ SOÁT DỮ LIỆU MẪU TOÀN HỆ THỐNG

| STT | Phân hệ / Module | File & Dòng Code | Chức năng | Loại dữ liệu | API hiện có | Mức độ | Hướng xử lý |
|---|---|---|---|---|---|---|---|
| 1 | **Phòng đào tạo** | `screens/phong_dao_tao/management/training_import_screen.dart:45-120` | Import Excel dữ liệu Lớp học phần, Sinh viên, Giảng viên | **MOCK DATA** (Lưu RAM qua `MockTrainingData.instance`) | Có: `POST /api/admin/users/import`, `POST /api/lop-hoc-phan` | **CRITICAL** | Xóa bỏ `MockTrainingData`, kết nối trực tiếp multipart form-data tới `/api/admin/users/import`. |
| 2 | **Phòng đào tạo** | `screens/phong_dao_tao/management/training_add_form_screen.dart:50-95` | Thêm mới thủ công Lớp học phần, Giảng viên, Sinh viên | **MOCK DATA** (Lưu RAM qua `MockTrainingData.instance`) | Có: `POST /api/lop-hoc-phan`, `POST /api/admin/users` | **CRITICAL** | Thay thế logic lưu RAM bằng gọi `GovernanceApiService.createCourse` hoặc `AdminApiService.createUser`. |
| 3 | **Giáo vụ khoa** | `screens/giao_vu/tools/governance_import_screen.dart:40-110` | Import danh sách LHP và Sinh viên khoa | **MOCK DATA** (Lưu RAM qua `MockGovernanceData.instance`) | Có: `POST /api/admin/users/import`, `POST /api/lop-hoc-phan` | **CRITICAL** | Chuyển luồng đọc Excel sang gửi HTTP POST multipart tới Backend API. |
| 4 | **Giáo vụ khoa** | `screens/giao_vu/tools/governance_data_management_screen.dart:180-210` | Nút Thêm mới và Nút Import | **MOCK DATA ROUTE** (Giao diện hiển thị danh sách từ API thật nhưng bấm Thêm/Import lại chuyển sang Mock) | Có API | **HIGH** | Điều hướng sang form gọi API thật thay vì mở màn hình Mock. |
| 5 | **Giảng viên** | `screens/lecturer/course/lecturer_course_detail_screen.dart:708-718` | Cấu hình Lớp học phần (Số lượng SV, số nhóm tối đa, thời hạn) | **LOCAL DATA** (Trả về `copyWith`, set `setState` cục bộ, KHÔNG gọi API) | Cần bổ sung: `PUT /api/lop-hoc-phan/{id}` | **CRITICAL** | Tạo endpoint `PUT /api/lop-hoc-phan/{id}` trên Backend và gọi API khi bấm Lưu. |
| 6 | **Xác thực** | `widgets/common/change_email_dialog.dart:125-130` | Xác thực OTP đổi Email người dùng | **FAKE OTP HARDCODE** (`if (otp != '123456')`) | Backend có `/api/auth/change-email` | **CRITICAL** | Loại bỏ hardcode `123456`, triển khai flow gửi OTP email thật từ Server. |
| 7 | **Xác thực** | `services/auth_service.dart:106-107` | Đăng nhập tài khoản kiểm thử | **HARDCODE TEST USER** (`cleanUsername == 'test_user_1792849805122'`) | Dùng JWT auth | **HIGH** | Xóa hoàn toàn bypass check trong AuthService. |
| 8 | **Quản trị viên** | `screens/admin/activity/admin_activity_log_screen.dart:28-80` | Nhật ký hoạt động toàn hệ thống | **MOCK DATA** (Danh sách 6 đối tượng `AdminActivityModel` fix cứng trong code) | Backend có bảng `LichSuHeThong` | **HIGH** | Tạo endpoint `GET /api/admin/activity-logs` để đọc từ bảng `LichSuHeThong`. |
| 9 | **Quản trị viên** | `screens/admin/role/admin_role_screen.dart:25-90` | Quản lý vai trò và phân quyền hệ thống | **STATIC UI HARDCODE** (Render bảng quyền tĩnh, không có lưu/sửa) | CSDL dùng enum `VaiTro` | **MEDIUM** | Chuyển thành giao diện cấu hình phân quyền động hoặc ẩn nếu là RBAC cố định. |
| 10 | **Backend Admin** | `Controllers/AdminController.cs:109-110` | Thống kê tỷ lệ hoàn thành đề tài | **HARDCODE BACKEND** (`TyLeHoanThanh = 85.5`) | Cần query từ `BaoCaoTienDo` & `DangKyDeTai` | **MEDIUM** | Tính toán tỷ lệ thực tế dựa trên số nhóm có điểm >= 5.0 chia cho tổng nhóm. |
| 11 | **Backend Admin** | `Controllers/AdminController.cs:142-152` | Phổ điểm đồ án môn học | **HARDCODE BACKEND** (Xuất sắc=15, Giỏi=28, Khá=18, Trung bình=5, Rớt=2) | Cần query từ `BaoCaoTienDo.Diem` | **MEDIUM** | Đếm số lượng điểm thực tế theo thang điểm 10. |
| 12 | **Backend Admin** | `Controllers/AdminController.cs:110` | Số lượng sinh viên hoạt động | **HARDCODE BACKEND** (`ActiveStudents = Math.Max(totalStudents, 35)`) | Query `NguoiDung.TrangThai` | **LOW** | Bỏ `Math.Max`, lấy đúng count từ CSDL. |
| 13 | **Backend LHP** | `Controllers/LopHocPhanController.cs:166` | Số điện thoại giảng viên lớp học phần | **HARDCODE BACKEND** (`SoDienThoai = "0909123456"`) | Lấy từ `GiangVien.SoDienThoai` | **LOW** | Truy vấn trường `SoDienThoai` thật từ bảng `GiangVien`/`NguoiDung`. |
| 14 | **Dữ liệu tĩnh** | `data/mock_training_data.dart:1-350` | Toàn bộ dữ liệu mẫu Phòng Đào tạo | **MOCK DATA STORE** | Có API tương ứng | **HIGH** | Đánh dấu `@deprecated` và dọn dẹp khỏi codebase. |
| 15 | **Dữ liệu tĩnh** | `data/mock_governance_data.dart:1-280` | Toàn bộ dữ liệu mẫu Giáo vụ Khoa | **MOCK DATA STORE** | Có API tương ứng | **HIGH** | Đánh dấu `@deprecated` và dọn dẹp khỏi codebase. |
| 16 | **Dữ liệu tĩnh** | `data/mock_courses.dart:1-120` | Danh sách khóa học mẫu | **MOCK DATA** | `GET /api/lop-hoc-phan` | **MEDIUM** | Xóa bỏ file thừa. |
| 17 | **Dữ liệu tĩnh** | `data/mock_groups.dart:1-150` | Danh sách nhóm sinh viên mẫu | **MOCK DATA** | `GET /api/groups` | **MEDIUM** | Xóa bỏ file thừa. |
| 18 | **Dữ liệu tĩnh** | `data/mock_topics.dart:1-180` | Danh sách đề tài mẫu | **MOCK DATA** | `GET /api/de-tai` | **MEDIUM** | Xóa bỏ file thừa. |
| 19 | **Dữ liệu tĩnh** | `data/mock_reports.dart:1-90` | Danh sách báo cáo mẫu | **MOCK DATA** | `GET /api/bao-cao` | **MEDIUM** | Xóa bỏ file thừa. |
| 20 | **Mạng** | `services/api_service.dart:37` | Cloudflare Quick Tunnel URL | **DEAD URL HARDCODE** | Local/Production URL | **HIGH** | Xóa bỏ URL trycloudflare chết, chuyển sang cấu hình `.env` động. |

---

## 3. PHÂN TÍCH RỦI RO NGHIỆP VỤ DO DỮ LIỆU MẪU

1. **Rủi ro mất dữ liệu nghiêm trọng ở vai trò Quản lý:**
   - Trưởng phòng đào tạo hoặc Giáo vụ khoa thực hiện import 500 sinh viên hoặc tạo 10 lớp học phần mới trên ứng dụng. Giao diện báo thành công và hiển thị ngay trên danh sách (do ghi vào mảng RAM `MockTrainingData`). Tuy nhiên, khi người dùng đăng xuất hoặc tắt app, toàn bộ 500 sinh viên và 10 lớp học phần biến mất không dấu vết.
2. **Rủi ro Bypass OTP Đổi Email:**
   - Bất kỳ ai cầm điện thoại đang đăng nhập có thể đổi email tài khoản sang email của kẻ tấn công bằng cách nhập bừa OTP và điền `123456`, chiếm đoạt hoàn toàn tài khoản qua cơ chế quên mật khẩu.
3. **Báo cáo Thống kê Sai Lệch ở Cấp Lãnh Đạo:**
   - Ban giám hiệu hoặc Quản trị viên xem Dashboard thống kê thấy tỷ lệ hoàn thành luôn là 85.5% và phổ điểm luôn hiển thị cố định dù sinh viên chưa nộp báo cáo hoặc điểm thực tế rất thấp.
