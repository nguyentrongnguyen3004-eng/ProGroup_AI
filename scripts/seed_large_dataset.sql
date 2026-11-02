-- ==============================================================================
-- SCRIPT TẠO DỮ LIỆU ĐẦY ĐỦ VÀ PHONG PHÚ CHO PROGROUP AI (250+ SINH VIÊN)
-- HỆ THỐNG ĐỒ ÁN VỚI ĐẦY ĐỦ 5 ROLES: ADMIN, SINH VIÊN, GIẢNG VIÊN, GIÁO VỤ, P. ĐÀO TẠO
-- HỖ TRỢ CHẠY F5 NHIỀU LẦN (IDEMPOTENT - AN TOÀN KHÔNG BỊ LỖI TRÙNG KHÓA)
-- ==============================================================================
USE [ProjectRegistrationDB];
GO

SET NOCOUNT ON;

-- ==============================================================================
-- 1. KIỂM TRA VÀ TẠO BẢNG NẾU CHƯA CÓ (TRÁNH LỖI INVALID OBJECT NAME)
-- ==============================================================================

IF OBJECT_ID(N'[dbo].[ThongBaos]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ThongBaos] (
        [ThongBaoId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [NguoiDungId] INT NOT NULL,
        [TieuDe] NVARCHAR(200) NOT NULL,
        [NoiDung] NVARCHAR(1000) NOT NULL,
        [LoaiThongBao] NVARCHAR(50) NOT NULL DEFAULT N'Hệ thống',
        [DaDoc] BIT NOT NULL DEFAULT 0,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        [LienKetId] INT NULL,
        [LoaiLienKet] NVARCHAR(50) NULL,
        CONSTRAINT [FK_ThongBaos_NguoiDungs] FOREIGN KEY ([NguoiDungId]) REFERENCES [dbo].[NguoiDungs] ([NguoiDungId]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_ThongBaos_NguoiDungId] ON [dbo].[ThongBaos]([NguoiDungId]);
    PRINT N'>> Đã tạo bảng ThongBaos thành công!';
END
GO

IF OBJECT_ID(N'[dbo].[BaoCaoTienDos]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[BaoCaoTienDos] (
        [BaoCaoId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [NhomId] INT NOT NULL,
        [DeTaiId] INT NULL,
        [TieuDe] NVARCHAR(200) NOT NULL,
        [NoiDung] NVARCHAR(MAX) NOT NULL,
        [FileUrl] NVARCHAR(500) NULL,
        [GithubUrl] NVARCHAR(500) NULL,
        [DemoUrl] NVARCHAR(500) NULL,
        [TuanBaoCao] INT NOT NULL DEFAULT 1,
        [NgayNop] DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        [TrangThai] NVARCHAR(50) NOT NULL DEFAULT N'Đã nộp',
        [NhanXetGiangVien] NVARCHAR(MAX) NULL,
        [Diem] DECIMAL(4,2) NULL,
        [GiangVienId] INT NULL,
        [NgayNhanXet] DATETIME2 NULL,
        CONSTRAINT [FK_BaoCaoTienDos_NhomDoAns] FOREIGN KEY ([NhomId]) REFERENCES [dbo].[NhomDoAns] ([NhomId]),
        CONSTRAINT [FK_BaoCaoTienDos_DeTaiDoAns] FOREIGN KEY ([DeTaiId]) REFERENCES [dbo].[DeTaiDoAns] ([DeTaiId]),
        CONSTRAINT [FK_BaoCaoTienDos_GiangViens] FOREIGN KEY ([GiangVienId]) REFERENCES [dbo].[GiangViens] ([GiangVienId])
    );
    CREATE INDEX [IX_BaoCaoTienDos_NhomId] ON [dbo].[BaoCaoTienDos]([NhomId]);
    CREATE INDEX [IX_BaoCaoTienDos_DeTaiId] ON [dbo].[BaoCaoTienDos]([DeTaiId]);
    PRINT N'>> Đã tạo bảng BaoCaoTienDos thành công!';
END
GO

-- ==============================================================================
-- 2. KHỞI TẠO VAI TRÒ, KHOA VÀ HỌC KỲ
-- ==============================================================================

-- 2.1 Vai Trò
IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'ADMIN')
    INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa) VALUES ('ADMIN', N'Quản trị viên', N'Quản lý hệ thống');
IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'SINHVIEN')
    INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa) VALUES ('SINHVIEN', N'Sinh viên', N'Đăng ký nhóm và đồ án');
IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'GIANGVIEN')
    INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa) VALUES ('GIANGVIEN', N'Giảng viên', N'Quản lý đề tài đồ án');
IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'GIAOVUKHOA')
    INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa) VALUES ('GIAOVUKHOA', N'Giáo vụ Khoa', N'Quản lý dữ liệu Khoa');
IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'PHONGDAOTAO')
    INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa) VALUES ('PHONGDAOTAO', N'Phòng Đào tạo', N'Quản lý học phần và đào tạo');

-- 2.2 Khoa
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'CNTT')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('CNTT', N'Công nghệ thông tin', 1);
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'KTPM')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('KTPM', N'Kỹ thuật phần mềm', 1);
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'HTTT')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('HTTT', N'Hệ thống thông tin', 1);
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'KHMT')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('KHMT', N'Khoa học máy tính', 1);
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'ATTT')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('ATTT', N'An toàn thông tin', 1);

-- 2.3 Học kỳ
IF NOT EXISTS (SELECT 1 FROM HocKys WHERE TenHocKy = N'Học kỳ 1' AND NamHoc = '2026-2027')
    INSERT INTO HocKys (TenHocKy, NamHoc, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Học kỳ 1', '2026-2027', '2026-09-01', '2027-01-31', 1);

IF NOT EXISTS (SELECT 1 FROM HocKys WHERE TenHocKy = N'Học kỳ 2' AND NamHoc = '2026-2027')
    INSERT INTO HocKys (TenHocKy, NamHoc, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Học kỳ 2', '2026-2027', '2027-02-15', '2027-06-30', 1);

IF NOT EXISTS (SELECT 1 FROM HocKys WHERE TenHocKy = N'Học kỳ hè' AND NamHoc = '2025-2026')
    INSERT INTO HocKys (TenHocKy, NamHoc, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Học kỳ hè', '2025-2026', '2026-06-01', '2026-08-15', 0);
GO

-- ==============================================================================
-- 3. KHỞI TẠO TÀI KHOẢN ADMIN, GIÁO VỤ, PHÒNG ĐÀO TẠO VÀ 6 GIẢNG VIÊN
-- ==============================================================================

DECLARE @PasswordHash NVARCHAR(500) = N'$2b$12$3l0Sgmr43kRU5Ie78igHvOH72BSXBx/xJmhx6gy47gOxG8lxYExXW'; -- Password: "123456"
DECLARE @VaiTroAdmin INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'ADMIN');
DECLARE @VaiTroGVK   INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'GIAOVUKHOA');
DECLARE @VaiTroPDT   INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'PHONGDAOTAO');
DECLARE @VaiTroGV    INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'GIANGVIEN');

DECLARE @KhoaCNTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'CNTT');
DECLARE @KhoaKTPM INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KTPM');
DECLARE @KhoaHTTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'HTTT');
DECLARE @KhoaKHMT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KHMT');
DECLARE @KhoaATTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'ATTT');

-- 3.1 Admin & Quản lý
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'admin.demo')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('admin.demo', @PasswordHash, 'admin.demo@example.com', N'Quản trị viên Demo', @VaiTroAdmin, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'admin01')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('admin01', @PasswordHash, 'admin01@progroup.edu.vn', N'Nguyễn Văn Quản Trị', @VaiTroAdmin, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'gvk.demo')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('gvk.demo', @PasswordHash, 'gvk.demo@example.com', N'Giáo vụ Khoa Demo', @VaiTroGVK, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'giaovu01')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('giaovu01', @PasswordHash, 'giaovu01@progroup.edu.vn', N'Trần Thị Giáo Vụ', @VaiTroGVK, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'pdt.demo')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('pdt.demo', @PasswordHash, 'pdt.demo@example.com', N'Phòng Đào tạo Demo', @VaiTroPDT, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'daotao01')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('daotao01', @PasswordHash, 'daotao01@progroup.edu.vn', N'Lê Minh Đào Tạo', @VaiTroPDT, 1);

-- 3.2 6 Giảng viên
-- GV001
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'GV001')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('GV001', @PasswordHash, 'gv001@example.com', N'Nguyễn Văn Giảng', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV001')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV001', @KhoaCNTT, N'Thạc sĩ', N'Phát triển ứng dụng di động & Web'
    FROM NguoiDungs WHERE TenDangNhap = 'GV001';

-- GV002
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'GV002')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('GV002', @PasswordHash, 'gv002@example.com', N'Trần Thị Mai Lan', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV002')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV002', @KhoaKTPM, N'Tiến sĩ', N'Kỹ thuật phần mềm & Agile/Scrum'
    FROM NguoiDungs WHERE TenDangNhap = 'GV002';

-- GV003
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'GV003')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('GV003', @PasswordHash, 'gv003@example.com', N'Lê Hoàng Nam', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV003')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV003', @KhoaKHMT, N'Tiến sĩ', N'Trí tuệ nhân tạo & Deep Learning'
    FROM NguoiDungs WHERE TenDangNhap = 'GV003';

-- GV004
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'GV004')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('GV004', @PasswordHash, 'gv004@example.com', N'Phạm Quốc Hùng', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV004')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV004', @KhoaHTTT, N'Thạc sĩ', N'Cơ sở dữ liệu lớn & Big Data'
    FROM NguoiDungs WHERE TenDangNhap = 'GV004';

-- GV005
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'GV005')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('GV005', @PasswordHash, 'gv005@example.com', N'Đặng Minh Tuấn', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV005')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV005', @KhoaATTT, N'Thạc sĩ', N'Kiểm thử tự động & An toàn thông tin'
    FROM NguoiDungs WHERE TenDangNhap = 'GV005';

-- GV006
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'GV006')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('GV006', @PasswordHash, 'gv006@example.com', N'Vũ Thị Bích Ngọc', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV006')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV006', @KhoaCNTT, N'Tiến sĩ', N'Điện toán đám mây & Fullstack Web'
    FROM NguoiDungs WHERE TenDangNhap = 'GV006';
GO

-- ==============================================================================
-- 4. HỌC PHẦN, LỚP HỌC PHẦN VÀ PHÂN CÔNG GIẢNG VIÊN
-- ==============================================================================

DECLARE @HocKy1 INT = (SELECT TOP 1 HocKyId FROM HocKys WHERE TenHocKy = N'Học kỳ 1' AND NamHoc = '2026-2027');
DECLARE @KhoaCNTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'CNTT');
DECLARE @KhoaKTPM INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KTPM');
DECLARE @KhoaHTTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'HTTT');
DECLARE @KhoaKHMT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KHMT');
DECLARE @KhoaATTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'ATTT');

-- 4.1 Danh mục Học phần
IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'LTDD')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('LTDD', N'Lập trình di động', 3, @KhoaCNTT, N'Phát triển ứng dụng Flutter/Android/iOS', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'CNPM')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('CNPM', N'Công nghệ phần mềm', 3, @KhoaKTPM, N'Quy trình phát triển phần mềm và kiến trúc', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'AI')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('AI', N'Trí tuệ nhân tạo', 3, @KhoaKHMT, N'Mô hình học máy, Deep Learning và LLM', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'CSDL')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('CSDL', N'Cơ sở dữ liệu nâng cao', 3, @KhoaHTTT, N'Tối ưu hóa chỉ mục, phân tán và NoSQL', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'KTPM')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('KTPM', N'Kiểm thử phần mềm', 3, @KhoaATTT, N'Kiểm thử tự động, CI/CD và bảo mật', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'WDEV')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('WDEV', N'Phát triển ứng dụng Web', 3, @KhoaCNTT, N'Phát triển Web Fullstack với .NET Core & React', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'ATTT')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('ATTT', N'An toàn thông tin ứng dụng', 3, @KhoaATTT, N'Bảo mật ứng dụng, mã hóa và an ninh mạng', 1);

DECLARE @HpLTDD INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'LTDD');
DECLARE @HpCNPM INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'CNPM');
DECLARE @HpAI   INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'AI');
DECLARE @HpCSDL INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'CSDL');
DECLARE @HpKTPM INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'KTPM');
DECLARE @HpWDEV INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'WDEV');
DECLARE @HpATTT INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'ATTT');

-- 4.2 Lớp học phần
IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('LTDD-01', N'Lập trình di động - Nhóm 01', @HpLTDD, @HocKy1, @KhoaCNTT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-02')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('LTDD-02', N'Lập trình di động - Nhóm 02', @HpLTDD, @HocKy1, @KhoaCNTT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('CNPM-01', N'Công nghệ phần mềm - Nhóm 01', @HpCNPM, @HocKy1, @KhoaKTPM, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-02')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('CNPM-02', N'Công nghệ phần mềm - Nhóm 02', @HpCNPM, @HocKy1, @KhoaKTPM, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'AI-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('AI-01', N'Trí tuệ nhân tạo - Nhóm 01', @HpAI, @HocKy1, @KhoaKHMT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'AI-02')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('AI-02', N'Trí tuệ nhân tạo - Nhóm 02', @HpAI, @HocKy1, @KhoaKHMT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('CSDL-01', N'Cơ sở dữ liệu - Nhóm 01', @HpCSDL, @HocKy1, @KhoaHTTT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-02')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('CSDL-02', N'Cơ sở dữ liệu - Nhóm 02', @HpCSDL, @HocKy1, @KhoaHTTT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'KTPM-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('KTPM-01', N'Kiểm thử phần mềm - Nhóm 01', @HpKTPM, @HocKy1, @KhoaATTT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'KTPM-02')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('KTPM-02', N'Kiểm thử phần mềm - Nhóm 02', @HpKTPM, @HocKy1, @KhoaATTT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'WDEV-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('WDEV-01', N'Phát triển ứng dụng Web - Nhóm 01', @HpWDEV, @HocKy1, @KhoaCNTT, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'ATTT-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('ATTT-01', N'An toàn thông tin - Nhóm 01', @HpATTT, @HocKy1, @KhoaATTT, 50, 1);

-- 4.3 Phân công giảng viên
DECLARE @GV1 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV001');
DECLARE @GV2 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV002');
DECLARE @GV3 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV003');
DECLARE @GV4 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV004');
DECLARE @GV5 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV005');
DECLARE @GV6 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV006');

DECLARE @LhpLTDD1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-01');
DECLARE @LhpLTDD2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-02');
DECLARE @LhpCNPM1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-01');
DECLARE @LhpCNPM2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-02');
DECLARE @LhpAI1   INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'AI-01');
DECLARE @LhpAI2   INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'AI-02');
DECLARE @LhpCSDL1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-01');
DECLARE @LhpCSDL2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-02');
DECLARE @LhpKTPM1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'KTPM-01');
DECLARE @LhpKTPM2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'KTPM-02');
DECLARE @LhpWDEV1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'WDEV-01');
DECLARE @LhpATTT1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'ATTT-01');

IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpLTDD1 AND GiangVienId = @GV1)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpLTDD1, @GV1);
IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpLTDD2 AND GiangVienId = @GV1)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpLTDD2, @GV1);

IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpCNPM1 AND GiangVienId = @GV2)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpCNPM1, @GV2);
IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpCNPM2 AND GiangVienId = @GV2)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpCNPM2, @GV2);

IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpAI1 AND GiangVienId = @GV3)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpAI1, @GV3);
IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpAI2 AND GiangVienId = @GV3)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpAI2, @GV3);

IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpCSDL1 AND GiangVienId = @GV4)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpCSDL1, @GV4);
IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpCSDL2 AND GiangVienId = @GV4)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpCSDL2, @GV4);

IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpKTPM1 AND GiangVienId = @GV5)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpKTPM1, @GV5);
IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpKTPM2 AND GiangVienId = @GV5)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpKTPM2, @GV5);

IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpWDEV1 AND GiangVienId = @GV6)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpWDEV1, @GV6);
IF NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpATTT1 AND GiangVienId = @GV5)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId) VALUES (@LhpATTT1, @GV5);
GO

-- ==============================================================================
-- 5. ĐỢT ĐĂNG KÝ ĐỒ ÁN (ĐANG MỞ, CHƯA MỞ, ĐÃ ĐÓNG)
-- ==============================================================================

DECLARE @LhpLTDD1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-01');
DECLARE @LhpLTDD2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-02');
DECLARE @LhpCNPM1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-01');
DECLARE @LhpCNPM2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-02');
DECLARE @LhpAI1   INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'AI-01');
DECLARE @LhpAI2   INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'AI-02');
DECLARE @LhpCSDL1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-01');
DECLARE @LhpCSDL2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-02');
DECLARE @LhpKTPM1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'KTPM-01');
DECLARE @LhpWDEV1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'WDEV-01');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpLTDD1 AND TenDot = N'Đợt đăng ký đồ án Demo 2026')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpLTDD1, N'Đợt đăng ký đồ án Demo 2026', DATEADD(DAY, -15, SYSDATETIME()), DATEADD(DAY, 45, SYSDATETIME()), 3, 5, N'Đang mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpLTDD2 AND TenDot = N'Đợt đăng ký đồ án Di động N02')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpLTDD2, N'Đợt đăng ký đồ án Di động N02', DATEADD(DAY, -10, SYSDATETIME()), DATEADD(DAY, 45, SYSDATETIME()), 3, 5, N'Đang mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCNPM1 AND TenDot = N'Đợt đăng ký đồ án Công nghệ phần mềm K21')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpCNPM1, N'Đợt đăng ký đồ án Công nghệ phần mềm K21', DATEADD(DAY, -12, SYSDATETIME()), DATEADD(DAY, 50, SYSDATETIME()), 3, 5, N'Đang mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpAI1 AND TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpAI1, N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01', DATEADD(DAY, -10, SYSDATETIME()), DATEADD(DAY, 50, SYSDATETIME()), 2, 4, N'Đang mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpAI2 AND TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N02')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpAI2, N'Đợt đăng ký đồ án Trí tuệ nhân tạo N02', DATEADD(DAY, 10, SYSDATETIME()), DATEADD(DAY, 70, SYSDATETIME()), 2, 4, N'Chưa mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCSDL1 AND TenDot = N'Đợt đăng ký đồ án CSDL N01')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpCSDL1, N'Đợt đăng ký đồ án CSDL N01', DATEADD(DAY, -8, SYSDATETIME()), DATEADD(DAY, 52, SYSDATETIME()), 2, 3, N'Đang mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCSDL2 AND TenDot = N'Đợt đăng ký đồ án CSDL Nâng cao 2026')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpCSDL2, N'Đợt đăng ký đồ án CSDL Nâng cao 2026', DATEADD(DAY, -5, SYSDATETIME()), DATEADD(DAY, 55, SYSDATETIME()), 2, 3, N'Đang mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpKTPM1 AND TenDot = N'Đợt đăng ký đồ án Kiểm thử phần mềm 2026')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpKTPM1, N'Đợt đăng ký đồ án Kiểm thử phần mềm 2026', DATEADD(DAY, -14, SYSDATETIME()), DATEADD(DAY, 40, SYSDATETIME()), 2, 4, N'Đang mở');

IF NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpWDEV1 AND TenDot = N'Đợt đăng ký đồ án Phát triển Web Fullstack')
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpWDEV1, N'Đợt đăng ký đồ án Phát triển Web Fullstack', DATEADD(DAY, -60, SYSDATETIME()), DATEADD(DAY, -5, SYSDATETIME()), 3, 5, N'Đã đóng');
GO

-- ==============================================================================
-- 6. BỔ SUNG 250 SINH VIÊN (SV001 -> SV250) ĐẦY ĐỦ THÔNG TIN, EMAIL, HỌ TÊN
-- ==============================================================================

DECLARE @PasswordHash NVARCHAR(500) = N'$2b$12$3l0Sgmr43kRU5Ie78igHvOH72BSXBx/xJmhx6gy47gOxG8lxYExXW';
DECLARE @VaiTroSV INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'SINHVIEN');
DECLARE @KhoaCNTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'CNTT');
DECLARE @KhoaKTPM INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KTPM');
DECLARE @KhoaHTTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'HTTT');
DECLARE @KhoaKHMT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KHMT');
DECLARE @KhoaATTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'ATTT');


-- Tạo bảng tạm để nạp 250 sinh viên mẫu
DECLARE @TempStudents TABLE (
    MSSV VARCHAR(30),
    HoTen NVARCHAR(200),
    Email VARCHAR(150),
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    MaKhoa VARCHAR(20)
);

INSERT INTO @TempStudents (MSSV, HoTen, Email, NgaySinh, GioiTinh, MaKhoa)
VALUES

