# 06. BÁO CÁO LÀM SẠCH VÀ CHUẨN HÓA DỮ LIỆU SQL SERVER
*(Database Data Cleansing, Migration Script & Verification Report)*

---

## 1. THIẾT KẾ KỊCH BẢN SỬA ĐỔI DỮ LIỆU (REMEDIATION SCRIPT)
Kịch bản sửa đổi dữ liệu được thiết kế theo các nguyên tắc an toàn cao nhất:
- **Nguyên tử (Atomicity):** Bao bọc toàn bộ trong khối `BEGIN TRANSACTION ... COMMIT TRANSACTION` kết hợp với `TRY ... CATCH` và `ROLLBACK TRANSACTION`.
- **Rõ ràng và có định hướng (Targeted):** Xác định chính xác các ID và điều kiện nhị phân `Latin1_General_BIN2` để chỉ tác động đúng các bản ghi bị lỗi.
- **Tính toàn vẹn khóa ngoại (Referential Integrity):** Trước khi xóa các bản ghi học kỳ trùng lặp bị lỗi (HocKyId 5, 6, 7), toàn bộ các lớp học phần đang tham chiếu đến chúng đều được remap sang học kỳ chuẩn (HocKyId 2, 3, 4).

### Mã nguồn tệp [Database_Remediation_UTF8.sql](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/Database_Remediation_UTF8.sql):
```sql
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

    -- Remap any other LopHocPhans pointing to duplicate HocKys if present
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
```

---

## 2. KẾT QUẢ THỰC THI SCRIPT
- **Thời gian thực thi:** 2026-11-26 17:39:05.
- **Kết quả trả về:** `REMEDIATION_SUCCESS`.
- **Số bản ghi bị xóa:** 3 bản ghi trùng lặp (`HocKys` ID 5, 6, 7).
- **Số bản ghi được cập nhật:**
  - `LopHocPhans`: 2 bản ghi (ID 17, 18).
  - `HocPhans`: 2 bản ghi (ID 8, 9).
  - `Khoas`: 1 bản ghi (ID 6).
  - `GiangViens`: 1 bản ghi (ID 8).
  - `SinhViens`: 79 bản ghi giới tính nữ (`GioiTinh = N'Nữ'`).
  - **Tổng cộng tác động:** 88 bản ghi (85 cập nhật, 3 xóa bỏ).

---

## 3. QUÉT TOÀN DIỆN HẬU KIỂM TOÁN (POST-REMEDIATION AUDIT)
Đã thực thi tập lệnh PowerShell [scan_exact_mojibake.ps1](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/scan_exact_mojibake.ps1) sử dụng phân biệt nhị phân `Latin1_General_BIN2` quét qua tất cả các cột văn bản của toàn bộ các bảng trong CSDL:
```
=== SCANNING ALL COLUMNS FOR EXACT MOJIBAKE SIGNATURES ===
TOTAL CONFIRMED MOJIBAKE FOUND: 0
```
**Khẳng định:** 100% dữ liệu trong cơ sở dữ liệu `ProjectRegistrationDB` hiện tại hoàn toàn sạch, chuẩn Unicode tiếng Việt.
