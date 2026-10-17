﻿/* ============================================================
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
   21. BẢNG THÔNG BÁO
   ============================================================ */

CREATE TABLE ThongBaos
(
    ThongBaoId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL,

    TieuDe NVARCHAR(200) NOT NULL,

    NoiDung NVARCHAR(1000) NOT NULL,

    LoaiThongBao NVARCHAR(50) NOT NULL DEFAULT N'Hệ thống',

    DaDoc BIT NOT NULL DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    LienKetId INT NULL,

    LoaiLienKet NVARCHAR(50) NULL,

    CONSTRAINT FK_ThongBaos_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   22. INDEX
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
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('CNTT', N'Khoa Công nghệ Thông tin', 1);
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'KTPM')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('KTPM', N'Khoa Kỹ thuật Phần mềm', 1);
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'HTTT')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('HTTT', N'Khoa Hệ thống Thông tin', 1);
IF NOT EXISTS (SELECT 1 FROM Khoas WHERE MaKhoa = 'KHMT')
    INSERT INTO Khoas (MaKhoa, TenKhoa, TrangThai) VALUES ('KHMT', N'Khoa Khoa học Máy tính', 1);

DECLARE @KhoaCNTTId INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'CNTT');
DECLARE @KhoaKTPMId INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KTPM');
DECLARE @KhoaHTTTId INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'HTTT');
DECLARE @KhoaKHMTId INT = (SELECT KhoaId FROM Khoas WHERE MaKhoa = 'KHMT');

---

-- 3. HỌC KỲ
IF NOT EXISTS (SELECT 1 FROM HocKys WHERE TenHocKy = N'Học kỳ 1' AND NamHoc = '2026-2027')
    INSERT INTO HocKys (TenHocKy, NamHoc, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Học kỳ 1', '2026-2027', '2026-09-01', '2027-01-31', 1);

DECLARE @HocKyId INT = (SELECT TOP 1 HocKyId FROM HocKys WHERE TenHocKy = N'Học kỳ 1' AND NamHoc = '2026-2027');

---

-- 4. HỌC PHẦN
IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'LTDD')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('LTDD', N'Lập trình di động', 3, @KhoaCNTTId, N'Phát triển ứng dụng di động đa nền tảng với Flutter và Native.', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'CNPM')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('CNPM', N'Công nghệ phần mềm', 3, @KhoaKTPMId, N'Quy trình xây dựng phần mềm, thiết kế kiến trúc và quản lý dự án.', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'CSDL')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('CSDL', N'Cơ sở dữ liệu', 3, @KhoaHTTTId, N'Thiết kế CSDL quan hệ, tối ưu truy vấn SQL và quản trị dữ liệu.', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'AI')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('AI', N'Trí tuệ nhân tạo', 3, @KhoaKHMTId, N'Các mô hình học máy Machine Learning, Deep Learning và GenAI.', 1);

IF NOT EXISTS (SELECT 1 FROM HocPhans WHERE MaHocPhan = 'KTPM')
    INSERT INTO HocPhans (MaHocPhan, TenHocPhan, SoTinChi, KhoaId, MoTa, TrangThai)
    VALUES ('KTPM', N'Kiểm thử phần mềm', 3, @KhoaKTPMId, N'Quy trình kiểm thử đơn vị, kiểm thử tích hợp và tự động hóa kiểm thử.', 1);

DECLARE @HpLTDD INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'LTDD');
DECLARE @HpCNPM INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'CNPM');
DECLARE @HpCSDL INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'CSDL');
DECLARE @HpAI   INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'AI');
DECLARE @HpKTPM INT = (SELECT HocPhanId FROM HocPhans WHERE MaHocPhan = 'KTPM');

---

-- 5. TÀI KHOẢN NGƯỜI DÙNG (23 TÀI KHOẢN - MẬT KHẨU "123456")
DECLARE @PasswordHash NVARCHAR(500) = N'$2b$12$3l0Sgmr43kRU5Ie78igHvOH72BSXBx/xJmhx6gy47gOxG8lxYExXW';

DECLARE @VaiTroAdmin INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'ADMIN');
DECLARE @VaiTroSV    INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'SINHVIEN');
DECLARE @VaiTroGV    INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'GIANGVIEN');
DECLARE @VaiTroGVK   INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'GIAOVUKHOA');
DECLARE @VaiTroPDT   INT = (SELECT VaiTroId FROM VaiTros WHERE MaVaiTro = 'PHONGDAOTAO');

