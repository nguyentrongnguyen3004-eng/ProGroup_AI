# 06. BÁO CÁO XÁC MINH TÍNH TOÀN VẸN CƠ SỞ DỮ LIỆU (DATABASE INTEGRITY VERIFICATION)
**Dự án:** ProGroup_AI  
**Cơ sở dữ liệu:** Microsoft SQL Server 2022 Express (`ProjectRegistrationDB`)  
**Phương pháp:** Kết nối ADO.NET trực tiếp, phân tích Schema, Foreign Keys, Orphans, Constraints và Transaction Locks.  

---

## 1. THỐNG KÊ DỮ LIỆU THỰC TẾ TRONG LIVE DATABASE

| Tên bảng (Table) | Số lượng bản ghi thực tế | Khóa chính (PK) | Ghi chú toàn vẹn |
|---|:---:|---|---|
| `NguoiDungs` | **264** | `NguoiDungId` | 252 Sinh viên, 6 Giảng viên, 6 Cán bộ |
| `SinhViens` | **252** | `SinhVienId` | Khóa ngoại 1-1 tới `NguoiDungs` |
| `GiangViens` | **6** | `GiangVienId` | Khóa ngoại 1-1 tới `NguoiDungs` |
| `VaiTros` | **5** | `VaiTroId` | 5 vai trò hệ thống chuẩn |
| `LopHocPhans` | **12** | `LopHocPhanId` | 12 lớp học phần đang mở |
| `SinhVienLopHocPhans` | **451** | `Id` | Phân công sinh viên vào lớp học phần |
| `NhomDoAns` | **28** | `NhomId` | 28 nhóm đang hoạt động |
| `ThanhVienNhoms` | **96** | `ThanhVienId` | Thành viên nhóm (0 orphan) |
| `DeTaiDoAns` | **52** | `DeTaiId` | 39 Chưa sử dụng, 13 Đã đăng ký |
| `DangKyDeTais` | **12** | `DangKyId` | Đăng ký đề tài (0 orphan) |
| `BaoCaoTienDos` | **6** | `BaoCaoId` | Báo cáo tiến độ |
| `ThongBaos` | **152** | `ThongBaoId` | Lưu trữ thông báo |
| `PasswordResetOtps` | **2** | `OtpId` | Lưu OTP đổi mật khẩu/email |

---

## 2. KẾT QUẢ KIỂM TRA TOÀN VẸN QUAN HỆ & RÀNG BUỘC (INTEGRITY AUDIT)

1. **Kiểm tra Bản ghi Mồ côi (Orphan Records Check):**
   - Thành viên nhóm không tồn tại nhóm (`ThanhVienNhoms` -> `NhomDoAns`): **0 bản ghi (PASS)**.
   - Đăng ký đề tài không tồn tại nhóm (`DangKyDeTais` -> `NhomDoAns`): **0 bản ghi (PASS)**.
   - Đăng ký đề tài không tồn tại đề tài (`DangKyDeTais` -> `DeTaiDoAns`): **0 bản ghi (PASS)**.
2. **Kiểm tra Trùng lặp Đăng ký Đề tài (Duplicate Topic Registration):**
   - Truy vấn các đề tài có nhiều hơn 1 bản ký ở trạng thái hoạt động: **0 bản ghi trùng lặp (PASS)**.
3. **Kiểm tra Logic Rã nhóm và Hoàn trả Trạng thái Đề tài:**
   - Trong `GroupsController.cs`, phương thức `DisbandGroup` đã thực hiện giải phóng bản ghi `DangKyDeTais` và gán lại `deTai.TrangThai = "Chưa sử dụng"`. Đề tài không còn bị treo ở trạng thái sử dụng sau khi nhóm giải tán.
4. **Kiểm tra Đồng thời (Concurrency / Race-condition Protection):**
   - Script integration test đã bắn 2 luồng đồng thời đăng ký cùng 1 đề tài:
     Cơ chế Transaction với `IsolationLevel.Serializable` đã chặn các xung đột tranh chấp, đảm bảo tính toàn vẹn ACID.
