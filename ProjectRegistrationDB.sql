/* ============================================================
   1. TẠO DATABASE
   ============================================================ */

CREATE DATABASE ProjectRegistrationDB;
GO

USE ProjectRegistrationDB;
GO


/* ============================================================
   2. BẢNG VAI TRÒ
   ============================================================ */

CREATE TABLE VaiTros
(
    VaiTroId INT IDENTITY(1,1) PRIMARY KEY,

    MaVaiTro VARCHAR(50) NOT NULL UNIQUE,

    TenVaiTro NVARCHAR(100) NOT NULL,

    MoTa NVARCHAR(255) NULL
);
GO


INSERT INTO VaiTros
(
    MaVaiTro,
    TenVaiTro,
    MoTa
)
VALUES
(
    'ADMIN',
    N'Quản trị viên',
    N'Quản lý tài khoản, phân quyền và dữ liệu hệ thống'
),
(
    'SINHVIEN',
    N'Sinh viên',
    N'Tham gia đăng ký nhóm và đề tài đồ án môn học'
),
(
    'GIANGVIEN',
    N'Giảng viên',
    N'Quản lý lớp học phần, đợt đăng ký và đề tài đồ án'
),
(
    'GIAOVUKHOA',
    N'Giáo vụ Khoa',
    N'Quản lý dữ liệu sinh viên và giảng viên thuộc Khoa'
),
(
    'PHONGDAOTAO',
    N'Phòng Đào tạo',
    N'Quản lý dữ liệu học kỳ, học phần và lớp học phần'
);
GO


/* ============================================================
   3. BẢNG KHOA
   ============================================================ */