-- Quản trị, Giáo vụ, Phòng đào tạo
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'admin01')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('admin01', @PasswordHash, 'admin01@example.com', N'Quản Trị Viên Hệ Thống', @VaiTroAdmin, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'giaovu01')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('giaovu01', @PasswordHash, 'giaovu01@example.com', N'Nguyễn Thị Giáo Vụ', @VaiTroGVK, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'daotao01')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('daotao01', @PasswordHash, 'daotao01@example.com', N'Trần Văn Đào Tạo', @VaiTroPDT, 1);

-- 5 Giảng viên
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'gv001')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('gv001', @PasswordHash, 'gv001@example.com', N'Nguyễn Văn Giảng', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'gv002')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('gv002', @PasswordHash, 'gv002@example.com', N'Trần Thị Mai', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'gv003')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('gv003', @PasswordHash, 'gv003@example.com', N'Lê Hoàng Nam', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'gv004')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('gv004', @PasswordHash, 'gv004@example.com', N'Vũ Hải Đăng', @VaiTroGV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'gv005')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('gv005', @PasswordHash, 'gv005@example.com', N'Đặng Phương Thảo', @VaiTroGV, 1);

-- 15 Sinh viên (sv001 -> sv015)
IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv001')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv001', @PasswordHash, 'sv001@example.com', N'Trần Minh An', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv002')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv002', @PasswordHash, 'sv002@example.com', N'Lê Hoàng Bình', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv003')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv003', @PasswordHash, 'sv003@example.com', N'Phạm Gia Huy', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv004')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv004', @PasswordHash, 'sv004@example.com', N'Võ Ngọc Mai', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv005')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv005', @PasswordHash, 'sv005@example.com', N'Đặng Quốc Khánh', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv006')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv006', @PasswordHash, 'sv006@example.com', N'Bùi Thanh Trúc', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv007')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv007', @PasswordHash, 'sv007@example.com', N'Nguyễn Hữu Tài', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv008')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv008', @PasswordHash, 'sv008@example.com', N'Trần Quang Vinh', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv009')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv009', @PasswordHash, 'sv009@example.com', N'Đỗ Thu Thảo', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv010')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv010', @PasswordHash, 'sv010@example.com', N'Phan Hoàng Long', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv011')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv011', @PasswordHash, 'sv011@example.com', N'Hoàng Yến Nhi', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv012')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv012', @PasswordHash, 'sv012@example.com', N'Lý Cẩm Tú', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv013')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv013', @PasswordHash, 'sv013@example.com', N'Đỗ Phương Anh', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv014')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv014', @PasswordHash, 'sv014@example.com', N'Huỳnh Tấn Sang', @VaiTroSV, 1);

IF NOT EXISTS (SELECT 1 FROM NguoiDungs WHERE TenDangNhap = 'sv015')
    INSERT INTO NguoiDungs (TenDangNhap, MatKhauHash, Email, HoTen, VaiTroId, TrangThai)
    VALUES ('sv015', @PasswordHash, 'sv015@example.com', N'Trịnh Minh Triết', @VaiTroSV, 1);

---

-- 6. THÔNG TIN GIẢNG VIÊN (5 GIẢNG VIÊN)
IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV001')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV001', @KhoaCNTTId, N'Tiến sĩ', N'Phát triển phần mềm & Di động'
    FROM NguoiDungs WHERE TenDangNhap = 'gv001';

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV002')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV002', @KhoaKTPMId, N'Thạc sĩ', N'Công nghệ phần mềm & UI/UX'
    FROM NguoiDungs WHERE TenDangNhap = 'gv002';

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV003')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV003', @KhoaKHMTId, N'Phó Giáo sư', N'Trí tuệ nhân tạo & Dữ liệu lớn'
    FROM NguoiDungs WHERE TenDangNhap = 'gv003';

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV004')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV004', @KhoaHTTTId, N'Tiến sĩ', N'Cơ sở dữ liệu & Hệ thống thông tin'
    FROM NguoiDungs WHERE TenDangNhap = 'gv004';

IF NOT EXISTS (SELECT 1 FROM GiangViens WHERE MaGiangVien = 'GV005')
    INSERT INTO GiangViens (NguoiDungId, MaGiangVien, KhoaId, HocVi, ChuyenMon)
    SELECT NguoiDungId, 'GV005', @KhoaCNTTId, N'Thạc sĩ', N'An toàn thông tin & Mạng máy tính'
    FROM NguoiDungs WHERE TenDangNhap = 'gv005';

DECLARE @GV1 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV001');
DECLARE @GV2 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV002');
DECLARE @GV3 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV003');
DECLARE @GV4 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV004');
DECLARE @GV5 INT = (SELECT GiangVienId FROM GiangViens WHERE MaGiangVien = 'GV005');

---

