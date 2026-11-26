# 07. BÁO CÁO PHÂN TÍCH NGUYÊN NHÂN GỐC RỄ (5-WHY ROOT CAUSE ANALYSIS)

## TC_BUG_CROSS_GROUP (User Issue: Đang ở nhóm t nhưng đăng ký đề tài hiển thị nhóm 02)

**Vấn đề ghi nhận**: Sinh viên đang ở trong nhóm t của lớp học phần A, nhưng khi bấm vào Đăng ký đề tài lại hiển thị nhóm đại diện là "Nhóm Demo 02".

### Chuỗi Phân Tích 5 Why:
- Tại sao lại hiển thị Nhóm Demo 02? -> Vì biến _myGroup trong TopicDetailScreen nhận giá trị của Nhóm Demo 02.
- Tại sao _myGroup lại nhận giá trị Nhóm Demo 02? -> Vì TopicDetailScreen có dòng code fallback: `foundGroup ?? myGroups.first`. Khi foundGroup là null, code tự động gán nhóm đầu tiên trong danh sách tất cả nhóm của sinh viên.
- Tại sao foundGroup lại null? -> Vì khi chuyển màn hình từ GroupDetailScreen sang TopicScreen, đối tượng Course không được truyền tiếp sang TopicDetailScreen hoặc CourseId không khớp.
- Tại sao lại có fallback myGroups.first? -> Do lập trình viên giả định sinh viên chỉ có duy nhất 1 nhóm trong toàn trường, vi phạm nghiệp vụ sinh viên học nhiều môn đồ án song song.
- Nguyên nhân gốc rễ (Root Cause): Khiếm khuyết thiết kế luồng dữ liệu (State Navigation Defect) và giả định sai về ràng buộc nghiệp vụ (Business Logic Assumption).

### Giải Pháp Khắc Phục Triệt Để:
Xóa bỏ hoàn toàn fallback `myGroups.first`. Chỉ liên kết nhóm thuộc đúng Lớp học phần của đề tài. Nếu sinh viên chưa có nhóm trong môn đó, hiển thị thông báo yêu cầu tham gia/tạo nhóm đúng môn học.

---

## TC_PDT_019 (Avatar Giáo vụ khoa và Phòng đào tạo bị đổi chung)

**Vấn đề ghi nhận**: Khi tài khoản Phòng đào tạo đổi ảnh đại diện, tài khoản Giáo vụ khoa cũng bị đổi theo.

### Chuỗi Phân Tích 5 Why:
- Tại sao hai vai trò bị đổi chung avatar? -> Vì UserAvatarView sử dụng giá trị dynamicAvatar từ singleton AvatarService.instance.avatarNotifier.
- Tại sao avatarNotifier lại áp dụng cho cả hai tài khoản? -> Vì avatarNotifier là biến đơn cấp ứng dụng (Global ValueNotifier<String>), không phân biệt username của tài khoản đang render.
- Tại sao không lọc theo username? -> UserAvatarView kiểm tra `if (dynamicAvatar.isNotEmpty)` đầu tiên và bỏ qua việc kiểm tra username có khớp với currentUser.username hay không.
- Tại sao lại thiết kế như vậy? -> Để hỗ trợ reactive update tức thì khi vừa chụp/đổi ảnh đại diện, nhưng quên đặt điều kiện phân lập không gian bộ nhớ (Context Isolation Defect).
- Nguyên nhân gốc rễ (Root Cause): Thiếu cơ chế cô lập dữ liệu theo danh tính người dùng trong State Management (Shared Mutable State without User Key Partitioning).

### Giải Pháp Khắc Phục Triệt Để:
Bổ sung điều kiện kiểm tra `isCurrentUser = username.toLowerCase() == currentUser.username.toLowerCase()`. Nếu render avatar của người dùng khác, chỉ sử dụng avatarUrl truyền vào, cấm tuyệt đối đọc avatarNotifier toàn cục.

---

## TC_ADM_001 & TC_ADM_002 (Số liệu tổng quan & Biểu đồ phân bổ 5 vai trò hiển thị sai)