CREATE TABLE Khoas
(
    KhoaId INT IDENTITY(1,1) PRIMARY KEY,

    MaKhoa VARCHAR(20) NOT NULL UNIQUE,

    TenKhoa NVARCHAR(200) NOT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO


/* ============================================================
   4. BẢNG NGƯỜI DÙNG
   ============================================================ */

CREATE TABLE NguoiDungs
(
    NguoiDungId INT IDENTITY(1,1) PRIMARY KEY,

    TenDangNhap VARCHAR(100) NOT NULL UNIQUE,

    MatKhauHash NVARCHAR(500) NOT NULL,

    Email VARCHAR(150) NOT NULL UNIQUE,

    HoTen NVARCHAR(200) NOT NULL,

    SoDienThoai VARCHAR(20) NULL,

    AvatarUrl NVARCHAR(500) NULL,

    VaiTroId INT NOT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    YeuCauDoiMatKhau BIT NOT NULL DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_NguoiDungs_VaiTros
        FOREIGN KEY (VaiTroId)
        REFERENCES VaiTros(VaiTroId)
);
GO


/* ============================================================
   5. BẢNG HỌC KỲ
   ============================================================ */

CREATE TABLE HocKys
(
    HocKyId INT IDENTITY(1,1) PRIMARY KEY,

    TenHocKy NVARCHAR(100) NOT NULL,

    NamHoc VARCHAR(20) NOT NULL,

    NgayBatDau DATE NOT NULL,

    NgayKetThuc DATE NOT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_HocKys_TenHocKy_NamHoc
        UNIQUE (TenHocKy, NamHoc),

    CONSTRAINT CK_HocKys_Ngay
        CHECK (NgayKetThuc > NgayBatDau)
);
GO


/* ============================================================
   6. BẢNG SINH VIÊN
   ============================================================ */

CREATE TABLE SinhViens
(
    SinhVienId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL UNIQUE,

    MSSV VARCHAR(30) NOT NULL UNIQUE,

    KhoaId INT NOT NULL,

    NgaySinh DATE NULL,

    GioiTinh NVARCHAR(10) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_SinhViens_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId),

    CONSTRAINT FK_SinhViens_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   7. BẢNG GIẢNG VIÊN
   ============================================================ */

CREATE TABLE GiangViens
(
    GiangVienId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL UNIQUE,

    MaGiangVien VARCHAR(30) NOT NULL UNIQUE,

    KhoaId INT NOT NULL,

    HocVi NVARCHAR(100) NULL,

    ChuyenMon NVARCHAR(200) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_GiangViens_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId),

    CONSTRAINT FK_GiangViens_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   8. BẢNG HỌC PHẦN
   ============================================================ */

CREATE TABLE HocPhans
(
    HocPhanId INT IDENTITY(1,1) PRIMARY KEY,

    MaHocPhan VARCHAR(30) NOT NULL UNIQUE,

    TenHocPhan NVARCHAR(300) NOT NULL,

    SoTinChi INT NOT NULL,

    KhoaId INT NULL,

    MoTa NVARCHAR(1000) NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT CK_HocPhans_SoTinChi
        CHECK (SoTinChi > 0),

    CONSTRAINT FK_HocPhans_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   9. BẢNG LỚP HỌC PHẦN
   ============================================================ */

CREATE TABLE LopHocPhans
(
    LopHocPhanId INT IDENTITY(1,1) PRIMARY KEY,

    MaLopHocPhan VARCHAR(50) NOT NULL,

    TenLopHocPhan NVARCHAR(300) NULL,

    HocPhanId INT NOT NULL,

    HocKyId INT NOT NULL,

    KhoaId INT NOT NULL,

    SoLuongToiDa INT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_LopHocPhans_MaLop_HocKy
        UNIQUE (MaLopHocPhan, HocKyId),

    CONSTRAINT CK_LopHocPhans_SoLuong
        CHECK
        (
            SoLuongToiDa IS NULL
            OR SoLuongToiDa > 0
        ),

    CONSTRAINT FK_LopHocPhans_HocPhans
        FOREIGN KEY (HocPhanId)
        REFERENCES HocPhans(HocPhanId),

    CONSTRAINT FK_LopHocPhans_HocKys
        FOREIGN KEY (HocKyId)
        REFERENCES HocKys(HocKyId),

    CONSTRAINT FK_LopHocPhans_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   10. BẢNG PHÂN CÔNG GIẢNG VIÊN
   ============================================================ */

CREATE TABLE PhanCongGiangViens
(
    PhanCongId INT IDENTITY(1,1) PRIMARY KEY,

    LopHocPhanId INT NOT NULL,

    GiangVienId INT NOT NULL,

    VaiTro NVARCHAR(100)
        NOT NULL
        DEFAULT N'Giảng viên phụ trách',

    NgayPhanCong DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    TrangThai BIT
        NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_PhanCongGiangVien
        UNIQUE (LopHocPhanId, GiangVienId),

    CONSTRAINT FK_PhanCongGiangViens_LopHocPhans
        FOREIGN KEY (LopHocPhanId)
        REFERENCES LopHocPhans(LopHocPhanId),

    CONSTRAINT FK_PhanCongGiangViens_GiangViens
        FOREIGN KEY (GiangVienId)
        REFERENCES GiangViens(GiangVienId)
);
GO


/* ============================================================
   11. BẢNG SINH VIÊN - LỚP HỌC PHẦN
   ============================================================ */

CREATE TABLE SinhVienLopHocPhans
(
    SinhVienLopHocPhanId INT IDENTITY(1,1) PRIMARY KEY,

    SinhVienId INT NOT NULL,

    LopHocPhanId INT NOT NULL,

    NgayThamGia DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    TrangThai BIT
        NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_SinhVien_LopHocPhan
        UNIQUE (SinhVienId, LopHocPhanId),

    CONSTRAINT FK_SinhVienLopHocPhans_SinhViens
        FOREIGN KEY (SinhVienId)
        REFERENCES SinhViens(SinhVienId),

    CONSTRAINT FK_SinhVienLopHocPhans_LopHocPhans
        FOREIGN KEY (LopHocPhanId)
        REFERENCES LopHocPhans(LopHocPhanId)
);
GO


/* ============================================================
   12. BẢNG ĐỢT ĐĂNG KÝ ĐỒ ÁN
   ============================================================ */

CREATE TABLE DotDangKyDoAns
(
    DotDangKyId INT IDENTITY(1,1) PRIMARY KEY,

    LopHocPhanId INT NOT NULL,

    TenDot NVARCHAR(200) NOT NULL,

    NgayBatDau DATETIME2 NOT NULL,

    NgayKetThuc DATETIME2 NOT NULL,

    MinMembers INT NOT NULL,

    MaxMembers INT NOT NULL,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Chưa mở',

    CreatedAt DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT CK_DotDangKyDoAns_Ngay
        CHECK (NgayKetThuc > NgayBatDau),

    CONSTRAINT CK_DotDangKyDoAns_ThanhVien
        CHECK
        (
            MinMembers > 0
            AND MaxMembers >= MinMembers
        ),

    CONSTRAINT CK_DotDangKyDoAns_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Chưa mở',
                N'Đang mở',
                N'Đã đóng'
            )
        ),

    CONSTRAINT FK_DotDangKyDoAns_LopHocPhans
        FOREIGN KEY (LopHocPhanId)
        REFERENCES LopHocPhans(LopHocPhanId)
);
GO


/* ============================================================
   13. BẢNG NHÓM ĐỒ ÁN
   ============================================================ */

CREATE TABLE NhomDoAns
(
    NhomId INT IDENTITY(1,1) PRIMARY KEY,

    DotDangKyId INT NOT NULL,

    TenNhom NVARCHAR(200) NOT NULL,

    TruongNhomId INT NOT NULL,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Đang hoạt động',

    CreatedAt DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT UQ_NhomDoAns_Dot_TenNhom
        UNIQUE (DotDangKyId, TenNhom),

    CONSTRAINT CK_NhomDoAns_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Đang hoạt động',
                N'Đã khóa',
                N'Đã hủy'
            )
        ),

    CONSTRAINT FK_NhomDoAns_DotDangKy
        FOREIGN KEY (DotDangKyId)
        REFERENCES DotDangKyDoAns(DotDangKyId),

    CONSTRAINT FK_NhomDoAns_TruongNhom
        FOREIGN KEY (TruongNhomId)
        REFERENCES SinhViens(SinhVienId)
);
GO


