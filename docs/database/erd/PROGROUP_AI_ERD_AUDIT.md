# BÁO CÁO KIỂM TOÁN CƠ SỞ DỮ LIỆU & BÀN GIAO SƠ ĐỒ THỰC THỂ LIÊN KẾT (ERD) CHUẨN
## DỰ ÁN: PROGROUP AI – HỆ THỐNG QUẢN LÝ ĐĂNG KÝ NHÓM & ĐỒ ÁN MÔN HỌC

---

## 1. THÔNG TIN TRUY CẬP VÀ MÔI TRƯỜNG KẾT NỐI THỰC TẾ

- **Hệ quản trị CSDL (RDBMS):** Microsoft SQL Server Express 64-bit (LAPTOP-3RHN15E2\SQLEXPRESS)
- **Tên cơ sở dữ liệu:** ProjectRegistrationDB
- **Phương thức xác thực:** Windows Authentication (Trusted_Connection=True;TrustServerCertificate=True;)
- **Tệp cấu hình Backend khai báo:**
  - ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/appsettings.json
  - ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/appsettings.Development.json
- **DbContext:** ApplicationDbContext (ProGroup_AI.API.Data)
- **EF Core Version:** 10.0.0 (Microsoft.EntityFrameworkCore.SqlServer)
- **Chế độ kiểm toán:** **STRICT READ-ONLY (Chỉ đọc)**
  - *Không thực hiện bất kỳ lệnh DDL, DML, DROP, ALTER, UPDATE hay Migration nào trên cơ sở dữ liệu vật lý.*
  - *Bảo toàn 100% tính nguyên vẹn của dữ liệu và cấu trúc bảng hiện hành.*

---

## 2. BẢNG TỔNG KẾT SỐ LIỆU ĐỊNH LƯỢNG

| Chỉ số kiểm toán | Số lượng thực tế | Ghi chú & Chi tiết kỹ thuật |
| :--- | :---: | :--- |
| **Tổng số bảng trong Database** | **23 bảng** | Bao gồm 21 bảng nghiệp vụ và 2 bảng hệ thống |
| **Bảng dữ liệu nghiệp vụ** | **21 bảng** | Được quản lý thông qua EF Core DbSets |
| **Bảng hệ thống / Metadata** | **2 bảng** | __EFMigrationsHistory (quản lý di chuyển CSDL), sysdiagrams |
| **Tổng số trường dữ liệu (Columns)** | **175 cột** | Đầy đủ thuộc tính kiểu dữ liệu, nullability, identity, default value |
| **Khóa chính (Primary Keys - PK)** | **23 khóa** | 100% bảng có PK; int IDENTITY(1,1) trên 22 bảng, string trên __EFMigrationsHistory |
| **Khóa ngoại vật lý (Foreign Keys - FK)** | **30 khóa** | Có ràng buộc toàn vẹn tham chiếu thực thi tại cấp RDBMS |
| **Ràng buộc kiểm tra (Check Constraints)** | **22 ràng buộc** | Đảm bảo hợp lệ cho các trường trạng thái, vai trò, số lượng thành viên |
| **Chỉ mục & Ràng buộc duy nhất (Indexes/Uniques)**| **117 chỉ mục** | Bao gồm Clustered PKs, Non-Clustered FK indexes, Unique Constraints |
| **Mối quan hệ logic phi vật lý** | **3 quan hệ** | Các quan hệ nghiệp vụ có chủ đích không gắn FK để tránh cascade loop |

---

## 3. PHÂN CHIA PHÂN HỆ VÀ KIẾN TRÚC NGHIỆP VỤ (3 MODULES)

