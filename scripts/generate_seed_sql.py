import os
import random

def generate_sql():
    random.seed(42)  # For reproducible realistic data

    ho_list = [
        "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Phan", "Vũ", "Võ",
        "Đặng", "Bùi", "Đỗ", "Hồ", "Ngô", "Dương", "Lý", "Lương", "Trịnh", "Đinh", "Đoàn", "Mai"
    ]

    dem_nam = [
        "Văn", "Minh", "Hoàng", "Đức", "Quang", "Tuấn", "Hữu", "Trọng", "Quốc",
        "Huy", "Đình", "Khắc", "Thanh", "Hải", "Bảo", "Công", "Tiến", "Nhật"
    ]

    ten_nam = [
        "An", "Bình", "Cường", "Dũng", "Đạt", "Giang", "Hải", "Hiếu", "Hùng", "Huy",
        "Khoa", "Kiên", "Long", "Minh", "Nam", "Nghĩa", "Nhân", "Phúc", "Quân", "Sơn",
        "Tâm", "Thắng", "Thành", "Thịnh", "Tiến", "Toàn", "Trung", "Tuấn", "Tùng", "Việt", "Vũ"
    ]

    dem_nu = [
        "Thị", "Ngọc", "Thùy", "Thu", "Phương", "Thanh", "Kim", "Quỳnh", "Mai",
        "Tuyết", "Bích", "Lan", "Ánh", "Hồng", "Diệu", "Khánh", "Hà", "Yến"
    ]

    ten_nu = [
        "Anh", "Chi", "Dung", "Duyên", "Giang", "Hà", "Hằng", "Hạnh", "Hoa", "Hương",
        "Huyền", "Lan", "Linh", "Ly", "Mai", "My", "Nga", "Ngân", "Nhi", "Nhung",
        "Phương", "Quyên", "Quỳnh", "Tâm", "Thảo", "Thu", "Thư", "Thủy", "Trang", "Trâm", "Uyên", "Vy", "Yến"
    ]

    # Pre-defined first 5 students to match existing DB
    known_students = [
        (1, "SV001", "Trần Minh An", "sv001@example.com", "2005-01-15", "Nam", "CNTT"),
        (2, "SV002", "Lê Hoàng Bình", "sv002@example.com", "2005-03-20", "Nam", "CNTT"),
        (3, "SV003", "Phạm Gia Huy", "sv003@example.com", "2005-06-10", "Nam", "CNTT"),
        (4, "SV004", "Võ Ngọc Mai", "sv004@example.com", "2005-08-12", "Nữ", "CNTT"),
        (5, "SV005", "Đặng Quốc Khánh", "sv005@example.com", "2005-11-05", "Nữ", "CNTT"),
    ]

    khoa_codes = ["CNTT", "KTPM", "HTTT", "KHMT", "ATTT"]

    students = list(known_students)
    for i in range(6, 251):
        mssv = f"SV{i:03d}"
        email = f"sv{i:03d}@example.com"
        gender = "Nam" if (i % 2 == 1 or i % 3 == 0) else "Nữ"
        khoa = khoa_codes[i % len(khoa_codes)]
        
        ho = ho_list[i % len(ho_list)]
        if gender == "Nam":
            dem = dem_nam[(i * 3) % len(dem_nam)]
            ten = ten_nam[(i * 7) % len(ten_nam)]
        else:
            dem = dem_nu[(i * 5) % len(dem_nu)]
            ten = ten_nu[(i * 11) % len(ten_nu)]
        
        hoten = f"{ho} {dem} {ten}"
        birth_year = 2003 + (i % 3)
        birth_month = 1 + (i % 12)
        birth_day = 1 + ((i * 3) % 28)
        dob = f"{birth_year:04d}-{birth_month:02d}-{birth_day:02d}"
        
        students.append((i, mssv, hoten, email, dob, gender, khoa))

    lines = []
    lines.append("-- ==============================================================================")
    lines.append("-- SCRIPT TẠO DỮ LIỆU ĐẦY ĐỦ VÀ PHONG PHÚ CHO PROGROUP AI (250+ SINH VIÊN)")
    lines.append("-- HỆ THỐNG ĐỒ ÁN VỚI ĐẦY ĐỦ 5 ROLES: ADMIN, SINH VIÊN, GIẢNG VIÊN, GIÁO VỤ, P. ĐÀO TẠO")
    lines.append("-- HỖ TRỢ CHẠY F5 NHIỀU LẦN (IDEMPOTENT - AN TOÀN KHÔNG BỊ LỖI TRÙNG KHÓA)")
    lines.append("-- ==============================================================================")
    lines.append("USE [ProjectRegistrationDB];")
    lines.append("GO\n")
    lines.append("SET NOCOUNT ON;\n")

    # 1. DDL GUARANTEE
    lines.append("-- ==============================================================================")
    lines.append("-- 1. KIỂM TRA VÀ TẠO BẢNG NẾU CHƯA CÓ (TRÁNH LỖI INVALID OBJECT NAME)")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 2. VAI TRÒ, KHOA, HỌC KỲ
    lines.append("-- ==============================================================================")
    lines.append("-- 2. KHỞI TẠO VAI TRÒ, KHOA VÀ HỌC KỲ")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 3. TÀI KHOẢN QUẢN TRỊ & GIẢNG VIÊN
    lines.append("-- ==============================================================================")
    lines.append("-- 3. KHỞI TẠO TÀI KHOẢN ADMIN, GIÁO VỤ, PHÒNG ĐÀO TẠO VÀ 6 GIẢNG VIÊN")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 4. HỌC PHẦN & LỚP HỌC PHẦN & PHÂN CÔNG
    lines.append("-- ==============================================================================")
    lines.append("-- 4. HỌC PHẦN, LỚP HỌC PHẦN VÀ PHÂN CÔNG GIẢNG VIÊN")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 5. ĐỢT ĐĂNG KÝ ĐỒ ÁN
    lines.append("-- ==============================================================================")
    lines.append("-- 5. ĐỢT ĐĂNG KÝ ĐỒ ÁN (ĐANG MỞ, CHƯA MỞ, ĐÃ ĐÓNG)")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 6. DANH SÁCH 250 SINH VIÊN (TÀI KHOẢN & HỒ SƠ)
    lines.append("-- ==============================================================================")
    lines.append("-- 6. BỔ SUNG 250 SINH VIÊN (SV001 -> SV250) ĐẦY ĐỦ THÔNG TIN, EMAIL, HỌ TÊN")
    lines.append("-- ==============================================================================")
    lines.append("""
DECLARE @PasswordHash NVARCHAR(500) = N'$2b$12$3l0Sgmr43kRU5Ie78igHvOH72BSXBx/xJmhx6gy47gOxG8lxYExXW';
DECLARE @VaiTroSV INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'SINHVIEN');
DECLARE @KhoaCNTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'CNTT');
DECLARE @KhoaKTPM INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KTPM');
DECLARE @KhoaHTTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'HTTT');
DECLARE @KhoaKHMT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KHMT');
DECLARE @KhoaATTT INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'ATTT');
""")

    lines.append("""
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
""")
    student_values = []
    for s in students:
        _, mssv, hoten, email, dob, gender, khoa = s
        student_values.append(f"('{mssv}', N'{hoten}', '{email}', '{dob}', N'{gender}', '{khoa}')")
    
    lines.append(",\n".join(student_values) + ";\n")

    lines.append("""
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
""")

    # 7. PHÂN BỔ SINH VIÊN VÀO CÁC LỚP HỌC PHẦN (SINHVIENLOPHOCPHANS)
    lines.append("-- ==============================================================================")
    lines.append("-- 7. ĐĂNG KÝ HỌC PHẦN: PHÂN BỔ 250 SINH VIÊN VÀO 12 LỚP HỌC PHẦN")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 8. ĐỀ TÀI ĐỒ ÁN (35 ĐỀ TÀI ĐA DẠNG)
    topics = [
        (
            "Ứng dụng quản lý đăng ký nhóm đồ án",
            "Xây dựng ứng dụng di động hỗ trợ sinh viên ghép nhóm, đăng ký đề tài và theo dõi tiến độ.",
            "Tự động hóa toàn bộ quy trình đăng ký đồ án môn học cho khoa CNTT.",
            "Sinh viên, giảng viên và phòng đào tạo toàn trường.",
            "Flutter, ASP.NET Core Web API, SQL Server",
            "Giảng viên", 1, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Demo 2026"
        ),
        (
            "Hệ thống quản lý công việc nhóm Agile/Scrum",
            "Ứng dụng quản lý dự án nhóm theo phương pháp Agile/Scrum với bảng Kanban và Sprint backlog.",
            "Hỗ trợ phân công công việc, ước lượng thời gian và theo dõi burndown chart.",
            "Các nhóm sinh viên làm bài tập lớn và đồ án tốt nghiệp.",
            "Flutter, ASP.NET Core, SignalR, SQL Server",
            "Giảng viên", 1, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Demo 2026"
        ),
        (
            "Ứng dụng gợi ý đề tài và ghép nhóm bằng AI",
            "Sử dụng AI để phân tích năng lực sinh viên, đề xuất đề tài phù hợp và tìm bạn cùng tiến.",
            "Tối ưu tỷ lệ ghép nhóm thành công và nâng cao chất lượng đề tài.",
            "Toàn bộ sinh viên thuộc khối ngành Công nghệ thông tin.",
            "Flutter, FastAPI, Gemini API, Pinecone Vector DB",
            "Giảng viên", 1, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Demo 2026"
        ),
        (
            "Ứng dụng học từ vựng tiếng Anh theo phương pháp Spaced Repetition",
            "Ứng dụng ghi nhớ từ vựng qua thẻ flashcard lặp lại ngắt quãng kết hợp nhận diện phát âm AI.",
            "Tăng hiệu quả ghi nhớ từ vựng lên 200% sau 30 ngày sử dụng.",
            "Người học tiếng Anh chuẩn bị thi TOEIC/IELTS.",
            "Flutter, Google Speech-to-Text, SQLite, Node.js",
            "Giảng viên", 1, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Demo 2026"
        ),
        (
            "Hệ thống theo dõi sức khỏe và lịch trình tập luyện cá nhân",
            "Đo lường chỉ số calo, theo dõi bước chân, gợi ý thực đơn và bài tập phù hợp thể trạng.",
            "Hỗ trợ người dùng duy trì lối sống lành mạnh và đạt mục tiêu cân nặng.",
            "Người dùng di động cá nhân trên cả iOS và Android.",
            "Flutter, HealthKit, Google Fit API, Firebase",
            "Giảng viên", 1, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Demo 2026"
        ),
        (
            "Ứng dụng thương mại điện tử chuyên đồ gia dụng thông minh SmartHome",
            "Ứng dụng mua sắm thiết bị IoT nhà thông minh, tích hợp cổng thanh toán VNPay và MoMo.",
            "Xây dựng trải nghiệm mua sắm mượt mà, thanh toán an toàn và tra cứu đơn hàng theo thời gian thực.",
            "Khách hàng mua sắm trực tuyến trên di động.",
            "Flutter, .NET 8 Web API, VNPay SDK, Redis",
            "Giảng viên", 1, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Di động N02"
        ),
        (
            "Ứng dụng đặt lịch khám bệnh và sổ sức khỏe điện tử",
            "Đặt lịch hẹn với bác sĩ, tra cứu hồ sơ bệnh án và nhắc lịch uống thuốc tự động.",
            "Giảm thời gian chờ đợi tại bệnh viện và quản lý tiền sử bệnh lý tập trung.",
            "Bệnh nhân và các phòng khám chuyên khoa liên kết.",
            "Flutter, Golang, PostgreSQL, Docker",
            "Giảng viên", 1, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Di động N02"
        ),
        (
            "Ứng dụng tìm trọ và đánh giá phòng trọ sinh viên",
            "Tìm kiếm phòng trọ theo bán kính trường học, lọc giá thành, tiện ích và review minh bạch.",
            "Giúp sinh viên tìm được nhà trọ an ninh, đúng giá, tránh bị lừa đảo đặt cọc.",
            "Khu vực xung quanh các trường đại học tại TP.HCM.",
            "Flutter, ASP.NET Core, Mapbox API, SQL Server",
            "Sinh viên đề xuất", 1, "SV005", "Chưa sử dụng", "Chờ duyệt", None, "Đợt đăng ký đồ án Demo 2026"
        ),
        (
            "Game 2D đa nền tảng giáo dục lịch sử Việt Nam",
            "Trò chơi hành động nhập vai tái hiện các trận đánh lịch sử và câu đố kiến thức.",
            "Tạo sân chơi hấp dẫn, giúp giới trẻ tiếp cận lịch sử dân tộc hào hùng.",
            "Thiết bị di động Android & iOS.",
            "Unity 2D, C#, Firebase Analytics",
            "Sinh viên đề xuất", 1, "SV009", "Chưa sử dụng", "Từ chối", "Phạm vi đề tài và công nghệ Unity chưa phù hợp với chuẩn đầu ra môn học Lập trình di động.", "Đợt đăng ký đồ án Demo 2026"
        ),
        # CNPM topics
        (
            "Hệ thống quản lý chuỗi cung ứng nông sản xuất khẩu",
            "Phần mềm quản lý nguồn gốc xuất xứ, kho bãi và chứng nhận VietGAP cho chuỗi cung ứng.",
            "Truy xuất nguồn gốc sản phẩm theo mã QR và quản lý vận chuyển logistics.",
            "Doanh nghiệp xuất khẩu nông sản và các hợp tác xã liên kết.",
            "ASP.NET Core, React.js, SQL Server, Azure Blob Storage",
            "Giảng viên", 2, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Công nghệ phần mềm K21"
        ),
        (
            "Nền tảng tuyển dụng việc làm IT và phỏng vấn trực tuyến",
            "Hệ thống đăng tin tuyển dụng, phân tích CV tự động bằng NLP và phòng phỏng vấn WebRTC.",
            "Kết nối ứng viên tài năng với các công ty công nghệ nhanh chóng, tiện lợi.",
            "Nhà tuyển dụng công nghệ và sinh viên mới tốt nghiệp.",
            "React.js, Node.js, NestJS, MongoDB, WebRTC",
            "Giảng viên", 2, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Công nghệ phần mềm K21"
        ),
        (
            "Hệ thống quản lý thư viện số và tra cứu tài liệu đại học",
            "Quản lý đầu sách, tài liệu nghiên cứu, mượn trả sách trực tuyến và tích hợp mã vạch/RFID.",
            "Hiện đại hóa hệ thống thư viện truyền thống sang mô hình thư viện số thông minh.",
            "Thư viện các trường đại học và cao đẳng.",
            "Vue.js, ASP.NET Core, SQL Server, Elasticsearch",
            "Giảng viên", 2, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Công nghệ phần mềm K21"
        ),
        (
            "Hệ thống quản lý phòng khám nha khoa thông minh",
            "Quản lý hồ sơ bệnh án nha khoa, lập kế hoạch điều trị, theo dõi công nợ và chăm sóc khách hàng.",
            "Số hóa toàn diện nghiệp vụ phòng khám nha khoa quy mô vừa và nhỏ.",
            "Các chuỗi phòng khám nha khoa.",
            "Next.js, TailwindCSS, Express.js, PostgreSQL",
            "Sinh viên đề xuất", 2, "SV012", "Chưa sử dụng", "Chờ duyệt", None, "Đợt đăng ký đồ án Công nghệ phần mềm K21"
        ),
        # AI topics
        (
            "Hệ thống nhận diện biển số xe tự động bằng Deep Learning",
            "Nhận diện biển số xe ô tô và xe máy qua camera độ phân giải cao ứng dụng YOLOv8 và OCR.",
            "Tự động hóa kiểm soát xe ra vào bãi đỗ với độ chính xác trên 98% và độ trễ dưới 200ms.",
            "Bãi đỗ xe trường đại học, tòa nhà văn phòng và khu đô thị.",
            "Python, YOLOv8, PyTorch, OpenCV, FastAPI",
            "Giảng viên", 3, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Trí tuệ nhân tạo N01"
        ),
        (
            "Trợ lý ảo học tập RAG dựa trên mô hình ngôn ngữ lớn LLM",
            "Xây dựng chatbot RAG tra cứu giáo trình môn học, tổng hợp kiến thức và tạo đề trắc nghiệm.",
            "Hỗ trợ sinh viên giải đáp thắc mắc 24/7 với câu trả lời trích dẫn chính xác từ tài liệu khoa.",
            "Sinh viên khối ngành Khoa học máy tính & CNTT.",
            "Python, LangChain, ChromaDB, Gemini 1.5 Flash API",
            "Giảng viên", 3, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Trí tuệ nhân tạo N01"
        ),
        (
            "Phát hiện và cảnh báo ngủ gật cho tài xế đường dài",
            "Giám sát mắt và cử chỉ khuôn mặt tài xế qua camera cabin để phát hiện triệu chứng buồn ngủ.",
            "Đưa ra cảnh báo âm thanh kịp thời khi tài xế nhắm mắt quá 2 giây hoặc ngáp liên tục.",
            "Tài xế xe khách đường dài và xe tải vận tải hàng hóa.",
            "Python, MediaPipe, OpenCV, TensorFlow Lite",
            "Giảng viên", 3, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Trí tuệ nhân tạo N01"
        ),
        (
            "Hệ thống phân loại rác thải tự động qua ảnh chụp",
            "Nhận diện và phân loại rác thành: rác hữu cơ, rác tái chế và rác vô cơ qua camera.",
            "Nâng cao ý thức phân loại rác tại nguồn và tích hợp vào thùng rác thông minh.",
            "Khuôn viên nhà trường và nơi công cộng.",
            "Python, PyTorch, MobileNetV3, Raspberry Pi",
            "Giảng viên", 3, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Trí tuệ nhân tạo N01"
        ),
        (
            "Hệ thống điểm danh tự động bằng nhận diện khuôn mặt sinh viên",
            "Điểm danh sinh viên vào lớp học bằng camera gắn tại cửa lớp, hỗ trợ nhận diện nhiều người cùng lúc.",
            "Tiết kiệm thời gian điểm danh truyền thống, phòng chống điểm danh hộ.",
            "Phòng học thực hành và giảng đường đại học.",
            "Python, FaceNet, OpenCV, Flutter",
            "Sinh viên đề xuất", 3, "SV004", "Chưa sử dụng", "Chờ duyệt", None, "Đợt đăng ký đồ án Trí tuệ nhân tạo N01"
        ),
        (
            "Dự đoán giá chứng khoán bằng mạng nơ-ron LSTM kết hợp Sentiment Analysis",
            "Thu thập tin tức tài chính và dữ liệu giá lịch sử để dự đoán xu hướng biến động giá cổ phiếu.",
            "Đưa ra chỉ báo tham khảo hỗ trợ nhà đầu tư cá nhân.",
            "Thị trường chứng khoán Việt Nam (VN-Index).",
            "Python, TensorFlow, LSTM, BeautifulSoup, Pandas",
            "Sinh viên đề xuất", 3, "SV018", "Chưa sử dụng", "Từ chối", "Đề tài mang tính suy đoán tài chính, rủi ro mô hình cao và không phù hợp với chuẩn nghiên cứu khoa học cơ bản của môn học.", "Đợt đăng ký đồ án Trí tuệ nhân tạo N01"
        ),
        # CSDL topics
        (
            "Tối ưu hóa chỉ mục và hiệu năng cơ sở dữ liệu lớn",
            "Nghiên cứu cơ chế Indexing, Partitioning, In-Memory OLTP và Query Execution Plan trong SQL Server.",
            "Giảm thời gian phản hồi truy vấn dữ liệu hàng chục triệu bản ghi xuống dưới 100ms.",
            "Hệ thống giao dịch tài chính và thương mại điện tử quy mô lớn.",
            "SQL Server, T-SQL, Extended Events, Database Engine Tuning",
            "Giảng viên", 4, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án CSDL N01"
        ),
        (
            "Hệ thống kho dữ liệu Data Warehouse phân tích kinh doanh BI",
            "Thiết kế kiến trúc Star Schema, ETL Pipeline tự động và xây dựng báo cáo phân tích đa chiều.",
            "Cung cấp dashboard trực quan hỗ trợ ban giám đốc ra quyết định kinh doanh chiến lược.",
            "Dữ liệu bán hàng chuỗi siêu thị bán lẻ toàn quốc.",
            "SQL Server, SSIS, SSAS, Power BI, Python",
            "Giảng viên", 4, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án CSDL N01"
        ),
        (
            "Xây dựng cơ sở dữ liệu phân tán NoSQL với MongoDB và Redis",
            "Thiết kế kiến trúc Sharding, Replica Sets và giải pháp Caching chịu tải cao cho mạng xã hội.",
            "Đảm bảo tính sẵn sàng cao (High Availability) và khả năng mở rộng ngang (Horizontal Scaling).",
            "Hệ thống nhắn tin tức thời và dòng thời gian mạng xã hội.",
            "MongoDB, Redis, Docker, Node.js",
            "Giảng viên", 4, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án CSDL Nâng cao 2026"
        ),
        (
            "Hệ thống giám sát và sao lưu dữ liệu tự động cho doanh nghiệp",
            "Tự động hóa quy trình sao lưu vi sai, nén dữ liệu và phục hồi sự cố khẩn cấp (Disaster Recovery).",
            "Đảm bảo an toàn dữ liệu và thời gian phục hồi RTO < 15 phút, RPO < 1 giờ.",
            "Hạ tầng máy chủ cơ sở dữ liệu doanh nghiệp.",
            "SQL Server, PowerShell, Azure Blob Storage",
            "Sinh viên đề xuất", 4, "SV025", "Chưa sử dụng", "Chờ duyệt", None, "Đợt đăng ký đồ án CSDL Nâng cao 2026"
        ),
        # KTPM topics
        (
            "Khung kiểm thử tự động Automation Testing cho Web và Mobile",
            "Xây dựng Page Object Model framework kiểm thử hồi quy tự động tích hợp CI/CD pipeline.",
            "Tự động hóa 85% kịch bản kiểm thử chức năng quan trọng trên cả trình duyệt và app di động.",
            "Hệ thống đăng ký tín chỉ và cổng thông tin sinh viên.",
            "Selenium, Appium, Java/TestNG, Allure Report, Jenkins",
            "Giảng viên", 5, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Kiểm thử phần mềm 2026"
        ),
        (
            "Đánh giá an toàn thông tin và phát hiện lỗ hổng OWASP Top 10",
            "Thực hiện kiểm thử xâm nhập Penetration Testing và quét mã nguồn bảo mật SAST/DAST.",
            "Phát hiện và đưa ra giải pháp khắc phục triệt để các lỗ hổng SQL Injection, XSS, CSRF.",
            "Cổng dịch vụ công trực tuyến giả lập.",
            "Kali Linux, Burp Suite, OWASP ZAP, SonarQube, Python",
            "Giảng viên", 5, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Kiểm thử phần mềm 2026"
        ),
        (
            "Hệ thống kiểm thử hiệu năng và chịu tải Performance Testing",
            "Giả lập 10.000 người dùng đồng thời truy cập để đo lường ngưỡng chịu tải và độ ổn định hệ thống.",
            "Xác định điểm nghẽn cổ chai (bottlenecks) về CPU, RAM, Network và Database lock.",
            "Hệ thống bán vé sự kiện trực tuyến vào giờ cao điểm.",
            "Apache JMeter, Locust, Grafana, InfluxDB",
            "Giảng viên", 5, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Kiểm thử phần mềm 2026"
        ),
        (
            "Kiểm thử tự động API bằng Postman Newman kết hợp CI/CD",
            "Xây dựng bộ test suite kiểm tra hợp đồng API Contract Testing, Data-Driven Testing.",
            "Phát hiện lỗi hồi quy API ngay khi lập trình viên tạo Pull Request.",
            "Hệ thống Backend Microservices thương mại điện tử.",
            "Postman, Newman, JavaScript, GitHub Actions",
            "Sinh viên đề xuất", 5, "SV032", "Chưa sử dụng", "Chờ duyệt", None, "Đợt đăng ký đồ án Kiểm thử phần mềm 2026"
        ),
        # Web & Cloud topics
        (
            "Xây dựng nền tảng học trực tuyến LMS theo kiến trúc Microservices",
            "Nền tảng đào tạo trực tuyến với tính năng xem video streaming, làm bài thi trắc nghiệm và cấp chứng chỉ.",
            "Khả năng mở rộng linh hoạt theo kiến trúc hướng dịch vụ với API Gateway và Message Broker.",
            "Học viên và giảng viên các trung tâm đào tạo công nghệ.",
            ".NET 8, Next.js, RabbitMQ, Docker, Kubernetes",
            "Giảng viên", 6, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Phát triển Web Fullstack"
        ),
        (
            "Hệ thống quản lý chuỗi khách sạn và đặt phòng trực tuyến",
            "Quản lý buồng phòng, dịch vụ buồng, hóa đơn và đồng bộ kênh bán phòng OTA qua API.",
            "Tối ưu tỷ lệ lấp đầy phòng và quản lý dòng tiền minh bạch, tức thì.",
            "Chuỗi khách sạn và homestay du lịch.",
            "React.js, ASP.NET Core, PostgreSQL, Redis",
            "Giảng viên", 6, None, "Đã đăng ký", "Đã duyệt", None, "Đợt đăng ký đồ án Phát triển Web Fullstack"
        ),
        (
            "Nền tảng đấu giá tài sản trực tuyến theo thời gian thực",
            "Hệ thống đấu giá với cơ chế trả giá realtime, chống tấn công bắn giá phút chót qua WebSocket.",
            "Đảm bảo tính công bằng, minh bạch tuyệt đối và xác thực người tham gia qua CCCD gắn chip.",
            "Các phiên đấu giá sản phẩm sưu tầm và đồ cổ.",
            "Vue.js 3, NestJS, Socket.IO, MongoDB",
            "Giảng viên", 6, None, "Chưa sử dụng", "Đã duyệt", None, "Đợt đăng ký đồ án Phát triển Web Fullstack"
        ),
        (
            "Cổng thông tin hướng nghiệp và kết nối cựu sinh viên",
            "Mạng xã hội cựu sinh viên chia sẻ kinh nghiệm phỏng vấn, cơ hội việc làm và cố vấn nghề nghiệp.",
            "Xây dựng cộng đồng cựu sinh viên gắn kết, hỗ trợ thế hệ đàn em.",
            "Toàn thể cựu sinh viên và sinh viên đang theo học tại trường.",
            "React.js, Node.js, GraphQL, PostgreSQL",
            "Sinh viên đề xuất", 6, "SV045", "Chưa sử dụng", "Chờ duyệt", None, "Đợt đăng ký đồ án Phát triển Web Fullstack"
        )
    ]

    lines.append("-- ==============================================================================")
    lines.append("-- 8. BỔ SUNG 30+ ĐỀ TÀI ĐỒ ÁN ĐA DẠNG CÔNG NGHỆ (MOBILE, AI, CLOUD, QA, CSDL)")
    lines.append("-- ==============================================================================")
    lines.append("""
DECLARE @GV1 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV001');
DECLARE @GV2 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV002');
DECLARE @GV3 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV003');
DECLARE @GV4 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV004');
DECLARE @GV5 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV005');
DECLARE @GV6 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV006');
""")

    for t in topics:
        ten, mota, muctieu, phamvi, tech, nguon, gv_idx, sv_mssv, trangthai, trangthaiduyet, lydo, dot_name = t
        gv_var = f"@GV{gv_idx}"
        sv_val = f"(SELECT SinhVienId FROM SinhViens WHERE MSSV = '{sv_mssv}')" if sv_mssv else "NULL"
        lydo_val = f"N'{lydo}'" if lydo else "NULL"
        lines.append(f"""
IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'{ten}')
BEGIN
    DECLARE @DotId_{abs(hash(ten)) % 100000} INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE TenDot = N'{dot_name}');
    IF @DotId_{abs(hash(ten)) % 100000} IS NULL
        SET @DotId_{abs(hash(ten)) % 100000} = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns ORDER BY DotDangKyId);

    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, SinhVienDeXuatId, TrangThai, TrangThaiDuyet, LyDoTuChoi)
    VALUES (@DotId_{abs(hash(ten)) % 100000}, N'{ten}', N'{mota}', N'{muctieu}', N'{phamvi}', N'{tech}', N'{nguon}', {gv_var}, {sv_val}, N'{trangthai}', N'{trangthaiduyet}', {lydo_val});
END
""")
    lines.append("PRINT N'>> Đã hoàn thành nạp danh mục đề tài đồ án!';\nGO\n")

    # 9. NHÓM ĐỒ ÁN VÀ THÀNH VIÊN NHÓM (25 NHÓM)
    lines.append("-- ==============================================================================")
    lines.append("-- 9. BỔ SUNG 25 NHÓM ĐỒ ÁN VÀ PHÂN BỔ THÀNH VIÊN VÀO NHÓM")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    groups_data = [
        ("Nhóm Demo 01", "@DotLTDD1", "SV001", ["SV002", "SV003"], None),
        ("Nhóm Mobile Pro", "@DotLTDD1", "SV006", ["SV007", "SV008"], "SV010"),
        ("Nhóm Agile Dev", "@DotCNPM1", "SV011", ["SV012", "SV013"], None),
        ("Nhóm AI Innovators", "@DotAI1", "SV016", ["SV017", "SV018"], "SV020"),
        ("Nhóm Quality First", "@DotKTPM1", "SV021", ["SV022", "SV023"], None),
        ("Nhóm CyberGuard", "@DotKTPM1", "SV026", ["SV027", "SV028"], "SV030"),
        ("Nhóm Cloud Titans", "@DotWDEV1", "SV051", ["SV052", "SV053", "SV054"], None),
        ("Nhóm FinTech Core", "@DotLTDD2", "SV041", ["SV042", "SV043"], None),
        ("Nhóm SmartHome IoT", "@DotLTDD2", "SV046", ["SV047", "SV048"], "SV050"),
        ("Nhóm EduTech Future", "@DotCNPM1", "SV031", ["SV032", "SV033", "SV034"], None),
        ("Nhóm Data Wizards", "@DotCSDL1", "SV061", ["SV062", "SV063"], None),
        ("Nhóm Vision AI", "@DotAI1", "SV071", ["SV072", "SV073"], "SV075"),
        ("Nhóm NextGen Web", "@DotWDEV1", "SV081", ["SV082", "SV083"], None),
        ("Nhóm CodeCrafters", "@DotCNPM1", "SV086", ["SV087", "SV088"], None),
        ("Nhóm DevOps Pioneers", "@DotWDEV1", "SV091", ["SV092", "SV093"], None),
        ("Nhóm SwiftCoders", "@DotLTDD1", "SV096", ["SV097", "SV098"], "SV100"),
        ("Nhóm BioTech IT", "@DotAI1", "SV101", ["SV102", "SV103"], None),
        ("Nhóm SecureNet", "@DotKTPM1", "SV106", ["SV107", "SV108"], None),
        ("Nhóm EcoTech", "@DotAI1", "SV111", ["SV112", "SV113"], None),
        ("Nhóm AutoTest Masters", "@DotKTPM1", "SV116", ["SV117", "SV118"], "SV120"),
        ("Nhóm BigData Analytics", "@DotCSDL2", "SV121", ["SV122", "SV123"], None),
        ("Nhóm Omnichannel Retail", "@DotCNPM1", "SV126", ["SV127", "SV128"], None),
        ("Nhóm MedTech Solution", "@DotLTDD2", "SV131", ["SV132", "SV133"], None),
        ("Nhóm BlockChain Lab", "@DotCSDL2", "SV136", ["SV137", "SV138"], None),
        ("Nhóm DeepLearning X", "@DotAI1", "SV141", ["SV142", "SV143"], "SV145")
    ]

    for g_idx, g in enumerate(groups_data):
        ten_nhom, dot_var, leader_mssv, members, pending = g
        gid_var = f"@NhomId_{g_idx+1}"
        lines.append(f"""
-- {ten_nhom}
DECLARE {gid_var} INT;
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'{ten_nhom}')
BEGIN
    DECLARE @Leader_{g_idx+1} INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = '{leader_mssv}');
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, TrangThai)
    VALUES ({dot_var}, N'{ten_nhom}', @Leader_{g_idx+1}, N'Đang hoạt động');
    SET {gid_var} = SCOPE_IDENTITY();
END
ELSE
    SET {gid_var} = (SELECT NhomId FROM NhomDoAns WHERE TenNhom = N'{ten_nhom}');

-- Trưởng nhóm
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = {gid_var} AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = '{leader_mssv}'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES ({gid_var}, (SELECT SinhVienId FROM SinhViens WHERE MSSV = '{leader_mssv}'), N'Trưởng nhóm', N'Đã tham gia');
""")
        for m in members:
            lines.append(f"""
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = {gid_var} AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = '{m}'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES ({gid_var}, (SELECT SinhVienId FROM SinhViens WHERE MSSV = '{m}'), N'Thành viên', N'Đã tham gia');
""")
        if pending:
            lines.append(f"""
-- Thành viên chờ tham gia (để test tính năng lời mời)
IF NOT EXISTS (SELECT 1 FROM ThanhVienNhoms WHERE NhomId = {gid_var} AND SinhVienId = (SELECT SinhVienId FROM SinhViens WHERE MSSV = '{pending}'))
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
    VALUES ({gid_var}, (SELECT SinhVienId FROM SinhViens WHERE MSSV = '{pending}'), N'Thành viên', N'Chờ tham gia');
""")

    lines.append("PRINT N'>> Đã hoàn thành nạp danh sách 25 nhóm đồ án và thành viên!';\nGO\n")

    # 10. ĐĂNG KÝ ĐỀ TÀI (DANGKYDETAIS)
    lines.append("-- ==============================================================================")
    lines.append("-- 10. ĐĂNG KÝ ĐỀ TÀI (ĐÃ DUYỆT, CHỜ DUYỆT, TỪ CHỐI)")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 11. BÁO CÁO TIẾN ĐỘ (BAOCAOTIENDOS)
    lines.append("-- ==============================================================================")
    lines.append("-- 11. BÁO CÁO TIẾN ĐỘ ĐỒ ÁN (ĐẦY ĐỦ LINK GITHUB, NHẬN XÉT VÀ ĐIỂM SỐ)")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 12. THÔNG BÁO CHO TẤT CẢ CÁC VAI TRÒ
    lines.append("-- ==============================================================================")
    lines.append("-- 12. BỔ SUNG THÔNG BÁO CHO TẤT CẢ 5 ROLES (SINH VIÊN, GIẢNG VIÊN, GIÁO VỤ, P. ĐÀO TẠO, ADMIN)")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 13. LỊCH SỬ IMPORT & LỖI IMPORT
    lines.append("-- ==============================================================================")
    lines.append("-- 13. LỊCH SỬ IMPORT DỮ LIỆU VÀ LỖI IMPORT (GIÁO VỤ & PHÒNG ĐÀO TẠO)")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 14. LỊCH SỬ YÊU CẦU AI (AIREQUESTS)
    lines.append("-- ==============================================================================")
    lines.append("-- 14. LỊCH SỬ YÊU CẦU AI (GEMINI AI GỢI Ý ĐỀ TÀI & PHÂN TÍCH KHẢ THI)")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    # 15. TỔNG KẾT VÀ KIỂM TRA SỐ LƯỢNG BẢN GHI
    lines.append("-- ==============================================================================")
    lines.append("-- 15. KIỂM TRA TỔNG SỐ LƯỢNG BẢN GHI SAU KHI NẠP DỮ LIỆU")
    lines.append("-- ==============================================================================")
    lines.append("""
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
""")

    output_path = r"D:\TRONGNGUYEN_HK7\PhatTrienUngDungDiDong\ProGroup_AI\scripts\seed_large_dataset.sql"
    with open(output_path, "w", encoding="utf-8-sig") as f:
        f.write("\n".join(lines))
    print(f"Generated successfully: {output_path}")

if __name__ == "__main__":
    generate_sql()
