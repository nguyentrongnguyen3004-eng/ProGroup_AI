# 06. BÁO CÁO KIỂM TOÁN NGHIỆP VỤ HỌC VỤ (BUSINESS LOGIC AUDIT)
## ĐÁNH GIÁ QUY TRÌNH HỌC VỤ THEO TỪNG VAI TRÒ & KHẮC PHỤC LỖI KHỚP NHÓM

---

### 1. QUY TRÌNH NGHIỆP VỤ SINH VIÊN & TRƯỞNG NHÓM

#### 1.1. Luồng Thành lập Nhóm & Quản lý Thành viên
1. Sinh viên chỉ được tạo nhóm khi đợt đăng ký của Lớp học phần đang ở trạng thái `Mở` (`TrangThai == true`).
2. Sinh viên tạo nhóm mặc định trở thành Trưởng nhóm (`TruongNhomId`).
3. Trưởng nhóm có quyền:
   - Đổi tên nhóm (kèm kiểm tra không trùng tên trong cùng đợt).
   - Gửi lời mời tới sinh viên khác theo MSSV.
   - Duyệt hoặc từ chối sinh viên xin gia nhập nhóm.
   - Xóa thành viên khỏi nhóm (nếu chưa nộp báo cáo chính thức).
4. Giới hạn số lượng thành viên: Nhóm chỉ được phép đăng ký đề tài khi số lượng thành viên nằm trong khoảng `[MinMembers, MaxMembers]` (thông thường từ 1 đến 4 sinh viên).

#### 1.2. Luồng Khớp Nhóm & Đăng Ký Đề Tài (Phân tích lỗi & Khắc phục triệt để)
- **Vấn đề thực tế của người dùng:** Người dùng phản ánh *"mình đang ở nhóm t nhưng khi vào đăng ký đề tài thì là nhóm 02 là sao nhỉ???"*.
- **Nguyên nhân nghiệp vụ:**
  - Sinh viên có thể tham gia nhiều nhóm ở các học phần khác nhau (hoặc các nhóm cũ ở học kỳ trước).
  - Đề tài A thuộc về Lớp học phần CNTT01 (Đợt 1). Nhóm "t" của sinh viên thuộc Lớp học phần CNTT01. Nhưng nhóm "Demo 02" lại thuộc Lớp học phần KTPM02.
  - Trước khi sửa: Mã nguồn Flutter trong `topic_detail_screen.dart` viết:
    ```dart
    final myGroup = foundGroup ?? myGroups.first; // LẤY BỪA NHÓM ĐẦU TIÊN!
    ```
    Dẫn tới việc hệ thống tự ý gán nhóm "Demo 02" vào đề tài của Lớp CNTT01!
  - **Khắc phục triệt để:**
    - Loại bỏ hoàn toàn fallback lấy bừa `myGroups.first`.
    - Lọc chính xác nhóm mà sinh viên làm trưởng nhóm **VÀ** nhóm đó phải thuộc cùng `LopHocPhanId`/`DotDangKyId` với đề tài.
    - Nếu sinh viên không có nhóm nào thuộc lớp học phần đó, hiển thị thông báo rõ ràng: *"Bạn chưa có nhóm hợp lệ trong học phần này. Vui lòng tạo nhóm trước khi đăng ký đề tài."*

---

### 2. QUY TRÌNH NGHIỆP VỤ GIẢNG VIÊN HƯỚNG DẪN
1. **Quản lý Đề tài:**
   - Giảng viên có thể tạo đề tài mới cho đợt đăng ký thuộc khoa của mình.
   - Giảng viên duyệt hoặc từ chối đề tài do sinh viên tự đề xuất (`TrangThai = 'Đã duyệt' / 'Từ chối'`).
2. **Phê duyệt Đăng ký của Nhóm:**
   - Khi nhóm gửi yêu cầu đăng ký đề tài, đề tài chuyển sang trạng thái `Chờ giảng viên duyệt`.
   - Giảng viên xem danh sách thành viên, CV và định hướng của nhóm trước khi bấm `Chấp nhận`.
   - Khi chấp nhận, nhóm chính thức được giao đề tài. Các yêu cầu đăng ký khác vào đề tài này tự động bị hủy bỏ.
3. **Đánh giá Báo cáo Tiến độ:**
   - Giảng viên xem file báo cáo, link mã nguồn Git của nhóm.
   - Nhập nhận xét chi tiết và chấm điểm tiến độ theo thang điểm 10.

---

### 3. QUY TRÌNH NGHIỆP VỤ GIÁO VỤ KHOA & PHÒNG ĐÀO TẠO
1. **Giáo vụ khoa:**
   - Giám sát danh sách lớp học phần và đề tài thuộc khoa quản lý.
   - Mở đợt đăng ký đồ án cho các lớp chuyên ngành.
2. **Phòng đào tạo:**
   - Quản lý danh mục học kỳ và niên khóa toàn trường.
   - Xem dashboard tổng hợp số liệu đồ án liên khoa.