### 3.1. Phân hệ 1: Người dùng, Phân quyền & Quản trị Hệ thống (7 Bảng)
Quản trị toàn bộ vòng đời tài khoản, bảo mật phân quyền theo vai trò (RBAC), cơ chế khôi phục mật khẩu OTP, hàng đợi thông báo, tương tác AI và theo dõi các đợt import dữ liệu lớn:
1. VaiTros: Danh mục vai trò (ADMIN, GIAOVUKHOA, PHONGDAOTAO, GIANGVIEN, SINHVIEN).
2. NguoiDungs: Bảng trung tâm định danh người dùng, lưu mật khẩu băm, email, số điện thoại, trạng thái hoạt động.
3. PasswordResetOtps: Lưu trữ và kiểm soát mã OTP khôi phục mật khẩu có giới hạn thời gian hết hạn (ExpiresAt).
4. ThongBaos: Hệ thống thông báo đẩy tới người dùng, hỗ trợ liên kết đa hình (Polymorphic).
5. AIRequests: Nhật ký tương tác trí tuệ nhân tạo (Gemini AI), lưu lịch sử prompt, model response, execution time.
6. DotImports: Quản lý các phiên import danh sách sinh viên/giảng viên/lớp học phần từ file Excel.
7. LoiImports: Lưu chi tiết các dòng lỗi phát sinh trong đợt import để phục vụ đối soát, sửa đổi.

### 3.2. Phân hệ 2: Quản lý Đào tạo, Khoa & Lớp Học Phần (8 Bảng)
Quản lý mô hình cấu trúc phân cấp học thuật của nhà trường cùng với hồ sơ chuyên biệt của sinh viên và giảng viên:
1. Khoas: Danh mục các Khoa/Viện đào tạo trực thuộc trường.
2. HocKys: Danh mục các học kỳ và năm học chính quy.
3. HocPhans: Học phần / môn học đồ án có số tín chỉ và mã môn.
4. LopHocPhans: Lớp học phần cụ thể được mở trong từng học kỳ theo khoa.
5. SinhViens: Hồ sơ chi tiết sinh viên (Mã sinh viên, ngày sinh), liên kết quan hệ 1:1 duy nhất với NguoiDungs.
6. GiangViens: Hồ sơ chi tiết giảng viên (Mã giảng viên, học vị, chuyên môn), liên kết 1:1 duy nhất với NguoiDungs.
7. PhanCongGiangViens: Bảng liên kết nhiều-nhiều (N:N) phân công giảng viên phụ trách từng lớp học phần.
8. SinhVienLopHocPhans: Bảng liên kết nhiều-nhiều (N:N) danh sách sinh viên ghi danh vào từng lớp học phần.

### 3.3. Phân hệ 3: Đợt đăng ký, Nhóm, Đề tài & Tiến độ Đồ án (6 Bảng)
Phân hệ cốt lõi vận hành toàn bộ nghiệp vụ đăng ký nhóm sinh viên, lựa chọn/đề xuất đề tài đồ án và nộp báo cáo tiến độ:
1. DotDangKyDoAns: Đợt mở đăng ký nhóm và đề tài cho từng lớp học phần (khống chế thời gian mở/đóng, giới hạn số thành viên).
2. NhomDoAns: Nhóm sinh viên thực hiện đồ án, có nhóm trưởng và trạng thái nhóm.
3. ThanhVienNhoms: Danh sách các sinh viên tham gia trong từng nhóm (xác định nhóm trưởng/thành viên, trạng thái tham gia).
4. DeTaiDoAns: Ngân hàng đề tài đồ án (do giảng viên khởi tạo hoặc do nhóm sinh viên tự đề xuất).
5. DangKyDeTais: Bản ghi đăng ký đề tài của nhóm và tiến trình xét duyệt của giảng viên phụ trách.
6. BaoCaoTienDos: Báo cáo tiến độ đồ án theo từng tuần/giai đoạn (lưu mã nguồn GitHub, bản báo cáo, điểm số, đánh giá phản hồi).

---

## 4. MA TRẬN ĐỐI CHIẾU 1-1: CƠ SỞ DỮ LIỆU SQL SERVER VS MÃ NGUỒN BACKEND C#

