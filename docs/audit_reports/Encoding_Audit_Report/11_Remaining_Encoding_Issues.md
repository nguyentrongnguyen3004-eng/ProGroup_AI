# 11. CÁC VẤN ĐỀ TỒN ĐỌNG VÀ BIỆN PHÁP BẢO VỆ DÀI HẠN
*(Remaining Issues & Long-term Defense Mechanisms)*

---

## 1. TÌNH TRẠNG VẤN ĐỀ HIỆN TẠI
- **Lỗi Mojibake trên CSDL:** 0 lỗi (Đã khắc phục 100%).
- **Lỗi mã hóa tại Backend API:** 0 lỗi (Đã chuẩn hóa JSON UTF-8 serialization).
- **Lỗi giải mã tại Frontend:** 0 lỗi (Đã xác minh pipeline `utf8.decode(response.bodyBytes)`).
- **Lỗi xuất nhập file CSV/Excel:** 0 lỗi (Đã tích hợp UTF-8 BOM `\uFEFF` và OpenXML parser).

---

## 2. NGUY CƠ TIỀM ẨN VÀ BIỆN PHÁP BẢO VỆ DÀI HẠN

### 2.1. Nguy cơ từ các file Seed Script hoặc Migration thủ công
- **Rủi ro:** Khi lập trình viên chạy script SQL chèn dữ liệu bằng PowerShell hoặc Command Prompt trên Windows mà không đổi code page sang UTF-8 (`chcp 65001`), lỗi Mojibake sẽ tái xuất hiện.
- **Biện pháp phòng ngừa:**
  1. Trong tất cả các file script `.sql`, luôn thêm tiền tố `N` trước mọi hằng số chuỗi (ví dụ: `N'Phát triển ứng dụng Web'`).
  2. Lưu trữ toàn bộ các file `.sql` ở định dạng **UTF-8 with BOM** (hoặc UTF-8).
  3. Khuyến nghị chạy script qua SQL Server Management Studio (SSMS) hoặc Azure Data Studio thay vì chạy qua cmd pipe thô.

### 2.2. Nguy cơ từ người dùng tải lên tệp CSV lưu định dạng ANSI
- **Rủi ro:** Người dùng mở file mẫu trên Excel, chỉnh sửa rồi chọn lưu dạng "CSV (Comma delimited) (*.csv)" thông thường (Windows-1258 hoặc CP1252) thay vì "CSV UTF-8 (Comma delimited) (*.csv)".
- **Biện pháp phòng ngừa:**
  1. Ưu tiên hướng dẫn người dùng sử dụng định dạng `.xlsx` (Excel chuẩn) thay cho `.csv`, vì `.xlsx` luôn bảo toàn Unicode UTF-8.
  2. Tại tầng xử lý file của Backend/Frontend, duy trì khối xử lý lỗi `try-catch` chuyển đổi dự phòng (fallback) để phát hiện và cảnh báo người dùng khi tệp tin chứa ký tự không thể giải mã theo UTF-8.

### 2.3. Quy định chuẩn hóa chuỗi Unicode (Unicode Normalization)
- Tích hợp middleware hoặc Action Filter tự động chuẩn hóa chuỗi văn bản nhận được sang dạng chuẩn **NFC** (`input.Normalize(NormalizationForm.FormC)`) trước khi lưu trữ vào CSDL để tránh hiện tượng cùng một từ tiếng Việt nhưng có hai mã nhị phân khác nhau (do tổ hợp dấu).