/* ============================================================
   14. BẢNG THÀNH VIÊN NHÓM
   ============================================================ */

CREATE TABLE ThanhVienNhoms
(
    ThanhVienNhomId INT IDENTITY(1,1) PRIMARY KEY,

    NhomId INT NOT NULL,

    SinhVienId INT NOT NULL,

    VaiTro NVARCHAR(50)
        NOT NULL
        DEFAULT N'Thành viên',

    NgayThamGia DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Đã tham gia',

    CONSTRAINT UQ_ThanhVienNhom
        UNIQUE (NhomId, SinhVienId),

    CONSTRAINT CK_ThanhVienNhoms_VaiTro
        CHECK
        (
            VaiTro IN
            (
                N'Trưởng nhóm',
                N'Thành viên'
            )
        ),

    CONSTRAINT CK_ThanhVienNhoms_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Chờ tham gia',
                N'Đã tham gia',
                N'Đã rời nhóm'
            )
        ),

    CONSTRAINT FK_ThanhVienNhoms_NhomDoAns
        FOREIGN KEY (NhomId)
        REFERENCES NhomDoAns(NhomId),

    CONSTRAINT FK_ThanhVienNhoms_SinhViens
        FOREIGN KEY (SinhVienId)
        REFERENCES SinhViens(SinhVienId)
);
GO


/* ============================================================
   15. BẢNG ĐỀ TÀI ĐỒ ÁN
   ============================================================ */

CREATE TABLE DeTaiDoAns
(
    DeTaiId INT IDENTITY(1,1) PRIMARY KEY,

    DotDangKyId INT NOT NULL,

    TenDeTai NVARCHAR(500) NOT NULL,

    MoTa NVARCHAR(MAX) NULL,

    MucTieu NVARCHAR(MAX) NULL,

    PhamVi NVARCHAR(MAX) NULL,

    CongNgheDuKien NVARCHAR(1000) NULL,

    NguonDeTai NVARCHAR(50) NOT NULL,

    GiangVienId INT NULL,

    SinhVienDeXuatId INT NULL,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Chưa sử dụng',

    TrangThaiDuyet NVARCHAR(50)
        NOT NULL
        DEFAULT N'Chờ duyệt',

    LyDoTuChoi NVARCHAR(1000) NULL,

    CreatedAt DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT CK_DeTaiDoAns_Nguon
        CHECK
        (
            NguonDeTai IN
            (
                N'Giảng viên',
                N'Sinh viên đề xuất'
            )
        ),

    CONSTRAINT CK_DeTaiDoAns_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Chưa sử dụng',
                N'Đã đăng ký',
                N'Đã khóa',
                N'Đã hủy'
            )
        ),

    CONSTRAINT CK_DeTaiDoAns_TrangThaiDuyet
        CHECK
        (
            TrangThaiDuyet IN
            (
                N'Chờ duyệt',
                N'Đã duyệt',
                N'Từ chối'
            )
        ),

    CONSTRAINT FK_DeTaiDoAns_DotDangKy
        FOREIGN KEY (DotDangKyId)
        REFERENCES DotDangKyDoAns(DotDangKyId),

    CONSTRAINT FK_DeTaiDoAns_GiangViens
        FOREIGN KEY (GiangVienId)
        REFERENCES GiangViens(GiangVienId),

    CONSTRAINT FK_DeTaiDoAns_SinhViens
        FOREIGN KEY (SinhVienDeXuatId)
        REFERENCES SinhViens(SinhVienId)
);
GO


/* ============================================================
   16. BẢNG ĐĂNG KÝ ĐỀ TÀI
   ============================================================ */

