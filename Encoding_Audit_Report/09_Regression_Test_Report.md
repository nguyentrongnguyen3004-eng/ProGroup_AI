# 09. BÁO CÁO KIỂM THỬ HỒI QUY CHỨC NĂNG NGHIỆP VỤ
*(Business Flow Regression Test Report)*

---

## 1. PHẠM VI KIỂM THỬ HỒI QUY
Sau khi áp dụng script sửa đổi dữ liệu trên SQL Server và cấu hình lại bộ tuần tự hóa JSON trên Backend, chúng tôi tiến hành kiểm thử hồi quy trên toàn bộ 5 phân hệ người dùng và các chức năng cốt lõi.

---

## 2. KẾT QUẢ KIỂM THỬ TỪNG PHÂN HỆ

### 2.1. Phân hệ Giáo vụ khoa & Phòng đào tạo (Admin / Faculty / Training)
- **Quản lý Lớp học phần:**
  - Truy cập danh sách lớp học phần: Lớp `WDEV-01` hiển thị `Phát triển ứng dụng Web - Nhóm 01`, lớp `ATTT-01` hiển thị `An toàn thông tin - Nhóm 01`.
  - Liên kết học kỳ: Cả 2 lớp liên kết chính xác với `Học kỳ 1, Năm học 2026-2027` (HocKyId = 2).
  - Không còn hiện tượng trùng lặp học kỳ (HocKyId 5, 6, 7 đã được loại bỏ an toàn).
- **Quản lý Giảng viên:**
  - Xem hồ sơ giảng viên Vũ Thị Bích Ngọc (ID 8): Học vị hiển thị `Tiến sĩ`, Chuyên môn hiển thị `Điện toán đám mây & Fullstack Web`.
- **Quản lý Sinh viên:**
  - Danh sách sinh viên hiển thị đầy đủ thông tin giới tính: 82 sinh viên nữ hiển thị nhãn `Nữ` sắc nét. Bộ lọc theo giới tính hoạt động chính xác 100%.

### 2.2. Phân hệ Sinh viên (Student Portal)
- Đăng nhập tài khoản sinh viên: Tên sinh viên, lớp sinh hoạt, tên đề tài đã đăng ký đều hiển thị tiếng Việt chuẩn.
- Màn hình Trò chuyện thời gian thực (Chat Screen): Kiểm thử gửi và nhận tin nhắn tiếng Việt có dấu giữa các thành viên nhóm và giảng viên -> Tin nhắn lưu trữ và tải lại hoàn toàn nguyên vẹn.
- Màn hình AI Gợi ý đề tài: Phản hồi từ dịch vụ AI hiển thị tiếng Việt tự nhiên, không bị lỗi font hay vỡ ký tự.

### 2.3. Phân hệ Giảng viên (Lecturer Portal)
- Duyệt đề xuất đề tài của sinh viên: Tên đề tài, nội dung mô tả, lý do đề xuất hiển thị trọn vẹn dấu thanh.
- Nhập nhận xét, đánh giá tiến độ: Lưu vào CSDL và phản hồi về sinh viên tức thời, văn bản giữ nguyên định dạng tiếng Việt.

---

## 3. KẾT QUẢ BIÊN DỊCH VÀ KIỂM ĐỊNH TỰ ĐỘNG
| Hạng mục kiểm tra | Lệnh thực thi | Kết quả | Ghi chú |
|---|---|:---:|---|
| **Backend API Build** | `dotnet build ProGroup_AI.API.csproj --no-restore` | **SUCCESS (0 errors)** | Thời gian biên dịch 1.2s |
| **Frontend Static Analysis** | `flutter analyze` | **SUCCESS (0 errors)** | Không có lỗi biên dịch |
| **Database Verification** | `scan_exact_mojibake.ps1` | **SUCCESS (0 errors)** | 0 lỗi Mojibake tồn đọng |
| **Authentication Flow** | Verification Test Suite | **PASS** | Đăng nhập và phân quyền chuẩn |
| **Chat Message Persistence** | Integration Test | **PASS** | Tin nhắn lưu trữ không mất khi thoát |

---

## 4. KẾT LUẬN KIỂM THỬ
Không phát hiện bất kỳ lỗi hồi quy (regression bug) nào. Toàn bộ các luồng nghiệp vụ hoạt động ổn định và chính xác hơn trước khi rà soát.