('SV001', N'Trần Minh An', 'sv001@example.com', '2005-01-15', N'Nam', 'CNTT'),
('SV002', N'Lê Hoàng Bình', 'sv002@example.com', '2005-03-20', N'Nam', 'CNTT'),
('SV003', N'Phạm Gia Huy', 'sv003@example.com', '2005-06-10', N'Nam', 'CNTT'),
('SV004', N'Võ Ngọc Mai', 'sv004@example.com', '2005-08-12', N'Nữ', 'CNTT'),
('SV005', N'Đặng Quốc Khánh', 'sv005@example.com', '2005-11-05', N'Nữ', 'CNTT'),
('SV006', N'Phan Văn Kiên', 'sv006@example.com', '2003-07-19', N'Nam', 'KTPM'),
('SV007', N'Vũ Đức Quân', 'sv007@example.com', '2004-08-22', N'Nam', 'HTTT'),
('SV008', N'Võ Phương Quỳnh', 'sv008@example.com', '2005-09-25', N'Nữ', 'KHMT'),
('SV009', N'Đặng Huy Bình', 'sv009@example.com', '2003-10-28', N'Nam', 'ATTT'),
('SV010', N'Bùi Diệu Lan', 'sv010@example.com', '2004-11-03', N'Nữ', 'CNTT'),
('SV011', N'Đỗ Công Nghĩa', 'sv011@example.com', '2005-12-06', N'Nam', 'KTPM'),
('SV012', N'Hồ Văn Thành', 'sv012@example.com', '2003-01-09', N'Nam', 'HTTT'),
('SV013', N'Ngô Đức Việt', 'sv013@example.com', '2004-02-12', N'Nam', 'KHMT'),
('SV014', N'Dương Hà Quỳnh', 'sv014@example.com', '2005-03-15', N'Nữ', 'ATTT'),
('SV015', N'Lý Huy Long', 'sv015@example.com', '2003-04-18', N'Nam', 'CNTT'),
('SV016', N'Lương Mai Lan', 'sv016@example.com', '2004-05-21', N'Nữ', 'KTPM'),
('SV017', N'Trịnh Công Trung', 'sv017@example.com', '2005-06-24', N'Nam', 'HTTT'),
('SV018', N'Đinh Văn Cường', 'sv018@example.com', '2003-07-27', N'Nam', 'KHMT'),
('SV019', N'Đoàn Đức Huy', 'sv019@example.com', '2004-08-02', N'Nam', 'ATTT'),
('SV020', N'Mai Bích Quỳnh', 'sv020@example.com', '2005-09-05', N'Nữ', 'CNTT'),
('SV021', N'Nguyễn Huy Thịnh', 'sv021@example.com', '2003-10-08', N'Nam', 'KTPM'),
('SV022', N'Trần Thùy Lan', 'sv022@example.com', '2004-11-11', N'Nữ', 'HTTT'),
('SV023', N'Lê Công Hải', 'sv023@example.com', '2005-12-14', N'Nam', 'KHMT'),
('SV024', N'Phạm Văn Minh', 'sv024@example.com', '2003-01-17', N'Nam', 'ATTT'),
('SV025', N'Hoàng Đức Tâm', 'sv025@example.com', '2004-02-20', N'Nam', 'CNTT'),
('SV026', N'Huỳnh Phương Quỳnh', 'sv026@example.com', '2005-03-23', N'Nữ', 'KTPM'),
('SV027', N'Phan Huy Dũng', 'sv027@example.com', '2003-04-26', N'Nam', 'HTTT'),
('SV028', N'Vũ Diệu Lan', 'sv028@example.com', '2004-05-01', N'Nữ', 'KHMT'),
('SV029', N'Võ Công Phúc', 'sv029@example.com', '2005-06-04', N'Nam', 'ATTT'),
('SV030', N'Đặng Văn Tiến', 'sv030@example.com', '2003-07-07', N'Nam', 'CNTT'),
('SV031', N'Bùi Đức An', 'sv031@example.com', '2004-08-10', N'Nam', 'KTPM'),
('SV032', N'Đỗ Hà Quỳnh', 'sv032@example.com', '2005-09-13', N'Nữ', 'HTTT'),
('SV033', N'Hồ Huy Nam', 'sv033@example.com', '2003-10-16', N'Nam', 'KHMT'),
('SV034', N'Ngô Mai Lan', 'sv034@example.com', '2004-11-19', N'Nữ', 'ATTT'),
('SV035', N'Dương Công Tùng', 'sv035@example.com', '2005-12-22', N'Nam', 'CNTT'),
('SV036', N'Lý Văn Đạt', 'sv036@example.com', '2003-01-25', N'Nam', 'KTPM'),
('SV037', N'Lương Đức Kiên', 'sv037@example.com', '2004-02-28', N'Nam', 'HTTT'),
('SV038', N'Trịnh Bích Quỳnh', 'sv038@example.com', '2005-03-03', N'Nữ', 'KHMT'),
('SV039', N'Đinh Huy Toàn', 'sv039@example.com', '2003-04-06', N'Nam', 'ATTT'),
('SV040', N'Đoàn Thùy Lan', 'sv040@example.com', '2004-05-09', N'Nữ', 'CNTT'),
('SV041', N'Mai Công Hùng', 'sv041@example.com', '2005-06-12', N'Nam', 'KTPM'),
('SV042', N'Nguyễn Văn Nghĩa', 'sv042@example.com', '2003-07-15', N'Nam', 'HTTT'),
('SV043', N'Trần Đức Thành', 'sv043@example.com', '2004-08-18', N'Nam', 'KHMT'),
('SV044', N'Lê Phương Quỳnh', 'sv044@example.com', '2005-09-21', N'Nữ', 'ATTT'),
('SV045', N'Phạm Huy Giang', 'sv045@example.com', '2003-10-24', N'Nam', 'CNTT'),
('SV046', N'Hoàng Diệu Lan', 'sv046@example.com', '2004-11-27', N'Nữ', 'KTPM'),
('SV047', N'Huỳnh Công Sơn', 'sv047@example.com', '2005-12-02', N'Nam', 'HTTT'),
('SV048', N'Phan Văn Trung', 'sv048@example.com', '2003-01-05', N'Nam', 'KHMT'),
('SV049', N'Vũ Đức Cường', 'sv049@example.com', '2004-02-08', N'Nam', 'ATTT'),
('SV050', N'Võ Hà Quỳnh', 'sv050@example.com', '2005-03-11', N'Nữ', 'CNTT'),
('SV051', N'Đặng Huy Nhân', 'sv051@example.com', '2003-04-14', N'Nam', 'KTPM'),
('SV052', N'Bùi Mai Lan', 'sv052@example.com', '2004-05-17', N'Nữ', 'HTTT'),
('SV053', N'Đỗ Công Vũ', 'sv053@example.com', '2005-06-20', N'Nam', 'KHMT'),
('SV054', N'Hồ Văn Hải', 'sv054@example.com', '2003-07-23', N'Nam', 'ATTT'),
('SV055', N'Ngô Đức Minh', 'sv055@example.com', '2004-08-26', N'Nam', 'CNTT'),
('SV056', N'Dương Bích Quỳnh', 'sv056@example.com', '2005-09-01', N'Nữ', 'KTPM'),
('SV057', N'Lý Huy Tuấn', 'sv057@example.com', '2003-10-04', N'Nam', 'HTTT'),
('SV058', N'Lương Thùy Lan', 'sv058@example.com', '2004-11-07', N'Nữ', 'KHMT'),
('SV059', N'Trịnh Công Khoa', 'sv059@example.com', '2005-12-10', N'Nam', 'ATTT'),
('SV060', N'Đinh Văn Phúc', 'sv060@example.com', '2003-01-13', N'Nam', 'CNTT'),
('SV061', N'Đoàn Đức Tiến', 'sv061@example.com', '2004-02-16', N'Nam', 'KTPM'),
('SV062', N'Mai Phương Quỳnh', 'sv062@example.com', '2005-03-19', N'Nữ', 'HTTT'),
('SV063', N'Nguyễn Huy Hiếu', 'sv063@example.com', '2003-04-22', N'Nam', 'KHMT'),
('SV064', N'Trần Diệu Lan', 'sv064@example.com', '2004-05-25', N'Nữ', 'ATTT'),
('SV065', N'Lê Công Thắng', 'sv065@example.com', '2005-06-28', N'Nam', 'CNTT'),
('SV066', N'Phạm Văn Tùng', 'sv066@example.com', '2003-07-03', N'Nam', 'KTPM'),
('SV067', N'Hoàng Đức Đạt', 'sv067@example.com', '2004-08-06', N'Nam', 'HTTT'),
('SV068', N'Huỳnh Hà Quỳnh', 'sv068@example.com', '2005-09-09', N'Nữ', 'KHMT'),
('SV069', N'Phan Huy Quân', 'sv069@example.com', '2003-10-12', N'Nam', 'ATTT'),
('SV070', N'Vũ Mai Lan', 'sv070@example.com', '2004-11-15', N'Nữ', 'CNTT'),
('SV071', N'Võ Công Bình', 'sv071@example.com', '2005-12-18', N'Nam', 'KTPM'),
('SV072', N'Đặng Văn Hùng', 'sv072@example.com', '2003-01-21', N'Nam', 'HTTT'),
('SV073', N'Bùi Đức Nghĩa', 'sv073@example.com', '2004-02-24', N'Nam', 'KHMT'),
('SV074', N'Đỗ Bích Quỳnh', 'sv074@example.com', '2005-03-27', N'Nữ', 'ATTT'),
('SV075', N'Hồ Huy Việt', 'sv075@example.com', '2003-04-02', N'Nam', 'CNTT'),
('SV076', N'Ngô Thùy Lan', 'sv076@example.com', '2004-05-05', N'Nữ', 'KTPM'),
('SV077', N'Dương Công Long', 'sv077@example.com', '2005-06-08', N'Nam', 'HTTT'),
('SV078', N'Lý Văn Sơn', 'sv078@example.com', '2003-07-11', N'Nam', 'KHMT'),
('SV079', N'Lương Đức Trung', 'sv079@example.com', '2004-08-14', N'Nam', 'ATTT'),
('SV080', N'Trịnh Phương Quỳnh', 'sv080@example.com', '2005-09-17', N'Nữ', 'CNTT'),
('SV081', N'Đinh Huy Huy', 'sv081@example.com', '2003-10-20', N'Nam', 'KTPM'),
('SV082', N'Đoàn Diệu Lan', 'sv082@example.com', '2004-11-23', N'Nữ', 'HTTT'),
('SV083', N'Mai Công Thịnh', 'sv083@example.com', '2005-12-26', N'Nam', 'KHMT'),
('SV084', N'Nguyễn Văn Vũ', 'sv084@example.com', '2003-01-01', N'Nam', 'ATTT'),
('SV085', N'Trần Đức Hải', 'sv085@example.com', '2004-02-04', N'Nam', 'CNTT'),
('SV086', N'Lê Hà Quỳnh', 'sv086@example.com', '2005-03-07', N'Nữ', 'KTPM'),
('SV087', N'Phạm Huy Tâm', 'sv087@example.com', '2003-04-10', N'Nam', 'HTTT'),
('SV088', N'Hoàng Mai Lan', 'sv088@example.com', '2004-05-13', N'Nữ', 'KHMT'),
('SV089', N'Huỳnh Công Dũng', 'sv089@example.com', '2005-06-16', N'Nam', 'ATTT'),
('SV090', N'Phan Văn Khoa', 'sv090@example.com', '2003-07-19', N'Nam', 'CNTT'),
('SV091', N'Vũ Đức Phúc', 'sv091@example.com', '2004-08-22', N'Nam', 'KTPM'),
('SV092', N'Võ Bích Quỳnh', 'sv092@example.com', '2005-09-25', N'Nữ', 'HTTT'),
('SV093', N'Đặng Huy An', 'sv093@example.com', '2003-10-28', N'Nam', 'KHMT'),
('SV094', N'Bùi Thùy Lan', 'sv094@example.com', '2004-11-03', N'Nữ', 'ATTT'),
('SV095', N'Đỗ Công Nam', 'sv095@example.com', '2005-12-06', N'Nam', 'CNTT'),
('SV096', N'Hồ Văn Thắng', 'sv096@example.com', '2003-01-09', N'Nam', 'KTPM'),
('SV097', N'Ngô Đức Tùng', 'sv097@example.com', '2004-02-12', N'Nam', 'HTTT'),
('SV098', N'Dương Phương Quỳnh', 'sv098@example.com', '2005-03-15', N'Nữ', 'KHMT'),
('SV099', N'Lý Huy Kiên', 'sv099@example.com', '2003-04-18', N'Nam', 'ATTT'),
('SV100', N'Lương Diệu Lan', 'sv100@example.com', '2004-05-21', N'Nữ', 'CNTT'),
('SV101', N'Trịnh Công Toàn', 'sv101@example.com', '2005-06-24', N'Nam', 'KTPM'),
('SV102', N'Đinh Văn Bình', 'sv102@example.com', '2003-07-27', N'Nam', 'HTTT'),
('SV103', N'Đoàn Đức Hùng', 'sv103@example.com', '2004-08-02', N'Nam', 'KHMT'),
('SV104', N'Mai Hà Quỳnh', 'sv104@example.com', '2005-09-05', N'Nữ', 'ATTT'),
('SV105', N'Nguyễn Huy Thành', 'sv105@example.com', '2003-10-08', N'Nam', 'CNTT'),
('SV106', N'Trần Mai Lan', 'sv106@example.com', '2004-11-11', N'Nữ', 'KTPM'),
('SV107', N'Lê Công Giang', 'sv107@example.com', '2005-12-14', N'Nam', 'HTTT'),
('SV108', N'Phạm Văn Long', 'sv108@example.com', '2003-01-17', N'Nam', 'KHMT'),
('SV109', N'Hoàng Đức Sơn', 'sv109@example.com', '2004-02-20', N'Nam', 'ATTT'),
('SV110', N'Huỳnh Bích Quỳnh', 'sv110@example.com', '2005-03-23', N'Nữ', 'CNTT'),
('SV111', N'Phan Huy Cường', 'sv111@example.com', '2003-04-26', N'Nam', 'KTPM'),
('SV112', N'Vũ Thùy Lan', 'sv112@example.com', '2004-05-01', N'Nữ', 'HTTT'),
('SV113', N'Võ Công Nhân', 'sv113@example.com', '2005-06-04', N'Nam', 'KHMT'),
('SV114', N'Đặng Văn Thịnh', 'sv114@example.com', '2003-07-07', N'Nam', 'ATTT'),
('SV115', N'Bùi Đức Vũ', 'sv115@example.com', '2004-08-10', N'Nam', 'CNTT'),
('SV116', N'Đỗ Phương Quỳnh', 'sv116@example.com', '2005-09-13', N'Nữ', 'KTPM'),
('SV117', N'Hồ Huy Minh', 'sv117@example.com', '2003-10-16', N'Nam', 'HTTT'),
('SV118', N'Ngô Diệu Lan', 'sv118@example.com', '2004-11-19', N'Nữ', 'KHMT'),
('SV119', N'Dương Công Tuấn', 'sv119@example.com', '2005-12-22', N'Nam', 'ATTT'),
('SV120', N'Lý Văn Dũng', 'sv120@example.com', '2003-01-25', N'Nam', 'CNTT'),
('SV121', N'Lương Đức Khoa', 'sv121@example.com', '2004-02-28', N'Nam', 'KTPM'),
('SV122', N'Trịnh Hà Quỳnh', 'sv122@example.com', '2005-03-03', N'Nữ', 'HTTT'),
('SV123', N'Đinh Huy Tiến', 'sv123@example.com', '2003-04-06', N'Nam', 'KHMT'),
('SV124', N'Đoàn Mai Lan', 'sv124@example.com', '2004-05-09', N'Nữ', 'ATTT'),
('SV125', N'Mai Công Hiếu', 'sv125@example.com', '2005-06-12', N'Nam', 'CNTT'),
('SV126', N'Nguyễn Văn Nam', 'sv126@example.com', '2003-07-15', N'Nam', 'KTPM'),
('SV127', N'Trần Đức Thắng', 'sv127@example.com', '2004-08-18', N'Nam', 'HTTT'),
('SV128', N'Lê Bích Quỳnh', 'sv128@example.com', '2005-09-21', N'Nữ', 'KHMT'),
('SV129', N'Phạm Huy Đạt', 'sv129@example.com', '2003-10-24', N'Nam', 'ATTT'),
('SV130', N'Hoàng Thùy Lan', 'sv130@example.com', '2004-11-27', N'Nữ', 'CNTT'),
('SV131', N'Huỳnh Công Quân', 'sv131@example.com', '2005-12-02', N'Nam', 'KTPM'),
('SV132', N'Phan Văn Toàn', 'sv132@example.com', '2003-01-05', N'Nam', 'HTTT'),
('SV133', N'Vũ Đức Bình', 'sv133@example.com', '2004-02-08', N'Nam', 'KHMT'),
('SV134', N'Võ Phương Quỳnh', 'sv134@example.com', '2005-03-11', N'Nữ', 'ATTT'),
('SV135', N'Đặng Huy Nghĩa', 'sv135@example.com', '2003-04-14', N'Nam', 'CNTT'),
('SV136', N'Bùi Diệu Lan', 'sv136@example.com', '2004-05-17', N'Nữ', 'KTPM'),
('SV137', N'Đỗ Công Việt', 'sv137@example.com', '2005-06-20', N'Nam', 'HTTT'),
('SV138', N'Hồ Văn Giang', 'sv138@example.com', '2003-07-23', N'Nam', 'KHMT'),
('SV139', N'Ngô Đức Long', 'sv139@example.com', '2004-08-26', N'Nam', 'ATTT'),
('SV140', N'Dương Hà Quỳnh', 'sv140@example.com', '2005-09-01', N'Nữ', 'CNTT'),
('SV141', N'Lý Huy Trung', 'sv141@example.com', '2003-10-04', N'Nam', 'KTPM'),
('SV142', N'Lương Mai Lan', 'sv142@example.com', '2004-11-07', N'Nữ', 'HTTT'),
('SV143', N'Trịnh Công Huy', 'sv143@example.com', '2005-12-10', N'Nam', 'KHMT'),
('SV144', N'Đinh Văn Nhân', 'sv144@example.com', '2003-01-13', N'Nam', 'ATTT'),
('SV145', N'Đoàn Đức Thịnh', 'sv145@example.com', '2004-02-16', N'Nam', 'CNTT'),
('SV146', N'Mai Bích Quỳnh', 'sv146@example.com', '2005-03-19', N'Nữ', 'KTPM'),
('SV147', N'Nguyễn Huy Hải', 'sv147@example.com', '2003-04-22', N'Nam', 'HTTT'),
('SV148', N'Trần Thùy Lan', 'sv148@example.com', '2004-05-25', N'Nữ', 'KHMT'),
('SV149', N'Lê Công Tâm', 'sv149@example.com', '2005-06-28', N'Nam', 'ATTT'),
('SV150', N'Phạm Văn Tuấn', 'sv150@example.com', '2003-07-03', N'Nam', 'CNTT'),
('SV151', N'Hoàng Đức Dũng', 'sv151@example.com', '2004-08-06', N'Nam', 'KTPM'),
('SV152', N'Huỳnh Phương Quỳnh', 'sv152@example.com', '2005-09-09', N'Nữ', 'HTTT'),
('SV153', N'Phan Huy Phúc', 'sv153@example.com', '2003-10-12', N'Nam', 'KHMT'),
('SV154', N'Vũ Diệu Lan', 'sv154@example.com', '2004-11-15', N'Nữ', 'ATTT'),
('SV155', N'Võ Công An', 'sv155@example.com', '2005-12-18', N'Nam', 'CNTT'),
('SV156', N'Đặng Văn Hiếu', 'sv156@example.com', '2003-01-21', N'Nam', 'KTPM'),
('SV157', N'Bùi Đức Nam', 'sv157@example.com', '2004-02-24', N'Nam', 'HTTT'),
('SV158', N'Đỗ Hà Quỳnh', 'sv158@example.com', '2005-03-27', N'Nữ', 'KHMT'),
('SV159', N'Hồ Huy Tùng', 'sv159@example.com', '2003-04-02', N'Nam', 'ATTT'),
('SV160', N'Ngô Mai Lan', 'sv160@example.com', '2004-05-05', N'Nữ', 'CNTT'),
('SV161', N'Dương Công Kiên', 'sv161@example.com', '2005-06-08', N'Nam', 'KTPM'),
('SV162', N'Lý Văn Quân', 'sv162@example.com', '2003-07-11', N'Nam', 'HTTT'),
('SV163', N'Lương Đức Toàn', 'sv163@example.com', '2004-08-14', N'Nam', 'KHMT'),
('SV164', N'Trịnh Bích Quỳnh', 'sv164@example.com', '2005-09-17', N'Nữ', 'ATTT'),
('SV165', N'Đinh Huy Hùng', 'sv165@example.com', '2003-10-20', N'Nam', 'CNTT'),
('SV166', N'Đoàn Thùy Lan', 'sv166@example.com', '2004-11-23', N'Nữ', 'KTPM'),
('SV167', N'Mai Công Thành', 'sv167@example.com', '2005-12-26', N'Nam', 'HTTT'),
('SV168', N'Nguyễn Văn Việt', 'sv168@example.com', '2003-01-01', N'Nam', 'KHMT'),
('SV169', N'Trần Đức Giang', 'sv169@example.com', '2004-02-04', N'Nam', 'ATTT'),
('SV170', N'Lê Phương Quỳnh', 'sv170@example.com', '2005-03-07', N'Nữ', 'CNTT'),
('SV171', N'Phạm Huy Sơn', 'sv171@example.com', '2003-04-10', N'Nam', 'KTPM'),
('SV172', N'Hoàng Diệu Lan', 'sv172@example.com', '2004-05-13', N'Nữ', 'HTTT'),
('SV173', N'Huỳnh Công Cường', 'sv173@example.com', '2005-06-16', N'Nam', 'KHMT'),
('SV174', N'Phan Văn Huy', 'sv174@example.com', '2003-07-19', N'Nam', 'ATTT'),
('SV175', N'Vũ Đức Nhân', 'sv175@example.com', '2004-08-22', N'Nam', 'CNTT'),
('SV176', N'Võ Hà Quỳnh', 'sv176@example.com', '2005-09-25', N'Nữ', 'KTPM'),
('SV177', N'Đặng Huy Vũ', 'sv177@example.com', '2003-10-28', N'Nam', 'HTTT'),
('SV178', N'Bùi Mai Lan', 'sv178@example.com', '2004-11-03', N'Nữ', 'KHMT'),
('SV179', N'Đỗ Công Minh', 'sv179@example.com', '2005-12-06', N'Nam', 'ATTT'),
('SV180', N'Hồ Văn Tâm', 'sv180@example.com', '2003-01-09', N'Nam', 'CNTT'),
('SV181', N'Ngô Đức Tuấn', 'sv181@example.com', '2004-02-12', N'Nam', 'KTPM'),
('SV182', N'Dương Bích Quỳnh', 'sv182@example.com', '2005-03-15', N'Nữ', 'HTTT'),
('SV183', N'Lý Huy Khoa', 'sv183@example.com', '2003-04-18', N'Nam', 'KHMT'),
('SV184', N'Lương Thùy Lan', 'sv184@example.com', '2004-05-21', N'Nữ', 'ATTT'),
('SV185', N'Trịnh Công Tiến', 'sv185@example.com', '2005-06-24', N'Nam', 'CNTT'),
('SV186', N'Đinh Văn An', 'sv186@example.com', '2003-07-27', N'Nam', 'KTPM'),
('SV187', N'Đoàn Đức Hiếu', 'sv187@example.com', '2004-08-02', N'Nam', 'HTTT'),
('SV188', N'Mai Phương Quỳnh', 'sv188@example.com', '2005-09-05', N'Nữ', 'KHMT'),
('SV189', N'Nguyễn Huy Thắng', 'sv189@example.com', '2003-10-08', N'Nam', 'ATTT'),
('SV190', N'Trần Diệu Lan', 'sv190@example.com', '2004-11-11', N'Nữ', 'CNTT'),
('SV191', N'Lê Công Đạt', 'sv191@example.com', '2005-12-14', N'Nam', 'KTPM'),
('SV192', N'Phạm Văn Kiên', 'sv192@example.com', '2003-01-17', N'Nam', 'HTTT'),
('SV193', N'Hoàng Đức Quân', 'sv193@example.com', '2004-02-20', N'Nam', 'KHMT'),
('SV194', N'Huỳnh Hà Quỳnh', 'sv194@example.com', '2005-03-23', N'Nữ', 'ATTT'),
('SV195', N'Phan Huy Bình', 'sv195@example.com', '2003-04-26', N'Nam', 'CNTT'),
('SV196', N'Vũ Mai Lan', 'sv196@example.com', '2004-05-01', N'Nữ', 'KTPM'),
('SV197', N'Võ Công Nghĩa', 'sv197@example.com', '2005-06-04', N'Nam', 'HTTT'),
('SV198', N'Đặng Văn Thành', 'sv198@example.com', '2003-07-07', N'Nam', 'KHMT'),
('SV199', N'Bùi Đức Việt', 'sv199@example.com', '2004-08-10', N'Nam', 'ATTT'),
('SV200', N'Đỗ Bích Quỳnh', 'sv200@example.com', '2005-09-13', N'Nữ', 'CNTT'),
('SV201', N'Hồ Huy Long', 'sv201@example.com', '2003-10-16', N'Nam', 'KTPM'),
('SV202', N'Ngô Thùy Lan', 'sv202@example.com', '2004-11-19', N'Nữ', 'HTTT'),
('SV203', N'Dương Công Trung', 'sv203@example.com', '2005-12-22', N'Nam', 'KHMT'),
('SV204', N'Lý Văn Cường', 'sv204@example.com', '2003-01-25', N'Nam', 'ATTT'),
('SV205', N'Lương Đức Huy', 'sv205@example.com', '2004-02-28', N'Nam', 'CNTT'),
('SV206', N'Trịnh Phương Quỳnh', 'sv206@example.com', '2005-03-03', N'Nữ', 'KTPM'),
('SV207', N'Đinh Huy Thịnh', 'sv207@example.com', '2003-04-06', N'Nam', 'HTTT'),
('SV208', N'Đoàn Diệu Lan', 'sv208@example.com', '2004-05-09', N'Nữ', 'KHMT'),
('SV209', N'Mai Công Hải', 'sv209@example.com', '2005-06-12', N'Nam', 'ATTT'),
('SV210', N'Nguyễn Văn Minh', 'sv210@example.com', '2003-07-15', N'Nam', 'CNTT'),
('SV211', N'Trần Đức Tâm', 'sv211@example.com', '2004-08-18', N'Nam', 'KTPM'),
('SV212', N'Lê Hà Quỳnh', 'sv212@example.com', '2005-09-21', N'Nữ', 'HTTT'),
('SV213', N'Phạm Huy Dũng', 'sv213@example.com', '2003-10-24', N'Nam', 'KHMT'),
('SV214', N'Hoàng Mai Lan', 'sv214@example.com', '2004-11-27', N'Nữ', 'ATTT'),
('SV215', N'Huỳnh Công Phúc', 'sv215@example.com', '2005-12-02', N'Nam', 'CNTT'),
('SV216', N'Phan Văn Tiến', 'sv216@example.com', '2003-01-05', N'Nam', 'KTPM'),
('SV217', N'Vũ Đức An', 'sv217@example.com', '2004-02-08', N'Nam', 'HTTT'),
('SV218', N'Võ Bích Quỳnh', 'sv218@example.com', '2005-03-11', N'Nữ', 'KHMT'),
('SV219', N'Đặng Huy Nam', 'sv219@example.com', '2003-04-14', N'Nam', 'ATTT'),
('SV220', N'Bùi Thùy Lan', 'sv220@example.com', '2004-05-17', N'Nữ', 'CNTT'),
('SV221', N'Đỗ Công Tùng', 'sv221@example.com', '2005-06-20', N'Nam', 'KTPM'),
('SV222', N'Hồ Văn Đạt', 'sv222@example.com', '2003-07-23', N'Nam', 'HTTT'),
('SV223', N'Ngô Đức Kiên', 'sv223@example.com', '2004-08-26', N'Nam', 'KHMT'),
('SV224', N'Dương Phương Quỳnh', 'sv224@example.com', '2005-09-01', N'Nữ', 'ATTT'),
('SV225', N'Lý Huy Toàn', 'sv225@example.com', '2003-10-04', N'Nam', 'CNTT'),
('SV226', N'Lương Diệu Lan', 'sv226@example.com', '2004-11-07', N'Nữ', 'KTPM'),
('SV227', N'Trịnh Công Hùng', 'sv227@example.com', '2005-12-10', N'Nam', 'HTTT'),
('SV228', N'Đinh Văn Nghĩa', 'sv228@example.com', '2003-01-13', N'Nam', 'KHMT'),
('SV229', N'Đoàn Đức Thành', 'sv229@example.com', '2004-02-16', N'Nam', 'ATTT'),
('SV230', N'Mai Hà Quỳnh', 'sv230@example.com', '2005-03-19', N'Nữ', 'CNTT'),
('SV231', N'Nguyễn Huy Giang', 'sv231@example.com', '2003-04-22', N'Nam', 'KTPM'),
('SV232', N'Trần Mai Lan', 'sv232@example.com', '2004-05-25', N'Nữ', 'HTTT'),
('SV233', N'Lê Công Sơn', 'sv233@example.com', '2005-06-28', N'Nam', 'KHMT'),
('SV234', N'Phạm Văn Trung', 'sv234@example.com', '2003-07-03', N'Nam', 'ATTT'),
('SV235', N'Hoàng Đức Cường', 'sv235@example.com', '2004-08-06', N'Nam', 'CNTT'),
('SV236', N'Huỳnh Bích Quỳnh', 'sv236@example.com', '2005-09-09', N'Nữ', 'KTPM'),
('SV237', N'Phan Huy Nhân', 'sv237@example.com', '2003-10-12', N'Nam', 'HTTT'),
('SV238', N'Vũ Thùy Lan', 'sv238@example.com', '2004-11-15', N'Nữ', 'KHMT'),
('SV239', N'Võ Công Vũ', 'sv239@example.com', '2005-12-18', N'Nam', 'ATTT'),
('SV240', N'Đặng Văn Hải', 'sv240@example.com', '2003-01-21', N'Nam', 'CNTT'),
('SV241', N'Bùi Đức Minh', 'sv241@example.com', '2004-02-24', N'Nam', 'KTPM'),
('SV242', N'Đỗ Phương Quỳnh', 'sv242@example.com', '2005-03-27', N'Nữ', 'HTTT'),
('SV243', N'Hồ Huy Tuấn', 'sv243@example.com', '2003-04-02', N'Nam', 'KHMT'),
('SV244', N'Ngô Diệu Lan', 'sv244@example.com', '2004-05-05', N'Nữ', 'ATTT'),
('SV245', N'Dương Công Khoa', 'sv245@example.com', '2005-06-08', N'Nam', 'CNTT'),
('SV246', N'Lý Văn Phúc', 'sv246@example.com', '2003-07-11', N'Nam', 'KTPM'),
('SV247', N'Lương Đức Tiến', 'sv247@example.com', '2004-08-14', N'Nam', 'HTTT'),
('SV248', N'Trịnh Hà Quỳnh', 'sv248@example.com', '2005-09-17', N'Nữ', 'KHMT'),
('SV249', N'Đinh Huy Hiếu', 'sv249@example.com', '2003-10-20', N'Nam', 'ATTT'),
('SV250', N'Đoàn Mai Lan', 'sv250@example.com', '2004-11-23', N'Nữ', 'CNTT');


