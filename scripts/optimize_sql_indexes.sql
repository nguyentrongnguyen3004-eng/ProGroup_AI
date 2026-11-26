-- Evidence-based covering indexes for ProGroup_AI hot queries
-- Prevents table/index scans and reduces Sort/Hash memory grants on SQL Server Express

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ThongBaos_User_LoaiLienKet_CreatedAt' AND object_id = OBJECT_ID('dbo.ThongBaos'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ThongBaos_User_LoaiLienKet_CreatedAt
    ON dbo.ThongBaos (NguoiDungId, LoaiLienKet, CreatedAt DESC)
    INCLUDE (DaDoc, LienKetId, TieuDe, LoaiThongBao);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ThanhVienNhoms_SinhVienId_TrangThai' AND object_id = OBJECT_ID('dbo.ThanhVienNhoms'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ThanhVienNhoms_SinhVienId_TrangThai
    ON dbo.ThanhVienNhoms (SinhVienId, TrangThai)
    INCLUDE (NhomId, VaiTro);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ThanhVienNhoms_NhomId_TrangThai' AND object_id = OBJECT_ID('dbo.ThanhVienNhoms'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ThanhVienNhoms_NhomId_TrangThai
    ON dbo.ThanhVienNhoms (NhomId, TrangThai)
    INCLUDE (SinhVienId, VaiTro);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DangKyDeTais_TrangThai' AND object_id = OBJECT_ID('dbo.DangKyDeTais'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DangKyDeTais_TrangThai
    ON dbo.DangKyDeTais (TrangThai)
    INCLUDE (NhomId, DeTaiId, NgayDangKy, NgayDuyet);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DeTaiDoAns_CreatedAt' AND object_id = OBJECT_ID('dbo.DeTaiDoAns'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DeTaiDoAns_CreatedAt
    ON dbo.DeTaiDoAns (CreatedAt DESC)
    INCLUDE (DotDangKyId, TrangThai, TrangThaiDuyet, GiangVienId, SinhVienDeXuatId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DotDangKyDoAns_LopHocPhanId_TrangThai' AND object_id = OBJECT_ID('dbo.DotDangKyDoAns'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DotDangKyDoAns_LopHocPhanId_TrangThai
    ON dbo.DotDangKyDoAns (LopHocPhanId, TrangThai)
    INCLUDE (NgayBatDau, NgayKetThuc, TenDot, MinMembers, MaxMembers, CreatedAt);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SinhVienLopHocPhans_SinhVienId_TrangThai' AND object_id = OBJECT_ID('dbo.SinhVienLopHocPhans'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SinhVienLopHocPhans_SinhVienId_TrangThai
    ON dbo.SinhVienLopHocPhans (SinhVienId, TrangThai)
    INCLUDE (LopHocPhanId, NgayThamGia);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PhanCongGiangViens_GiangVienId_TrangThai' AND object_id = OBJECT_ID('dbo.PhanCongGiangViens'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_PhanCongGiangViens_GiangVienId_TrangThai
    ON dbo.PhanCongGiangViens (GiangVienId, TrangThai)
    INCLUDE (LopHocPhanId, NgayPhanCong);
END
GO