-- 7. THÔNG TIN SINH VIÊN (15 SINH VIÊN)
INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT nd.NguoiDungId, UPPER(nd.TenDangNhap), @KhoaCNTTId, '2005-01-15', N'Nam'
FROM NguoiDungs nd
WHERE nd.TenDangNhap IN ('sv001','sv002','sv003','sv007','sv008','sv010','sv014','sv015')
  AND NOT EXISTS (SELECT 1 FROM SinhViens WHERE NguoiDungId = nd.NguoiDungId);

INSERT INTO SinhViens (NguoiDungId, MSSV, KhoaId, NgaySinh, GioiTinh)
SELECT nd.NguoiDungId, UPPER(nd.TenDangNhap), @KhoaCNTTId, '2005-08-20', N'Nữ'
FROM NguoiDungs nd
WHERE nd.TenDangNhap IN ('sv004','sv005','sv006','sv009','sv011','sv012','sv013')
  AND NOT EXISTS (SELECT 1 FROM SinhViens WHERE NguoiDungId = nd.NguoiDungId);

DECLARE @SV1 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV001');
DECLARE @SV2 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV002');
DECLARE @SV3 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV003');
DECLARE @SV4 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV004');
DECLARE @SV5 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV005');
DECLARE @SV6 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV006');
DECLARE @SV7 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV007');
DECLARE @SV8 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV008');
DECLARE @SV9 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV009');
DECLARE @SV10 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV010');
DECLARE @SV11 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV011');
DECLARE @SV12 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV012');
DECLARE @SV13 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV013');
DECLARE @SV14 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV014');
DECLARE @SV15 INT = (SELECT SinhVienId FROM SinhViens WHERE MSSV = 'SV015');

---

-- 8. LỚP HỌC PHẦN (6 LỚP)
IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('LTDD-01', N'Lập trình di động - Nhóm 01', @HpLTDD, @HocKyId, @KhoaCNTTId, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-02')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('LTDD-02', N'Lập trình di động - Nhóm 02', @HpLTDD, @HocKyId, @KhoaCNTTId, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('CNPM-01', N'Công nghệ phần mềm - Nhóm 01', @HpCNPM, @HocKyId, @KhoaKTPMId, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-02')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('CNPM-02', N'Công nghệ phần mềm - Nhóm 02', @HpCNPM, @HocKyId, @KhoaKTPMId, 50, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('CSDL-01', N'Cơ sở dữ liệu - Nhóm 01', @HpCSDL, @HocKyId, @KhoaHTTTId, 60, 1);

IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'AI-01')
    INSERT INTO LopHocPhans (MaLopHocPhan, TenLopHocPhan, HocPhanId, HocKyId, KhoaId, SoLuongToiDa, TrangThai)
    VALUES ('AI-01', N'Trí tuệ nhân tạo - Nhóm 01', @HpAI, @HocKyId, @KhoaKHMTId, 50, 1);

DECLARE @LhpLTDD1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-01');
DECLARE @LhpLTDD2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'LTDD-02');
DECLARE @LhpCNPM1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-01');
DECLARE @LhpCNPM2 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CNPM-02');
DECLARE @LhpCSDL1 INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'CSDL-01');
DECLARE @LhpAI1   INT = (SELECT LopHocPhanId FROM LopHocPhans WHERE MaLopHocPhan = 'AI-01');

---

-- 9. PHÂN CÔNG GIẢNG VIÊN PHỤ TRÁCH LỚP HỌC PHẦN
IF @LhpLTDD1 IS NOT NULL AND @GV1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpLTDD1)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId, VaiTro, TrangThai) VALUES (@LhpLTDD1, @GV1, N'Giảng viên phụ trách', 1);

IF @LhpLTDD2 IS NOT NULL AND @GV2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpLTDD2)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId, VaiTro, TrangThai) VALUES (@LhpLTDD2, @GV2, N'Giảng viên phụ trách', 1);

IF @LhpCNPM1 IS NOT NULL AND @GV1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpCNPM1)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId, VaiTro, TrangThai) VALUES (@LhpCNPM1, @GV1, N'Giảng viên phụ trách', 1);

IF @LhpCNPM2 IS NOT NULL AND @GV2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpCNPM2)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId, VaiTro, TrangThai) VALUES (@LhpCNPM2, @GV2, N'Giảng viên phụ trách', 1);

IF @LhpCSDL1 IS NOT NULL AND @GV4 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpCSDL1)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId, VaiTro, TrangThai) VALUES (@LhpCSDL1, @GV4, N'Giảng viên phụ trách', 1);

IF @LhpAI1 IS NOT NULL AND @GV3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PhanCongGiangViens WHERE LopHocPhanId = @LhpAI1)
    INSERT INTO PhanCongGiangViens (LopHocPhanId, GiangVienId, VaiTro, TrangThai) VALUES (@LhpAI1, @GV3, N'Giảng viên phụ trách', 1);

---

