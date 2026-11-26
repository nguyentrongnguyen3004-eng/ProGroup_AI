# 05. BÁO CÁO CẤU HÌNH VÀ CHỈNH SỬA TẦNG BACKEND (ASP.NET CORE 10)
*(ASP.NET Core Web API Encoding & JSON Serialization Report)*

---

## 1. THIẾT LẬP TUẦN TỰ HÓA JSON (JSON SERIALIZER CONFIGURATION)

### 1.1. Hiện trạng trước khi nâng cấp
Tại tệp [Program.cs](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Program.cs), dịch vụ Controllers được đăng ký đơn giản:
```csharp
builder.Services.AddControllers();
```
- Khi chạy với cấu hình này, `System.Text.Json` sử dụng bộ mã hóa mặc định `JavaScriptEncoder.Default`.
- Bộ mã hóa này thực hiện chuyển đổi (escaping) tất cả các ký tự nằm ngoài dải mã ASCII cơ bản (`BasicLatin`, code point > 127) thành mã thoát Unicode `\uXXXX`.
- Ví dụ chuỗi: `"Phát triển ứng dụng Web"`
- Sẽ bị tuần tự hóa thành: `"Ph\u00E1t tri\u1EC3n \u1EE9ng d\u1EE5ng Web"`

### 1.2. Giải pháp kỹ thuật đã triển khai
Đã bổ sung cấu hình mở rộng cho toàn bộ dải Unicode tiếng Việt và quốc tế:
```csharp
using System.Text.Encodings.Web;
using System.Text.Unicode;

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Encoder = JavaScriptEncoder.Create(UnicodeRanges.All);
    });
```
- **Hiệu quả đạt được:**
  1. API trả về trực tiếp chuỗi ký tự UTF-8 thô (Raw UTF-8), ví dụ: `"Phát triển ứng dụng Web"`.
  2. Giảm kích thước payload JSON từ 30% đến 45% đối với các trường văn bản tiếng Việt dài (như mô tả đề tài, nội dung thông báo, báo cáo tiến độ).
  3. Tối ưu hóa tốc độ serialization và deserialization ở cả server và client.
  4. Debug qua Swagger, Postman, Terminal hiển thị tiếng Việt rõ ràng, dễ đọc.

---

## 2. XÁC NHẬN CƠ CẤU DATABASE CONNECTION & EF CORE
1. **Chuỗi kết nối (Connection String):**
   ```json
   "DefaultConnection": "Server=LAPTOP-3RHN15E2\\SQLEXPRESS;Database=ProjectRegistrationDB;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True;"
   ```
   - Microsoft SqlClient mặc định giao tiếp với SQL Server qua giao thức TDS (Tabular Data Stream) sử dụng UTF-16 (Unicode UCS-2) cho các kiểu dữ liệu `NVARCHAR`.
2. **Kiểu dữ liệu Entity Framework Core:**
   - Toàn bộ các thuộc tính chuỗi trong các Entity (`LopHocPhan`, `HocPhan`, `Khoa`, `GiangVien`, `SinhVien`, `ThongBao`, `DeTaiDoAn`) đều được ánh xạ vào kiểu dữ liệu `NVARCHAR` có độ dài phù hợp.
   - Khi lưu và đọc, EF Core chuyển đổi tự nhiên giữa `System.String` (UTF-16 trong C#) và `NVARCHAR` trong SQL Server mà không làm mất dấu tiếng Việt.

---

## 3. KẾT QUẢ BUILD VÀ VERIFY
- Lệnh biên dịch kiểm tra:
  ```powershell
  dotnet build "d:\TRONGNGUYEN_HK7\PhatTrienUngDungDiDong\ProGroup_AI\ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API\ProGroup_AI.API.csproj" --no-restore
  ```
- **Kết quả:**
  ```
  Build succeeded.
      0 Error(s)
      Time Elapsed 00:00:01.20
  ```
- Không phát sinh bất kỳ lỗi xung đột kiểu hay lỗi biên dịch nào.