-- Insert NguoiDungs cho sinh viên chưa có
INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
SELECT t.MSSV, @PasswordHash, t.Email, t.HoTen, @VaiTroSV, 1
FROM @TempStudents t
WHERE NOT EXISTS (SELECT 1 FROM NguoiDungs nd WHERE nd.TenDangNhap = t.MSSV);

-- Insert SinhViens cho sinh viên chưa có
INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT nd.NguoiDungId, t.MSSV, k.KhoaId, t.NgaySinh, t.GioiTinh
FROM @TempStudents t
INNER JOIN NguoiDungs nd ON nd.TenDangNhap = t.MSSV
INNER JOIN Khoas k ON k.MaKhoa = t.MaKhoa
WHERE NOT EXISTS (SELECT 1 FROM SinhViens sv WHERE sv.MSSV = t.MSSV);

PRINT N'>> Đã hoàn thành nạp danh sách 250 sinh viên!';
GO

-- ==============================================================================
-- 7. ĐĂNG KÝ HỌC PHẦN: PHÂN BỔ 250 SINH VIÊN VÀO 12 LỚP HỌC PHẦN
-- ==============================================================================

DECLARE @LhpLTDD1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-01');
DECLARE @LhpLTDD2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-02');
DECLARE @LhpCNPM1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-01');
DECLARE @LhpCNPM2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-02');
DECLARE @LhpAI1   INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'AI-01');
DECLARE @LhpAI2   INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'AI-02');
DECLARE @LhpCSDL1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-01');
DECLARE @LhpCSDL2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-02');
DECLARE @LhpKTPM1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'KTPM-01');
DECLARE @LhpKTPM2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'KTPM-02');
DECLARE @LhpWDEV1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'WDEV-01');
DECLARE @LhpATTT1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'ATTT-01');

-- Lớp LTDD-01: SV001 - SV040
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpLTDD1, '2026-09-01', 1
FROM SinhViens sv WHERE sv.MSSV BETWEEN 'SV001' AND 'SV040'
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpLTDD1);

-- Lớp LTDD-02: SV041 - SV080
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpLTDD2, '2026-09-01', 1
FROM SinhViens sv WHERE sv.MSSV BETWEEN 'SV041' AND 'SV080'
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpLTDD2);

-- Lớp CNPM-01: SV001 - SV035 và SV081 - SV090
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpCNPM1, '2026-09-01', 1
FROM SinhViens sv WHERE (sv.MSSV BETWEEN 'SV001' AND 'SV035' OR sv.MSSV BETWEEN 'SV081' AND 'SV090')
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpCNPM1);

-- Lớp CNPM-02: SV091 - SV130
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpCNPM2, '2026-09-01', 1
FROM SinhViens sv WHERE sv.MSSV BETWEEN 'SV091' AND 'SV130'
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpCNPM2);

-- Lớp AI-01: SV001 - SV015 và SV131 - SV160
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpAI1, '2026-09-01', 1
FROM SinhViens sv WHERE (sv.MSSV BETWEEN 'SV001' AND 'SV015' OR sv.MSSV BETWEEN 'SV131' AND 'SV160')
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpAI1);

-- Lớp AI-02: SV161 - SV195
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpAI2, '2026-09-01', 1
FROM SinhViens sv WHERE sv.MSSV BETWEEN 'SV161' AND 'SV195'
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpAI2);

-- Lớp CSDL-01: SV001 - SV020 và SV196 - SV220
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpCSDL1, '2026-09-01', 1
FROM SinhViens sv WHERE (sv.MSSV BETWEEN 'SV001' AND 'SV020' OR sv.MSSV BETWEEN 'SV196' AND 'SV220')
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpCSDL1);

-- Lớp CSDL-02: SV021 - SV050 và SV221 - SV235
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpCSDL2, '2026-09-01', 1
FROM SinhViens sv WHERE (sv.MSSV BETWEEN 'SV021' AND 'SV050' OR sv.MSSV BETWEEN 'SV221' AND 'SV235')
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpCSDL2);

-- Lớp KTPM-01: SV010 - SV030 và SV236 - SV250
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpKTPM1, '2026-09-01', 1
FROM SinhViens sv WHERE (sv.MSSV BETWEEN 'SV010' AND 'SV030' OR sv.MSSV BETWEEN 'SV236' AND 'SV250')
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpKTPM1);

-- Lớp WDEV-01: SV051 - SV090
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpWDEV1, '2026-09-01', 1
FROM SinhViens sv WHERE sv.MSSV BETWEEN 'SV051' AND 'SV090'
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpWDEV1);

-- Lớp ATTT-01: SV091 - SV130
INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId, NgayThamGia, TrangThai)
SELECT sv.SinhVienId, @LhpATTT1, '2026-09-01', 1
FROM SinhViens sv WHERE sv.MSSV BETWEEN 'SV091' AND 'SV130'
AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE SinhVienId = sv.SinhVienId AND LopHocPhanId = @LhpATTT1);

PRINT N'>> Đã phân bổ sinh viên vào tất cả các lớp học phần thành công!';
GO

-- ==============================================================================
-- 8. BỔ SUNG 30+ ĐỀ TÀI ĐỒ ÁN ĐA DẠNG CÔNG NGHỆ (MOBILE, AI, CLOUD, QA, CSDL)
-- ==============================================================================

DECLARE @GV1 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV001');
DECLARE @GV2 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV002');
DECLARE @GV3 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV003');
DECLARE @GV4 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV004');
DECLARE @GV5 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV005');
DECLARE @GV6 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV006');


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng quản lý đăng ký nhóm đồ án')
BEGIN
    DECLARE @DotId_52335 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
    IF @DotId_52335 IS NULL
        SET @DotId_52335 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_52335, N'Ứng dụng quản lý đăng ký nhóm đồ án', N'Xây dựng ứng dụng di động hỗ trợ sinh viên ghép nhóm, đăng ký đề tài và theo dõi tiến độ.', N'Tự động hóa toàn bộ quy trình đăng ký đồ án môn học cho khoa CNTT.', N'Sinh viên, giảng viên và phòng đào tạo toàn trường.', N'Flutter, ASP.NET Core Web API, SQL Server', N'Giảng viên', @GV1, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống quản lý công việc nhóm Agile/Scrum')
BEGIN
    DECLARE @DotId_4567 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
    IF @DotId_4567 IS NULL
        SET @DotId_4567 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_4567, N'Hệ thống quản lý công việc nhóm Agile/Scrum', N'Ứng dụng quản lý dự án nhóm theo phương pháp Agile/Scrum với bảng Kanban và Sprint backlog.', N'Hỗ trợ phân công công việc, ước lượng thời gian và theo dõi burndown chart.', N'Các nhóm sinh viên làm bài tập lớn và đồ án tốt nghiệp.', N'Flutter, ASP.NET Core, SignalR, SQL Server', N'Giảng viên', @GV1, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng gợi ý đề tài và ghép nhóm bằng AI')
BEGIN
    DECLARE @DotId_94408 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
    IF @DotId_94408 IS NULL
        SET @DotId_94408 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_94408, N'Ứng dụng gợi ý đề tài và ghép nhóm bằng AI', N'Sử dụng AI để phân tích năng lực sinh viên, đề xuất đề tài phù hợp và tìm bạn cùng tiến.', N'Tối ưu tỷ lệ ghép nhóm thành công và nâng cao chất lượng đề tài.', N'Toàn bộ sinh viên thuộc khối ngành Công nghệ thông tin.', N'Flutter, FastAPI, Gemini API, Pinecone Vector DB', N'Giảng viên', @GV1, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng học từ vựng tiếng Anh theo phương pháp Spaced Repetition')
BEGIN
    DECLARE @DotId_27724 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
    IF @DotId_27724 IS NULL
        SET @DotId_27724 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_27724, N'Ứng dụng học từ vựng tiếng Anh theo phương pháp Spaced Repetition', N'Ứng dụng ghi nhớ từ vựng qua thẻ flashcard lặp lại ngắt quãng kết hợp nhận diện phát âm AI.', N'Tăng hiệu quả ghi nhớ từ vựng lên 200% sau 30 ngày sử dụng.', N'Người học tiếng Anh chuẩn bị thi TOEIC/IELTS.', N'Flutter, Google Speech-to-Text, SQLite, Node.js', N'Giảng viên', @GV1, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống theo dõi sức khỏe và lịch trình tập luyện cá nhân')
BEGIN
    DECLARE @DotId_51217 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
    IF @DotId_51217 IS NULL
        SET @DotId_51217 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_51217, N'Hệ thống theo dõi sức khỏe và lịch trình tập luyện cá nhân', N'Đo lường chỉ số calo, theo dõi bước chân, gợi ý thực đơn và bài tập phù hợp thể trạng.', N'Hỗ trợ người dùng duy trì lối sống lành mạnh và đạt mục tiêu cân nặng.', N'Người dùng di động cá nhân trên cả iOS và Android.', N'Flutter, HealthKit, Google Fit API, Firebase', N'Giảng viên', @GV1, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng thương mại điện tử chuyên đồ gia dụng thông minh SmartHome')
BEGIN
    DECLARE @DotId_25580 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Di động N02');
    IF @DotId_25580 IS NULL
        SET @DotId_25580 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_25580, N'Ứng dụng thương mại điện tử chuyên đồ gia dụng thông minh SmartHome', N'Ứng dụng mua sắm thiết bị IoT nhà thông minh, tích hợp cổng thanh toán VNPay và MoMo.', N'Xây dựng trải nghiệm mua sắm mượt mà, thanh toán an toàn và tra cứu đơn hàng theo thời gian thực.', N'Khách hàng mua sắm trực tuyến trên di động.', N'Flutter, .NET 8 Web API, VNPay SDK, Redis', N'Giảng viên', @GV1, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng đặt lịch khám bệnh và sổ sức khỏe điện tử')