CREATE TABLE DangKyDeTais
(
    DangKyDeTaiId INT IDENTITY(1,1) PRIMARY KEY,

    NhomId INT NOT NULL,

    DeTaiId INT NOT NULL,

    NgayDangKy DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Chờ duyệt',

    GhiChu NVARCHAR(1000) NULL,

    NgayDuyet DATETIME2 NULL,

    GiangVienDuyetId INT NULL,

    CONSTRAINT UQ_DangKyDeTai
        UNIQUE (NhomId, DeTaiId),

    CONSTRAINT CK_DangKyDeTais_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Chờ duyệt',
                N'Đã duyệt',
                N'Từ chối',
                N'Đã hủy'
            )
        ),

    CONSTRAINT CK_DangKyDeTais_NgayDuyet
        CHECK
        (
            (
                TrangThai = N'Chờ duyệt'
                AND NgayDuyet IS NULL
            )
            OR
            (
                TrangThai IN
                (
                    N'Đã duyệt',
                    N'Từ chối'
                )
                AND NgayDuyet IS NOT NULL
            )
            OR
            (
                TrangThai = N'Đã hủy'
            )
        ),

    CONSTRAINT FK_DangKyDeTais_NhomDoAns
        FOREIGN KEY (NhomId)
        REFERENCES NhomDoAns(NhomId),

    CONSTRAINT FK_DangKyDeTais_DeTaiDoAns
        FOREIGN KEY (DeTaiId)
        REFERENCES DeTaiDoAns(DeTaiId),

    CONSTRAINT FK_DangKyDeTais_GiangViens
        FOREIGN KEY (GiangVienDuyetId)
        REFERENCES GiangViens(GiangVienId)
);
GO


/* ============================================================
   17. BẢNG OTP QUÊN MẬT KHẨU
   ============================================================ */

CREATE TABLE PasswordResetOtps
(
    OtpId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL,

    OtpCodeHash NVARCHAR(500) NOT NULL,

    ExpiredAt DATETIME2 NOT NULL,

    SoLanThu INT NOT NULL DEFAULT 0,

    IsUsed BIT NOT NULL DEFAULT 0,

    CreatedAt DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT CK_PasswordResetOtps_SoLanThu
        CHECK (SoLanThu >= 0),

    CONSTRAINT CK_PasswordResetOtps_ExpiredAt
        CHECK (ExpiredAt > CreatedAt),

    CONSTRAINT FK_PasswordResetOtps_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   18. BẢNG LỊCH SỬ YÊU CẦU AI
   ============================================================ */

CREATE TABLE AIRequests
(
    AIRequestId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL,

    ChucNangAI NVARCHAR(100) NOT NULL,

    Prompt NVARCHAR(MAX) NOT NULL,

    Response NVARCHAR(MAX) NULL,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Thành công',

    CreatedAt DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT CK_AIRequests_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Đang xử lý',
                N'Thành công',
                N'Thất bại'
            )
        ),

    CONSTRAINT FK_AIRequests_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   19. BẢNG ĐỢT IMPORT DỮ LIỆU
   ============================================================ */

