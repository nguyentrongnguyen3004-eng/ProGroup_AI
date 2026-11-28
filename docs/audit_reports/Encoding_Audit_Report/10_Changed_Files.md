# 10. DANH MỤC TOÀN BỘ CÁC TẬP TIN ĐÃ ĐƯỢC CHỈNH SỬA
*(Changelog & Impacted Files Register)*

---

## 1. TẬP TIN CƠ SỞ DỮ LIỆU & SCRIPT HỆ THỐNG

### 1.1. [Database_Remediation_UTF8.sql](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/Database_Remediation_UTF8.sql)
- **Hành động:** Tạo mới.
- **Mục đích:** Script SQL sửa đổi chuẩn hóa dữ liệu bị Mojibake trong cơ sở dữ liệu `ProjectRegistrationDB`. Bao gồm transaction rollback, sửa text cho các bảng `LopHocPhans`, `HocPhans`, `Khoas`, `GiangViens`, `SinhViens`, và dọn dẹp các bản ghi trùng lặp trong bảng `HocKys`.

### 1.2. [execute_remediation.ps1](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/execute_remediation.ps1)
- **Hành động:** Tạo mới.
- **Mục đích:** Script PowerShell hỗ trợ kết nối trực tiếp đến SQL Server Local Instance để thực thi kịch bản sửa đổi dữ liệu một cách an toàn và tự động.

### 1.3. [scan_exact_mojibake.ps1](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/scan_exact_mojibake.ps1)
- **Hành động:** Tạo mới.
- **Mục đích:** Công cụ kiểm toán tự động quét 100% cột văn bản của tất cả các bảng trong CSDL với phân loại nhị phân `Latin1_General_BIN2` để phát hiện dấu vết Mojibake kép.

---

## 2. TẬP TIN TẦNG BACKEND (ASP.NET CORE WEB API)

### 2.1. [Program.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Program.cs)
- **Hành động:** Cập nhật.
- **Chi tiết thay đổi:**
  - Bổ sung `using System.Text.Encodings.Web;` và `using System.Text.Unicode;`.
  - Cấu hình `AddControllers()` với `JavaScriptEncoder.Create(UnicodeRanges.All)` để xuất trực tiếp Raw UTF-8 thay vì escape `\uXXXX`.

---

## 3. TẬP TIN TÀI LIỆU BÁO CÁO (ENCODING AUDIT REPORT)
Thư mục: [Encoding_Audit_Report/](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/)
- [01_Encoding_Audit_Summary.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/01_Encoding_Audit_Summary.md)
- [02_Mojibake_Findings.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/02_Mojibake_Findings.md)
- [03_Root_Cause_Analysis.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/03_Root_Cause_Analysis.md)
- [04_Frontend_Fix_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/04_Frontend_Fix_Report.md)
- [05_Backend_Fix_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/05_Backend_Fix_Report.md)
- [06_Database_Data_Correction.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/06_Database_Data_Correction.md)
- [07_Import_Export_Encoding_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/07_Import_Export_Encoding_Report.md)
- [08_Unicode_Test_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/08_Unicode_Test_Report.md)
- [09_Regression_Test_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/09_Regression_Test_Report.md)
- [10_Changed_Files.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/10_Changed_Files.md)
- [11_Remaining_Encoding_Issues.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/11_Remaining_Encoding_Issues.md)
- [12_Final_Encoding_Verification.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/12_Final_Encoding_Verification.md)
