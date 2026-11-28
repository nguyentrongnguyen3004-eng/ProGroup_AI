# 03. PHÂN TÍCH NGUYÊN NHÂN GỐC CỦA TỪNG LOẠI LỖI
*(Root Cause Analysis across Systems Architecture)*

---

## 1. NGUYÊN NHÂN GỐC TẠI TẦNG CƠ SỞ DỮ LIỆU (DATABASE LAYER)

### 1.1. Hiện tượng "Double Encoding" / "ANSI to UTF-8 Mismatch"
Khi điều tra nguồn gốc của 89 bản ghi bị hỏng, chúng tôi nhận thấy các đặc điểm sau:
- Ký tự `á` (Unicode code point `U+00E1`) trong UTF-8 được biểu diễn dưới dạng 2 byte: `0xC3 0xA1`.
- Khi một tiến trình hoặc script seed dữ liệu được thực thi trong môi trường Windows Console (cmd.exe hoặc PowerShell cũ) đang sử dụng Code Page mặc định của Windows (`CP1252` hoặc `CP1258`) mà **chưa thiết lập UTF-8 code page `chcp 65001`**:
  - Byte `0xC3` được diễn giải trong Windows-1252 thành ký tự `Ã` (`U+00C3`).
  - Byte `0xA1` được diễn giải thành ký tự `¡` (`U+00A1`).
  - Kết quả là chuỗi UTF-8 nhị phân hợp lệ `[0xC3, 0xA1]` bị chuyển đổi thành chuỗi 2 ký tự: `"Ã¡"`.
- Khi chuỗi này được chèn vào SQL Server vào cột kiểu `NVARCHAR`, SQL Server lưu giữ chính xác chuỗi Unicode 2 ký tự `"Ã¡"` thay vì ký tự `"á"`.
- Tương tự với ký tự `ữ` (`U+1EEF`):
  - UTF-8 biểu diễn bằng 3 byte: `0xE1 0xBB 0xAF`.
  - Dưới Code Page Windows, 3 byte này bị diễn giải thành: `á` (`0xE1`), `»` (`0xBB`), `¯` (`0xAF`).
  - Kết quả là `"Nữ"` bị lưu thành `"Ná»¯"`.

### 1.2. Cơ chế Idempotent của Seed Script
Trong script khởi tạo dữ liệu mẫu ban đầu:
- Các lệnh chèn dữ liệu sử dụng mệnh đề:
  ```sql
  IF NOT EXISTS (SELECT 1 FROM LopHocPhans WHERE MaLopHocPhan = 'WDEV-01')
      INSERT INTO LopHocPhans (...) VALUES (...);
  ```
- Vì bản ghi `WDEV-01` đã tồn tại từ lần chạy seed script đầu tiên (bị lỗi code page), các lần chạy cập nhật script tiếp theo (dù đã lưu file ở dạng UTF-8) **không bao giờ thực hiện ghi đè** lên bản ghi cũ.
- Điều này giải thích tại sao chỉ có 89 bản ghi cụ thể (thuộc các học phần WDEV, ATTT, giảng viên GV006, học kỳ 5-7 và sinh viên nữ) bị giữ nguyên tình trạng Mojibake qua nhiều phiên bản.

---

## 2. NGUYÊN NHÂN TẠI TẦNG BACKEND (ASP.NET CORE WEB API)

### 2.1. Cấu hình JSON Serializer mặc định
Trong tệp [Program.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Program.cs):
- API ban đầu chỉ gọi:
  ```csharp
  builder.Services.AddControllers();
  ```
- Thư viện `System.Text.Json` của .NET mặc định sử dụng `JavaScriptEncoder.Default`, giới hạn trong dải ký tự `UnicodeRanges.BasicLatin`.
- Khi tuần tự hóa các ký tự tiếng Việt (như `à, á, ả, ã, ạ, đ, ê, ơ, ư...`), `System.Text.Json` mặc định chuyển đổi chúng thành các chuỗi thoát ký tự dạng `\uXXXX` (ví dụ `\u0110\u1ea1i h\u1ecdc`).
- Mặc dù Flutter client có thể hiểu các chuỗi `\uXXXX`, việc này làm tăng dung lượng payload JSON từ 30% đến 50%, giảm tốc độ phân tích cú pháp và gây khó khăn khi debug qua các công cụ như Postman hoặc curl nếu terminal không hỗ trợ Unicode.

### 2.2. Trách nhiệm tầng Backend đối với dữ liệu CSDL
- Backend sử dụng Entity Framework Core 10 truy vấn dữ liệu từ SQL Server và đóng vai trò trung chuyển trung thực (pass-through).
- Khi SQL Server trả về chuỗi `NVARCHAR` có nội dung `"PhĂ¡t triá»ƒn á»©ng dá»¥ng Web - NhĂ³m 01"`, EF Core giữ nguyên giá trị này và serialize sang JSON.
- Do đó, Backend không tự tạo ra Mojibake, nhưng thiếu cơ chế kiểm tra dữ liệu đầu vào (Input Validation Sanitization) để ngăn chặn việc chèn các chuỗi double-encoded vào cơ sở dữ liệu.

---

## 3. NGUYÊN NHÂN TẠI TẦNG FRONTEND (FLUTTER)

### 3.1. Xác nhận vai trò của Flutter Client
Tại tầng Frontend Flutter:
- Kiểm tra toàn diện phương thức `_send()` trong [api_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/api_service.dart):
  ```dart
  final response = await request.send();
  final responseBody = await response.stream.bytesToString(utf8);
  // hoặc:
  final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
  ```
  -> Frontend đã giải mã luồng byte phản hồi theo UTF-8 một cách hoàn toàn chính xác.
- Khi nhận được chuỗi `"PhĂ¡t triá»ƒn á»©ng dá»¥ng Web - NhĂ³m 01"`, Flutter hiển thị chính xác các ký tự mà API gửi đến.
- Do đó, Frontend không có lỗi logic giải mã mạng. Lỗi hiển thị hoàn toàn là hệ quả của dữ liệu sai lệch xuất phát từ cơ sở dữ liệu.

---

## 4. KẾT LUẬN VỀ KIẾN TRÚC
| Tầng | Có phải nguyên nhân gốc không? | Vai trò trong sự cố | Hành động khắc phục triệt để |
|---|:---:|---|---|
| **Database (SQL Server)** | **CÓ (ROOT CAUSE)** | Nơi lưu giữ các chuỗi bị double-encoded từ quá trình seed dữ liệu cũ | Chạy script cập nhật dữ liệu, xóa bản ghi duplicate |
| **Backend (.NET 10 API)** | Khuyến nghị nâng cấp | Serializer mặc định escape ký tự non-ASCII | Cấu hình `JavaScriptEncoder.Create(UnicodeRanges.All)` |
| **Frontend (Flutter)** | Không | Nạn nhân hiển thị dữ liệu sai từ backend | Giữ nguyên pipeline giải mã UTF-8 chuẩn xác |