CREATE TABLE DotImports
(
    DotImportId INT IDENTITY(1,1) PRIMARY KEY,

    LoaiDuLieu NVARCHAR(100) NOT NULL,

    TenFile NVARCHAR(500) NOT NULL,

    NguoiImportId INT NOT NULL,

    TongSoDong INT NOT NULL DEFAULT 0,

    SoDongThanhCong INT NOT NULL DEFAULT 0,

    SoDongLoi INT NOT NULL DEFAULT 0,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Đang xử lý',

    CreatedAt DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT CK_DotImports_SoDong
        CHECK
        (
            TongSoDong >= 0
            AND SoDongThanhCong >= 0
            AND SoDongLoi >= 0
            AND SoDongThanhCong + SoDongLoi <= TongSoDong
        ),

    CONSTRAINT CK_DotImports_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Đang xử lý',
                N'Hoàn thành',
                N'Hoàn thành có lỗi',
                N'Thất bại'
            )
        ),

    CONSTRAINT FK_DotImports_NguoiDungs
        FOREIGN KEY (NguoiImportId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   20. BẢNG LỖI IMPORT
   ============================================================ */

CREATE TABLE LoiImports
(
    LoiImportId INT IDENTITY(1,1) PRIMARY KEY,

    DotImportId INT NOT NULL,

    SoDong INT NOT NULL,

    TenCot NVARCHAR(200) NULL,

    NoiDungLoi NVARCHAR(1000) NOT NULL,

    CreatedAt DATETIME2
        NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT CK_LoiImports_SoDong
        CHECK (SoDong > 0),

    CONSTRAINT FK_LoiImports_DotImports
        FOREIGN KEY (DotImportId)
        REFERENCES DotImports(DotImportId)
        ON DELETE CASCADE
);
GO


/* ============================================================
   21. INDEX
   ============================================================ */

CREATE INDEX IX_SinhViens_KhoaId
ON SinhViens(KhoaId);
GO


CREATE INDEX IX_GiangViens_KhoaId
ON GiangViens(KhoaId);
GO


CREATE INDEX IX_LopHocPhans_HocPhanId
ON LopHocPhans(HocPhanId);
GO


CREATE INDEX IX_LopHocPhans_HocKyId
ON LopHocPhans(HocKyId);
GO


CREATE INDEX IX_LopHocPhans_KhoaId
ON LopHocPhans(KhoaId);
GO


CREATE INDEX IX_PhanCongGiangViens_LopHocPhanId
ON PhanCongGiangViens(LopHocPhanId);
GO


CREATE INDEX IX_PhanCongGiangViens_GiangVienId
ON PhanCongGiangViens(GiangVienId);
GO


CREATE INDEX IX_SinhVienLopHocPhans_SinhVienId
ON SinhVienLopHocPhans(SinhVienId);
GO


CREATE INDEX IX_SinhVienLopHocPhans_LopHocPhanId
ON SinhVienLopHocPhans(LopHocPhanId);
GO


CREATE INDEX IX_DotDangKyDoAns_LopHocPhanId
ON DotDangKyDoAns(LopHocPhanId);
GO


CREATE INDEX IX_NhomDoAns_DotDangKyId
ON NhomDoAns(DotDangKyId);
GO


CREATE INDEX IX_NhomDoAns_TruongNhomId
ON NhomDoAns(TruongNhomId);
GO


CREATE INDEX IX_ThanhVienNhoms_NhomId
ON ThanhVienNhoms(NhomId);
GO


CREATE INDEX IX_ThanhVienNhoms_SinhVienId
ON ThanhVienNhoms(SinhVienId);
GO


CREATE INDEX IX_DeTaiDoAns_DotDangKyId
ON DeTaiDoAns(DotDangKyId);
GO


CREATE INDEX IX_DeTaiDoAns_GiangVienId
ON DeTaiDoAns(GiangVienId);
GO


CREATE INDEX IX_DeTaiDoAns_SinhVienDeXuatId
ON DeTaiDoAns(SinhVienDeXuatId);
GO


CREATE INDEX IX_DeTaiDoAns_TrangThaiDuyet
ON DeTaiDoAns(TrangThaiDuyet);
GO


CREATE INDEX IX_DangKyDeTais_NhomId
ON DangKyDeTais(NhomId);
GO


CREATE INDEX IX_DangKyDeTais_DeTaiId
ON DangKyDeTais(DeTaiId);
GO


CREATE INDEX IX_PasswordResetOtps_NguoiDungId
ON PasswordResetOtps(NguoiDungId);
GO


CREATE INDEX IX_AIRequests_NguoiDungId
ON AIRequests(NguoiDungId);
GO


CREATE INDEX IX_DotImports_NguoiImportId
ON DotImports(NguoiImportId);
GO


CREATE INDEX IX_LoiImports_DotImportId
ON LoiImports(DotImportId);
GO

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ DỮ LIỆU MẪU -------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

USE ProjectRegistrationDB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

---

-- 1. VAI TRO

IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'ADMIN')
INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa)
VALUES ('ADMIN', N'Quản trị viên', N'Quản lý hệ thống');

IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'SINHVIEN')
INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa)
VALUES ('SINHVIEN', N'Sinh viên', N'Đăng ký nhóm và đồ án');

IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'GIANGVIEN')
INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa)
VALUES ('GIANGVIEN', N'Giảng viên', N'Quản lý đề tài');

IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'GIAOVUKHOA')
INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa)
VALUES ('GIAOVUKHOA', N'Giáo vụ Khoa', N'Quản lý dữ liệu khoa');

IF NOT EXISTS (SELECT 1 FROM VaiTros WHERE MaVaiTro = 'PHONGDAOTAO')
INSERT INTO VaiTros (MaVaiTro, TenVaiTro, MoTa)
VALUES ('PHONGDAOTAO', N'Phòng Đào tạo', N'Quản lý học phần');

---

-- 2. KHOA

IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'CNTT')
INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai)
VALUES ('CNTT', N'Công nghệ thông tin', 1);

DECLARE @KhoaId INT =
(SELECT TOP 1 KhoaId FROM Khoas WHERE MaKhoa = 'CNTT');

---

-- 3. TAI KHOAN DEMO

/*
Hash bên dưới là BCrypt hash thường dùng cho mật khẩu
"password". Chỉ dùng demo nếu AuthService xác minh bằng
BCrypt tương thích. Nếu dự án dùng cơ chế khác, phải đổi
hash theo đúng AuthService.cs.

```
Tài khoản demo: mật khẩu "123456"
```

*/