-- 10. GHI DANH SINH VIÊN VÀO LỚP HỌC PHẦN
INSERT INTO SinhVienLopHocPhans (LopHocPhanId, SinhVienId, TrangThai)
SELECT @LhpLTDD1, sv.SinhVienId, 1
FROM SinhViens sv JOIN NguoiDungs nd ON sv.NguoiDungId = nd.NguoiDungId
WHERE nd.TenDangNhap IN ('sv001','sv002','sv003','sv004','sv005')
  AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE LopHocPhanId = @LhpLTDD1 AND SinhVienId = sv.SinhVienId);

INSERT INTO SinhVienLopHocPhans (LopHocPhanId, SinhVienId, TrangThai)
SELECT @LhpLTDD2, sv.SinhVienId, 1
FROM SinhViens sv JOIN NguoiDungs nd ON sv.NguoiDungId = nd.NguoiDungId
WHERE nd.TenDangNhap IN ('sv006','sv007','sv008','sv009','sv010')
  AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE LopHocPhanId = @LhpLTDD2 AND SinhVienId = sv.SinhVienId);

INSERT INTO SinhVienLopHocPhans (LopHocPhanId, SinhVienId, TrangThai)
SELECT @LhpCNPM1, sv.SinhVienId, 1
FROM SinhViens sv JOIN NguoiDungs nd ON sv.NguoiDungId = nd.NguoiDungId
WHERE nd.TenDangNhap IN ('sv001','sv002','sv003','sv004','sv005')
  AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE LopHocPhanId = @LhpCNPM1 AND SinhVienId = sv.SinhVienId);

INSERT INTO SinhVienLopHocPhans (LopHocPhanId, SinhVienId, TrangThai)
SELECT @LhpCNPM2, sv.SinhVienId, 1
FROM SinhViens sv JOIN NguoiDungs nd ON sv.NguoiDungId = nd.NguoiDungId
WHERE nd.TenDangNhap IN ('sv011','sv012','sv013','sv014','sv015')
  AND NOT EXISTS (SELECT 1 FROM SinhVienLopHocPhans WHERE LopHocPhanId = @LhpCNPM2 AND SinhVienId = sv.SinhVienId);

---

-- 11. ĐỢT ĐĂNG KÝ ĐỒ ÁN (6 ĐỢT MỞ)
IF @LhpLTDD1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpLTDD1)
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpLTDD1, N'Đợt đăng ký đồ án Lập trình di động N01', DATEADD(day, -7, GETDATE()), DATEADD(day, 30, GETDATE()), 3, 5, N'Đang mở');

IF @LhpLTDD2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpLTDD2)
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpLTDD2, N'Đợt đăng ký đồ án Lập trình di động N02', DATEADD(day, -7, GETDATE()), DATEADD(day, 30, GETDATE()), 3, 5, N'Đang mở');

IF @LhpCNPM1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCNPM1)
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpCNPM1, N'Đợt đăng ký đồ án Công nghệ phần mềm N01', DATEADD(day, -7, GETDATE()), DATEADD(day, 30, GETDATE()), 3, 5, N'Đang mở');

IF @LhpCNPM2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCNPM2)
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpCNPM2, N'Đợt đăng ký đồ án Công nghệ phần mềm N02', DATEADD(day, -7, GETDATE()), DATEADD(day, 30, GETDATE()), 3, 5, N'Đang mở');

IF @LhpCSDL1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCSDL1)
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpCSDL1, N'Đợt đăng ký đồ án Cơ sở dữ liệu', DATEADD(day, -7, GETDATE()), DATEADD(day, 30, GETDATE()), 2, 4, N'Đang mở');

IF @LhpAI1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpAI1)
    INSERT INTO DotDangKyDoAns (LopHocPhanId, TenDot, NgayBatDau, NgayKetThuc, MinMembers, MaxMembers, TrangThai)
    VALUES (@LhpAI1, N'Đợt đăng ký đồ án Trí tuệ nhân tạo', DATEADD(day, -7, GETDATE()), DATEADD(day, 30, GETDATE()), 2, 4, N'Đang mở');

DECLARE @Dot1 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpLTDD1);
DECLARE @Dot2 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpLTDD2);
DECLARE @Dot3 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCNPM1);
DECLARE @Dot4 INT = (SELECT TOP 1 DotDangKyId FROM DotDangKyDoAns WHERE LopHocPhanId = @LhpCNPM2);

---

