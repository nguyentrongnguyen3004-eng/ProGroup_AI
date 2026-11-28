# 05. BÁO CÁO LỖI LOGIC NGHIỆP VỤ & QUY TRÌNH HỆ THỐNG (BUSINESS LOGIC AUDIT)

## 1. TỔNG QUAN
Qua quá trình phân tích luồng dữ liệu (Data Flow) và logic xử lý nghiệp vụ trên cả Frontend và Backend, chúng tôi ghi nhận nhiều lỗ hổng logic nghiêm trọng ảnh hưởng trực tiếp đến tính toàn vẹn của quy trình đào tạo và đăng ký đề tài.

---

## 2. CHI TIẾT CÁC LỖI LOGIC NGHIỆP VỤ NGHIÊM TRỌNG

### 2.1. Lỗi Mất Dữ Liệu Khi Giảng Viên Cấu Hình Lớp Học Phần
- **Vị trí:** `screens/lecturer/course/lecturer_course_detail_screen.dart:708-718` kết hợp với `LecturerCourseSettingsScreen`.
- **Hiện tượng:** Giảng viên điều chỉnh số lượng sinh viên tối đa/nhóm, số nhóm tối đa của lớp, quy định đề tài và thời hạn. Khi nhấn "Lưu cấu hình", màn hình chỉ đóng lại và trả về một instance `CourseModel` mới cho màn hình cha cập nhật `setState`.
- **Lỗi logic:** Không có bất kỳ dòng code nào gửi HTTP request lên Backend! Backend cũng chưa hề có endpoint cập nhật cấu hình lớp (`PUT /api/lop-hoc-phan/{id}/cau-hinh`).
- **Hậu quả:** Khi giảng viên kéo vuốt để reload hoặc thoát màn hình quay lại, toàn bộ cấu hình vừa thiết lập bị ghi đè lại bởi dữ liệu cũ từ server. Sinh viên trong lớp vẫn đăng ký theo quy chế cũ.

---

### 2.2. Lỗi Không Giải Phóng Trạng Thái Đề Tài Khi Nhóm Bị Giải Tán (Orphan Locked Topic)
- **Vị trí:** `Controllers/GroupsController.cs`, phương thức `DisbandGroup(int id)`.
- **Hiện tượng:** Khi Trưởng nhóm hoặc Giảng viên thực hiện giải tán nhóm (`DisbandGroup`):
  - Backend cập nhật trạng thái nhóm thành `DaGiaiTan` và xóa danh sách thành viên trong `ThanhVienNhom`.
  - **TUY NHIÊN:** Hệ thống KHÔNG kiểm tra xem nhóm này đã được duyệt đề tài trong bảng `DangKyDeTai` hay chưa!
- **Hậu quả:**
  - Bản ghi `DangKyDeTai` của nhóm vẫn giữ trạng thái `DaDuyet`.
  - Bản ghi `DeTai` tương ứng vẫn giữ trạng thái `DaDangKy` hoặc `Khoa`.
  - Đề tài này bị "treo" vĩnh viễn trong CSDL, không nhóm nào khác có thể đăng ký được, gây thất thoát tài nguyên đề tài của giảng viên.

---

### 2.3. Lỗi Bỏ Qua Kiểm Tra Đợt Đăng Ký (Registration Window Bypass)
- **Vị trí:** `Controllers/ProjectsController.cs:64-90` so với `DangKyDeTaiController.cs:40-80`.
- **Hiện tượng:** Hệ thống tồn tại song song 2 Controller cho phép đăng ký đề tài: `ProjectsController` và `DangKyDeTaiController`.
  - Trong khi `DangKyDeTaiController` có kiểm tra thời gian hiệu lực của `DotDangKy` (`TuNgay <= now <= DenNgay`), thì endpoint `POST /api/projects/dang-ky` trong `ProjectsController` lại **bỏ qua hoàn toàn bước kiểm tra đợt đăng ký**.
- **Hậu quả:** Bất kỳ sinh viên nào biết gọi trực tiếp endpoint `/api/projects/dang-ky` qua Postman/cURL đều có thể đăng ký đề tài trước hoặc sau thời hạn quy định của Nhà trường.

---

### 2.4. Rủi Ro Điểm Báo Cáo Tiến Độ Vượt Ngưỡng (Out-of-Range Grading)
- **Vị trí:** `Controllers/BaoCaoTienDoController.cs:115-135`, phương thức `GradeReport`.
- **Lỗi logic:** Thiếu validation chặt chẽ phạm vi điểm số trên tầng Model Validation:
  ```csharp
  public class GradeReportRequest {
      public decimal Diem { get; set; } // Thiếu [Range(0.0, 10.0)]
      public string? NhanXet { get; set; }
  }
  ```
- **Hậu quả:** Giảng viên có thể vô tình nhập điểm `-5` hoặc `15.0`, CSDL SQL Server vẫn chấp nhận lưu vì cột `Diem` kiểu `DECIMAL(4,2)` cho phép lưu đến `99.99`.

---

### 2.5. Không Ràng Buộc Một Sinh Viên Trong Nhiều Nhóm Của Cùng Một Học Phần
- **Vị trí:** `Controllers/GroupsController.cs`, phương thức `AddMember` và `RespondJoinRequest`.
- **Lỗi logic:** Khi duyệt sinh viên vào nhóm mới, hệ thống chỉ kiểm tra sinh viên có trong nhóm hiện tại không (`ThanhVienNhom.Any(m => m.NhomId == id && m.SinhVienId == studentId)`). Nếu sinh viên gửi nhiều yêu cầu vào các nhóm khác nhau trong cùng một Lớp học phần và các trưởng nhóm cùng duyệt, sinh viên đó sẽ tồn tại đồng thời trong 2 nhóm khác nhau của cùng 1 lớp!