DECLARE @PasswordHash NVARCHAR(500) =
N'$2b$12$3l0Sgmr43kRU5Ie78igHvOH72BSXBx/xJmhx6gy47gOxG8lxYExXW';

DECLARE @VaiTroAdmin INT =
(SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'ADMIN');
DECLARE @VaiTroSV INT =
(SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'SINHVIEN');
DECLARE @VaiTroGV INT =
(SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'GIANGVIEN');
DECLARE @VaiTroGVK INT =
(SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'GIAOVUKHOA');
DECLARE @VaiTroPDT INT =
(SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'PHONGDAOTAO');

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'admin.demo')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('admin.demo', @PasswordHash, '[admin.demo@example.com](mailto:admin.demo@example.com)',
N'Quản trị viên Demo', @VaiTroAdmin, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'gvk.demo')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('gvk.demo', @PasswordHash, '[gvk.demo@example.com](mailto:gvk.demo@example.com)',
N'Giáo vụ Khoa Demo', @VaiTroGVK, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'pdt.demo')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('pdt.demo', @PasswordHash, '[pdt.demo@example.com](mailto:pdt.demo@example.com)',
N'Phòng Đào tạo Demo', @VaiTroPDT, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'GV001')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('GV001', @PasswordHash, '[gv001@example.com](mailto:gv001@example.com)',
N'Nguyễn Văn Giảng', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'SV001')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('SV001', @PasswordHash, '[sv001@example.com](mailto:sv001@example.com)',
N'Trần Minh An', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'SV002')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('SV002', @PasswordHash, '[sv002@example.com](mailto:sv002@example.com)',
N'Lê Hoàng Bình', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'SV003')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('SV003', @PasswordHash, '[sv003@example.com](mailto:sv003@example.com)',
N'Phạm Gia Huy', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'SV004')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('SV004', @PasswordHash, '[sv004@example.com](mailto:sv004@example.com)',
N'Võ Ngọc Mai', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'SV005')
INSERT INTO NguoiDungs
(TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
VALUES ('SV005', @PasswordHash, '[sv005@example.com](mailto:sv005@example.com)',
N'Đặng Quốc Khánh', @VaiTroSV, 1);

---

-- 4. HOC KY

IF NOT EXISTS (
SELECT 1 FROM HocKys
WHERE TenHocKy = N'Học kỳ 1' AND NamHoc = '2026-2027'
)
INSERT INTO HocKys
(TenHocKy, NamHoc, NgayBatDau, NgayKetThuc, TrangThai)
VALUES (N'Học kỳ 1', '2026-2027',
'2026-09-01', '2027-01-31', 1);

DECLARE @HocKyId INT =
(
SELECT TOP 1 HocKyId FROM HocKys
WHERE TenHocKy = N'Học kỳ 1' AND NamHoc = '2026-2027'
);

---

-- 5. SINH VIEN

IF NOT EXISTS (SELECT 1 FROM SinhViens WHERE MSSV = 'SV001')
INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT NguoiDungId, 'SV001', @KhoaId, '2005-01-15', N'Nam'
FROM NguoiDungs WHERE TenDangNhap = 'SV001';

IF NOT EXISTS (SELECT 1 FROM SinhViens WHERE MSSV = 'SV002')
INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT NguoiDungId, 'SV002', @KhoaId, '2005-03-20', N'Nam'
FROM NguoiDungs WHERE TenDangNhap = 'SV002';

IF NOT EXISTS (SELECT 1 FROM SinhViens WHERE MSSV = 'SV003')
INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT NguoiDungId, 'SV003', @KhoaId, '2005-06-10', N'Nam'
FROM NguoiDungs WHERE TenDangNhap = 'SV003';

IF NOT EXISTS (SELECT 1 FROM SinhViens WHERE MSSV = 'SV004')
INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT NguoiDungId, 'SV004', @KhoaId, '2005-08-12', N'Nữ'
FROM NguoiDungs WHERE TenDangNhap = 'SV004';

IF NOT EXISTS (SELECT 1 FROM SinhViens WHERE MSSV = 'SV005')
INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT NguoiDungId, 'SV005', @KhoaId, '2005-11-05', N'Nữ'
FROM NguoiDungs WHERE TenDangNhap = 'SV005';

---

-- 6. GIANG VIEN

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV001')
INSERT INTO GiangViens
(NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
SELECT NguoiDungId, 'GV001', @KhoaId, N'Thạc sĩ',
N'Phát triển phần mềm'
FROM NguoiDungs WHERE TenDangNhap = 'GV001';

DECLARE @GiangVienId INT =
(SELECT TOP 1 GiangVienId FROM GiangViens
WHERE MaGiangVien = 'GV001');

DECLARE @SV1 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV001');
DECLARE @SV2 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV002');
DECLARE @SV3 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV003');
DECLARE @SV4 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV004');
DECLARE @SV5 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV005');

---

-- 7. HOC PHAN

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'LTDD')
INSERT INTO HocPhans
(MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
VALUES ('LTDD', N'Lập trình di động', 3, @KhoaId,
N'Phát triển ứng dụng di động', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'CNPM')
INSERT INTO HocPhans
(MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
VALUES ('CNPM', N'Công nghệ phần mềm', 3, @KhoaId,
N'Phân tích và phát triển phần mềm', 1);

DECLARE @HocPhanLTDD INT =
(SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'LTDD');
DECLARE @HocPhanCNPM INT =
(SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'CNPM');

---

-- 8. LOP HOC PHAN

IF NOT EXISTS (
SELECT 1 FROM LopHocPhans
WHERE MaLopHocPhan = 'LTDD-01' AND HocKyId = @HocKyId
)
INSERT INTO LopHocPhans
(MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId,
KhoaId, SoLuongToiDa, TrangThai)
VALUES ('LTDD-01', N'Lập trình di động - Nhóm 01',
@HocPhanLTDD, @HocKyId, @KhoaId, 40, 1);

IF NOT EXISTS (
SELECT 1 FROM LopHocPhans
WHERE MaLopHocPhan = 'CNPM-01' AND HocKyId = @HocKyId
)
INSERT INTO LopHocPhans
(MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId,
KhoaId, SoLuongToiDa, TrangThai)
VALUES ('CNPM-01', N'Công nghệ phần mềm - Nhóm 01',
@HocPhanCNPM, @HocKyId, @KhoaId, 40, 1);

DECLARE @LopLTDD INT =
(
SELECT LopHocPhanId FROM LopHocPhans
WHERE MaLopHocPhan = 'LTDD-01' AND HocKyId = @HocKyId
);
DECLARE @LopCNPM INT =
(
SELECT LopHocPhanId FROM LopHocPhans
WHERE MaLopHocPhan = 'CNPM-01' AND HocKyId = @HocKyId
);

---

-- 9. PHAN CONG GIANG VIEN

IF NOT EXISTS (
SELECT 1 FROM PhanCongGiangViens
WHERE LopHocPhanId = @LopLTDD AND GiangVienId = @GiangVienId
)
INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId)
VALUES (@LopLTDD, @GiangVienId);

IF NOT EXISTS (
SELECT 1 FROM PhanCongGiangViens
WHERE LopHocPhanId = @LopCNPM AND GiangVienId = @GiangVienId
)
INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId)
VALUES (@LopCNPM, @GiangVienId);

---

-- 10. SINH VIEN DANG KY LOP HOC PHAN

INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId)
SELECT x.SinhVienId, @LopLTDD
FROM (VALUES (@SV1), (@SV2), (@SV3), (@SV4), (@SV5)) x(SinhVienId)
WHERE x.SinhVienId IS NOT NULL
AND NOT EXISTS (
SELECT 1 FROM SinhVienLopHocPhans sl
WHERE sl.SinhVienId = x.SinhVienId
AND sl.LopHocPhanId = @LopLTDD
);

