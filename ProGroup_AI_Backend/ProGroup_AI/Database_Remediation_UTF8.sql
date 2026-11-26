-- ============================================================================
-- PROGROUP_AI GLOBAL UTF-8 ENCODING REMEDIATION & MOJIBAKE CLEANUP SCRIPT
-- Database: ProjectRegistrationDB
-- Engine: Microsoft SQL Server
-- Description: Corrects all double-encoded UTF-8 strings (Mojibake) in database
-- ============================================================================

USE [ProjectRegistrationDB];
GO

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Correct LopHocPhans (Update text and remap HocKyId from duplicate corrupted ID 5 to canonical ID 2)
    UPDATE [dbo].[LopHocPhans]
    SET [TenLopHocPhan] = N'Phát triển ứng dụng Web - Nhóm 01',
        [HocKyId] = 2
    WHERE [LopHocPhanId] = 17;

    UPDATE [dbo].[LopHocPhans]
    SET [TenLopHocPhan] = N'An toàn thông tin - Nhóm 01',
        [HocKyId] = 2
    WHERE [LopHocPhanId] = 18;

    -- Update any other LopHocPhans pointing to duplicate HocKys if present
    UPDATE [dbo].[LopHocPhans] SET [HocKyId] = 2 WHERE [HocKyId] = 5;
    UPDATE [dbo].[LopHocPhans] SET [HocKyId] = 3 WHERE [HocKyId] = 6;
    UPDATE [dbo].[LopHocPhans] SET [HocKyId] = 4 WHERE [HocKyId] = 7;

    -- 2. Remove duplicate corrupted HocKys (5, 6, 7 are duplicates of 2, 3, 4 created with broken encoding)
    DELETE FROM [dbo].[HocKys]
    WHERE [HocKyId] IN (5, 6, 7);

    -- 3. Correct HocPhans
    UPDATE [dbo].[HocPhans]
    SET [TenHocPhan] = N'Phát triển ứng dụng Web',
        [MoTa] = N'Phát triển Web Fullstack với .NET Core & React'
    WHERE [HocPhanId] = 8;

    UPDATE [dbo].[HocPhans]
    SET [TenHocPhan] = N'An toàn thông tin ứng dụng',
        [MoTa] = N'Bảo mật ứng dụng, mã hóa và an ninh mạng'
    WHERE [HocPhanId] = 9;

    -- 4. Correct Khoas
    UPDATE [dbo].[Khoas]
    SET [TenKhoa] = N'Khoa An toàn Thông tin'
    WHERE [KhoaId] = 6;

    -- 5. Correct GiangViens
    UPDATE [dbo].[GiangViens]
    SET [HocVi] = N'Tiến sĩ',
        [ChuyenMon] = N'Điện toán đám mây & Fullstack Web'
    WHERE [GiangVienId] = 8;

    -- 6. Correct SinhViens (Female gender Mojibake: 'Ná»¯' -> 'Nữ')
    UPDATE [dbo].[SinhViens]
    SET [GioiTinh] = N'Nữ'
    WHERE [GioiTinh] COLLATE Latin1_General_BIN2 = NCHAR(78) + NCHAR(225) + NCHAR(187) + NCHAR(175)
       OR [GioiTinh] LIKE N'%Ná»¯%'
       OR [GioiTinh] LIKE N'%Ã%';

    COMMIT TRANSACTION;
    PRINT N'REMEDIATION COMPLETED SUCCESSFULLY.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'ERROR ENCOUNTERED. TRANSACTION ROLLED BACK.';
    THROW;
END CATCH;
GO