BEGIN
    DECLARE @DotId_11298 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Di động N02');
    IF @DotId_11298 IS NULL
        SET @DotId_11298 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_11298, N'Ứng dụng đặt lịch khám bệnh và sổ sức khỏe điện tử', N'Đặt lịch hẹn với bác sĩ, tra cứu hồ sơ bệnh án và nhắc lịch uống thuốc tự động.', N'Giảm thời gian chờ đợi tại bệnh viện và quản lý tiền sử bệnh lý tập trung.', N'Bệnh nhân và các phòng khám chuyên khoa liên kết.', N'Flutter, Golang, PostgreSQL, Docker', N'Giảng viên', @GV1, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng tìm trọ và đánh giá phòng trọ sinh viên')
BEGIN
    DECLARE @DotId_2274 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
    IF @DotId_2274 IS NULL
        SET @DotId_2274 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_2274, N'Ứng dụng tìm trọ và đánh giá phòng trọ sinh viên', N'Tìm kiếm phòng trọ theo bán kính trường học, lọc giá thành, tiện ích và review minh bạch.', N'Giúp sinh viên tìm được nhà trọ an ninh, đúng giá, tránh bị lừa đảo đặt cọc.', N'Khu vực xung quanh các trường đại học tại TP.HCM.', N'Flutter, ASP.NET Core, Mapbox API, SQL Server', N'Sinh viên đề xuất', @GV1, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV005'), N'Chưa sử dụng', N'Chờ duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Game 2D đa nền tảng giáo dục lịch sử Việt Nam')
BEGIN
    DECLARE @DotId_91366 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
    IF @DotId_91366 IS NULL
        SET @DotId_91366 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_91366, N'Game 2D đa nền tảng giáo dục lịch sử Việt Nam', N'Trò chơi hành động nhập vai tái hiện các trận đánh lịch sử và câu đố kiến thức.', N'Tạo sân chơi hấp dẫn, giúp giới trẻ tiếp cận lịch sử dân tộc hào hùng.', N'Thiết bị di động Android & iOS.', N'Unity 2D, C#, Firebase Analytics', N'Sinh viên đề xuất', @GV1, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV009'), N'Chưa sử dụng', N'Từ chối', N'Phạm vi đề tài và công nghệ Unity chưa phù hợp với chuẩn đầu ra môn học Lập trình di động.');
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống quản lý chuỗi cung ứng nông sản xuất khẩu')
BEGIN
    DECLARE @DotId_20560 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Công nghệ phần mềm K21');
    IF @DotId_20560 IS NULL
        SET @DotId_20560 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_20560, N'Hệ thống quản lý chuỗi cung ứng nông sản xuất khẩu', N'Phần mềm quản lý nguồn gốc xuất xứ, kho bãi và chứng nhận VietGAP cho chuỗi cung ứng.', N'Truy xuất nguồn gốc sản phẩm theo mã QR và quản lý vận chuyển logistics.', N'Doanh nghiệp xuất khẩu nông sản và các hợp tác xã liên kết.', N'ASP.NET Core, React.js, SQL Server, Azure Blob Storage', N'Giảng viên', @GV2, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Nền tảng tuyển dụng việc làm IT và phỏng vấn trực tuyến')
BEGIN
    DECLARE @DotId_5283 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Công nghệ phần mềm K21');
    IF @DotId_5283 IS NULL
        SET @DotId_5283 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_5283, N'Nền tảng tuyển dụng việc làm IT và phỏng vấn trực tuyến', N'Hệ thống đăng tin tuyển dụng, phân tích CV tự động bằng NLP và phòng phỏng vấn WebRTC.', N'Kết nối ứng viên tài năng với các công ty công nghệ nhanh chóng, tiện lợi.', N'Nhà tuyển dụng công nghệ và sinh viên mới tốt nghiệp.', N'React.js, Node.js, NestJS, MongoDB, WebRTC', N'Giảng viên', @GV2, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống quản lý thư viện số và tra cứu tài liệu đại học')
BEGIN
    DECLARE @DotId_35226 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Công nghệ phần mềm K21');
    IF @DotId_35226 IS NULL
        SET @DotId_35226 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_35226, N'Hệ thống quản lý thư viện số và tra cứu tài liệu đại học', N'Quản lý đầu sách, tài liệu nghiên cứu, mượn trả sách trực tuyến và tích hợp mã vạch/RFID.', N'Hiện đại hóa hệ thống thư viện truyền thống sang mô hình thư viện số thông minh.', N'Thư viện các trường đại học và cao đẳng.', N'Vue.js, ASP.NET Core, SQL Server, Elasticsearch', N'Giảng viên', @GV2, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống quản lý phòng khám nha khoa thông minh')
BEGIN
    DECLARE @DotId_95456 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Công nghệ phần mềm K21');
    IF @DotId_95456 IS NULL
        SET @DotId_95456 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_95456, N'Hệ thống quản lý phòng khám nha khoa thông minh', N'Quản lý hồ sơ bệnh án nha khoa, lập kế hoạch điều trị, theo dõi công nợ và chăm sóc khách hàng.', N'Số hóa toàn diện nghiệp vụ phòng khám nha khoa quy mô vừa và nhỏ.', N'Các chuỗi phòng khám nha khoa.', N'Next.js, TailwindCSS, Express.js, PostgreSQL', N'Sinh viên đề xuất', @GV2, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV012'), N'Chưa sử dụng', N'Chờ duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống nhận diện biển số xe tự động bằng Deep Learning')
BEGIN
    DECLARE @DotId_88299 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01');
    IF @DotId_88299 IS NULL
        SET @DotId_88299 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_88299, N'Hệ thống nhận diện biển số xe tự động bằng Deep Learning', N'Nhận diện biển số xe ô tô và xe máy qua camera độ phân giải cao ứng dụng YOLOv8 và OCR.', N'Tự động hóa kiểm soát xe ra vào bãi đỗ với độ chính xác trên 98% và độ trễ dưới 200ms.', N'Bãi đỗ xe trường đại học, tòa nhà văn phòng và khu đô thị.', N'Python, YOLOv8, PyTorch, OpenCV, FastAPI', N'Giảng viên', @GV3, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Trợ lý ảo học tập RAG dựa trên mô hình ngôn ngữ lớn LLM')
BEGIN
    DECLARE @DotId_89916 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01');
    IF @DotId_89916 IS NULL
        SET @DotId_89916 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_89916, N'Trợ lý ảo học tập RAG dựa trên mô hình ngôn ngữ lớn LLM', N'Xây dựng chatbot RAG tra cứu giáo trình môn học, tổng hợp kiến thức và tạo đề trắc nghiệm.', N'Hỗ trợ sinh viên giải đáp thắc mắc 24/7 với câu trả lời trích dẫn chính xác từ tài liệu khoa.', N'Sinh viên khối ngành Khoa học máy tính & CNTT.', N'Python, LangChain, ChromaDB, Gemini 1.5 Flash API', N'Giảng viên', @GV3, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Phát hiện và cảnh báo ngủ gật cho tài xế đường dài')
BEGIN
    DECLARE @DotId_19120 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01');
    IF @DotId_19120 IS NULL
        SET @DotId_19120 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_19120, N'Phát hiện và cảnh báo ngủ gật cho tài xế đường dài', N'Giám sát mắt và cử chỉ khuôn mặt tài xế qua camera cabin để phát hiện triệu chứng buồn ngủ.', N'Đưa ra cảnh báo âm thanh kịp thời khi tài xế nhắm mắt quá 2 giây hoặc ngáp liên tục.', N'Tài xế xe khách đường dài và xe tải vận tải hàng hóa.', N'Python, MediaPipe, OpenCV, TensorFlow Lite', N'Giảng viên', @GV3, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống phân loại rác thải tự động qua ảnh chụp')
BEGIN
    DECLARE @DotId_86665 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01');
    IF @DotId_86665 IS NULL
        SET @DotId_86665 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_86665, N'Hệ thống phân loại rác thải tự động qua ảnh chụp', N'Nhận diện và phân loại rác thành: rác hữu cơ, rác tái chế và rác vô cơ qua camera.', N'Nâng cao ý thức phân loại rác tại nguồn và tích hợp vào thùng rác thông minh.', N'Khuôn viên nhà trường và nơi công cộng.', N'Python, PyTorch, MobileNetV3, Raspberry Pi', N'Giảng viên', @GV3, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống điểm danh tự động bằng nhận diện khuôn mặt sinh viên')
BEGIN
    DECLARE @DotId_80035 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01');
    IF @DotId_80035 IS NULL
        SET @DotId_80035 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_80035, N'Hệ thống điểm danh tự động bằng nhận diện khuôn mặt sinh viên', N'Điểm danh sinh viên vào lớp học bằng camera gắn tại cửa lớp, hỗ trợ nhận diện nhiều người cùng lúc.', N'Tiết kiệm thời gian điểm danh truyền thống, phòng chống điểm danh hộ.', N'Phòng học thực hành và giảng đường đại học.', N'Python, FaceNet, OpenCV, Flutter', N'Sinh viên đề xuất', @GV3, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV004'), N'Chưa sử dụng', N'Chờ duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Dự đoán giá chứng khoán bằng mạng nơ-ron LSTM kết hợp Sentiment Analysis')
BEGIN
    DECLARE @DotId_98341 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01');
    IF @DotId_98341 IS NULL
        SET @DotId_98341 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_98341, N'Dự đoán giá chứng khoán bằng mạng nơ-ron LSTM kết hợp Sentiment Analysis', N'Thu thập tin tức tài chính và dữ liệu giá lịch sử để dự đoán xu hướng biến động giá cổ phiếu.', N'Đưa ra chỉ báo tham khảo hỗ trợ nhà đầu tư cá nhân.', N'Thị trường chứng khoán Việt Nam (VN-Index).', N'Python, TensorFlow, LSTM, BeautifulSoup, Pandas', N'Sinh viên đề xuất', @GV3, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV018'), N'Chưa sử dụng', N'Từ chối', N'Đề tài mang tính suy đoán tài chính, rủi ro mô hình cao và không phù hợp với chuẩn nghiên cứu khoa học cơ bản của môn học.');
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Tối ưu hóa chỉ mục và hiệu năng cơ sở dữ liệu lớn')
BEGIN
    DECLARE @DotId_2897 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án CSDL N01');
    IF @DotId_2897 IS NULL
        SET @DotId_2897 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_2897, N'Tối ưu hóa chỉ mục và hiệu năng cơ sở dữ liệu lớn', N'Nghiên cứu cơ chế Indexing, Partitioning, In-Memory OLTP và Query Execution Plan trong SQL Server.', N'Giảm thời gian phản hồi truy vấn dữ liệu hàng chục triệu bản ghi xuống dưới 100ms.', N'Hệ thống giao dịch tài chính và thương mại điện tử quy mô lớn.', N'SQL Server, T-SQL, Extended Events, Database Engine Tuning', N'Giảng viên', @GV4, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống kho dữ liệu Data Warehouse phân tích kinh doanh BI')
BEGIN
    DECLARE @DotId_40368 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án CSDL N01');
    IF @DotId_40368 IS NULL
        SET @DotId_40368 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_40368, N'Hệ thống kho dữ liệu Data Warehouse phân tích kinh doanh BI', N'Thiết kế kiến trúc Star Schema, ETL Pipeline tự động và xây dựng báo cáo phân tích đa chiều.', N'Cung cấp dashboard trực quan hỗ trợ ban giám đốc ra quyết định kinh doanh chiến lược.', N'Dữ liệu bán hàng chuỗi siêu thị bán lẻ toàn quốc.', N'SQL Server, SSIS, SSAS, Power BI, Python', N'Giảng viên', @GV4, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Xây dựng cơ sở dữ liệu phân tán NoSQL với MongoDB và Redis')
BEGIN
    DECLARE @DotId_63075 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án CSDL Nâng cao 2026');
    IF @DotId_63075 IS NULL
        SET @DotId_63075 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_63075, N'Xây dựng cơ sở dữ liệu phân tán NoSQL với MongoDB và Redis', N'Thiết kế kiến trúc Sharding, Replica Sets và giải pháp Caching chịu tải cao cho mạng xã hội.', N'Đảm bảo tính sẵn sàng cao (High Availability) và khả năng mở rộng ngang (Horizontal Scaling).', N'Hệ thống nhắn tin tức thời và dòng thời gian mạng xã hội.', N'MongoDB, Redis, Docker, Node.js', N'Giảng viên', @GV4, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống giám sát và sao lưu dữ liệu tự động cho doanh nghiệp')
BEGIN
    DECLARE @DotId_22881 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án CSDL Nâng cao 2026');
    IF @DotId_22881 IS NULL
        SET @DotId_22881 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_22881, N'Hệ thống giám sát và sao lưu dữ liệu tự động cho doanh nghiệp', N'Tự động hóa quy trình sao lưu vi sai, nén dữ liệu và phục hồi sự cố khẩn cấp (Disaster Recovery).', N'Đảm bảo an toàn dữ liệu và thời gian phục hồi RTO < 15 phút, RPO < 1 giờ.', N'Hạ tầng máy chủ cơ sở dữ liệu doanh nghiệp.', N'SQL Server, PowerShell, Azure Blob Storage', N'Sinh viên đề xuất', @GV4, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV025'), N'Chưa sử dụng', N'Chờ duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Khung kiểm thử tự động Automation Testing cho Web và Mobile')
BEGIN
    DECLARE @DotId_49455 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Kiểm thử phần mềm 2026');
    IF @DotId_49455 IS NULL
        SET @DotId_49455 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_49455, N'Khung kiểm thử tự động Automation Testing cho Web và Mobile', N'Xây dựng Page Object Model framework kiểm thử hồi quy tự động tích hợp CI/CD pipeline.', N'Tự động hóa 85% kịch bản kiểm thử chức năng quan trọng trên cả trình duyệt và app di động.', N'Hệ thống đăng ký tín chỉ và cổng thông tin sinh viên.', N'Selenium, Appium, Java/TestNG, Allure Report, Jenkins', N'Giảng viên', @GV5, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Đánh giá an toàn thông tin và phát hiện lỗ hổng OWASP Top 10')
BEGIN
    DECLARE @DotId_78003 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Kiểm thử phần mềm 2026');
    IF @DotId_78003 IS NULL
        SET @DotId_78003 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_78003, N'Đánh giá an toàn thông tin và phát hiện lỗ hổng OWASP Top 10', N'Thực hiện kiểm thử xâm nhập Penetration Testing và quét mã nguồn bảo mật SAST/DAST.', N'Phát hiện và đưa ra giải pháp khắc phục triệt để các lỗ hổng SQL Injection, XSS, CSRF.', N'Cổng dịch vụ công trực tuyến giả lập.', N'Kali Linux, Burp Suite, OWASP ZAP, SonarQube, Python', N'Giảng viên', @GV5, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống kiểm thử hiệu năng và chịu tải Performance Testing')
BEGIN
    DECLARE @DotId_36115 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Kiểm thử phần mềm 2026');
    IF @DotId_36115 IS NULL
        SET @DotId_36115 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_36115, N'Hệ thống kiểm thử hiệu năng và chịu tải Performance Testing', N'Giả lập 10.000 người dùng đồng thời truy cập để đo lường ngưỡng chịu tải và độ ổn định hệ thống.', N'Xác định điểm nghẽn cổ chai (bottlenecks) về CPU, RAM, Network và Database lock.', N'Hệ thống bán vé sự kiện trực tuyến vào giờ cao điểm.', N'Apache JMeter, Locust, Grafana, InfluxDB', N'Giảng viên', @GV5, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Kiểm thử tự động API bằng Postman Newman kết hợp CI/CD')
