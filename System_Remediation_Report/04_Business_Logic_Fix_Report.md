# BÁO CÁO KHẮC PHỤC LOGIC NGHIỆP VỤ (BUSINESS LOGIC FIX REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Sửa đổi các lỗi logic cốt lõi ảnh hưởng đến tính đúng đắn và quy trình vận hành xuyên suốt của hệ thống.  

---

## 1. CÁC LỖI LOGIC NGHIỆP VỤ ĐÃ ĐƯỢC KHẮC PHỤC

### 1.1. Lỗi BUG-BL-01: Trạng thái Đề tài bị khóa vĩnh viễn khi Nhóm giải tán
- **Nguyên nhân gốc rễ:**
  - Trong quy trình phân nhóm và đăng ký đề tài: Khi một nhóm đăng ký một đề tài, trạng thái đề tài trong bảng `DeTaiDoAns` chuyển sang `"Đã sử dụng"` hoặc `"Đang thực hiện"`.
  - Khi nhóm trưởng thực hiện hành động "Rã nhóm" (Disband Group) tại `GroupsController.DisbandGroup`, hệ thống chỉ xóa các bản ghi trong `NhomSinhViens` và `DangKyDeTais` mà không hoàn trả trạng thái của đề tài trong `DeTaiDoAns`. Hậu quả là đề tài bị "treo" vĩnh viễn, không một nhóm nào khác trong lớp có thể chọn lại đề tài này.
- **Biện pháp khắc phục trong [GroupsController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/GroupsController.cs):**
  ```csharp
  // Thu hồi và giải phóng đề tài nếu nhóm đã đăng ký
  var activeRegistrations = await _db.DangKyDeTais
      .Where(d => d.NhomId == id)
      .ToListAsync();

  foreach (var reg in activeRegistrations)
  {
      var deTai = await _db.DeTaiDoAns.FindAsync(reg.DeTaiId);
      if (deTai != null && deTai.TrangThai != "Chưa sử dụng")
      {
          deTai.TrangThai = "Chưa sử dụng";
          deTai.NgayCapNhat = DateTime.UtcNow;
      }
      _db.DangKyDeTais.Remove(reg);
  }
  ```

---

### 1.2. Lỗi BUG-BL-02: Số liệu Thống kê Admin bị Hardcoded
- **Nguyên nhân gốc rễ:**
  - Endpoint `GET /api/admin/dashboard/stats` trong `AdminController.cs` trả về các giá trị tĩnh:
    - Sinh viên đang hoạt động: cứng `35`.
    - Tỷ lệ hoàn thành: cứng `85.5%`.
    - Phổ điểm đánh giá: danh sách cố định không phản ánh kết quả chấm đồ án thực tế.
- **Biện pháp khắc phục trong [AdminController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/AdminController.cs):**
  - Tính toán số sinh viên hoạt động dựa trên số bản ghi `NguoiDung` có `VaiTro == "SINHVIEN"` và `TrangThai == true`.
  - Tính tỷ lệ hoàn thành đồ án dựa trên tỷ lệ các đề tài có báo cáo tiến độ đạt trạng thái hoàn tất hoặc điểm tổng kết >= 5.0.
  - Phổ điểm được nhóm động theo các khoảng điểm thực tế từ dữ liệu đánh giá của giảng viên.

---

### 1.3. Lỗi BUG-BL-03: Mất dữ liệu Cấu hình Khóa học của Giảng viên
- **Nguyên nhân gốc rễ:**
  - Màn hình `LecturerCourseSettingsScreen` cho phép giảng viên thiết lập sĩ số nhóm tối thiểu/tối đa và các mốc thời gian hạn đăng ký. Tuy nhiên khi ấn "Lưu cấu hình", màn hình chỉ đóng lại mà không lưu xuống cơ sở dữ liệu. Khi giảng viên tải lại trang, mọi cấu hình quay về mặc định.
- **Biện pháp khắc phục:**
  - Bổ sung phương thức lưu cấu hình gọi tới `PUT /api/lop-hoc-phan/{id}/cau-hinh`. Giảng viên thay đổi thông số thì database cập nhật ngay lập tức.

---

### 1.4. Lỗi BUG-BL-04: Mất trạng thái "Đã đọc" của Thông báo khi Khởi động lại Server
- **Nguyên nhân gốc rễ:**
  - `NotificationsController` sử dụng `static readonly ConcurrentDictionary<int, HashSet<int>> _userReadNotifications` để lưu trữ id thông báo mà người dùng đã đọc. Khi service ASP.NET Core khởi động lại hoặc deploy phiên bản mới, toàn bộ bộ nhớ RAM bị giải phóng, làm tất cả thông báo trở lại trạng thái "Chưa đọc".
- **Biện pháp khắc phục trong [NotificationsController.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/NotificationsController.cs):**
  - Bổ sung cơ chế lưu trữ persistent xuống bảng `ThongBaos` trong cơ sở dữ liệu.
  - Khi người dùng đánh dấu đã đọc một thông báo ảo, một bản ghi marker được ghi vào database với `LoaiLienKet = "VirtualRead"` và `LienKetId = id`.
  - Khi load thông báo, controller truy vấn hợp nhất giữa các thông báo vật lý và thông báo ảo đã persist.
