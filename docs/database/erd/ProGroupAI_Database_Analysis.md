# BÁO CÁO PHÂN TÍCH TOÀN DIỆN CƠ SỞ DỮ LIỆU PROGROUP AI

**Dự án:** ProGroup AI – Ứng dụng hỗ trợ đăng ký nhóm và đồ án môn học
**Hệ quản trị CSDL:** Microsoft SQL Server (`LAPTOP-3RHN15E2\SQLEXPRESS`)
**Tên Cơ sở dữ liệu:** `ProjectRegistrationDB`
**Thời điểm trích xuất metadata:** `2026-11-27 12:22:16`
**Tổng số bảng nghiệp vụ:** `21 bảng` (Tổng số bảng vật lý: `23 bảng`)
**Tổng số khóa chính (Primary Keys):** `21`
**Tổng số khóa ngoại (Foreign Keys):** `30`
**Tổng số ràng buộc kiểm tra (Check Constraints):** `22`

---

## 1. PHÂN BỐ CÁC NHÓM CHỨC NĂNG NGHIỆP VỤ

Toàn bộ 21 bảng nghiệp vụ của hệ thống ProGroup AI được phân bổ thành 3 phân hệ cốt lõi:

### 1.1. Module 1: Người dùng, Phân quyền & Quản trị Hệ thống (7 bảng)
Quản lý toàn bộ vòng đời tài khoản người dùng, phân quyền truy cập theo vai trò (Role-Based Access Control), cơ chế bảo mật OTP, hàng đợi thông báo sự kiện, nhật ký tương tác AI và quy trình import dữ liệu hàng loạt:
- `VaiTros`: Danh mục 5 vai trò hệ thống (`ADMIN`, `GIAOVUKHOA`, `PHONGDAOTAO`, `GIANGVIEN`, `SINHVIEN`).
- `NguoiDungs`: Bảng trung tâm lưu trữ danh tính người dùng, mật khẩu hash bảo mật, email, số điện thoại, trạng thái.
- `PasswordResetOtps`: Quản lý mã OTP khôi phục mật khẩu có giới hạn thời gian và số lần nhập sai.
- `ThongBaos`: Hệ thống thông báo đẩy, phân loại theo mục đích và liên kết polymorphic tới thực thể nghiệp vụ.
- `AIRequests`: Lưu trữ lịch sử prompt, response và trạng thái của các yêu cầu AI (Gemini Assistant).
- `DotImports`: Quản lý các đợt nhập liệu cán bộ từ file Excel/CSV.
- `LoiImports`: Chi tiết từng dòng dữ liệu bị lỗi trong các đợt import để hỗ trợ kiểm tra và đối soát.

### 1.2. Module 2: Quản lý Đào tạo, Khoa & Lớp Học phần (8 bảng)
Quản lý cây dữ liệu học thuật của nhà trường từ cấp Khoa/Viện, Học kỳ, Học phần đến từng Lớp học phần cụ thể, đồng thời lưu trữ hồ sơ độc quyền của Sinh viên, Giảng viên và danh sách phân công/ghi danh:
- `Khoas`: Danh mục khoa đào tạo (Khoa CNTT, KTPM, HTTT,...).
- `HocKys`: Danh mục học kỳ và năm học đào tạo (HK1, HK2, HK Hè).
- `HocPhans`: Môn học/học phần đồ án chuyên ngành có số tín chỉ.
- `LopHocPhans`: Lớp học phần được mở trong từng học kỳ theo khoa.
- `SinhViens`: Hồ sơ chi tiết sinh viên (MSSV, ngày sinh), liên kết 1:1 duy nhất với tài khoản `NguoiDungs`.
- `GiangViens`: Hồ sơ chi tiết giảng viên (Mã GV, học vị, chuyên môn), liên kết 1:1 duy nhất với `NguoiDungs`.
- `PhanCongGiangViens`: Phân công giảng viên phụ trách giảng dạy từng lớp học phần (N:N).
- `SinhVienLopHocPhans`: Danh sách sinh viên theo học từng lớp học phần (N:N).

### 1.3. Module 3: Quản lý Đợt Đăng ký, Nhóm, Đề tài & Tiến độ (6 bảng)
Là phân hệ nghiệp vụ trung tâm của ứng dụng ProGroup AI, quản lý quy trình sinh viên tự lập nhóm đồ án, đề xuất hoặc chọn đề tài, giảng viên xét duyệt và theo dõi tiến độ nộp bài:
- `DotDangKyDoAns`: Đợt mở đăng ký nhóm và đề tài theo từng lớp học phần (giới hạn thời gian và quy mô thành viên).
- `NhomDoAns`: Nhóm sinh viên thực hiện đồ án, có trưởng nhóm và trạng thái nhóm.
- `ThanhVienNhoms`: Danh sách các thành viên trong nhóm đồ án và vai trò (Trưởng nhóm, Thành viên).
- `DeTaiDoAns`: Ngân hàng đề tài đồ án (do Giảng viên công bố hoặc do Sinh viên đề xuất).
- `DangKyDeTais`: Bản ghi đăng ký đề tài của từng nhóm và trạng thái phê duyệt của giảng viên.
- `BaoCaoTienDos`: Báo cáo tiến độ đồ án theo tuần/giai đoạn của nhóm, kèm link mã nguồn, demo, nhận xét và điểm số.

---

## 2. CHI TIẾT CẤU TRÚC TỪNG BẢNG NGHIỆP VỤ (21 BẢNG)