BEGIN
    DECLARE @DotId_79126 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Kiểm thử phần mềm 2026');
    IF @DotId_79126 IS NULL
        SET @DotId_79126 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_79126, N'Kiểm thử tự động API bằng Postman Newman kết hợp CI/CD', N'Xây dựng bộ test suite kiểm tra hợp đồng API Contract Testing, Data-Driven Testing.', N'Phát hiện lỗi hồi quy API ngay khi lập trình viên tạo Pull Request.', N'Hệ thống Backend Microservices thương mại điện tử.', N'Postman, Newman, JavaScript, GitHub Actions', N'Sinh viên đề xuất', @GV5, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV032'), N'Chưa sử dụng', N'Chờ duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Xây dựng nền tảng học trực tuyến LMS theo kiến trúc Microservices')
BEGIN
    DECLARE @DotId_81614 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Phát triển Web Fullstack');
    IF @DotId_81614 IS NULL
        SET @DotId_81614 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_81614, N'Xây dựng nền tảng học trực tuyến LMS theo kiến trúc Microservices', N'Nền tảng đào tạo trực tuyến với tính năng xem video streaming, làm bài thi trắc nghiệm và cấp chứng chỉ.', N'Khả năng mở rộng linh hoạt theo kiến trúc hướng dịch vụ với API Gateway và Message Broker.', N'Học viên và giảng viên các trung tâm đào tạo công nghệ.', N'.NET 8, Next.js, RabbitMQ, Docker, Kubernetes', N'Giảng viên', @GV6, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống quản lý chuỗi khách sạn và đặt phòng trực tuyến')
BEGIN
    DECLARE @DotId_70192 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Phát triển Web Fullstack');
    IF @DotId_70192 IS NULL
        SET @DotId_70192 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_70192, N'Hệ thống quản lý chuỗi khách sạn và đặt phòng trực tuyến', N'Quản lý buồng phòng, dịch vụ buồng, hóa đơn và đồng bộ kênh bán phòng OTA qua API.', N'Tối ưu tỷ lệ lấp đầy phòng và quản lý dòng tiền minh bạch, tức thì.', N'Chuỗi khách sạn và homestay du lịch.', N'React.js, ASP.NET Core, PostgreSQL, Redis', N'Giảng viên', @GV6, NULL, N'Đã đăng ký', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Nền tảng đấu giá tài sản trực tuyến theo thời gian thực')
BEGIN
    DECLARE @DotId_89626 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Phát triển Web Fullstack');
    IF @DotId_89626 IS NULL
        SET @DotId_89626 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_89626, N'Nền tảng đấu giá tài sản trực tuyến theo thời gian thực', N'Hệ thống đấu giá với cơ chế trả giá realtime, chống tấn công bắn giá phút chót qua WebSocket.', N'Đảm bảo tính công bằng, minh bạch tuyệt đối và xác thực người tham gia qua CCCD gắn chip.', N'Các phiên đấu giá sản phẩm sưu tầm và đồ cổ.', N'Vue.js 3, NestJS, Socket.IO, MongoDB', N'Giảng viên', @GV6, NULL, N'Chưa sử dụng', N'Đã duyệt', NULL);
END


IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Cổng thông tin hướng nghiệp và kết nối cựu sinh viên')
BEGIN
    DECLARE @DotId_88919 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Phát triển Web Fullstack');
    IF @DotId_88919 IS NULL
        SET @DotId_88919 = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_88919, N'Cổng thông tin hướng nghiệp và kết nối cựu sinh viên', N'Mạng xã hội cựu sinh viên chia sẻ kinh nghiệm phỏng vấn, cơ hội việc làm và cố vấn nghề nghiệp.', N'Xây dựng cộng đồng cựu sinh viên gắn kết, hỗ trợ thế hệ đàn em.', N'Toàn thể cựu sinh viên và sinh viên đang theo học tại trường.', N'React.js, Node.js, GraphQL, PostgreSQL', N'Sinh viên đề xuất', @GV6, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV045'), N'Chưa sử dụng', N'Chờ duyệt', NULL);
END

PRINT N'>> Đã hoàn thành nạp danh mục đề tài đồ án!';
GO

-- ==============================================================================
-- 9. BỔ SUNG 25 NHÓM ĐỒ ÁN VÀ PHÂN BỔ THÀNH VIÊN VÀO NHÓM
-- ==============================================================================

DECLARE @DotLTDD1 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Demo 2026');
DECLARE @DotLTDD2 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Di động N02');
DECLARE @DotCNPM1 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Công nghệ phần mềm K21');
DECLARE @DotAI1   INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Trí tuệ nhân tạo N01');
DECLARE @DotCSDL1 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án CSDL N01');
DECLARE @DotCSDL2 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án CSDL Nâng cao 2026');
DECLARE @DotKTPM1 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Kiểm thử phần mềm 2026');
DECLARE @DotWDEV1 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'Đợt đăng ký đồ án Phát triển Web Fullstack');

DECLARE @DotDefault INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);
IF @DotLTDD1 IS NULL SET @DotLTDD1 = @DotDefault;
IF @DotLTDD2 IS NULL SET @DotLTDD2 = @DotDefault;
IF @DotCNPM1 IS NULL SET @DotCNPM1 = @DotDefault;
IF @DotAI1   IS NULL SET @DotAI1   = @DotDefault;
IF @DotCSDL1 IS NULL SET @DotCSDL1 = @DotDefault;
IF @DotCSDL2 IS NULL SET @DotCSDL2 = @DotDefault;
IF @DotKTPM1 IS NULL SET @DotKTPM1 = @DotDefault;
IF @DotWDEV1 IS NULL SET @DotWDEV1 = @DotDefault;


-- Nhóm Demo 01
DECLARE @NhomId_1 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Demo 01')
BEGIN
    DECLARE @Leader_1 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV001');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotLTDD1, N'Nhóm Demo 01', @Leader_1, N'Đang hoạt động');
    SET @NhomId_1 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_1 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Demo 01');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_1 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV001'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_1, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV001'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_1 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV002'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_1, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV002'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_1 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV003'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_1, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV003'), N'Thành viên', N'Đã tham gia');


-- Nhóm Mobile Pro
DECLARE @NhomId_2 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Mobile Pro')
BEGIN
    DECLARE @Leader_2 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV006');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotLTDD1, N'Nhóm Mobile Pro', @Leader_2, N'Đang hoạt động');
    SET @NhomId_2 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_2 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Mobile Pro');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_2 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV006'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_2, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV006'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_2 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV007'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_2, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV007'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_2 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV008'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_2, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV008'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_2 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV010'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_2, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV010'), N'Thành viên', N'Chờ tham gia');


-- Nhóm Agile Dev
DECLARE @NhomId_3 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Agile Dev')
BEGIN
    DECLARE @Leader_3 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV011');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotCNPM1, N'Nhóm Agile Dev', @Leader_3, N'Đang hoạt động');
    SET @NhomId_3 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_3 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Agile Dev');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_3 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV011'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_3, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV011'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_3 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV012'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_3, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV012'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_3 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV013'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_3, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV013'), N'Thành viên', N'Đã tham gia');


-- Nhóm AI Innovators
DECLARE @NhomId_4 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm AI Innovators')
BEGIN
    DECLARE @Leader_4 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV016');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotAI1, N'Nhóm AI Innovators', @Leader_4, N'Đang hoạt động');
    SET @NhomId_4 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_4 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm AI Innovators');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_4 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV016'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_4, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV016'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_4 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV017'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_4, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV017'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_4 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV018'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_4, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV018'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_4 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV020'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_4, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV020'), N'Thành viên', N'Chờ tham gia');


-- Nhóm Quality First
DECLARE @NhomId_5 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Quality First')
BEGIN
    DECLARE @Leader_5 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV021');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotKTPM1, N'Nhóm Quality First', @Leader_5, N'Đang hoạt động');
    SET @NhomId_5 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_5 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Quality First');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_5 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV021'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_5, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV021'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_5 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV022'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_5, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV022'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_5 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV023'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_5, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV023'), N'Thành viên', N'Đã tham gia');


-- Nhóm CyberGuard
DECLARE @NhomId_6 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm CyberGuard')
BEGIN
    DECLARE @Leader_6 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV026');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotKTPM1, N'Nhóm CyberGuard', @Leader_6, N'Đang hoạt động');
    SET @NhomId_6 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_6 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm CyberGuard');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_6 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV026'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_6, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV026'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_6 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV027'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_6, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV027'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_6 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV028'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_6, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV028'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_6 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV030'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_6, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV030'), N'Thành viên', N'Chờ tham gia');


-- Nhóm Cloud Titans
DECLARE @NhomId_7 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Cloud Titans')
BEGIN
    DECLARE @Leader_7 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV051');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotWDEV1, N'Nhóm Cloud Titans', @Leader_7, N'Đang hoạt động');
    SET @NhomId_7 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_7 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Cloud Titans');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_7 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV051'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_7, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV051'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_7 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV052'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_7, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV052'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_7 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV053'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_7, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV053'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_7 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV054'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_7, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV054'), N'Thành viên', N'Đã tham gia');


-- Nhóm FinTech Core
DECLARE @NhomId_8 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm FinTech Core')
BEGIN
    DECLARE @Leader_8 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV041');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotLTDD2, N'Nhóm FinTech Core', @Leader_8, N'Đang hoạt động');
    SET @NhomId_8 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_8 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm FinTech Core');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_8 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV041'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_8, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV041'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_8 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV042'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_8, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV042'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_8 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV043'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_8, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV043'), N'Thành viên', N'Đã tham gia');


-- Nhóm SmartHome IoT
DECLARE @NhomId_9 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm SmartHome IoT')
BEGIN
    DECLARE @Leader_9 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV046');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotLTDD2, N'Nhóm SmartHome IoT', @Leader_9, N'Đang hoạt động');
    SET @NhomId_9 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_9 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm SmartHome IoT');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_9 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV046'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_9, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV046'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_9 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV047'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_9, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV047'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_9 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV048'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_9, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV048'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_9 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV050'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_9, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV050'), N'Thành viên', N'Chờ tham gia');


-- Nhóm EduTech Future
DECLARE @NhomId_10 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm EduTech Future')
BEGIN
    DECLARE @Leader_10 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV031');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotCNPM1, N'Nhóm EduTech Future', @Leader_10, N'Đang hoạt động');
    SET @NhomId_10 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_10 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm EduTech Future');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_10 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV031'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_10, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV031'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_10 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV032'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_10, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV032'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_10 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV033'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_10, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV033'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_10 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV034'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_10, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV034'), N'Thành viên', N'Đã tham gia');


-- Nhóm Data Wizards
DECLARE @NhomId_11 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Data Wizards')
BEGIN
    DECLARE @Leader_11 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV061');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotCSDL1, N'Nhóm Data Wizards', @Leader_11, N'Đang hoạt động');
    SET @NhomId_11 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_11 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Data Wizards');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_11 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV061'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_11, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV061'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_11 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV062'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_11, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV062'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_11 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV063'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_11, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV063'), N'Thành viên', N'Đã tham gia');


-- Nhóm Vision AI
DECLARE @NhomId_12 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Vision AI')
BEGIN
    DECLARE @Leader_12 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV071');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotAI1, N'Nhóm Vision AI', @Leader_12, N'Đang hoạt động');
    SET @NhomId_12 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_12 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Vision AI');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_12 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV071'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_12, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV071'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_12 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV072'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_12, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV072'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_12 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV073'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_12, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV073'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_12 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV075'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_12, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV075'), N'Thành viên', N'Chờ tham gia');


-- Nhóm NextGen Web
DECLARE @NhomId_13 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm NextGen Web')
BEGIN
    DECLARE @Leader_13 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV081');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotWDEV1, N'Nhóm NextGen Web', @Leader_13, N'Đang hoạt động');
    SET @NhomId_13 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_13 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm NextGen Web');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_13 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV081'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_13, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV081'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_13 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV082'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_13, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV082'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_13 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV083'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_13, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV083'), N'Thành viên', N'Đã tham gia');


-- Nhóm CodeCrafters
DECLARE @NhomId_14 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm CodeCrafters')
BEGIN
    DECLARE @Leader_14 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV086');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotCNPM1, N'Nhóm CodeCrafters', @Leader_14, N'Đang hoạt động');
    SET @NhomId_14 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_14 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm CodeCrafters');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_14 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV086'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_14, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV086'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_14 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV087'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_14, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV087'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_14 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV088'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_14, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV088'), N'Thành viên', N'Đã tham gia');


-- Nhóm DevOps Pioneers
DECLARE @NhomId_15 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm DevOps Pioneers')
BEGIN
    DECLARE @Leader_15 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV091');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotWDEV1, N'Nhóm DevOps Pioneers', @Leader_15, N'Đang hoạt động');
    SET @NhomId_15 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_15 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm DevOps Pioneers');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_15 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV091'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_15, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV091'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_15 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV092'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_15, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV092'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_15 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV093'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_15, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV093'), N'Thành viên', N'Đã tham gia');


-- Nhóm SwiftCoders
DECLARE @NhomId_16 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm SwiftCoders')
BEGIN
    DECLARE @Leader_16 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV096');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotLTDD1, N'Nhóm SwiftCoders', @Leader_16, N'Đang hoạt động');
    SET @NhomId_16 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_16 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm SwiftCoders');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_16 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV096'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_16, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV096'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_16 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV097'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_16, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV097'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_16 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV098'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_16, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV098'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_16 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV100'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_16, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV100'), N'Thành viên', N'Chờ tham gia');


-- Nhóm BioTech IT
DECLARE @NhomId_17 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm BioTech IT')
BEGIN
    DECLARE @Leader_17 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV101');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotAI1, N'Nhóm BioTech IT', @Leader_17, N'Đang hoạt động');
    SET @NhomId_17 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_17 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm BioTech IT');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_17 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV101'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_17, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV101'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_17 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV102'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_17, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV102'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_17 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV103'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_17, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV103'), N'Thành viên', N'Đã tham gia');


-- Nhóm SecureNet
DECLARE @NhomId_18 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm SecureNet')
BEGIN
    DECLARE @Leader_18 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV106');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotKTPM1, N'Nhóm SecureNet', @Leader_18, N'Đang hoạt động');
    SET @NhomId_18 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_18 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm SecureNet');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_18 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV106'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_18, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV106'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_18 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV107'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_18, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV107'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_18 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV108'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_18, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV108'), N'Thành viên', N'Đã tham gia');


-- Nhóm EcoTech
DECLARE @NhomId_19 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm EcoTech')
BEGIN
    DECLARE @Leader_19 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV111');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotAI1, N'Nhóm EcoTech', @Leader_19, N'Đang hoạt động');
    SET @NhomId_19 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_19 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm EcoTech');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_19 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV111'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_19, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV111'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_19 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV112'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_19, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV112'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_19 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV113'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_19, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV113'), N'Thành viên', N'Đã tham gia');


-- Nhóm AutoTest Masters
DECLARE @NhomId_20 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm AutoTest Masters')
BEGIN
    DECLARE @Leader_20 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV116');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotKTPM1, N'Nhóm AutoTest Masters', @Leader_20, N'Đang hoạt động');
    SET @NhomId_20 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_20 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm AutoTest Masters');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_20 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV116'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_20, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV116'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_20 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV117'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_20, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV117'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_20 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV118'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_20, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV118'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_20 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV120'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_20, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV120'), N'Thành viên', N'Chờ tham gia');


-- Nhóm BigData Analytics
DECLARE @NhomId_21 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm BigData Analytics')
BEGIN
    DECLARE @Leader_21 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV121');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotCSDL2, N'Nhóm BigData Analytics', @Leader_21, N'Đang hoạt động');
    SET @NhomId_21 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_21 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm BigData Analytics');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_21 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV121'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_21, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV121'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_21 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV122'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_21, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV122'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_21 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV123'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_21, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV123'), N'Thành viên', N'Đã tham gia');