Toàn bộ 21 bảng nghiệp vụ trong CSDL SQL Server được đối chiếu và map tương ứng 100% với các C# Entity Model trong thư mục ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Models/ và các khai báo DbSet<T> trong ApplicationDbContext.cs:

| STT | Tên bảng SQL Server | C# Model Entity Class | DbSet trong DbContext | Thuộc Phân hệ | Mức độ đồng bộ |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 1 | VaiTros | VaiTro.cs | DbSet<VaiTro> VaiTros | Module 1 | **100% Khớp** |
| 2 | NguoiDungs | NguoiDung.cs | DbSet<NguoiDung> NguoiDungs | Module 1 | **100% Khớp** |
| 3 | PasswordResetOtps | PasswordResetOtp.cs | DbSet<PasswordResetOtp> PasswordResetOtps | Module 1 | **100% Khớp** |
| 4 | ThongBaos | ThongBao.cs | DbSet<ThongBao> ThongBaos | Module 1 | **100% Khớp** |
| 5 | AIRequests | AIRequest.cs | DbSet<AIRequest> AIRequests | Module 1 | **100% Khớp** |
| 6 | DotImports | DotImport.cs | DbSet<DotImport> DotImports | Module 1 | **100% Khớp** |
| 7 | LoiImports | LoiImport.cs | DbSet<LoiImport> LoiImports | Module 1 | **100% Khớp** |
| 8 | Khoas | Khoa.cs | DbSet<Khoa> Khoas | Module 2 | **100% Khớp** |
| 9 | HocKys | HocKy.cs | DbSet<HocKy> HocKys | Module 2 | **100% Khớp** |
| 10 | HocPhans | HocPhan.cs | DbSet<HocPhan> HocPhans | Module 2 | **100% Khớp** |
| 11 | LopHocPhans | LopHocPhan.cs | DbSet<LopHocPhan> LopHocPhans | Module 2 | **100% Khớp** |
| 12 | SinhViens | SinhVien.cs | DbSet<SinhVien> SinhViens | Module 2 | **100% Khớp** |
| 13 | GiangViens | GiangVien.cs | DbSet<GiangVien> GiangViens | Module 2 | **100% Khớp** |
| 14 | PhanCongGiangViens| PhanCongGiangVien.cs| DbSet<PhanCongGiangVien> PhanCongGiangViens| Module 2 | **100% Khớp** |
| 15 | SinhVienLopHocPhans| SinhVienLopHocPhan.cs| DbSet<SinhVienLopHocPhan> SinhVienLopHocPhans| Module 2 | **100% Khớp** |
| 16 | DotDangKyDoAns | DotDangKyDoAn.cs | DbSet<DotDangKyDoAn> DotDangKyDoAns | Module 3 | **100% Khớp** |
| 17 | NhomDoAns | NhomDoAn.cs | DbSet<NhomDoAn> NhomDoAns | Module 3 | **100% Khớp** |
| 18 | ThanhVienNhoms | ThanhVienNhom.cs | DbSet<ThanhVienNhom> ThanhVienNhoms | Module 3 | **100% Khớp** |
| 19 | DeTaiDoAns | DeTaiDoAn.cs | DbSet<DeTaiDoAn> DeTaiDoAns | Module 3 | **100% Khớp** |
| 20 | DangKyDeTais | DangKyDeTai.cs | DbSet<DangKyDeTai> DangKyDeTais | Module 3 | **100% Khớp** |
| 21 | BaoCaoTienDos | BaoCaoTienDo.cs | DbSet<BaoCaoTienDo> BaoCaoTienDos | Module 3 | **100% Khớp** |

---

## 5. CÁC QUAN HỆ LOGIC KHÔNG CÓ RÀNG BUỘC KHÓA NGOẠI VẬT LÝ

Quá trình phân tích chuyên sâu phát hiện **3 mối quan hệ logic quan trọng** được xử lý ở tầng ứng dụng Backend mà không áp đặt Foreign Key vật lý ở cấp SQL Server:

1. **BaoCaoTienDos.DeTaiId -> DeTaiDoAns.Id:**
   - *Nguyên nhân kỹ thuật:* BaoCaoTienDos đã có FK trực tiếp tới NhomDoAns (FK_BaoCaoTienDos_NhomDoAns_NhomId ON DELETE CASCADE). Trong khi đó, NhomDoAns đã có quan hệ với DeTaiDoAns qua DangKyDeTais. Nếu thiết lập thêm FK vật lý từ BaoCaoTienDos tới DeTaiDoAns với quy tắc cascade sẽ gây ra lỗi Introducing FOREIGN KEY constraint may cause cycles or multiple cascade paths đặc trưng của SQL Server.
   - *Cơ chế đảm bảo:* Backend API kiểm tra tính hợp lệ của DeTaiId dựa trên đề tài đã được duyệt của nhóm trước khi cho phép tạo báo cáo.

2. **BaoCaoTienDos.GiangVienId -> GiangViens.Id:**
   - *Nguyên nhân kỹ thuật:* Dùng để ghi nhận giảng viên trực tiếp chấm điểm/nhận xét báo cáo tiến độ. Do giảng viên chấm có thể là GV hướng dẫn hoặc GV phản biện (được phân công động), mối quan hệ này được kiểm soát ở mức logic ứng dụng để tránh khóa cứng tham chiếu bảng khi có thay đổi nhân sự.

3. **ThongBaos.LienKetId & ThongBaos.LoaiLienKet (Polymorphic Association):**
   - *Nguyên nhân kỹ thuật:* Thông báo đẩy có thể dẫn người dùng tới nhiều thực thể khác nhau tùy theo ngữ cảnh: tới đợt đăng ký (DOT_DANG_KY), nhóm (NHOM), đề tài (DE_TAI), hoặc báo cáo tiến độ (BAO_CAO). Đây là mẫu thiết kế Đa hình (Polymorphic), do đó trường LienKetId lưu ID của các thực thể khác nhau tùy theo giá trị chuỗi của LoaiLienKet.

---

## 6. DANH MỤC 30 RÀNG BUỘC KHÓA NGOẠI VẬT LÝ (FOREIGN KEYS)