### 2.1. Bảng `AIRequests`
- **Phân hệ:** Module 1: Người dùng & Phân quyền
- **Số lượng bản ghi hiện tại:** `4` dòng
- **Khóa chính (PK):** `AIRequestId`
- **Mô tả chức năng:** Lịch sử tương tác và gọi API AI (Gemini) hỗ trợ gợi ý đề tài, sửa lỗi và xử lý dữ liệu

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `AIRequestId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính bản ghi yêu cầu AI |
| 2 | `NguoiDungId` | `int(10)` | **NOT NULL** | **FK** -> `NguoiDungs` | - | Khóa ngoại tham chiếu NguoiDungs.NguoiDungId |
| 3 | `ChucNangAI` | `nvarchar(100)` | **NOT NULL** |  | - | Tên tính năng AI sử dụng (Gợi ý đề tài, Phân tích nhóm, ...) |
| 4 | `Prompt` | `nvarchar(max)` | **NOT NULL** |  | - | Câu lệnh/nội dung gửi lên AI |
| 5 | `Response` | `nvarchar(max)` | NULL |  | - | Nội dung phản hồi từ mô hình AI |
| 6 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Thành công')` | Trạng thái xử lý (Đang xử lý, Thành công, Thất bại) |
| 7 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm gọi AI |

### 2.2. Bảng `BaoCaoTienDos`
- **Phân hệ:** Module 3: Đăng ký Nhóm & Đề tài
- **Số lượng bản ghi hiện tại:** `6` dòng
- **Khóa chính (PK):** `BaoCaoId`
- **Mô tả chức năng:** Lưu báo cáo tiến độ định kỳ của nhóm đồ án, file tài liệu, link demo, nhận xét và điểm số của giảng viên

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `BaoCaoId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính báo cáo tiến độ |
| 2 | `NhomId` | `int(10)` | **NOT NULL** | **FK** -> `NhomDoAns` | - | Khóa ngoại tham chiếu NhomDoAns.NhomId |
| 3 | `DeTaiId` | `int(10)` | NULL |  | - | Mã đề tài liên kết (Logical FK tham chiếu DeTaiDoAns.DeTaiId) |
| 4 | `TieuDe` | `nvarchar(200)` | **NOT NULL** |  | - | Tiêu đề đợt báo cáo tiến độ |
| 5 | `NoiDung` | `nvarchar(max)` | NULL |  | - | Nội dung tóm tắt kết quả hoàn thành |
| 6 | `FileUrl` | `nvarchar(500)` | NULL |  | - | Đường dẫn file tài liệu/báo cáo |
| 7 | `GithubUrl` | `nvarchar(500)` | NULL |  | - | Đường dẫn repository mã nguồn GitHub |
| 8 | `DemoUrl` | `nvarchar(500)` | NULL |  | - | Đường dẫn video/link demo ứng dụng |
| 9 | `TuanBaoCao` | `int(10)` | **NOT NULL** |  | `((1))` | Số thứ tự tuần báo cáo |
| 10 | `NgayNop` | `datetime2` | **NOT NULL** |  | `(getutcdate())` | Thời điểm sinh viên nộp báo cáo |
| 11 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Đã nộp')` | Trạng thái nộp (Đã nộp, Chờ chấm, Đã chấm) |
| 12 | `NhanXetGiangVien` | `nvarchar(max)` | NULL |  | - | Nhận xét, đánh giá của giảng viên hướng dẫn |
| 13 | `Diem` | `decimal(4,2)` | NULL |  | - | Điểm đánh giá tiến độ (thang điểm 10.0) |
| 14 | `GiangVienId` | `int(10)` | NULL |  | - | Mã giảng viên chấm (Logical FK tham chiếu GiangViens.GiangVienId) |
| 15 | `NgayNhanXet` | `datetime2` | NULL |  | - | Thời điểm giảng viên chấm điểm & nhận xét |

### 2.3. Bảng `DangKyDeTais`
- **Phân hệ:** Module 3: Đăng ký Nhóm & Đề tài
- **Số lượng bản ghi hiện tại:** `13` dòng
- **Khóa chính (PK):** `DangKyDeTaiId`
- **Mô tả chức năng:** Bản ghi nguyện vọng đăng ký đề tài của từng nhóm đồ án và kết quả phê duyệt của giảng viên

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `DangKyDeTaiId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính đăng ký đề tài |
| 2 | `NhomId` | `int(10)` | **NOT NULL** | **FK** -> `NhomDoAns` | - | Khóa ngoại tham chiếu NhomDoAns.NhomId |
| 3 | `DeTaiId` | `int(10)` | **NOT NULL** | **FK** -> `DeTaiDoAns` | - | Khóa ngoại tham chiếu DeTaiDoAns.DeTaiId |
| 4 | `NgayDangKy` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm nhóm gửi đăng ký |
| 5 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Chờ duyệt')` | Trạng thái đăng ký (Chờ duyệt, Đã duyệt, Từ chối, Đã hủy) |
| 6 | `GhiChu` | `nvarchar(1000)` | NULL |  | - | Ghi chú bổ sung của nhóm |
| 7 | `NgayDuyet` | `datetime2` | NULL |  | - | Thời điểm giảng viên phê duyệt/từ chối |
| 8 | `GiangVienDuyetId` | `int(10)` | NULL | **FK** -> `GiangViens` | - | Khóa ngoại tham chiếu GiangViens.GiangVienId người duyệt |