-- Nhóm Omnichannel Retail
DECLARE @NhomId_22 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Omnichannel Retail')
BEGIN
    DECLARE @Leader_22 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV126');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotCNPM1, N'Nhóm Omnichannel Retail', @Leader_22, N'Đang hoạt động');
    SET @NhomId_22 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_22 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Omnichannel Retail');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_22 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV126'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_22, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV126'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_22 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV127'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_22, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV127'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_22 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV128'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_22, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV128'), N'Thành viên', N'Đã tham gia');


-- Nhóm MedTech Solution
DECLARE @NhomId_23 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm MedTech Solution')
BEGIN
    DECLARE @Leader_23 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV131');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotLTDD2, N'Nhóm MedTech Solution', @Leader_23, N'Đang hoạt động');
    SET @NhomId_23 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_23 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm MedTech Solution');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_23 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV131'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_23, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV131'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_23 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV132'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_23, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV132'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_23 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV133'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_23, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV133'), N'Thành viên', N'Đã tham gia');


-- Nhóm BlockChain Lab
DECLARE @NhomId_24 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm BlockChain Lab')
BEGIN
    DECLARE @Leader_24 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV136');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotCSDL2, N'Nhóm BlockChain Lab', @Leader_24, N'Đang hoạt động');
    SET @NhomId_24 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_24 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm BlockChain Lab');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_24 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV136'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_24, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV136'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_24 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV137'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_24, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV137'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_24 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV138'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_24, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV138'), N'Thành viên', N'Đã tham gia');


-- Nhóm DeepLearning X
DECLARE @NhomId_25 INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm DeepLearning X')
BEGIN
    DECLARE @Leader_25 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV141');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES (@DotAI1, N'Nhóm DeepLearning X', @Leader_25, N'Đang hoạt động');
    SET @NhomId_25 = SCOPE_IDENTITY();
END
ELSE
    SET @NhomId_25 = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm DeepLearning X');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_25 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV141'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_25, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV141'), N'Trưởng nhóm', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_25 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV142'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_25, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV142'), N'Thành viên', N'Đã tham gia');


IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_25 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV143'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_25, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV143'), N'Thành viên', N'Đã tham gia');


-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = @NhomId_25 AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV145'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES (@NhomId_25, (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV145'), N'Thành viên', N'Chờ tham gia');

PRINT N'>> Đã hoàn thành nạp danh sách 25 nhóm đồ án và thành viên!';
GO

-- ==============================================================================
-- 10. ĐĂNG KÝ ĐỀ TÀI (ĐÃ DUYỆT, CHỜ DUYỆT, TỪ CHỐI)
-- ==============================================================================

DECLARE @GV1 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV001');
DECLARE @GV2 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV002');
DECLARE @GV3 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV003');
DECLARE @GV4 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV004');
DECLARE @GV5 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV005');
DECLARE @GV6 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV006');

-- Đăng ký 1: Nhóm Demo 01 -> Ứng dụng quản lý đăng ký nhóm đồ án (Đã duyệt)
DECLARE @N1 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Demo 01%');
DECLARE @D1 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%quản lý đăng ký nhóm đồ án%');
IF @N1 IS NOT NULL AND @D1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N1)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N1, @D1, DATEADD(DAY, -14, SYSDATETIME()), N'Đã duyệt', N'Đề tài phù hợp quy chuẩn môn học, đồng ý hướng dẫn.', DATEADD(DAY, -12, SYSDATETIME()), @GV1);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D1;
END

-- Đăng ký 2: Nhóm Mobile Pro -> Hệ thống quản lý công việc nhóm Agile/Scrum (Đã duyệt)
DECLARE @N2 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Mobile Pro%');
DECLARE @D2 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%quản lý công việc nhóm%');
IF @N2 IS NOT NULL AND @D2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N2)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N2, @D2, DATEADD(DAY, -12, SYSDATETIME()), N'Đã duyệt', N'Nhóm chuẩn bị đề cương chi tiết cho tuần tiếp theo.', DATEADD(DAY, -10, SYSDATETIME()), @GV1);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D2;
END

-- Đăng ký 3: Nhóm Agile Dev -> Hệ thống quản lý chuỗi cung ứng nông sản (Đã duyệt)
DECLARE @N3 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Agile Dev%');
DECLARE @D3 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%chuỗi cung ứng nông sản%');
IF @N3 IS NOT NULL AND @D3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N3)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N3, @D3, DATEADD(DAY, -10, SYSDATETIME()), N'Đã duyệt', N'Đồng ý thông qua kế hoạch nghiên cứu và kiến trúc phần mềm.', DATEADD(DAY, -8, SYSDATETIME()), @GV2);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D3;
END

-- Đăng ký 4: Nhóm AI Innovators -> Nhận diện biển số xe bằng Deep Learning (Đã duyệt)
DECLARE @N4 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%AI Innovators%');
DECLARE @D4 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%nhận diện biển số xe%');
IF @N4 IS NOT NULL AND @D4 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N4)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N4, @D4, DATEADD(DAY, -9, SYSDATETIME()), N'Đã duyệt', N'Mục tiêu nghiên cứu tốt, chú ý thu thập dữ liệu đa dạng điều kiện sáng.', DATEADD(DAY, -7, SYSDATETIME()), @GV3);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D4;
END

-- Đăng ký 5: Nhóm Vision AI -> Trợ lý ảo học tập RAG dựa trên LLM (Đã duyệt)
DECLARE @N12 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Vision AI%');
DECLARE @D5 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%Trợ lý ảo học tập RAG%');
IF @N12 IS NOT NULL AND @D5 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N12)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N12, @D5, DATEADD(DAY, -8, SYSDATETIME()), N'Đã duyệt', N'Chủ đề rất thời sự và thực tiễn, khuyến khích tích hợp vector database.', DATEADD(DAY, -6, SYSDATETIME()), @GV3);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D5;
END

-- Đăng ký 6: Nhóm Data Wizards -> Tối ưu hóa chỉ mục CSDL (Đã duyệt)
DECLARE @N11 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Data Wizards%');
DECLARE @D6 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%Tối ưu hóa chỉ mục%');
IF @N11 IS NOT NULL AND @D6 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N11)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N11, @D6, DATEADD(DAY, -7, SYSDATETIME()), N'Đã duyệt', N'Đồng ý hướng dẫn. Yêu cầu nhóm chuẩn bị kịch bản đo lường benchmark chuẩn.', DATEADD(DAY, -5, SYSDATETIME()), @GV4);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D6;
END

-- Đăng ký 7: Nhóm Quality First -> Khung kiểm thử tự động Automation Testing (Đã duyệt)
DECLARE @N5 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Quality First%');
DECLARE @D7 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%Automation Testing%');
IF @N5 IS NOT NULL AND @D7 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N5)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N5, @D7, DATEADD(DAY, -11, SYSDATETIME()), N'Đã duyệt', N'Đề cương chi tiết đạt yêu cầu, triển khai theo đúng tiến độ đề xuất.', DATEADD(DAY, -9, SYSDATETIME()), @GV5);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D7;
END

-- Đăng ký 8: Nhóm CyberGuard -> Đánh giá an toàn thông tin OWASP (Đã duyệt)
DECLARE @N6 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%CyberGuard%');
DECLARE @D8 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%an toàn thông tin và phát hiện lỗ hổng OWASP%');
IF @N6 IS NOT NULL AND @D8 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N6)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N6, @D8, DATEADD(DAY, -6, SYSDATETIME()), N'Đã duyệt', N'Nhóm chỉ được thực nghiệm trên máy ảo cô lập trong lab trường.', DATEADD(DAY, -4, SYSDATETIME()), @GV5);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D8;
END

-- Đăng ký 9: Nhóm FinTech Core -> Ứng dụng TMĐT SmartHome (Đã duyệt)
DECLARE @N8 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%FinTech Core%');
DECLARE @D9 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%thương mại điện tử chuyên đồ gia dụng%');
IF @N8 IS NOT NULL AND @D9 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N8)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N8, @D9, DATEADD(DAY, -5, SYSDATETIME()), N'Đã duyệt', N'Duyệt đề tài, chú ý bảo mật cổng thanh toán VNPay sandbox.', DATEADD(DAY, -3, SYSDATETIME()), @GV1);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D9;
END

-- Đăng ký 10: Nhóm Cloud Titans -> LMS Microservices (Đã duyệt)
DECLARE @N7 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Cloud Titans%');
DECLARE @D10 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%LMS theo kiến trúc Microservices%');
IF @N7 IS NOT NULL AND @D10 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N7)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu, NgayDuyet, GiangVienDuyetId)
    VALUES (@N7, @D10, DATEADD(DAY, -30, SYSDATETIME()), N'Đã duyệt', N'Đề tài lớn, phân công 4 bạn làm việc chặt chẽ theo sprint.', DATEADD(DAY, -28, SYSDATETIME()), @GV6);
    UPDATE DeTaiDoAns SET TrangThai = N'Đã đăng ký' WHERE DeTaiId = @D10;
END

-- Đăng ký Chờ duyệt 1: Nhóm SmartHome IoT (Chờ GV duyệt trên app)
DECLARE @N9 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%SmartHome IoT%');
DECLARE @D11 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%đặt lịch khám bệnh%');
IF @N9 IS NOT NULL AND @D11 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N9)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu)
    VALUES (@N9, @D11, DATEADD(DAY, -1, SYSDATETIME()), N'Chờ duyệt', N'Nhóm đã có kinh nghiệm làm việc với RESTful API và Flutter.');
END

-- Đăng ký Chờ duyệt 2: Nhóm EduTech Future (Chờ GV duyệt)
DECLARE @N10 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%EduTech Future%');
DECLARE @D12 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%quản lý thư viện số%');
IF @N10 IS NOT NULL AND @D12 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N10)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, GhiChu)
    VALUES (@N10, @D12, DATEADD(DAY, -2, SYSDATETIME()), N'Chờ duyệt', N'Nhóm mong muốn tìm hiểu sâu về kiến trúc Web hiện đại.');
END

PRINT N'>> Đã hoàn thành nạp đăng ký đề tài!';
GO

-- ==============================================================================
-- 11. BÁO CÁO TIẾN ĐỘ ĐỒ ÁN (ĐẦY ĐỦ LINK GITHUB, NHẬN XÉT VÀ ĐIỂM SỐ)
-- ==============================================================================

DECLARE @GV1 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV001');
DECLARE @GV2 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV002');
DECLARE @GV3 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV003');
DECLARE @GV5 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV005');

-- Nhóm Demo 01 - Báo cáo tuần 1, 2, 3
DECLARE @N1 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Demo 01%');
DECLARE @D1 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%quản lý đăng ký nhóm đồ án%');

IF @N1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BaoCaoTienDos WHERE NhomId = @N1 AND TuanBaoCao = 1)
    INSERT INTO BaoCaoTienDos (NhomId, DeTaiId, TieuDe, NoiDung, FileUrl, GithubUrl, DemoUrl, TuanBaoCao, NgayNop, TrangThai, NhanXetGiangVien, Diem, GiangVienId, NgayNhanXet)
    VALUES (@N1, @D1, N'Báo cáo tuần 1: Khảo sát hiện trạng và đặc tả yêu cầu SRS', 
            N'Nhóm đã hoàn thành khảo sát quy trình thực tế tại khoa, xây dựng biểu đồ Use Case và tài liệu đặc tả chức năng chi tiết.', 
            N'https://progroup.edu.vn/files/reports/tuan1_srs.pdf', N'https://github.com/progroup-demo/mobile-app', NULL, 1, 
            DATEADD(DAY, -10, SYSDATETIME()), N'Đạt', N'Tài liệu SRS chi tiết, mô hình hóa luồng nghiệp vụ tốt.', 9.0, @GV1, DATEADD(DAY, -9, SYSDATETIME()));

IF @N1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BaoCaoTienDos WHERE NhomId = @N1 AND TuanBaoCao = 2)
    INSERT INTO BaoCaoTienDos (NhomId, DeTaiId, TieuDe, NoiDung, FileUrl, GithubUrl, DemoUrl, TuanBaoCao, NgayNop, TrangThai, NhanXetGiangVien, Diem, GiangVienId, NgayNhanXet)
    VALUES (@N1, @D1, N'Báo cáo tuần 2: Thiết kế kiến trúc CSDL và UI Wireframe', 
            N'Thiết kế ERD chuẩn hóa 3NF gồm 21 bảng, thiết kế giao diện Figma cho 15 màn hình chính của sinh viên và giảng viên.', 
            N'https://progroup.edu.vn/files/reports/tuan2_design.pdf', N'https://github.com/progroup-demo/mobile-app', N'https://figma.com/@progroup_demo', 2, 
            DATEADD(DAY, -5, SYSDATETIME()), N'Đạt', N'Thiết kế CSDL logic, giao diện Figma hiện đại đạt chuẩn Clean Architecture.', 9.5, @GV1, DATEADD(DAY, -4, SYSDATETIME()));

IF @N1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BaoCaoTienDos WHERE NhomId = @N1 AND TuanBaoCao = 3)
    INSERT INTO BaoCaoTienDos (NhomId, DeTaiId, TieuDe, NoiDung, FileUrl, GithubUrl, DemoUrl, TuanBaoCao, NgayNop, TrangThai, NhanXetGiangVien, Diem, GiangVienId, NgayNhanXet)
    VALUES (@N1, @D1, N'Báo cáo tuần 3: Xây dựng RESTful API và Tích hợp Flutter', 
            N'Hoàn thành xây dựng Auth API (JWT), API danh sách lớp học phần và màn hình Home hiển thị dữ liệu thật 100%.', 
            N'https://progroup.edu.vn/files/reports/tuan3_api.pdf', N'https://github.com/progroup-demo/mobile-app', NULL, 3, 
            DATEADD(DAY, -1, SYSDATETIME()), N'Đã nộp', NULL, NULL, NULL, NULL);

-- Nhóm Mobile Pro - Báo cáo tuần 1, 2
DECLARE @N2 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Mobile Pro%');
DECLARE @D2 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%quản lý công việc nhóm%');

IF @N2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BaoCaoTienDos WHERE NhomId = @N2 AND TuanBaoCao = 1)
    INSERT INTO BaoCaoTienDos (NhomId, DeTaiId, TieuDe, NoiDung, FileUrl, GithubUrl, DemoUrl, TuanBaoCao, NgayNop, TrangThai, NhanXetGiangVien, Diem, GiangVienId, NgayNhanXet)
    VALUES (@N2, @D2, N'Báo cáo tuần 1: Nghiên cứu quy trình Scrum và phân tích yêu cầu', 
            N'Khảo sát các công cụ Jira, Trello và định hình các tính năng cốt lõi cho ứng dụng.', 
            NULL, N'https://github.com/mobile-pro/scrum-app', NULL, 1, 
            DATEADD(DAY, -8, SYSDATETIME()), N'Đạt', N'Nghiên cứu tốt, cần làm rõ hơn cơ chế tính điểm Story Point.', 8.5, @GV1, DATEADD(DAY, -7, SYSDATETIME()));

-- Nhóm AI Innovators - Báo cáo tuần 1
DECLARE @N4 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%AI Innovators%');
DECLARE @D4 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%nhận diện biển số xe%');

IF @N4 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BaoCaoTienDos WHERE NhomId = @N4 AND TuanBaoCao = 1)
    INSERT INTO BaoCaoTienDos (NhomId, DeTaiId, TieuDe, NoiDung, FileUrl, GithubUrl, DemoUrl, TuanBaoCao, NgayNop, TrangThai, NhanXetGiangVien, Diem, GiangVienId, NgayNhanXet)
    VALUES (@N4, @D4, N'Báo cáo tuần 1: Thu thập và tiền xử lý tập dữ liệu biển số xe', 
            N'Đã thu thập 2.500 ảnh biển số xe máy và ô tô, tiến hành dán nhãn bounding box bằng LabelImg.', 
            NULL, N'https://github.com/ai-innovators/alpr-vietnam', NULL, 1, 
            DATEADD(DAY, -6, SYSDATETIME()), N'Đạt', N'Dữ liệu dán nhãn chuẩn. Tiếp tục huấn luyện thử nghiệm trên YOLOv8n.', 9.0, @GV3, DATEADD(DAY, -5, SYSDATETIME()));