-- 12. ĐỀ TÀI ĐỒ ÁN (12 ĐỀ TÀI PHONG PHÚ)
IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng quản lý đăng ký nhóm đồ án')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot1, N'Ứng dụng quản lý đăng ký nhóm đồ án', N'Hệ thống quản lý nhóm và phân công đề tài trực tuyến cho sinh viên.', N'Tối ưu hóa quy trình đăng ký đồ án môn học.', N'Mobile App và Backend API.', N'Flutter, ASP.NET Core, SQL Server', N'Giảng viên', @GV1, N'Đã đăng ký', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống quản lý công việc nhóm')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot1, N'Hệ thống quản lý công việc nhóm', N'Quản lý công việc dạng Kanban, phân công nhiệm vụ và đánh giá tiến độ thành viên.', N'Nâng cao hiệu suất làm việc nhóm.', N'Mobile App & Web Admin.', N'Flutter, ASP.NET Core, SQL Server', N'Giảng viên', @GV1, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng gợi ý đề tài bằng AI')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot1, N'Ứng dụng gợi ý đề tài bằng AI', N'Trợ lý ảo phân tích năng lực và sở thích của sinh viên để đề xuất đề tài phù hợp.', N'Hỗ trợ sinh viên định hướng nghiên cứu.', N'Mobile App.', N'Flutter, Gemini API, Python FastAPI', N'Giảng viên', @GV1, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng thương mại điện tử đa nền tảng')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot2, N'Ứng dụng thương mại điện tử đa nền tảng', N'Nền tảng mua sắm trực tuyến hỗ trợ giỏ hàng, thanh toán qua cổng điện tử và tracking giao hàng.', N'Xây dựng sàn TMĐT hoàn chỉnh.', N'Mobile App và Web Quản trị.', N'Flutter, ASP.NET Core, SQL Server', N'Giảng viên', @GV2, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng quản lý chi tiêu cá nhân thông minh')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot2, N'Ứng dụng quản lý chi tiêu cá nhân thông minh', N'Theo dõi ngân sách, ghi chép thu chi hằng ngày và lập biểu đồ phân tích tài chính.', N'Hỗ trợ quản lý dòng tiền cá nhân hiệu quả.', N'Mobile App.', N'Flutter, SQLite, Syncfusion Charts', N'Giảng viên', @GV2, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng học từ vựng tiếng Anh theo Spaced Repetition')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot1, N'Ứng dụng học từ vựng tiếng Anh theo Spaced Repetition', N'Ứng dụng ghi nhớ từ vựng với thuật toán lặp lại ngắt quãng khoa học.', N'Tối ưu hóa khả năng ghi nhớ ngoại ngữ lâu dài.', N'Mobile App.', N'Flutter, Firebase, RESTful API', N'Giảng viên', @GV1, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống quản lý thư viện số trường đại học')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot3, N'Hệ thống quản lý thư viện số trường đại học', N'Mượn trả giáo trình trực tuyến, đọc tài liệu PDF có bản quyền và nhắc hạn trả sách.', N'Hiện đại hóa thư viện đại học.', N'Web & Mobile App.', N'React, ASP.NET Core, SQL Server', N'Giảng viên', @GV1, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Nền tảng kết nối thực tập và tuyển dụng sinh viên IT')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot4, N'Nền tảng kết nối thực tập và tuyển dụng sinh viên IT', N'Kết nối nhà tuyển dụng công nghệ với sinh viên CNTT tìm kiếm cơ hội thực tập.', N'Cầu nối việc làm sinh viên.', N'Web & Mobile App.', N'Flutter, Node.js, PostgreSQL', N'Giảng viên', @GV2, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng quản lý nhà trọ và hợp đồng cho thuê')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot2, N'Ứng dụng quản lý nhà trọ và hợp đồng cho thuê', N'Quản lý danh sách phòng, chỉ số điện nước, xuất hóa đơn và gửi thông báo tự động.', N'Minh bạch hóa quản lý nhà trọ.', N'Mobile App.', N'Flutter, Firebase Cloud Firestore', N'Giảng viên', @GV2, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống đặt lịch khám bệnh trực tuyến cho phòng khám')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot1, N'Hệ thống đặt lịch khám bệnh trực tuyến cho phòng khám', N'Đặt lịch hẹn theo chuyên khoa và bác sĩ, nhắc lịch tự động và lưu hồ sơ bệnh án.', N'Giảm tải xếp hàng tại cơ sở y tế.', N'Mobile & Web.', N'Flutter, ASP.NET Core, Redis', N'Giảng viên', @GV1, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Hệ thống điểm danh sinh viên bằng nhận diện khuôn mặt')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot4, N'Hệ thống điểm danh sinh viên bằng nhận diện khuôn mặt', N'Ứng dụng AI điểm danh tự động sinh viên qua camera lớp học, đối chiếu danh sách lớp.', N'Điểm danh tự động chính xác cao.', N'Mobile & AI Service.', N'Flutter, Python FastAPI, OpenCV', N'Giảng viên', @GV3, N'Chưa sử dụng', N'Đã duyệt');