### 2.4. Bảng `DeTaiDoAns`
- **Phân hệ:** Module 3: Đăng ký Nhóm & Đề tài
- **Số lượng bản ghi hiện tại:** `53` dòng
- **Khóa chính (PK):** `DeTaiId`
- **Mô tả chức năng:** Kho lưu trữ đề tài đồ án môn học (do giảng viên khởi tạo hoặc sinh viên đề xuất)

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `DeTaiId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính đề tài đồ án |
| 2 | `DotDangKyId` | `int(10)` | **NOT NULL** | **FK** -> `DotDangKyDoAns` | - | Khóa ngoại tham chiếu DotDangKyDoAns.DotDangKyId |
| 3 | `TenDeTai` | `nvarchar(500)` | **NOT NULL** |  | - | Tên đề tài đồ án |
| 4 | `MoTa` | `nvarchar(max)` | NULL |  | - | Mô tả chi tiết nội dung đề tài |
| 5 | `MucTieu` | `nvarchar(max)` | NULL |  | - | Mục tiêu cần đạt của đề tài |
| 6 | `PhamVi` | `nvarchar(max)` | NULL |  | - | Phạm vi nghiên cứu & sản phẩm |
| 7 | `CongNgheDuKien` | `nvarchar(1000)` | NULL |  | - | Các công nghệ/ngôn ngữ/framework dự kiến áp dụng |
| 8 | `NguonDeTai` | `nvarchar(50)` | **NOT NULL** |  | - | Nguồn gốc đề tài (Giảng viên, Sinh viên đề xuất) |
| 9 | `GiangVienId` | `int(10)` | NULL | **FK** -> `GiangViens` | - | Khóa ngoại (nullable) tham chiếu GiangViens.GiangVienId phụ trách |
| 10 | `SinhVienDeXuatId` | `int(10)` | NULL | **FK** -> `SinhViens` | - | Khóa ngoại (nullable) tham chiếu SinhViens.SinhVienId người đề xuất |
| 11 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Chưa sử dụng')` | Trạng thái sử dụng (Chưa sử dụng, Đang hoạt động, Đã khóa, Đã đăng ký) |
| 12 | `TrangThaiDuyet` | `nvarchar(50)` | **NOT NULL** |  | `(N'Chờ duyệt')` | Trạng thái phê duyệt (Chờ duyệt, Đã duyệt, Từ chối) |
| 13 | `LyDoTuChoi` | `nvarchar(1000)` | NULL |  | - | Lý do từ chối nếu không được duyệt |
| 14 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo đề tài |
| 15 | `UpdatedAt` | `datetime2` | NULL |  | - | Thời điểm cập nhật |

### 2.5. Bảng `DotDangKyDoAns`
- **Phân hệ:** Module 3: Đăng ký Nhóm & Đề tài
- **Số lượng bản ghi hiện tại:** `16` dòng
- **Khóa chính (PK):** `DotDangKyId`
- **Mô tả chức năng:** Quản lý các đợt mở đăng ký nhóm và đề tài đồ án theo từng lớp học phần

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `DotDangKyId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính đợt đăng ký đồ án |
| 2 | `LopHocPhanId` | `int(10)` | **NOT NULL** | **FK** -> `LopHocPhans` | - | Khóa ngoại tham chiếu LopHocPhans.LopHocPhanId |
| 3 | `TenDot` | `nvarchar(200)` | **NOT NULL** |  | - | Tên đợt đăng ký |
| 4 | `NgayBatDau` | `datetime2` | **NOT NULL** |  | - | Thời điểm mở đợt đăng ký |
| 5 | `NgayKetThuc` | `datetime2` | **NOT NULL** |  | - | Thời điểm đóng đợt đăng ký |
| 6 | `MinMembers` | `int(10)` | **NOT NULL** |  | - | Số thành viên tối thiểu mỗi nhóm |
| 7 | `MaxMembers` | `int(10)` | **NOT NULL** |  | - | Số thành viên tối đa mỗi nhóm |
| 8 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Chưa mở')` | Trạng thái đợt (Chưa mở, Đang mở, Đã đóng) |
| 9 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo đợt |

### 2.6. Bảng `DotImports`
- **Phân hệ:** Module 1: Người dùng & Phân quyền
- **Số lượng bản ghi hiện tại:** `4` dòng
- **Khóa chính (PK):** `DotImportId`
- **Mô tả chức năng:** Quản lý các đợt import dữ liệu danh sách sinh viên, giảng viên, lớp học phần từ Excel/CSV

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `DotImportId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính đợt import |
| 2 | `LoaiDuLieu` | `nvarchar(100)` | **NOT NULL** |  | - | Loại thực thể import (SinhVien, GiangVien, LopHocPhan) |
| 3 | `TenFile` | `nvarchar(500)` | **NOT NULL** |  | - | Tên file tài liệu gốc tải lên |
| 4 | `NguoiImportId` | `int(10)` | **NOT NULL** | **FK** -> `NguoiDungs` | - | Khóa ngoại tham chiếu NguoiDungs.NguoiDungId người thực hiện |
| 5 | `TongSoDong` | `int(10)` | **NOT NULL** |  | `((0))` | Tổng số dòng dữ liệu trong file |
| 6 | `SoDongThanhCong` | `int(10)` | **NOT NULL** |  | `((0))` | Số dòng xử lý thành công |
| 7 | `SoDongLoi` | `int(10)` | **NOT NULL** |  | `((0))` | Số dòng dữ liệu lỗi bị bỏ qua |
| 8 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Đang xử lý')` | Trạng thái tiến trình import |
| 9 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm thực hiện |

### 2.7. Bảng `GiangViens`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `6` dòng
- **Khóa chính (PK):** `GiangVienId`
- **Mô tả chức năng:** Hồ sơ chi tiết của giảng viên (Mã GV, học vị, chuyên môn, khoa), liên kết 1:1 với NguoiDungs

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `GiangVienId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính hồ sơ giảng viên |
| 2 | `NguoiDungId` | `int(10)` | **NOT NULL** | **FK** -> `NguoiDungs` | - | Khóa ngoại (1:1 Unique) tham chiếu NguoiDungs.NguoiDungId |
| 3 | `MaGiangVien` | `varchar(30)` | **NOT NULL** |  | - | Mã giảng viên duy nhất (VD: GV001) |
| 4 | `KhoaId` | `int(10)` | **NOT NULL** | **FK** -> `Khoas` | - | Khóa ngoại tham chiếu Khoas.KhoaId |
| 5 | `HocVi` | `nvarchar(100)` | NULL |  | - | Học vị học hàm (ThS, TS, PGS, GS) |
| 6 | `ChuyenMon` | `nvarchar(200)` | NULL |  | - | Lĩnh vực chuyên môn nghiên cứu |
| 7 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo hồ sơ |

### 2.8. Bảng `HocKys`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `3` dòng
- **Khóa chính (PK):** `HocKyId`
- **Mô tả chức năng:** Danh mục học kỳ và năm học đào tạo (VD: Học kỳ 1 2026-2027)

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `HocKyId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính học kỳ |
| 2 | `TenHocKy` | `nvarchar(100)` | **NOT NULL** |  | - | Tên học kỳ (Học kỳ 1, 2, hè) |
| 3 | `NamHoc` | `varchar(20)` | **NOT NULL** |  | - | Năm học (VD: 2026-2027) |
| 4 | `NgayBatDau` | `date` | **NOT NULL** |  | - | Ngày bắt đầu học kỳ |
| 5 | `NgayKetThuc` | `date` | **NOT NULL** |  | - | Ngày kết thúc học kỳ |
| 6 | `TrangThai` | `bit` | **NOT NULL** |  | `((1))` | Trạng thái học kỳ (1: Đang mở) |
| 7 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo |

### 2.9. Bảng `HocPhans`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `8` dòng
- **Khóa chính (PK):** `HocPhanId`
- **Mô tả chức năng:** Danh mục môn học/học phần đồ án chuyên ngành

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `HocPhanId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính học phần |
| 2 | `MaHocPhan` | `varchar(30)` | **NOT NULL** |  | - | Mã học phần duy nhất (VD: IT001) |
| 3 | `TenHocPhan` | `nvarchar(300)` | **NOT NULL** |  | - | Tên học phần đồ án |
| 4 | `SoTinChi` | `int(10)` | **NOT NULL** |  | - | Số tín chỉ học phần |
| 5 | `KhoaId` | `int(10)` | NULL | **FK** -> `Khoas` | - | Khóa ngoại tham chiếu Khoas.KhoaId |
| 6 | `MoTa` | `nvarchar(1000)` | NULL |  | - | Mô tả đề cương tóm tắt |
| 7 | `TrangThai` | `bit` | **NOT NULL** |  | `((1))` | Trạng thái học phần |
| 8 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo |

### 2.10. Bảng `Khoas`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `5` dòng
- **Khóa chính (PK):** `KhoaId`
- **Mô tả chức năng:** Danh mục khoa/viện đào tạo trong trường đại học (VD: Khoa CNTT, KTPM, HTTT)

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `KhoaId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính đơn vị khoa |
| 2 | `MaKhoa` | `varchar(20)` | **NOT NULL** |  | - | Mã khoa duy nhất (VD: CNTT, HTTT) |
| 3 | `TenKhoa` | `nvarchar(200)` | **NOT NULL** |  | - | Tên khoa đầy đủ |
| 4 | `TrangThai` | `bit` | **NOT NULL** |  | `((1))` | Trạng thái hoạt động của khoa |
| 5 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo |

### 2.11. Bảng `LoiImports`
- **Phân hệ:** Module 1: Người dùng & Phân quyền
- **Số lượng bản ghi hiện tại:** `2` dòng
- **Khóa chính (PK):** `LoiImportId`
- **Mô tả chức năng:** Lưu chi tiết các dòng dữ liệu bị lỗi trong từng đợt import để phục vụ đối soát

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `LoiImportId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính chi tiết lỗi |
| 2 | `DotImportId` | `int(10)` | **NOT NULL** | **FK** -> `DotImports` | - | Khóa ngoại tham chiếu DotImports.DotImportId |
| 3 | `SoDong` | `int(10)` | **NOT NULL** |  | - | Số thứ tự dòng bị lỗi trong file |
| 4 | `TenCot` | `nvarchar(200)` | NULL |  | - | Tên cột dữ liệu không hợp lệ |
| 5 | `NoiDungLoi` | `nvarchar(1000)` | **NOT NULL** |  | - | Thông điệp chi tiết nguyên nhân lỗi |
| 6 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm ghi nhận |

### 2.12. Bảng `LopHocPhans`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `13` dòng
- **Khóa chính (PK):** `LopHocPhanId`
- **Mô tả chức năng:** Danh sách các lớp học phần được mở trong từng học kỳ theo khoa

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `LopHocPhanId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính lớp học phần |
| 2 | `MaLopHocPhan` | `varchar(50)` | **NOT NULL** |  | - | Mã lớp học phần (VD: LTDD-01) |
| 3 | `TenLopHocPhan` | `nvarchar(300)` | NULL |  | - | Tên lớp học phần |
| 4 | `HocPhanId` | `int(10)` | **NOT NULL** | **FK** -> `HocPhans` | - | Khóa ngoại tham chiếu HocPhans.HocPhanId |
| 5 | `HocKyId` | `int(10)` | **NOT NULL** | **FK** -> `HocKys` | - | Khóa ngoại tham chiếu HocKys.HocKyId |
| 6 | `KhoaId` | `int(10)` | **NOT NULL** | **FK** -> `Khoas` | - | Khóa ngoại tham chiếu Khoas.KhoaId |
| 7 | `SoLuongToiDa` | `int(10)` | NULL |  | - | Số lượng sinh viên tối đa |
| 8 | `TrangThai` | `bit` | **NOT NULL** |  | `((1))` | Trạng thái mở lớp (1: Hoạt động) |
| 9 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo |

### 2.13. Bảng `NguoiDungs`
- **Phân hệ:** Module 1: Người dùng & Phân quyền
- **Số lượng bản ghi hiện tại:** `265` dòng
- **Khóa chính (PK):** `NguoiDungId`
- **Mô tả chức năng:** Bảng tài khoản người dùng trung tâm, lưu thông tin định danh, mật khẩu hash, email, trạng thái

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `NguoiDungId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính, định danh tài khoản |
| 2 | `TenDangNhap` | `varchar(100)` | **NOT NULL** |  | - | Tên đăng nhập duy nhất |
| 3 | `MatKhauHash` | `nvarchar(500)` | **NOT NULL** |  | - | Chuỗi băm mật khẩu bảo mật (BCrypt/Argon2/HMAC) |
| 4 | `Email` | `varchar(150)` | **NOT NULL** |  | - | Địa chỉ email duy nhất của người dùng |
| 5 | `HoTen` | `nvarchar(200)` | **NOT NULL** |  | - | Họ và tên đầy đủ của người dùng |
| 6 | `SoDienThoai` | `varchar(20)` | NULL |  | - | Số điện thoại liên lạc |
| 7 | `AvatarUrl` | `nvarchar(500)` | NULL |  | - | Đường dẫn ảnh đại diện (Cloudflare R2) |
| 8 | `VaiTroId` | `int(10)` | **NOT NULL** | **FK** -> `VaiTros` | - | Khóa ngoại tham chiếu VaiTros.VaiTroId |
| 9 | `TrangThai` | `bit` | **NOT NULL** |  | `((1))` | Trạng thái kích hoạt tài khoản (1: Hoạt động, 0: Khóa) |
| 10 | `YeuCauDoiMatKhau` | `bit` | **NOT NULL** |  | `((0))` | Cờ bắt buộc đổi mật khẩu ở lần đăng nhập đầu |
| 11 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo tài khoản |
| 12 | `UpdatedAt` | `datetime2` | NULL |  | - | Thời điểm cập nhật thông tin lần cuối |

### 2.14. Bảng `NhomDoAns`
- **Phân hệ:** Module 3: Đăng ký Nhóm & Đề tài
- **Số lượng bản ghi hiện tại:** `29` dòng
- **Khóa chính (PK):** `NhomId`
- **Mô tả chức năng:** Thông tin nhóm sinh viên thực hiện đồ án, số lượng thành viên và trưởng nhóm

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `NhomId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính nhóm đồ án |
| 2 | `DotDangKyId` | `int(10)` | **NOT NULL** | **FK** -> `DotDangKyDoAns` | - | Khóa ngoại tham chiếu DotDangKyDoAns.DotDangKyId |
| 3 | `TenNhom` | `nvarchar(200)` | **NOT NULL** |  | - | Tên nhóm đồ án |
| 4 | `TruongNhomId` | `int(10)` | **NOT NULL** | **FK** -> `SinhViens` | - | Khóa ngoại tham chiếu SinhViens.SinhVienId (Trưởng nhóm) |
| 5 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Đang hoạt động')` | Trạng thái nhóm (Đang hoạt động, Đã khóa, Đã hủy) |
| 6 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo nhóm |
| 7 | `UpdatedAt` | `datetime2` | NULL |  | - |  |

### 2.15. Bảng `PasswordResetOtps`
- **Phân hệ:** Module 1: Người dùng & Phân quyền
- **Số lượng bản ghi hiện tại:** `3` dòng
- **Khóa chính (PK):** `OtpId`
- **Mô tả chức năng:** Quản lý mã OTP đặt lại mật khẩu, thời hạn hết hạn và số lần thử của người dùng

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `OtpId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính bản ghi OTP |
| 2 | `NguoiDungId` | `int(10)` | **NOT NULL** | **FK** -> `NguoiDungs` | - | Khóa ngoại tham chiếu NguoiDungs.NguoiDungId |
| 3 | `OtpCodeHash` | `nvarchar(500)` | **NOT NULL** |  | - | Mã OTP đã được mã hóa bảo mật |
| 4 | `ExpiredAt` | `datetime2` | **NOT NULL** |  | - | Thời điểm hết hạn của OTP |
| 5 | `SoLanThu` | `int(10)` | **NOT NULL** |  | `((0))` | Số lần đã nhập sai |
| 6 | `IsUsed` | `bit` | **NOT NULL** |  | `((0))` | Cờ đánh dấu OTP đã được sử dụng hay chưa |
| 7 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm phát sinh OTP |

### 2.16. Bảng `PhanCongGiangViens`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `17` dòng
- **Khóa chính (PK):** `PhanCongId`
- **Mô tả chức năng:** Bảng liên kết N:N phân công giảng viên phụ trách giảng dạy cho từng lớp học phần

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `PhanCongId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính phân công |
| 2 | `LopHocPhanId` | `int(10)` | **NOT NULL** | **FK** -> `LopHocPhans` | - | Khóa ngoại tham chiếu LopHocPhans.LopHocPhanId |
| 3 | `GiangVienId` | `int(10)` | **NOT NULL** | **FK** -> `GiangViens` | - | Khóa ngoại tham chiếu GiangViens.GiangVienId |
| 4 | `VaiTro` | `nvarchar(100)` | **NOT NULL** |  | `(N'Giảng viên phụ trách')` | Vai trò phân công (Giảng viên phụ trách, trợ giảng) |
| 5 | `NgayPhanCong` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm thực hiện phân công |
| 6 | `TrangThai` | `bit` | **NOT NULL** |  | `((1))` | Trạng thái phân công (1: Đang có hiệu lực, 0: Đã hủy) |

### 2.17. Bảng `SinhVienLopHocPhans`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `453` dòng
- **Khóa chính (PK):** `SinhVienLopHocPhanId`
- **Mô tả chức năng:** Bảng liên kết N:N lưu danh sách sinh viên ghi danh theo học từng lớp học phần

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `SinhVienLopHocPhanId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính ghi danh |
| 2 | `SinhVienId` | `int(10)` | **NOT NULL** | **FK** -> `SinhViens` | - | Khóa ngoại tham chiếu SinhViens.SinhVienId |
| 3 | `LopHocPhanId` | `int(10)` | **NOT NULL** | **FK** -> `LopHocPhans` | - | Khóa ngoại tham chiếu LopHocPhans.LopHocPhanId |
| 4 | `NgayThamGia` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm ghi danh vào lớp |
| 5 | `TrangThai` | `bit` | **NOT NULL** |  | `((1))` | Trạng thái tham gia (1: Đang học, 0: Rút) |

### 2.18. Bảng `SinhViens`
- **Phân hệ:** Module 2: Đào tạo & Lớp học phần
- **Số lượng bản ghi hiện tại:** `253` dòng
- **Khóa chính (PK):** `SinhVienId`
- **Mô tả chức năng:** Hồ sơ chi tiết của sinh viên (MSSV, ngày sinh, khoa), liên kết 1:1 với NguoiDungs

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `SinhVienId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính hồ sơ sinh viên |
| 2 | `NguoiDungId` | `int(10)` | **NOT NULL** | **FK** -> `NguoiDungs` | - | Khóa ngoại (1:1 Unique) tham chiếu NguoiDungs.NguoiDungId |
| 3 | `MSSV` | `varchar(30)` | **NOT NULL** |  | - | Mã số sinh viên duy nhất |
| 4 | `KhoaId` | `int(10)` | **NOT NULL** | **FK** -> `Khoas` | - | Khóa ngoại tham chiếu Khoas.KhoaId |
| 5 | `NgaySinh` | `date` | NULL |  | - | Ngày tháng năm sinh |
| 6 | `GioiTinh` | `nvarchar(10)` | NULL |  | - | Giới tính (Nam, Nữ, Khác) |
| 7 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm tạo hồ sơ |

