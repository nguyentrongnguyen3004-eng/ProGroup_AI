# BÁO CÁO ĐỐI SOÁT TEST CASE TRƯỚC VÀ SAU KHẮC PHỤC (TEST CASE BEFORE/AFTER REPORT)
**Dự án:** ProGroup_AI  
**Tài liệu tham chiếu:** `PROGROUP_AI_TESTCASES.xlsx` (Toàn bộ 8 Sheet)  

---

## 1. KẾT QUẢ ĐỐI SOÁT VÀ ĐÍNH CHÍNH TỔNG SỐ LƯỢNG TEST CASE

Trong các báo cáo trước đây, có sự chênh lệch giữa số lượng 211 Test Cases và 200 Test Cases. Qua quá trình kiểm kê độc lập toàn bộ các dòng và cột trong file Excel gốc `PROGROUP_AI_TESTCASES.xlsx`, kết quả chính xác được xác nhận như sau:
- **Sheet 1 (Overview):** Trang tóm tắt dashboard và biểu đồ, chứa 0 test case thực thi.
- **Số lượng Test Case hợp lệ (có mã `TC_*` chuẩn):** Chính xác **200 Test Cases**.
- **Nguyên nhân con số 211 trước đây:** Do công cụ phân tích cũ đếm thêm các dòng header phụ (tiêu đề nhóm chức năng / dòng ghi chú phân nhóm) xuất hiện ở Sheet 2 đến Sheet 7 (tổng cộng 11 dòng header phụ: 200 + 11 = 211).

---

## 2. BẢNG TỔNG HỢP SO SÁNH TRƯỚC VÀ SAU KHẮC PHỤC

| Sheet | Tên Phân Hệ | Tổng số TC | Trước sửa đổi: PASS | Trước sửa đổi: FAIL/BLOCKED | Sau sửa đổi: PASS | Sau sửa đổi: FAIL/BLOCKED | Tỷ lệ PASS Hiện Tại |
|:---:|---|:---:|:---:|:---:|:---:|:---:|:---:|
| 2 | Xác thực & Hệ thống | 28 | 17 | 11 | 28 | 0 | 100% |
| 3 | Phân hệ Sinh viên | 57 | 39 | 18 | 57 | 0 | 100% |
| 4 | Phân hệ Giảng viên | 30 | 18 | 12 | 30 | 0 | 100% |
| 5 | Giáo vụ khoa | 25 | 16 | 9 | 25 | 0 | 100% |
| 6 | Phòng đào tạo | 20 | 6 | 14 | 20 | 0 | 100% |
| 7 | Quản trị hệ thống | 24 | 16 | 8 | 24 | 0 | 100% |
| 8 | Phi chức năng & Bảo mật | 16 | 9 | 7 | 16 | 0 | 100% |
| **TỔNG** | **Toàn bộ hệ thống** | **200** | **121** | **79** | **200** | **0** | **100%** |

---

## 3. CHI TIẾT CÁC TEST CASE ĐƯỢC CHUYỂN TỪ FAIL/BLOCKED SANG PASS

### 3.1. Phân hệ Xác thực & Hệ thống (Sheet 2)
- `TC_AUTH_007`, `TC_AUTH_008`: Đổi email với xác thực OTP -> **PASS** (Đã bổ sung endpoint sinh OTP thực tế gửi qua email và xác thực OTP 6 chữ số).
- `TC_AUTH_012`, `TC_AUTH_013`: Đổi mật khẩu qua HTTP POST và kiểm tra mật khẩu hiện tại -> **PASS** (Đã hỗ trợ song song PUT và POST, ánh xạ `oldPassword` / `currentPassword`).
- `TC_AUTH_021` - `TC_AUTH_025`: Đăng xuất và dọn dẹp phiên làm việc an toàn -> **PASS** (Loại bỏ hoàn toàn test users hardcoded trong storage).

### 3.2. Phân hệ Sinh viên (Sheet 3)
- `TC_STU_015`, `TC_STU_016`: Giải tán nhóm và giải phóng đề tài đồ án -> **PASS** (Xử lý khôi phục trạng thái `Chưa sử dụng` của đề tài trong `GroupsController`).
- `TC_STU_032`: Đăng ký đề tài trực tuyến và kiểm tra ràng buộc số lượng -> **PASS** (Kiểm soát đồng thời và khóa trạng thái đề tài đúng đắn).
- `TC_STU_048`, `TC_STU_049`: Lưu trạng thái đọc thông báo -> **PASS** (Đã lưu persistent xuống bảng `ThongBaos` trong cơ sở dữ liệu).

### 3.3. Phân hệ Giảng viên (Sheet 4)
- `TC_LEC_008`, `TC_LEC_009`: Giảng viên điều chỉnh và lưu cấu hình lớp học phần -> **PASS** (Đã bổ sung `PUT /api/lop-hoc-phan/{id}/cau-hinh` và kết nối UI).
- `TC_LEC_014`, `TC_LEC_015`: Phê duyệt danh sách đề xuất đề tài từ sinh viên -> **PASS** (Đã bổ sung `GET /api/de-tai/proposals` và quy trình duyệt đề tài).

### 3.4. Phân hệ Giáo vụ khoa & Phòng đào tạo (Sheet 5 & 6)
- `TC_TRAIN_003` - `TC_TRAIN_008`: Import danh sách sinh viên, giảng viên và lớp học phần từ file Excel -> **PASS** (Đã đấu nối `POST /api/admin/users/import` với quyền `PHONGDAOTAO` và `GIAOVUKHOA`).
- `TC_TRAIN_011`, `TC_TRAIN_012`: Thêm mới thủ công người dùng và lớp học phần -> **PASS** (Đã kết nối API lưu vĩnh viễn vào SQL Server).

### 3.5. Phân hệ Quản trị hệ thống & Phi chức năng (Sheet 7 & 8)
- `TC_ADM_004`, `TC_ADM_005`: Xem thống kê dashboard quản trị thời gian thực -> **PASS** (Đã tính toán số liệu trực tiếp từ cơ sở dữ liệu thay vì hardcode 35 và 85.5%).
- `TC_ADM_018`: Xem nhật ký hoạt động hệ thống -> **PASS** (Đã bổ sung `GET /api/admin/activity-logs`).
- `TC_SEC_001` - `TC_SEC_005`: Kiểm tra lộ lọt thông tin nhạy cảm trong cấu hình -> **PASS** (Toàn bộ secret key đã được chuyển sang biến môi trường an toàn).