| STT | Bảng nguồn (Foreign Key Table) | Cột khóa ngoại | Bảng đích (Primary Key Table) | Tên Constraint | Quy tắc xóa (Delete Rule) |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 1 | NguoiDungs | VaiTroId | VaiTros | FK_NguoiDungs_VaiTros_VaiTroId | CASCADE |
| 2 | PasswordResetOtps | NguoiDungId | NguoiDungs | FK_PasswordResetOtps_NguoiDungs_NguoiDungId | CASCADE |
| 3 | ThongBaos | NguoiDungId | NguoiDungs | FK_ThongBaos_NguoiDungs_NguoiDungId | CASCADE |
| 4 | AIRequests | NguoiDungId | NguoiDungs | FK_AIRequests_NguoiDungs_NguoiDungId | CASCADE |
| 5 | DotImports | NguoiDungId | NguoiDungs | FK_DotImports_NguoiDungs_NguoiDungId | CASCADE |
| 6 | LoiImports | DotImportId | DotImports | FK_LoiImports_DotImports_DotImportId | CASCADE |
| 7 | SinhViens | NguoiDungId | NguoiDungs | FK_SinhViens_NguoiDungs_NguoiDungId | CASCADE |
| 8 | SinhViens | KhoaId | Khoas | FK_SinhViens_Khoas_KhoaId | NO ACTION |
| 9 | GiangViens | NguoiDungId | NguoiDungs | FK_GiangViens_NguoiDungs_NguoiDungId | CASCADE |
| 10 | GiangViens | KhoaId | Khoas | FK_GiangViens_Khoas_KhoaId | NO ACTION |
| 11 | HocPhans | KhoaId | Khoas | FK_HocPhans_Khoas_KhoaId | CASCADE |
| 12 | LopHocPhans | HocPhanId | HocPhans | FK_LopHocPhans_HocPhans_HocPhanId | CASCADE |
| 13 | LopHocPhans | HocKyId | HocKys | FK_LopHocPhans_HocKys_HocKyId | CASCADE |
| 14 | LopHocPhans | KhoaId | Khoas | FK_LopHocPhans_Khoas_KhoaId | NO ACTION |
| 15 | PhanCongGiangViens| LopHocPhanId | LopHocPhans | FK_PhanCongGiangViens_LopHocPhans_LopHocPhanId | CASCADE |
| 16 | PhanCongGiangViens| GiangVienId | GiangViens | FK_PhanCongGiangViens_GiangViens_GiangVienId | CASCADE |
| 17 | SinhVienLopHocPhans| LopHocPhanId| LopHocPhans | FK_SinhVienLopHocPhans_LopHocPhans_LopHocPhanId | CASCADE |
| 18 | SinhVienLopHocPhans| SinhVienId | SinhViens | FK_SinhVienLopHocPhans_SinhViens_SinhVienId | CASCADE |
| 19 | DotDangKyDoAns | LopHocPhanId | LopHocPhans | FK_DotDangKyDoAns_LopHocPhans_LopHocPhanId | CASCADE |
| 20 | NhomDoAns | DotDangKyId | DotDangKyDoAns | FK_NhomDoAns_DotDangKyDoAns_DotDangKyId | CASCADE |
| 21 | NhomDoAns | TruongNhomId | SinhViens | FK_NhomDoAns_SinhViens_TruongNhomId | NO ACTION |
| 22 | ThanhVienNhoms | NhomId | NhomDoAns | FK_ThanhVienNhoms_NhomDoAns_NhomId | CASCADE |
| 23 | ThanhVienNhoms | SinhVienId | SinhViens | FK_ThanhVienNhoms_SinhViens_SinhVienId | NO ACTION |
| 24 | DeTaiDoAns | LopHocPhanId | LopHocPhans | FK_DeTaiDoAns_LopHocPhans_LopHocPhanId | CASCADE |
| 25 | DeTaiDoAns | GiangVienId | GiangViens | FK_DeTaiDoAns_GiangViens_GiangVienId | NO ACTION |
| 26 | DangKyDeTais | NhomId | NhomDoAns | FK_DangKyDeTais_NhomDoAns_NhomId | CASCADE |
| 27 | DangKyDeTais | DeTaiId | DeTaiDoAns | FK_DangKyDeTais_DeTaiDoAns_DeTaiId | CASCADE |
| 28 | DangKyDeTais | NguoiDuyetId | GiangViens | FK_DangKyDeTais_GiangViens_NguoiDuyetId | NO ACTION |
| 29 | BaoCaoTienDos | NhomId | NhomDoAns | FK_BaoCaoTienDos_NhomDoAns_NhomId | CASCADE |
| 30 | BaoCaoTienDos | NguoiNopId | SinhViens | FK_BaoCaoTienDos_SinhViens_NguoiNopId | NO ACTION |

---

## 7. DANH MỤC CÁC TỆP SƠ ĐỒ VÀ TÀI LIỆU BÀN GIAO

Tất cả các tệp sơ đồ và tài liệu đã được xuất và lưu trữ tại thư mục chuẩn: docs/database/erd/:

### 7.1. Sơ đồ Tổng thể Hệ thống (Overview ERD – Toàn bộ 21 Bảng Nghiệp vụ)
- **Vector SVG (Khuyến nghị xem trên trình duyệt/IDE):** [ProGroupAI_ERD.svg](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD.svg)
- **Vector PDF (In ấn khổ lớn, sắc nét mọi tỉ lệ zoom):** [ProGroupAI_ERD.pdf](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD.pdf)
- **Ảnh High-Resolution PNG (300 DPI, 6040x2900 px):** [ProGroupAI_ERD.png](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD.png)