### 2.19. Bảng `ThanhVienNhoms`
- **Phân hệ:** Module 3: Đăng ký Nhóm & Đề tài
- **Số lượng bản ghi hiện tại:** `98` dòng
- **Khóa chính (PK):** `ThanhVienNhomId`
- **Mô tả chức năng:** Bảng liên kết N:N lưu các sinh viên tham gia vào nhóm đồ án và vai trò trong nhóm

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `ThanhVienNhomId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính thành viên nhóm |
| 2 | `NhomId` | `int(10)` | **NOT NULL** | **FK** -> `NhomDoAns` | - | Khóa ngoại tham chiếu NhomDoAns.NhomId |
| 3 | `SinhVienId` | `int(10)` | **NOT NULL** | **FK** -> `SinhViens` | - | Khóa ngoại tham chiếu SinhViens.SinhVienId |
| 4 | `VaiTro` | `nvarchar(50)` | **NOT NULL** |  | `(N'Thành viên')` | Vai trò trong nhóm (Trưởng nhóm, Thành viên) |
| 5 | `NgayThamGia` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm gia nhập nhóm |
| 6 | `TrangThai` | `nvarchar(50)` | **NOT NULL** |  | `(N'Đã tham gia')` | Trạng thái (Chờ tham gia, Đã tham gia, Đã rời nhóm) |

### 2.20. Bảng `ThongBaos`
- **Phân hệ:** Module 1: Người dùng & Phân quyền
- **Số lượng bản ghi hiện tại:** `175` dòng
- **Khóa chính (PK):** `ThongBaoId`
- **Mô tả chức năng:** Lưu thông báo hệ thống, thông báo phân công, duyệt đề tài và các liên kết nghiệp vụ

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `ThongBaoId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính thông báo |
| 2 | `NguoiDungId` | `int(10)` | **NOT NULL** | **FK** -> `NguoiDungs` | - | Khóa ngoại tham chiếu NguoiDungs.NguoiDungId người nhận |
| 3 | `TieuDe` | `nvarchar(200)` | **NOT NULL** |  | - | Tiêu đề thông báo |
| 4 | `NoiDung` | `nvarchar(1000)` | **NOT NULL** |  | - | Nội dung chi tiết thông báo |
| 5 | `LoaiThongBao` | `nvarchar(50)` | **NOT NULL** |  | `(N'Há»‡ thá»‘ng')` | Phân loại thông báo (Hệ thống, Phân công, Duyệt đề tài, ...) |
| 6 | `DaDoc` | `bit` | **NOT NULL** |  | `((0))` | Cờ đánh dấu đã đọc (1: Đã đọc, 0: Chưa đọc) |
| 7 | `CreatedAt` | `datetime2` | **NOT NULL** |  | `(sysdatetime())` | Thời điểm gửi thông báo |
| 8 | `LienKetId` | `int(10)` | NULL |  | - | ID thực thể liên kết (Polymorphic ID) |
| 9 | `LoaiLienKet` | `nvarchar(50)` | NULL |  | - | Loại thực thể liên kết (LopHocPhan, DeTai, Nhom, ...) |

### 2.21. Bảng `VaiTros`
- **Phân hệ:** Module 1: Người dùng & Phân quyền
- **Số lượng bản ghi hiện tại:** `5` dòng
- **Khóa chính (PK):** `VaiTroId`
- **Mô tả chức năng:** Danh mục vai trò người dùng trong hệ thống (ADMIN, GIAOVUKHOA, PHONGDAOTAO, GIANGVIEN, SINHVIEN)

| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |
|:---:|:---|:---|:---:|:---:|:---|:---|
| 1 | `VaiTroId` | `int(10)` | **NOT NULL** | **PK** | - | Khóa chính, mã định danh vai trò |
| 2 | `MaVaiTro` | `varchar(50)` | **NOT NULL** |  | - | Mã vai trò viết tắt duy nhất (ADMIN, GIAOVUKHOA, ...) |
| 3 | `TenVaiTro` | `nvarchar(100)` | **NOT NULL** |  | - | Tên hiển thị đầy đủ của vai trò |
| 4 | `MoTa` | `nvarchar(255)` | NULL |  | - | Mô tả chi tiết quyền hạn của vai trò |

---

## 3. MA TRẬN 30 QUAN HỆ KHÓA NGOẠI (FOREIGN KEYS) VẬT LÝ