IF NOT EXISTS (SELECT 1 FROM DeTaiDoAns WHERE TenDeTai = N'Chatbot AI tư vấn quy chế và lộ trình học tập')
    INSERT INTO DeTaiDoAns (DotDangKyId, TenDeTai, MoTa, MucTieu, PhamVi, CongNgheDuKien, NguonDeTai, GiangVienId, TrangThai, TrangThaiDuyet)
    VALUES (@Dot1, N'Chatbot AI tư vấn quy chế và lộ trình học tập', N'Trợ lý ảo giải đáp thắc mắc về tín chỉ, học phần tiên quyết và định hướng chuẩn đầu ra.', N'Hỗ trợ sinh viên 24/7.', N'Mobile App.', N'Flutter, Gemini API, Vector DB', N'Giảng viên', @GV3, N'Chưa sử dụng', N'Đã duyệt');

---

-- 13. NHÓM ĐỒ ÁN VÀ THÀNH VIÊN NHÓM
-- Nhóm 1: Nhóm Demo 01 (Lớp LTDD-01)
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Demo 01')
BEGIN
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, SoLuongToiDa, TrangThai)
    VALUES (@Dot1, N'Nhóm Demo 01', @SV1, 5, N'Đang hoạt động');
    DECLARE @NhomId1 INT = SCOPE_IDENTITY();
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId1, @SV1, N'Trưởng nhóm', N'Đã tham gia');
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId1, @SV2, N'Thành viên', N'Đã tham gia');
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId1, @SV3, N'Thành viên', N'Đã tham gia');
END;

-- Nhóm 2: Nhóm Mobile Pro (Lớp LTDD-02)
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Mobile Pro')
BEGIN
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, SoLuongToiDa, TrangThai)
    VALUES (@Dot2, N'Nhóm Mobile Pro', @SV6, 5, N'Đang hoạt động');
    DECLARE @NhomId2 INT = SCOPE_IDENTITY();
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId2, @SV6, N'Trưởng nhóm', N'Đã tham gia');
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId2, @SV7, N'Thành viên', N'Đã tham gia');
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId2, @SV8, N'Thành viên', N'Đã tham gia');
END;

-- Nhóm 3: Nhóm Agile Dev (Lớp CNPM-02)
IF NOT EXISTS (SELECT 1 FROM NhomDoAns WHERE TenNhom = N'Nhóm Agile Dev')
BEGIN
    INSERT INTO NhomDoAns (DotDangKyId, TenNhom, TruongNhomId, SoLuongToiDa, TrangThai)
    VALUES (@Dot4, N'Nhóm Agile Dev', @SV11, 5, N'Đang hoạt động');
    DECLARE @NhomId3 INT = SCOPE_IDENTITY();
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId3, @SV11, N'Trưởng nhóm', N'Đã tham gia');
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId3, @SV12, N'Thành viên', N'Đã tham gia');
    INSERT INTO ThanhVienNhoms (NhomId, SinhVienId, VaiTro, TrangThai) VALUES (@NhomId3, @SV13, N'Thành viên', N'Đã tham gia');
END;

---

-- 14. ĐĂNG KÝ ĐỀ TÀI CỦA NHÓM
DECLARE @N1 INT = (SELECT TOP 1 NhomId FROM NhomDoAns WHERE TenNhom = N'Nhóm Demo 01');
DECLARE @DT1 INT = (SELECT TOP 1 DeTaiId FROM DeTaiDoAns WHERE TenDeTai = N'Ứng dụng quản lý đăng ký nhóm đồ án');
IF @N1 IS NOT NULL AND @DT1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DangKyDeTais WHERE NhomId = @N1)
BEGIN
    INSERT INTO DangKyDeTais (NhomId, DeTaiId, NgayDangKy, TrangThai, NgayDuyet, GiangVienDuyetId, GhiChu)
    VALUES (@N1, @DT1, DATEADD(day, -3, GETDATE()), N'Đã duyệt', DATEADD(day, -2, GETDATE()), @GV1, N'Đề tài phù hợp với năng lực nhóm.');
END;

---

-- 15. THÔNG BÁO HỆ THỐNG VÀ HỌC VỤ (21 THÔNG BÁO)
DELETE FROM ThongBaos;

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT u.NguoiDungId,
       N'Mở đợt đăng ký đồ án môn học HK1 (2026 - 2027)',
       N'Đợt đăng ký đồ án môn học đã chính thức mở. Sinh viên vui lòng hoàn tất việc lập nhóm và đăng ký đề tài trước hạn quy định.',
       N'Hệ thống',
       0,
       DATEADD(day, -2, GETDATE())