### 7.2. Sơ đồ Chi tiết Theo Từng Phân hệ Nghiệp vụ
1. **Module 1: Người dùng, Phân quyền & Quản trị Hệ thống (7 Bảng)**
   - [ProGroupAI_ERD_Module_01.svg](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_01.svg)
   - [ProGroupAI_ERD_Module_01.pdf](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_01.pdf)
   - [ProGroupAI_ERD_Module_01.png](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_01.png)

2. **Module 2: Quản lý Đào tạo, Khoa, Lớp Học Phần & Nhân sự (8 Bảng)**
   - [ProGroupAI_ERD_Module_02.svg](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_02.svg)
   - [ProGroupAI_ERD_Module_02.pdf](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_02.pdf)
   - [ProGroupAI_ERD_Module_02.png](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_02.png)

3. **Module 3: Đợt đăng ký, Nhóm đồ án, Đề tài & Tiến độ (6 Bảng)**
   - [ProGroupAI_ERD_Module_03.svg](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_03.svg)
   - [ProGroupAI_ERD_Module_03.pdf](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_03.pdf)
   - [ProGroupAI_ERD_Module_03.png](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_ERD_Module_03.png)

### 7.3. Từ điển Dữ liệu & Tài liệu Phân tích Chi tiết
- **Từ điển Dữ liệu Excel (Data Dictionary 4 Sheets):** [ProGroupAI_Database_Dictionary.xlsx](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_Database_Dictionary.xlsx)
  - *Sheet 1:* Tổng quan CSDL (Thông tin server, phiên bản, số lượng bảng, phân hệ)
  - *Sheet 2:* Danh mục Cột Dữ liệu (Chi tiết toàn bộ 175 cột: kiểu dữ liệu, nullability, PK, FK, Default)
  - *Sheet 3:* Quan hệ Khóa Ngoại (Toàn bộ 30 FKs, bảng cha-con, quy tắc On Delete/Update)
  - *Sheet 4:* Ràng buộc & Chỉ mục (Danh sách 22 Check Constraints và các Index quan trọng)
- **Báo cáo Phân tích Chuyên sâu CSDL (Markdown Full):** [ProGroupAI_Database_Analysis.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/docs/database/erd/ProGroupAI_Database_Analysis.md)

---

## 8. ĐÁNH GIÁ CHẤT LƯỢNG SCHEMA VÀ KHUYẾN NGHỊ TỐI ƯU HÓA

1. **Chuẩn hóa quan hệ 1:1:**
   - Cặp bảng NguoiDungs <-> SinhViens và NguoiDungs <-> GiangViens đã có Unique Index trên NguoiDungId, đảm bảo một người dùng chỉ có thể gắn với tối đa một hồ sơ tương ứng. Đây là mô hình chuẩn mực cho phân tách danh tính bảo mật và hồ sơ học thuật.
2. **Quản trị chống đệ quy Cascade:**
   - Việc EF Core cấu hình NO ACTION trên một số FK (ví dụ KhoaId trong SinhViens và GiangViens, TruongNhomId trong NhomDoAns) là quyết định kiến trúc rất chính xác, ngăn chặn hoàn toàn lỗi vòng tròn xóa dây chuyền (*Circular Cascade Path*) trong SQL Server.
3. **Đề xuất bổ sung Index hiệu năng cao:**
   - Khuyến nghị bổ sung Composite Index trên BaoCaoTienDos(NhomId, LanBaoCao) để tối ưu hóa truy vấn hiển thị danh sách báo cáo theo tiến độ tuần của nhóm sinh viên.
   - Bổ sung Index trên ThongBaos(NguoiDungId, DaDoc) để tăng tốc độ tải badge thông báo chưa đọc trên giao diện người dùng.
