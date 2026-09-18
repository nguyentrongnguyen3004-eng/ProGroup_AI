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