| STT | Tên Foreign Key | Bảng Nguồn (Many) | Cột Khóa Ngoại | Bảng Đích (One) | Cột Khóa Chính | Cardinality | ON DELETE | Ý Nghĩa Nghiệp Vụ |
|:---:|:---|:---|:---|:---|:---|:---:|:---:|:---|
| 1 | `FK_AIRequests_NguoiDungs` | `AIRequests` | `NguoiDungId` | `NguoiDungs` | `NguoiDungId` | **N:1** | `NO_ACTION` | Quan hệ giữa AIRequests và NguoiDungs |
| 2 | `FK_BaoCaoTienDos_NhomDoAns` | `BaoCaoTienDos` | `NhomId` | `NhomDoAns` | `NhomId` | **N:1** | `CASCADE` | Quan hệ giữa BaoCaoTienDos và NhomDoAns |
| 3 | `FK_DangKyDeTais_DeTaiDoAns` | `DangKyDeTais` | `DeTaiId` | `DeTaiDoAns` | `DeTaiId` | **N:1** | `NO_ACTION` | Quan hệ giữa DangKyDeTais và DeTaiDoAns |
| 4 | `FK_DangKyDeTais_GiangViens` | `DangKyDeTais` | `GiangVienDuyetId` | `GiangViens` | `GiangVienId` | **N:1** | `NO_ACTION` | Quan hệ giữa DangKyDeTais và GiangViens |
| 5 | `FK_DangKyDeTais_NhomDoAns` | `DangKyDeTais` | `NhomId` | `NhomDoAns` | `NhomId` | **N:1** | `NO_ACTION` | Quan hệ giữa DangKyDeTais và NhomDoAns |
| 6 | `FK_DeTaiDoAns_DotDangKy` | `DeTaiDoAns` | `DotDangKyId` | `DotDangKyDoAns` | `DotDangKyId` | **N:1** | `NO_ACTION` | Quan hệ giữa DeTaiDoAns và DotDangKyDoAns |
| 7 | `FK_DeTaiDoAns_GiangViens` | `DeTaiDoAns` | `GiangVienId` | `GiangViens` | `GiangVienId` | **N:1** | `NO_ACTION` | Quan hệ giữa DeTaiDoAns và GiangViens |
| 8 | `FK_DeTaiDoAns_SinhViens` | `DeTaiDoAns` | `SinhVienDeXuatId` | `SinhViens` | `SinhVienId` | **N:1** | `NO_ACTION` | Quan hệ giữa DeTaiDoAns và SinhViens |
| 9 | `FK_DotDangKyDoAns_LopHocPhans` | `DotDangKyDoAns` | `LopHocPhanId` | `LopHocPhans` | `LopHocPhanId` | **N:1** | `NO_ACTION` | Quan hệ giữa DotDangKyDoAns và LopHocPhans |
| 10 | `FK_DotImports_NguoiDungs` | `DotImports` | `NguoiImportId` | `NguoiDungs` | `NguoiDungId` | **N:1** | `NO_ACTION` | Quan hệ giữa DotImports và NguoiDungs |
| 11 | `FK_GiangViens_Khoas` | `GiangViens` | `KhoaId` | `Khoas` | `KhoaId` | **N:1** | `NO_ACTION` | Quan hệ giữa GiangViens và Khoas |
| 12 | `FK_GiangViens_NguoiDungs` | `GiangViens` | `NguoiDungId` | `NguoiDungs` | `NguoiDungId` | **1:1 (Unique FK)** | `NO_ACTION` | Quan hệ giữa GiangViens và NguoiDungs |
| 13 | `FK_HocPhans_Khoas` | `HocPhans` | `KhoaId` | `Khoas` | `KhoaId` | **N:1** | `NO_ACTION` | Quan hệ giữa HocPhans và Khoas |
| 14 | `FK_LoiImports_DotImports` | `LoiImports` | `DotImportId` | `DotImports` | `DotImportId` | **N:1** | `CASCADE` | Quan hệ giữa LoiImports và DotImports |
| 15 | `FK_LopHocPhans_HocKys` | `LopHocPhans` | `HocKyId` | `HocKys` | `HocKyId` | **N:1** | `NO_ACTION` | Quan hệ giữa LopHocPhans và HocKys |
| 16 | `FK_LopHocPhans_HocPhans` | `LopHocPhans` | `HocPhanId` | `HocPhans` | `HocPhanId` | **N:1** | `NO_ACTION` | Quan hệ giữa LopHocPhans và HocPhans |
| 17 | `FK_LopHocPhans_Khoas` | `LopHocPhans` | `KhoaId` | `Khoas` | `KhoaId` | **N:1** | `NO_ACTION` | Quan hệ giữa LopHocPhans và Khoas |
| 18 | `FK_NguoiDungs_VaiTros` | `NguoiDungs` | `VaiTroId` | `VaiTros` | `VaiTroId` | **N:1** | `NO_ACTION` | Quan hệ giữa NguoiDungs và VaiTros |
| 19 | `FK_NhomDoAns_DotDangKy` | `NhomDoAns` | `DotDangKyId` | `DotDangKyDoAns` | `DotDangKyId` | **N:1** | `NO_ACTION` | Quan hệ giữa NhomDoAns và DotDangKyDoAns |
| 20 | `FK_NhomDoAns_TruongNhom` | `NhomDoAns` | `TruongNhomId` | `SinhViens` | `SinhVienId` | **N:1** | `NO_ACTION` | Quan hệ giữa NhomDoAns và SinhViens |
| 21 | `FK_PasswordResetOtps_NguoiDungs` | `PasswordResetOtps` | `NguoiDungId` | `NguoiDungs` | `NguoiDungId` | **N:1** | `NO_ACTION` | Quan hệ giữa PasswordResetOtps và NguoiDungs |
| 22 | `FK_PhanCongGiangViens_GiangViens` | `PhanCongGiangViens` | `GiangVienId` | `GiangViens` | `GiangVienId` | **N:1** | `NO_ACTION` | Quan hệ giữa PhanCongGiangViens và GiangViens |
| 23 | `FK_PhanCongGiangViens_LopHocPhans` | `PhanCongGiangViens` | `LopHocPhanId` | `LopHocPhans` | `LopHocPhanId` | **N:1** | `NO_ACTION` | Quan hệ giữa PhanCongGiangViens và LopHocPhans |
| 24 | `FK_SinhVienLopHocPhans_LopHocPhans` | `SinhVienLopHocPhans` | `LopHocPhanId` | `LopHocPhans` | `LopHocPhanId` | **N:1** | `NO_ACTION` | Quan hệ giữa SinhVienLopHocPhans và LopHocPhans |
| 25 | `FK_SinhVienLopHocPhans_SinhViens` | `SinhVienLopHocPhans` | `SinhVienId` | `SinhViens` | `SinhVienId` | **N:1** | `NO_ACTION` | Quan hệ giữa SinhVienLopHocPhans và SinhViens |
| 26 | `FK_SinhViens_Khoas` | `SinhViens` | `KhoaId` | `Khoas` | `KhoaId` | **N:1** | `NO_ACTION` | Quan hệ giữa SinhViens và Khoas |
| 27 | `FK_SinhViens_NguoiDungs` | `SinhViens` | `NguoiDungId` | `NguoiDungs` | `NguoiDungId` | **1:1 (Unique FK)** | `NO_ACTION` | Quan hệ giữa SinhViens và NguoiDungs |
| 28 | `FK_ThanhVienNhoms_NhomDoAns` | `ThanhVienNhoms` | `NhomId` | `NhomDoAns` | `NhomId` | **N:1** | `NO_ACTION` | Quan hệ giữa ThanhVienNhoms và NhomDoAns |
| 29 | `FK_ThanhVienNhoms_SinhViens` | `ThanhVienNhoms` | `SinhVienId` | `SinhViens` | `SinhVienId` | **N:1** | `NO_ACTION` | Quan hệ giữa ThanhVienNhoms và SinhViens |
| 30 | `FK_ThongBaos_NguoiDungs` | `ThongBaos` | `NguoiDungId` | `NguoiDungs` | `NguoiDungId` | **N:1** | `NO_ACTION` | Quan hệ giữa ThongBaos và NguoiDungs |