FROM NguoiDungs u
WHERE u.TenDangNhap LIKE 'sv%';

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT u.NguoiDungId,
       N'Thông báo phân công hướng dẫn đồ án môn học',
       N'Khoa đã hoàn tất phân công giảng viên phụ trách các lớp học phần học kỳ mới. Quý Thầy/Cô vui lòng kiểm tra danh sách lớp phân công.',
       N'Học vụ',
       0,
       DATEADD(day, -3, GETDATE())
FROM NguoiDungs u
WHERE u.TenDangNhap LIKE 'gv%';

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT u.NguoiDungId,
       N'Có đơn đăng ký đề tài mới cần duyệt',
       N'Nhóm sinh viên đã gửi yêu cầu đăng ký đề tài đồ án môn học. Giảng viên vui lòng kiểm tra và duyệt trên hệ thống.',
       N'Đề tài',
       0,
       DATEADD(hour, -5, GETDATE())
FROM NguoiDungs u
WHERE u.TenDangNhap = 'gv001';

-- Bổ sung thông báo cho các vai trò còn lại
INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Đề xuất đề tài mới từ sinh viên', N'Sinh viên vừa gửi đề xuất đề tài mới cần Giáo vụ khoa kiểm duyệt danh mục.', N'Hệ thống', 0, GETDATE()
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('gvk.demo','giaovu01')
  AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Đề xuất đề tài mới từ sinh viên');

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Báo cáo tiến độ đăng ký đồ án toàn trường', N'Đã có 85% sinh viên hoàn thành ghép nhóm và đăng ký đề tài trong đợt 1.', N'Thống kê', 0, GETDATE()
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('pdt.demo','daotao01')
  AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Báo cáo tiến độ đăng ký đồ án toàn trường');

INSERT INTO ThongBaos (NguoiDungId, TieuDe, NoiDung, LoaiThongBao, DaDoc, CreatedAt)
SELECT nd.NguoiDungId, N'Hệ thống sao lưu định kỳ', N'Cơ sở dữ liệu ProjectRegistrationDB đã được sao lưu toàn vẹn thành công lúc 02:00.', N'Hệ thống', 1, GETDATE()
FROM NguoiDungs nd WHERE nd.TenDangNhap IN ('admin.demo','admin01')
  AND NOT EXISTS (SELECT 1 FROM ThongBaos WHERE NguoiDungId = nd.NguoiDungId AND TieuDe = N'Hệ thống sao lưu định kỳ');

-- Bổ sung Lịch sử Import & Lỗi import (Giáo vụ khoa & Phòng đào tạo)
DECLARE @UserGVK_Seed INT = (SELECT TOP 1 NguoiDungId FROM NguoiDungs WHERE TenDangNhap IN ('gvk.demo','giaovu01'));
DECLARE @UserPDT_Seed INT = (SELECT TOP 1 NguoiDungId FROM NguoiDungs WHERE TenDangNhap IN ('pdt.demo','daotao01'));

IF NOT EXISTS (SELECT 1 FROM DotImports WHERE TenFile = N'Danh_sach_sinh_vien_K21_CNTT.xlsx')
    INSERT INTO DotImports (LoaiDuLieu, TenFile, NguoiImportId, TongSoDong, SoDongThanhCong, SoDongLoi, TrangThai, CreatedAt)
    VALUES (N'SINHVIEN', N'Danh_sach_sinh_vien_K21_CNTT.xlsx', @UserGVK_Seed, 120, 120, 0, N'Hoàn thành', '2026-09-01 08:30:00');

IF NOT EXISTS (SELECT 1 FROM DotImports WHERE TenFile = N'Danh_sach_giang_vien_hoc_ky_1_2026.xlsx')
    INSERT INTO DotImports (LoaiDuLieu, TenFile, NguoiImportId, TongSoDong, SoDongThanhCong, SoDongLoi, TrangThai, CreatedAt)
    VALUES (N'GIANGVIEN', N'Danh_sach_giang_vien_hoc_ky_1_2026.xlsx', @UserPDT_Seed, 45, 45, 0, N'Hoàn thành', '2026-09-02 09:15:00');

DECLARE @DotImportLoi_Seed INT;
IF NOT EXISTS (SELECT 1 FROM DotImports WHERE TenFile = N'Phan_cong_lop_hoc_phan_dot_1.xlsx')
BEGIN
    INSERT INTO DotImports (LoaiDuLieu, TenFile, NguoiImportId, TongSoDong, SoDongThanhCong, SoDongLoi, TrangThai, CreatedAt)
    VALUES (N'LOPHOCPHAN', N'Phan_cong_lop_hoc_phan_dot_1.xlsx', @UserGVK_Seed, 50, 48, 2, N'Hoàn thành có lỗi', '2026-09-05 14:20:00');
    SET @DotImportLoi_Seed = SCOPE_IDENTITY();
