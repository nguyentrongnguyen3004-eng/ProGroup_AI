# 08. BÁO CÁO TOÀN VẸN DỮ LIỆU & CƠ SỞ DỮ LIỆU (DATA INTEGRITY AUDIT)

## 1. TỔNG QUAN
Cơ sở dữ liệu của dự án sử dụng Microsoft SQL Server 2022 (`ProjectRegistrationDB`), quản lý thông qua Entity Framework Core 9/10 với 26 bảng dữ liệu. Báo cáo này đi sâu vào các vấn đề mất dữ liệu, bất toàn vẹn khóa ngoại và rủi ro tranh chấp dữ liệu (Race Condition).

---

## 2. CÁC NGUY CƠ BẤT TOÀN VẸN DỮ LIỆU NGHIÊM TRỌNG

### 2.1. Mất Dữ Liệu Trạng Thái Thông Báo Do Lưu Bằng Bộ Nhớ RAM
- **Vị trí:** `Controllers/NotificationsController.cs`, dòng 16:
  ```csharp
  private static readonly ConcurrentDictionary<int, HashSet<int>> _userReadNotifications = new();
  ```
- **Hiện tượng:** Đối với các thông báo hệ thống tự động sinh ra có ID >= 100,000, trạng thái "Đã đọc" của người dùng không được lưu vào bảng `ThongBao` trong CSDL mà lưu vào biến `static ConcurrentDictionary` trong bộ nhớ RAM của tiến trình ASP.NET Core!
- **Hậu quả:**
  1. Bất cứ khi nào máy chủ API được khởi động lại (Deploy, Crash, Restart IIS/Kestrel), toàn bộ trạng thái đã đọc của hàng nghìn người dùng biến mất. Mọi người dùng mở app lên sẽ bị báo hàng loạt thông báo cũ chưa đọc.
  2. Khi triển khai hệ thống trên cụm máy chủ chịu tải (Load Balancer / Multi-instance), các request của cùng 1 user đến các instance khác nhau sẽ không đồng bộ trạng thái đọc.

---

### 2.2. Tranh Chấp Dữ Liệu Khi Đăng Ký Đề Tài (Race Condition)
- **Vị trí:** `DangKyDeTaiController.cs`, phương thức `RegisterTopic`.
- **Hiện tượng:**
  ```csharp
  var count = await _context.DangKyDeTais.CountAsync(d => d.DeTaiId == request.DeTaiId && d.TrangThai == "DaDuyet");
  if (count >= topic.SoNhomToiDa) return BadRequest("Đề tài đã đủ số lượng nhóm.");
  
  // Tạo bản ghi mới và lưu
  _context.DangKyDeTais.Add(newRegistration);
  await _context.SaveChangesAsync();
  ```
- **Lỗ hổng:** Không sử dụng Database Transaction ở mức `IsolationLevel.Serializable` và bảng `DeTai` **không có cột `RowVersion / [Timestamp]`** để kiểm soát Concurrency.
- **Kịch bản lỗi:** Nếu một đề tài chỉ còn đúng 1 slot trống và có 2 nhóm sinh viên cùng nhấn nút "Đăng ký" tại cùng một phần nghìn giây:
  1. Cả 2 luồng đều đọc được `count = 0` (hợp lệ).
  2. Cả 2 luồng đều thực hiện `Add()` và `SaveChangesAsync()`.
  3. Kết quả: Đề tài bị đăng ký vượt quá số nhóm tối đa cho phép!

---

### 2.3. Bất Toàn Vẹn Khóa Ngoại Khi Xóa / Giải Tán Nhóm
- **Bảng liên quan:** `Nhom`, `DangKyDeTai`, `ThanhVienNhom`, `BaoCaoTienDo`.
- **Rủi ro:** Khi xóa một `Nhom` hoặc `LopHocPhan`, nếu không cấu hình ràng buộc xóa cascade (`ON DELETE CASCADE`) hoặc xử lý xóa mềm (`IsDeleted`), các bản ghi con trong `BaoCaoTienDo` và `DangKyDeTai` sẽ bị mồ côi (Orphan Records), dẫn đến lỗi Foreign Key Exception khi thực thi truy vấn `Include()` trong EF Core.
