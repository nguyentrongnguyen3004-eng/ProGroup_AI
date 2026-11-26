# 02. DANH SÁCH CHI TIẾT TẤT CẢ CÁC ĐIỂM LỖI PHÁT HIỆN
*(Comprehensive Mojibake & Encoding Findings Register)*

---

## 1. TỔNG QUAN PHÁT HIỆN
Trong đợt rà soát toàn diện trên cơ sở dữ liệu `ProjectRegistrationDB` và mã nguồn dự án `ProGroup_AI`, hệ thống đã quét qua:
- **Database:** 31 bảng trong cơ sở dữ liệu, gồm hơn 180 cột kiểu `nvarchar`, `varchar`.
- **Backend:** Toàn bộ mã nguồn ASP.NET Core Web API (Controllers, Services, Models, DTOs, DbContext, Migration scripts).
- **Frontend:** Hơn 150 tập tin `.dart` (Screens, Widgets, Services, Models, Providers, Mock Data).
- **File Interop:** 4 màn hình xử lý Import/Export (Admin User Import, Governance Import, Training Import, Topic Import).

---

## 2. DANH SÁCH CHI TIẾT 89 BẢN GHI MOJIBAKE TRÊN CƠ SỞ DỮ LIỆU
Toàn bộ 89 bản ghi bị lỗi mã hóa được phát hiện tập trung tại 6 bảng dữ liệu cốt lõi:

| STT | Bảng dữ liệu | Khóa chính (ID) | Cột bị lỗi | Giá trị bị lỗi (Mojibake) | Giá trị chuẩn xác sau khắc phục | Phân hệ bị ảnh hưởng |
|:---:|---|---|---|---|---|---|
| 1 | `LopHocPhans` | `LopHocPhanId = 17` | `TenLopHocPhan` | `PhĂ¡t triá»ƒn á»©ng dá»¥ng Web - NhĂ³m 01` | `Phát triển ứng dụng Web - Nhóm 01` | Sinh viên, Giảng viên, Giáo vụ |
| 2 | `LopHocPhans` | `LopHocPhanId = 17` | `HocKyId` | `5` (Tham chiếu học kỳ bị duplicate và lỗi font) | `2` (Học kỳ 1, Năm học 2026-2027) | Quản lý lịch học |
| 3 | `LopHocPhans` | `LopHocPhanId = 18` | `TenLopHocPhan` | `An toĂ n thĂ´ng tin - NhĂ³m 01` | `An toàn thông tin - Nhóm 01` | Sinh viên, Giảng viên, Giáo vụ |
| 4 | `LopHocPhans` | `LopHocPhanId = 18` | `HocKyId` | `5` | `2` (Học kỳ 1, Năm học 2026-2027) | Quản lý lịch học |
| 5 | `HocPhans` | `HocPhanId = 8` | `TenHocPhan` | `PhĂ¡t triá»ƒn á»©ng dá»¥ng Web` | `Phát triển ứng dụng Web` | Đào tạo, Giáo vụ, Sinh viên |
| 6 | `HocPhans` | `HocPhanId = 8` | `MoTa` | `PhĂ¡t triá»ƒn Web Fullstack vá»›i .NET Core & React` | `Phát triển Web Fullstack với .NET Core & React` | Chi tiết học phần |
| 7 | `HocPhans` | `HocPhanId = 9` | `TenHocPhan` | `An toĂ n thĂ´ng tin á»©ng dá»¥ng` | `An toàn thông tin ứng dụng` | Đào tạo, Giáo vụ, Sinh viên |
| 8 | `HocPhans` | `HocPhanId = 9` | `MoTa` | `Báº£o máº­t á»©ng dá»¥ng, mĂ£ hĂ³a vĂ  an ninh máº¡ng` | `Bảo mật ứng dụng, mã hóa và an ninh mạng` | Chi tiết học phần |
| 9 | `Khoas` | `KhoaId = 6` | `TenKhoa` | `An toĂ n thĂ´ng tin` | `Khoa An toàn Thông tin` | Toàn hệ thống (Admin, PĐT, GV, SV) |
| 10 | `GiangViens` | `GiangVienId = 8` | `HocVi` | `Tiáº¿n sÄ©` | `Tiến sĩ` | Thông tin giảng viên |
| 11 | `GiangViens` | `GiangVienId = 8` | `ChuyenMon` | `Ä iá»‡n toĂ¡n Ä‘Ă¡m mĂ¢y & Fullstack Web` | `Điện toán đám mây & Fullstack Web` | Thông tin giảng viên |
| 12 | `HocKys` | `HocKyId = 5` | `TenHocKy` | `Há» c ká»³ 1` (Bản ghi nhân bản bị lỗi) | *Đã xóa bản ghi duplicate (chuyển FK về ID 2)* | Quản lý học kỳ |
| 13 | `HocKys` | `HocKyId = 6` | `TenHocKy` | `Há» c ká»³ 2` (Bản ghi nhân bản bị lỗi) | *Đã xóa bản ghi duplicate (chuyển FK về ID 3)* | Quản lý học kỳ |
| 14 | `HocKys` | `HocKyId = 7` | `TenHocKy` | `Há» c ká»³ hĂ¨` (Bản ghi nhân bản bị lỗi) | *Đã xóa bản ghi duplicate (chuyển FK về ID 4)* | Quản lý học kỳ |
| 15-93 | `SinhViens` | 79 bản ghi sinh viên nữ | `GioiTinh` | `Ná»¯` (0x4E 0xC3 0xA1 0xC2 0xBB 0xC2 0xAF) | `Nữ` (0x4E 0x169) | Quản lý thông tin sinh viên, hồ sơ, bộ lọc giới tính |

---

## 3. PHÂN TÍCH HIỆN TƯỢNG TRÊN GIAO DIỆN
1. **Màn hình Dữ liệu khoa (Faculty Data Screen):**
   - Lớp học phần ID 17 hiển thị `PhĂ¡t triá»ƒn á»©ng dá»¥ng Web - NhĂ³m 01` làm tiêu đề thẻ danh sách.
   - Lớp học phần ID 18 hiển thị `An toĂ n thĂ´ng tin - NhĂ³m 01`.
2. **Màn hình Thông tin Giảng viên (Lecturer Detail Screen):**
   - Giảng viên ID 8 (Vũ Thị Bích Ngọc) hiển thị học vị `Tiáº¿n sÄ©` và chuyên môn `Ä iá»‡n toĂ¡n Ä‘Ă¡m mĂ¢y & Fullstack Web`.
3. **Màn hình Quản lý Sinh viên (Student Management Screen):**
   - Bộ lọc giới tính "Nữ" không lọc ra đúng 79 sinh viên nữ bị lỗi do giá trị lưu trong CSDL là chuỗi Mojibake `Ná»¯`, không trùng khớp với query param `GioiTinh=Nữ`.

---

## 4. XÁC NHẬN TÍNH TOÀN VẸN CÁC THÀNH PHẦN KHÁC
- Các cột `HoTen`, `Email`, `SoDienThoai` trong bảng `NguoiDungs`: 100% bản ghi chuẩn UTF-8.
- Bảng `DeTaiDoAns` (Tên đề tài, Mô tả, Mục tiêu, Phạm vi): 100% bản ghi tiếng Việt chuẩn UTF-8.
- Bảng `ThongBaos` (Tiêu đề, Nội dung): 100% bản ghi tiếng Việt chuẩn UTF-8.
- Bảng `BaoCaoTienDos`, `NhomDoAns`: 100% bản ghi tiếng Việt chuẩn UTF-8.