END
ELSE
    SET @DotImportLoi_Seed = (SELECT DotImportId FROM DotImports WHERE TenFile = N'Phan_cong_lop_hoc_phan_dot_1.xlsx');

IF NOT EXISTS (SELECT 1 FROM LoiImports WHERE DotImportId = @DotImportLoi_Seed)
BEGIN
    INSERT INTO LoiImports (DotImportId, SoDong, TenCot, NoiDungLoi, CreatedAt)
    VALUES 
    (@DotImportLoi_Seed, 15, N'MaGiangVien', N'Mã giảng viên "GV999" không tồn tại trong hệ thống.', '2026-09-05 14:20:01'),
    (@DotImportLoi_Seed, 28, N'MaLopHocPhan', N'Lớp học phần "LTDD-99" bị trùng lặp mã.', '2026-09-05 14:20:02');
END

-- Bổ sung Lịch sử AI Requests & PasswordResetOtps
DECLARE @UserSV1_Seed INT = (SELECT TOP 1 NguoiDungId FROM NguoiDungs WHERE TenDangNhap IN ('sv001','SV001'));
DECLARE @UserGV1_Seed INT = (SELECT TOP 1 NguoiDungId FROM NguoiDungs WHERE TenDangNhap IN ('gv001','GV001'));

IF NOT EXISTS (SELECT 1 FROM AIRequests WHERE ChucNangAI = N'Gợi ý đề tài')
    INSERT INTO AIRequests (NguoiDungId, ChucNangAI, Prompt, Response, TrangThai, CreatedAt)
    VALUES (@UserSV1_Seed, N'Gợi ý đề tài', 
            N'Tôi muốn làm đề tài về ứng dụng di động Flutter có ứng dụng AI nhận diện giọng nói.', 
            N'Gợi ý đề tài: 1. Ứng dụng ghi chú thông minh chuyển đổi giọng nói thành văn bản. 2. Trợ lý học ngoại ngữ phát âm chuẩn.', 
            N'Thành công', GETDATE());

IF NOT EXISTS (SELECT 1 FROM AIRequests WHERE ChucNangAI = N'Đánh giá mục tiêu đề tài')
    INSERT INTO AIRequests (NguoiDungId, ChucNangAI, Prompt, Response, TrangThai, CreatedAt)
    VALUES (@UserGV1_Seed, N'Đánh giá mục tiêu đề tài', 
            N'Đánh giá tính khả thi đề tài: Hệ thống nhận diện biển số xe tự động bằng YOLOv8 trong 15 tuần.', 
            N'Đề tài có tính ứng dụng cao, khối lượng công việc phù hợp với nhóm 3 sinh viên chuyên ngành KHMT/CNTT.', 
            N'Thành công', GETDATE());

IF NOT EXISTS (SELECT 1 FROM PasswordResetOtps WHERE NguoiDungId = @UserSV1_Seed)
    INSERT INTO PasswordResetOtps (NguoiDungId, OtpCodeHash, ExpiredAt, SoLanThu, IsUsed, CreatedAt)
    VALUES (@UserSV1_Seed, N'123456', DATEADD(MINUTE, 15, GETDATE()), 0, 0, GETDATE());

COMMIT TRANSACTION;
GO

---

-- 16. KIỂM TRA DỮ LIỆU SAU KHI INSERT
SELECT NguoiDungId, TenDangNhap, HoTen, Email, VaiTroId, TrangThai FROM NguoiDungs ORDER BY NguoiDungId;
SELECT SinhVienId, MSSV, KhoaId FROM SinhViens ORDER BY SinhVienId;
SELECT GiangVienId, MaGiangVien, HocVi, ChuyenMon FROM GiangViens ORDER BY GiangVienId;
SELECT LopHocPhanId, MaLopHocPhan, TenLopHocPhan FROM LopHocPhans ORDER BY LopHocPhanId;
SELECT DotDangKyId, TenDot, TrangThai, MinMembers, MaxMembers FROM DotDangKyDoAns ORDER BY DotDangKyId;
SELECT DeTaiId, TenDeTai, NguonDeTai, TrangThai, TrangThaiDuyet FROM DeTaiDoAns ORDER BY DeTaiId;
SELECT NhomId, TenNhom, TruongNhomId, TrangThai FROM NhomDoAns ORDER BY NhomId;
SELECT ThongBaoId, NguoiDungId, TieuDe, LoaiThongBao, DaDoc FROM ThongBaos ORDER BY ThongBaoId;
GO

select * from NguoiDungs
select * from SinhViens
select * from LopHocPhans
select * from DotDangKyDoAns
select * from NhomDoAns
select * from DeTaiDoAns