INSERT INTO SinhVienLopHocPhans (SinhVienId, LopHocPhanId)
SELECT x.SinhVienId, @LopCNPM
FROM (VALUES (@SV1), (@SV2), (@SV3), (@SV4), (@SV5)) x(SinhVienId)
WHERE x.SinhVienId IS NOT NULL
AND NOT EXISTS (
SELECT 1 FROM SinhVienLopHocPhans sl
WHERE sl.SinhVienId = x.SinhVienId
AND sl.LopHocPhanId = @LopCNPM
);

---

-- 11. DOT DANG KY DO AN DANG MO

IF NOT EXISTS (
SELECT 1 FROM DotDangKyDoAns
WHERE LopHocPhanId = @LopLTDD
AND TenDot = N'Đợt đăng ký đồ án Demo 2026'
)
INSERT INTO DotDangKyDoAns
(LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc,
MinMembers, MaxMembers, TrangThai)
VALUES
(@LopLTDD, N'Đợt đăng ký đồ án Demo 2026',
DATEADD(DAY, -7, SYSDATETIME()),
DATEADD(DAY, 60, SYSDATETIME()),
3, 5, N'Đang mở');

DECLARE @DotId INT =
(
SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns
WHERE LopHocPhanId = @LopLTDD
AND TenDot = N'Đợt đăng ký đồ án Demo 2026'
);

---

-- 12. NHOM DO AN