-- Nhóm Quality First - Báo cáo tuần 1
DECLARE @N5 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom LIKE N'%Quality First%');
DECLARE @D7 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai LIKE N'%Automation Testing%');

IF @N5 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BaoCaoTienDos WHERE NhomId = @N5 AND TuanBaoCao = 1)
    INSERT INTO BaoCaoTienDos (NhomId, DeTaiId, TieuDe, NoiDung, FileUrl, GithubUrl, DemoUrl, TuanBaoCao, NgayNop, TrangThai, NhanXetGiangVien, Diem, GiangVienId, NgayNhanXet)
    VALUES (@N5, @D7, N'Báo cáo tuần 1: Xây dựng Test Strategy và Test Cases kiểm thử', 
            N'Hoàn thiện 200 Test Cases chi tiết bao phủ các module xác thực, đăng ký môn học và gửi thông báo.', 
            N'https://progroup.edu.vn/files/reports/test_cases_v1.xlsx', N'https://github.com/quality-first/test-framework', NULL, 1, 
            DATEADD(DAY, -7, SYSDATETIME()), N'Đạt', N'Bộ Test Cases rất kỹ lưỡng, có tính ứng dụng cao cho toàn dự án.', 9.5, @GV5, DATEADD(DAY, -6, SYSDATETIME()));

PRINT N'>> Đã hoàn thành nạp báo cáo tiến độ đồ án!';
GO

-- ==============================================================================
-- 12. BỔ SUNG THÔNG BÁO CHO TẤT CẢ 5 ROLES (SINH VIÊN, GIẢNG VIÊN, GIÁO VỤ, P. ĐÀO TẠO, ADMIN)
-- ==============================================================================

-- 12.1 Thông báo cho Sinh viên SV001..SV005
DECLARE @UserSV1 INT = (SELECT NguoiDungId FROM NguoiDungs WHERE TenDangNhap = 'SV001');
DECLARE @UserSV2 INT = (SELECT NguoiDungId FROM NguoiDungs WHERE TenDangNhap = 'SV002');
DECLARE @UserSV3 INT = (SELECT NguoiDungId FROM NguoiDungs WHERE TenDangNhap = 'SV003');

IF @UserSV1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = @UserSV1 AND TieuDe = N'Đề tài của bạn đã được phê duyệt')
    INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt, LoaiLienKet)
    VALUES (@UserSV1, N'Đề tài của bạn đã được phê duyệt', N'Giảng viên Nguyễn Văn Giảng đã phê duyệt đề tài "Ứng dụng quản lý đăng ký nhóm đồ án". Chúc mừng nhóm!', N'Đồ án', 1, DATEADD(DAY, -12, SYSDATETIME()), N'DETAI');

IF @UserSV1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = @UserSV1 AND TieuDe = N'Nhận xét báo cáo tiến độ tuần 2')
    INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt, LoaiLienKet)
    VALUES (@UserSV1, N'Nhận xét báo cáo tiến độ tuần 2', N'Báo cáo tuần 2 của nhóm đạt điểm 9.5. Giảng viên nhận xét: Thiết kế CSDL logic, giao diện Figma hiện đại.', N'Tiến độ', 0, DATEADD(DAY, -4, SYSDATETIME()), N'BAOCAO');

IF @UserSV1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = @UserSV1 AND TieuDe = N'Nhắc nhở nộp báo cáo tiến độ tuần 3')
    INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt, LoaiLienKet)
    VALUES (@UserSV1, N'Nhắc nhở nộp báo cáo tiến độ tuần 3', N'Hạn chót nộp báo cáo tiến độ tuần 3 là 23:59 Chủ Nhật tuần này. Vui lòng nộp đúng hạn.', N'Nhắc nhở', 0, DATEADD(HOUR, -5, SYSDATETIME()), N'BAOCAO');

IF @UserSV2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = @UserSV2 AND TieuDe = N'Lời mời tham gia nhóm đồ án')
    INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt, LoaiLienKet)
    VALUES (@UserSV2, N'Lời mời tham gia nhóm đồ án', N'Bạn vừa nhận được lời mời tham gia "Nhóm Quality First" từ trưởng nhóm SV021.', N'Nhóm', 0, DATEADD(DAY, -2, SYSDATETIME()), N'NHOM');

-- Thông báo phát đều cho các sinh viên SV006 -> SV030
INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Chào mừng bạn đến với hệ thống ProGroup AI', N'Hãy cập nhật đầy đủ thông tin hồ sơ cá nhân và kiểm tra danh sách lớp học phần của bạn.', N'Hệ thống', 1, DATEADD(DAY, -15, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap BETWEEN 'SV006' AND 'SV030'
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Chào mừng bạn đến với hệ thống ProGroup AI');

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Thông báo mở đợt đăng ký đồ án môn học', N'Khoa đã mở đợt đăng ký đồ án học kỳ 1 năm học 2026-2027. Hạn chót lập nhóm là ngày 20/11/2026.', N'Đồ án', 0, DATEADD(DAY, -3, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap BETWEEN 'SV006' AND 'SV030'
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Thông báo mở đợt đăng ký đồ án môn học');

-- 12.2 Thông báo cho Giảng viên (GV001 -> GV006)
INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Có đề xuất đề tài mới từ nhóm sinh viên', N'Nhóm sinh viên vừa gửi đăng ký đề tài mới. Vui lòng truy cập màn hình Duyệt đề tài để xem xét.', N'Đề tài', 0, DATEADD(HOUR, -3, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('GV001', 'GV002', 'GV003', 'GV004', 'GV005', 'GV006')
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Có đề xuất đề tài mới từ nhóm sinh viên');

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Nhắc nhở chấm điểm báo cáo tiến độ tuần', N'Hiện có 3 nhóm đã nộp báo cáo tiến độ tuần mới nhất đang chờ bạn nhận xét và chấm điểm.', N'Nhắc nhở', 0, DATEADD(DAY, -1, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('GV001', 'GV002', 'GV003', 'GV004', 'GV005', 'GV006')
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Nhắc nhở chấm điểm báo cáo tiến độ tuần');

-- 12.3 Thông báo cho Giáo vụ Khoa (gvk.demo, giaovu01)
INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Yêu cầu kiểm duyệt danh mục đề tài', N'Có 5 đề tài do sinh viên đề xuất đang chờ Giáo vụ khoa rà soát tính hợp lệ trước khi chuyển sang Giảng viên.', N'Kiểm duyệt', 0, DATEADD(HOUR, -6, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('gvk.demo', 'giaovu01')
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Yêu cầu kiểm duyệt danh mục đề tài');

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Kết quả import danh sách sinh viên K21', N'Đợt import danh sách sinh viên K21 hoàn thành: 250 sinh viên đã được cập nhật thành công vào CSDL.', N'Import', 1, DATEADD(DAY, -5, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('gvk.demo', 'giaovu01')
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Kết quả import danh sách sinh viên K21');

-- 12.4 Thông báo cho Phòng Đào tạo (pdt.demo, daotao01)
INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Báo cáo tiến độ đăng ký đồ án toàn trường', N'Thống kê đến hiện tại: 92% sinh viên khối ngành CNTT đã hoàn thành đăng ký nhóm và đề tài.', N'Báo cáo', 0, DATEADD(DAY, -1, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('pdt.demo', 'daotao01')
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Báo cáo tiến độ đăng ký đồ án toàn trường');

-- 12.5 Thông báo cho Admin (admin.demo, admin01)
INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Sao lưu cơ sở dữ liệu định kỳ thành công', N'Database ProjectRegistrationDB đã được sao lưu toàn vẹn vào lúc 02:00 AM hôm nay.', N'Hệ thống', 1, DATEADD(DAY, -1, SYSDATETIME())
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('admin.demo', 'admin01')
AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Sao lưu cơ sở dữ liệu định kỳ thành công');

PRINT N'>> Đã hoàn thành nạp danh mục thông báo cho tất cả 5 roles!';
GO

-- ==============================================================================
-- 13. LỊCH SỬ IMPORT DỮ LIỆU VÀ LỖI IMPORT (GIÁO VỤ & PHÒNG ĐÀO TẠO)
-- ==============================================================================

DECLARE @UserGVK INT = (SELECT NguoiDungId FROM NguoiDungs WHERE TenDangNhap = 'gvk.demo');
DECLARE @UserPDT INT = (SELECT NguoiDungId FROM NguoiDungs WHERE TenDangNhap = 'pdt.demo');

IF NOT EXISTS (SELECT 1 FROM DotImports WHERE TenFile = N'Danh_sach_sinh_vien_K21_CNTT.xlsx')
    INSERT INTO DotImports (LoaiDuLieu, TenFile, NguoiImportId, TongSoDong, SoDongThanhCong, SoDongLoi, TrangThai, CreatedAt)
    VALUES (N'SINHVIEN', N'Danh_sach_sinh_vien_K21_CNTT.xlsx', @UserGVK, 250, 250, 0, N'Hoàn thành', DATEADD(DAY, -10, SYSDATETIME()));

IF NOT EXISTS (SELECT 1 FROM DotImports WHERE TenFile = N'Danh_sach_giang_vien_2026.xlsx')
    INSERT INTO DotImports (LoaiDuLieu, TenFile, NguoiImportId, TongSoDong, SoDongThanhCong, SoDongLoi, TrangThai, CreatedAt)
    VALUES (N'GIANGVIEN', N'Danh_sach_giang_vien_2026.xlsx', @UserPDT, 45, 45, 0, N'Hoàn thành', DATEADD(DAY, -12, SYSDATETIME()));

DECLARE @DotImportLoi INT;
IF NOT EXISTS (SELECT 1 FROM DotImports WHERE TenFile = N'Phan_cong_lop_hoc_phan_dot_1.xlsx')
BEGIN
    INSERT INTO DotImports (LoaiDuLieu, TenFile, NguoiImportId, TongSoDong, SoDongThanhCong, SoDongLoi, TrangThai, CreatedAt)
    VALUES (N'LOPHOCPHAN', N'Phan_cong_lop_hoc_phan_dot_1.xlsx', @UserGVK, 50, 48, 2, N'Hoàn thành có lỗi', DATEADD(DAY, -8, SYSDATETIME()));
    SET @DotImportLoi = SCOPE_IDENTITY();
END
ELSE
    SET @DotImportLoi = (SELECT DotImportId FROM DotImports WHERE TenFile = N'Phan_cong_lop_hoc_phan_dot_1.xlsx');

IF @DotImportLoi IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LoiImports WHERE DotImportId = @DotImportLoi)
BEGIN
    INSERT INTO LoiImports (DotImportId, SoDong, TenCot, NoiDungLoi, CreatedAt)
    VALUES 
    (@DotImportLoi, 15, N'MaGiangVien', N'Mã giảng viên "GV999" không tồn tại trong hệ thống.', DATEADD(DAY, -8, SYSDATETIME())),
    (@DotImportLoi, 28, N'MaLopHocPhan', N'Lớp học phần "LTDD-99" bị trùng lặp mã trên hệ thống.', DATEADD(DAY, -8, SYSDATETIME()));
END
GO

-- ==============================================================================
-- 14. LỊCH SỬ YÊU CẦU AI (GEMINI AI GỢI Ý ĐỀ TÀI & PHÂN TÍCH KHẢ THI)
-- ==============================================================================

DECLARE @UserSV1 INT = (SELECT NguoiDungId FROM NguoiDungs WHERE TenDangNhap = 'SV001');
DECLARE @UserGV1 INT = (SELECT NguoiDungId FROM NguoiDungs WHERE TenDangNhap = 'GV001');

IF @UserSV1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM AIRequests WHERE NguoiDungId = @UserSV1 AND ChucNangAI = N'Gợi ý đề tài')
    INSERT INTO AIRequests (NguoiDungId, ChucNangAI, Prompt, Response, TrangThai, CreatedAt)
    VALUES (@UserSV1, N'Gợi ý đề tài', 
            N'Tôi muốn làm đề tài ứng dụng di động Flutter có ứng dụng AI nhận diện và tra cứu thông minh.', 
            N'Gợi ý 3 hướng đề tài nổi bật: 1. Trợ lý ảo học tập RAG tích hợp LLM. 2. Ứng dụng nhận diện và phân loại rác thải tự động. 3. Sổ sức khỏe điện tử thông minh tích hợp AI.', 
            N'Thành công', DATEADD(DAY, -14, SYSDATETIME()));

IF @UserGV1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM AIRequests WHERE NguoiDungId = @UserGV1 AND ChucNangAI = N'Đánh giá mục tiêu đề tài')
    INSERT INTO AIRequests (NguoiDungId, ChucNangAI, Prompt, Response, TrangThai, CreatedAt)
    VALUES (@UserGV1, N'Đánh giá mục tiêu đề tài', 
            N'Đánh giá tính khả thi và khối lượng công việc của đề tài: Hệ thống nhận diện biển số xe tự động bằng YOLOv8 trong 15 tuần cho nhóm 3 sinh viên.', 
            N'Đánh giá của Gemini AI: Tính khả thi 9/10, khối lượng phù hợp cho nhóm 3 sinh viên.', 
            N'Thành công', DATEADD(DAY, -13, SYSDATETIME()));
GO

-- ==============================================================================
-- 15. KIỂM TRA TỔNG SỐ LƯỢNG BẢN GHI SAU KHI NẠP DỮ LIỆU
-- ==============================================================================

SELECT 'NguoiDungs' AS TenBang, COUNT(*) AS TongSoBanGhi FROM NguoiDungs
UNION ALL
SELECT 'SinhViens', COUNT(*) FROM SinhViens
UNION ALL
SELECT 'GiangViens', COUNT(*) FROM GiangViens
UNION ALL
SELECT 'Khoas', COUNT(*) FROM Khoas
UNION ALL
SELECT 'HocPhans', COUNT(*) FROM HocPhans
UNION ALL
SELECT 'LopHocPhans', COUNT(*) FROM LopHocPhans
UNION ALL
SELECT 'SinhVienLopHocPhans', COUNT(*) FROM SinhVienLopHocPhans
UNION ALL
SELECT 'DotDangKyDoAns', COUNT(*) FROM DotDangKyDoAns
UNION ALL
SELECT 'DeTaiDoAns', COUNT(*) FROM DeTaiDoAns
UNION ALL
SELECT 'NhomDoAns', COUNT(*) FROM NhomDoAns
UNION ALL
SELECT 'ThanhVienNhoms', COUNT(*) FROM ThanhVienNhoms
UNION ALL
SELECT 'DangKyDeTais', COUNT(*) FROM DangKyDeTais
UNION ALL
SELECT 'BaoCaoTienDos', COUNT(*) FROM BaoCaoTienDos
UNION ALL
SELECT 'ThongBaos', COUNT(*) FROM ThongBaos
UNION ALL
SELECT 'DotImports', COUNT(*) FROM DotImports
UNION ALL
SELECT 'AIRequests', COUNT(*) FROM AIRequests;

PRINT N'==============================================================================';
PRINT N'>>> CHÚC MỪNG: HOÀN TẤT NẠP DỮ LIỆU ĐẦY ĐỦ VÀ PHONG PHÚ CHO PROGROUP AI! <<<';
PRINT N'==============================================================================';
GO