**Vấn đề ghi nhận**: Biểu đồ thanh ngang phân bổ vai trò hiển thị phần trăm không đúng với dữ liệu thực tế.

### Chuỗi Phân Tích 5 Why:
- Tại sao tỷ lệ phần trăm lại sai? -> Vì số lượng các vai trò Giáo vụ, Đào tạo, Admin bị tính là 5, 4, 2 thay vì số lượng thực tế trong CSDL.
- Tại sao code lại rơi vào số lượng mặc định 5, 4, 2? -> Vì biến rawGiaovu, rawPdt, rawAdmin đều trả về 0.
- Tại sao rawGiaovu lại bằng 0? -> Vì code lọc danh sách người dùng bằng cú pháp `u["vaiTro"] ?? u["role"]`.
- Tại sao u["vaiTro"] lại null? -> Vì API Backend /api/admin/users trả về đối tượng với các thuộc tính là `maVaiTro` và `tenVaiTro` (theo DTO AdminUserResponse).
- Nguyên nhân gốc rễ (Root Cause): Không đồng bộ Contract DTO giữa Frontend và Backend (Schema Key Mismatch Bug).

### Giải Pháp Khắc Phục Triệt Để:
Cập nhật bộ đếm vai trò hỗ trợ đọc `u["maVaiTro"]` và `u["tenVaiTro"]`. Tính toán tỷ lệ phần trăm chuẩn xác đạt tổng 100% trên Stacked Bar Chart.

---

## TC_STU_040 & TC_NFR_012 (Chưa ràng buộc kích thước ảnh > 10MB và định dạng ảnh độc hại)

**Vấn đề ghi nhận**: Người dùng có thể chọn file ảnh quá lớn (> 10MB) hoặc file định dạng không an toàn.

### Chuỗi Phân Tích 5 Why:
- Tại sao hệ thống cho phép chọn ảnh lớn? -> Vì hàm _pickImage trong ProfileAvatarPickerHelper không kiểm tra bytes.length trước khi chuyển sang Base64 Data URI.
- Tại sao không chặn định dạng lạ? -> Vì extension của ảnh chỉ được dùng để map MIME type mà không có whitelist định dạng.
- Tại sao Backend lại báo lỗi chung 5MB? -> Vì ProfileController giới hạn cứng 5MB thay vì chuẩn nghiệp vụ 10MB.
- Nguyên nhân gốc rễ (Root Cause): Thiếu lớp phòng thủ kép (Defense in Depth) trên cả Client Validation và Server-side Boundary.

### Giải Pháp Khắc Phục Triệt Để:
Bổ sung Whitelist định dạng [jpg, jpeg, png, webp] và kiểm tra bytes.lengthInBytes <= 10 * 1024 * 1024 ở Client. Nâng mức trần ở Backend ProfileController lên 10MB với thông báo chuẩn nghiệp vụ.

---

## TC_AUTH_028 (Lỗi kết nối lại mạng / 403 khi thiết bị có mạng trở lại)

**Vấn đề ghi nhận**: Khi tắt bật mạng Wi-Fi/4G trên điện thoại, app gọi API bị trả về HTTP 403 hoặc gián đoạn kết nối.

### Chuỗi Phân Tích 5 Why:
- Tại sao lại bị lỗi kết nối? -> Vì ApiService hủy và khởi tạo lại http.Client() cho từng request đơn lẻ khiến TCP socket bị đứt gãy giữa chừng.
- Tại sao lại nhận HTTP 403? -> Vì token JWT bị mất đồng bộ hoặc header xác thực chưa được gắn lại sau khi khôi phục socket.
- Nguyên nhân gốc rễ (Root Cause): Quản lý vòng đời HTTP Client không đúng (Ephemeral Client instead of Persistent Connection Pool).

### Giải Pháp Khắc Phục Triệt Để:
Dùng persistent http.Client() với HTTP Keep-Alive, bọc cơ chế tự động reAuthenticate() làm mới phiên làm việc khi phát hiện mạng phục hồi.

---