IF NOT EXISTS (
SELECT 1 FROM NhomDoAns
WHERE DotDangKyId = @DotId AND TenNhom = N'Nhóm Demo 01'
)
INSERT INTO NhomDoAns
(DotDangKyId, TenNhom, TruongNhomId, TrangThai)
VALUES (@DotId, N'Nhóm Demo 01', @SV1, N'Đang hoạt động');

DECLARE @NhomId INT =
(
SELECT TOP 1 NhomId FROM NhomDoAns
WHERE DotDangKyId = @DotId AND TenNhom = N'Nhóm Demo 01'
);

IF NOT EXISTS (
SELECT 1 FROM ThanhVienNhoms
WHERE NhomId = @NhomId AND SinhVienId = @SV1
)
INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
VALUES (@NhomId, @SV1, N'Trưởng nhóm', N'Đã tham gia');

IF NOT EXISTS (
SELECT 1 FROM ThanhVienNhoms
WHERE NhomId = @NhomId AND SinhVienId = @SV2
)
INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
VALUES (@NhomId, @SV2, N'Thành viên', N'Đã tham gia');

IF NOT EXISTS (
SELECT 1 FROM ThanhVienNhoms
WHERE NhomId = @NhomId AND SinhVienId = @SV3
)
INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai)
VALUES (@NhomId, @SV3, N'Thành viên', N'Đã tham gia');

---

-- 13. DE TAI DO AN

IF NOT EXISTS (
SELECT 1 FROM DeTaiDoAns
WHERE DotDangKyId = @DotId
AND TenDeTai = N'Ứng dụng quản lý đăng ký nhóm đồ án'
)
INSERT INTO DeTaiDoAns
(DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi,
CongNgheDuKien, NguonDeTai, GiangVienId,
TrangThai, TrangThaiDuyet)
VALUES
(@DotId,
N'Ứng dụng quản lý đăng ký nhóm đồ án',
N'Xây dựng ứng dụng hỗ trợ sinh viên đăng ký nhóm và đề tài.',
N'Giảm thao tác thủ công trong quá trình đăng ký.',
N'Sinh viên, giảng viên và quản lý đăng ký.',
N'Flutter, ASP.NET Core Web API, SQL Server',
N'Giảng viên', @GiangVienId,
N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (
SELECT 1 FROM DeTaiDoAns
WHERE DotDangKyId = @DotId
AND TenDeTai = N'Hệ thống quản lý công việc nhóm'
)
INSERT INTO DeTaiDoAns
(DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi,
CongNgheDuKien, NguonDeTai, GiangVienId,
TrangThai, TrangThaiDuyet)
VALUES
(@DotId,
N'Hệ thống quản lý công việc nhóm',
N'Quản lý công việc và tiến độ thực hiện đồ án.',
N'Hỗ trợ phân công nhiệm vụ và theo dõi tiến độ.',
N'Nhóm sinh viên thực hiện đồ án môn học.',
N'Flutter, ASP.NET Core, SQL Server',
N'Giảng viên', @GiangVienId,
N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (
SELECT 1 FROM DeTaiDoAns
WHERE DotDangKyId = @DotId
AND TenDeTai = N'Ứng dụng gợi ý đề tài bằng AI'
)
INSERT INTO DeTaiDoAns
(DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi,
CongNgheDuKien, NguonDeTai, GiangVienId,
TrangThai, TrangThaiDuyet)
VALUES
(@DotId,
N'Ứng dụng gợi ý đề tài bằng AI',
N'Ứng dụng AI để đề xuất đề tài theo nhu cầu sinh viên.',
N'Tạo gợi ý đề tài phù hợp với định hướng người dùng.',
N'Gợi ý và tra cứu đề tài đồ án.',
N'Flutter, ASP.NET Core, AI API',
N'Giảng viên', @GiangVienId,
N'Chưa sử dụng', N'Đã duyệt');

COMMIT TRANSACTION;
GO

---

-- 14. KIEM TRA DU LIEU SAU KHI INSERT

SELECT TenDangNhap, HoTen, Email, VaiTroId, TrangThai
FROM NguoiDungs
ORDER BY NguoiDungId;

SELECT MSSV, NguoiDungId, KhoaId
FROM SinhViens
ORDER BY SinhVienId;

SELECT MaLopHocPhan, TenLopHocPhan, HocKyId
FROM LopHocPhans;

SELECT DotDangKyId, TenDot, TrangThai, MinMembers, MaxMembers
FROM DotDangKyDoAns;

SELECT NhomId, TenNhom, DotDangKyId, TruongNhomId
FROM NhomDoAns;

SELECT DeTaiId, TenDeTai, TrangThai, TrangThaiDuyet
FROM DeTaiDoAns;
GO
