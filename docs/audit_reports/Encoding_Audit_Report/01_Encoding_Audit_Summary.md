# 01. BÁO CÁO TỔNG QUAN RÀ SOÁT MÃ HÓA TOÀN DỰ ÁN PROGROUP_AI
*(Global UTF-8 Encoding Audit & Mojibake Remediation Summary)*

---

## 1. MỤC TIÊU VÀ PHẠM VI DỰ ÁN
Dự án **ProGroup_AI** (Hệ thống phân công và quản lý đồ án tốt nghiệp ứng dụng AI) tích hợp đa tầng công nghệ:
- **Frontend:** Flutter (Mobile/Web multiplatform, Dart 3.x).
- **Backend:** ASP.NET Core 10 Web API, Entity Framework Core 10.
- **Database:** Microsoft SQL Server (Instance `LAPTOP-3RHN15E2\SQLEXPRESS`, Database `ProjectRegistrationDB`).
- **File Interop:** Import/Export dữ liệu người dùng, sinh viên, đề tài qua Excel (.xlsx) và CSV.

### Hiện tượng lỗi ghi nhận:
Tại giao diện Quản lý Dữ liệu khoa (và các màn hình liên quan đến học phần, lớp học phần, thông tin sinh viên), chuỗi tiếng Việt có dấu bị biến dạng thành Mojibake (ví dụ: `PhÃ¡t triá»ƒn á»©ng dá»¥ng Web - NhÃ³m 01` thay vì `Phát triển ứng dụng Web - Nhóm 01`, hoặc `Ná»¯` thay vì `Nữ`).

### Mục tiêu chiến dịch rà soát:
1. Rà soát 100% các tầng hệ thống: Cơ sở dữ liệu SQL Server, ASP.NET Core Web API, Flutter Client, các luồng Import/Export.
2. Xác định chính xác nguyên nhân gốc (Root Cause) gây biến dạng ký tự, tuyệt đối không dùng giải pháp vá lỗi tạm bợ (chuỗi hardcode, regex replace ở UI).
3. Làm sạch triệt để toàn bộ các bản ghi bị lỗi trong cơ sở dữ liệu với script chuyển đổi an toàn, có khả năng rollback.
4. Cấu hình chuẩn hóa mã hóa UTF-8 toàn bộ quy trình tuần tự hóa JSON (JSON Serializer), HTTP header (`charset=utf-8`), và xử lý file (UTF-8 BOM `\uFEFF`).
5. Thiết lập bộ tài liệu kiểm toán chi tiết gồm 12 báo cáo kỹ thuật.

---

## 2. TỔNG KẾT KẾT QUẢ ĐẠT ĐƯỢC
| Hạng mục kiểm tra | Trạng thái trước rà soát | Trạng thái sau khắc phục | Đánh giá |
|---|---|---|---|
| **SQL Server Database** | 89 bản ghi bị double-encoded UTF-8 (Mojibake) rải rác ở 6 bảng | 0 bản ghi lỗi, 100% chuỗi tiếng Việt chuẩn UTF-8 Unicode | **ĐẠT (Clean)** |
| **ASP.NET Core Web API** | Dùng cấu hình `System.Text.Json` mặc định (escape ký tự non-ASCII sang `\uXXXX`) | Đã tích hợp `JavaScriptEncoder.Create(UnicodeRanges.All)` xuất raw UTF-8 | **ĐẠT (Standardized)** |
| **Flutter Frontend Core** | Đã cấu hình `utf8.decode(response.bodyBytes)` | Xác nhận toàn bộ source `.dart` là UTF-8, không có Mojibake | **ĐẠT (Validated)** |
| **Excel & CSV Import/Export** | Một số luồng có nguy cơ thiếu BOM UTF-8 khi mở trên Windows Excel | Xác nhận xuất CSV có tiền tố `\uFEFF`, đọc file nhị phân decode UTF-8 chuẩn | **ĐẠT (Compliant)** |
| **Kiểm thử hệ thống** | Lỗi hiển thị tại màn hình Lớp học phần, Học phần, Khoa, Giảng viên, Sinh viên | 100% dữ liệu hiển thị tiếng Việt sắc nét, chuẩn Unicode NFC | **ĐẠT (Passed)** |

---

## 3. CƠ CẤU TÀI LIỆU KIỂM TOÁN (12 BÁO CÁO)
Bộ tài liệu kiểm toán được lưu trữ tại thư mục [Encoding_Audit_Report](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report):
1. [01_Encoding_Audit_Summary.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/01_Encoding_Audit_Summary.md) – Báo cáo tổng quan quá trình rà soát.
2. [02_Mojibake_Findings.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/02_Mojibake_Findings.md) – Danh sách chi tiết tất cả các bản ghi/vị trí phát hiện Mojibake.
3. [03_Root_Cause_Analysis.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/03_Root_Cause_Analysis.md) – Phân tích nguyên nhân gốc từng tầng hệ thống.
4. [04_Frontend_Fix_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/04_Frontend_Fix_Report.md) – Đánh giá và kiểm tra toàn diện Flutter UI & Services.
5. [05_Backend_Fix_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/05_Backend_Fix_Report.md) – Báo cáo cấu hình Web API JSON Serialization & Encoding.
6. [06_Database_Data_Correction.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/06_Database_Data_Correction.md) – Chi tiết script SQL sửa đổi dữ liệu và kết quả xác minh.
7. [07_Import_Export_Encoding_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/07_Import_Export_Encoding_Report.md) – Đánh giá luồng import/export Excel & CSV.
8. [08_Unicode_Test_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/08_Unicode_Test_Report.md) – Bộ dữ liệu kiểm thử tiếng Việt đặc thù (NFC, NFD, dấu ngã, hỏi, nặng, mũ).
9. [09_Regression_Test_Report.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/09_Regression_Test_Report.md) – Kiểm thử hồi quy chức năng nghiệp vụ sau khắc phục.
10. [10_Changed_Files.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/10_Changed_Files.md) – Danh mục toàn bộ các tập tin được cập nhật.
11. [11_Remaining_Encoding_Issues.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/11_Remaining_Encoding_Issues.md) – Ghi nhận các vấn đề tồn đọng và giải pháp bảo vệ dài hạn.
12. [12_Final_Encoding_Verification.md](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/Encoding_Audit_Report/12_Final_Encoding_Verification.md) – Biên bản nghiệm thu và quy chuẩn mã hóa cho đội ngũ phát triển.