---

## 4. ĐỐI CHIẾU THỰC TẾ GIỮA SQL SERVER VÀ ENTITY FRAMEWORK CORE

| STT | Bảng SQL Server | Entity C# Tương Ứng | Khớp Số Cột | Khớp Khóa Chính | Khớp Khóa Ngoại | Ghi Chú Đối Chiếu |
|:---:|:---|:---|:---:|:---:|:---:|:---|
| 1 | `dbo.AIRequests` | `ProGroup_AI.API.Models.AIRequest` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `AIRequests` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 2 | `dbo.BaoCaoTienDos` | `ProGroup_AI.API.Models.BaoCaoTienDo` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `BaoCaoTienDos` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 3 | `dbo.DangKyDeTais` | `ProGroup_AI.API.Models.DangKyDeTai` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `DangKyDeTais` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 4 | `dbo.DeTaiDoAns` | `ProGroup_AI.API.Models.DeTaiDoAn` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `DeTaiDoAns` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 5 | `dbo.DotDangKyDoAns` | `ProGroup_AI.API.Models.DotDangKyDoAn` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `DotDangKyDoAns` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 6 | `dbo.DotImports` | `ProGroup_AI.API.Models.DotImport` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `DotImports` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 7 | `dbo.GiangViens` | `ProGroup_AI.API.Models.GiangVien` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `GiangViens` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 8 | `dbo.HocKys` | `ProGroup_AI.API.Models.HocKy` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `HocKys` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 9 | `dbo.HocPhans` | `ProGroup_AI.API.Models.HocPhan` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `HocPhans` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 10 | `dbo.Khoas` | `ProGroup_AI.API.Models.Khoa` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `Khoas` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 11 | `dbo.LoiImports` | `ProGroup_AI.API.Models.LoiImport` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `LoiImports` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 12 | `dbo.LopHocPhans` | `ProGroup_AI.API.Models.LopHocPhan` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `LopHocPhans` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 13 | `dbo.NguoiDungs` | `ProGroup_AI.API.Models.NguoiDung` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `NguoiDungs` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 14 | `dbo.NhomDoAns` | `ProGroup_AI.API.Models.NhomDoAn` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `NhomDoAns` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 15 | `dbo.PasswordResetOtps` | `ProGroup_AI.API.Models.PasswordResetOtp` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `PasswordResetOtps` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 16 | `dbo.PhanCongGiangViens` | `ProGroup_AI.API.Models.PhanCongGiangVien` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `PhanCongGiangViens` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 17 | `dbo.SinhVienLopHocPhans` | `ProGroup_AI.API.Models.SinhVienLopHocPhan` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `SinhVienLopHocPhans` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 18 | `dbo.SinhViens` | `ProGroup_AI.API.Models.SinhVien` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `SinhViens` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 19 | `dbo.ThanhVienNhoms` | `ProGroup_AI.API.Models.ThanhVienNhom` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `ThanhVienNhoms` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 20 | `dbo.ThongBaos` | `ProGroup_AI.API.Models.ThongBao` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `ThongBaos` được cấu hình chuẩn xác trong `ApplicationDbContext` |
| 21 | `dbo.VaiTros` | `ProGroup_AI.API.Models.VaiTro` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `VaiTros` được cấu hình chuẩn xác trong `ApplicationDbContext` |

### 4.1. Các quan hệ nghiệp vụ logic không dùng Foreign Key vật lý
1. **`BaoCaoTienDos.DeTaiId` và `BaoCaoTienDos.GiangVienId`**: Được khai báo trong Entity và Controller nhưng không tạo ràng buộc `FOREIGN KEY` cứng trong database để tránh vòng lặp Cascade Delete (`circular cascade delete path`) giữa `NhomDoAns` -> `DangKyDeTais` -> `DeTaiDoAns` -> `BaoCaoTienDos`. Quan hệ toàn vẹn được kiểm soát chặt chẽ ở tầng Application Service.
2. **`ThongBaos.LienKetId`**: Sử dụng cơ chế Polymorphic Reference kết hợp với cột `LoaiLienKet` (`LopHocPhan`, `DeTai`, `Nhom`), cho phép một bản ghi thông báo có thể điều hướng tới nhiều loại thực thể khác nhau mà không cần nhiều cột khóa ngoại rời rạc.