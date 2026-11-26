# 12. BIÊN BẢN NGHIỆM THU VÀ QUY CHUẨN MÃ HÓA CHO ĐỘI NGŨ PHÁT TRIỂN
*(Final Acceptance Protocol & Developer Encoding Guidelines)*

---

## 1. BIÊN BẢN NGHIỆM THU KỸ THUẬT (ACCEPTANCE PROTOCOL)

| Hạng mục kiểm tra | Tiêu chuẩn nghiệm thu | Kết quả thực tế | Kết luận |
|---|---|---|:---:|
| **Dữ liệu màn hình Khoa** | Tên lớp học phần hiển thị "Phát triển ứng dụng Web - Nhóm 01", "An toàn thông tin - Nhóm 01" | Hiển thị chính xác, đầy đủ dấu thanh | **NGHIỆM THU** |
| **Dữ liệu Giảng viên** | Học vị "Tiến sĩ", Chuyên môn "Điện toán đám mây & Fullstack Web" | Hiển thị chính xác | **NGHIỆM THU** |
| **Dữ liệu Sinh viên** | 82 sinh viên nữ hiển thị giới tính "Nữ", lọc giới tính chính xác | Hiển thị chính xác, bộ lọc hoạt động 100% | **NGHIỆM THU** |
| **Tính toàn vẹn CSDL** | 0 bản ghi chứa Mojibake trên 31 bảng | Script quét nhị phân xác nhận 0 bản ghi lỗi | **NGHIỆM THU** |
| **JSON API Serialization** | Xuất trực tiếp raw UTF-8 cho ký tự tiếng Việt có dấu | Đã cấu hình `JavaScriptEncoder.Create(UnicodeRanges.All)` | **NGHIỆM THU** |
| **Biên dịch & Ứng dụng** | 0 lỗi build backend, frontend phân tích sạch | `dotnet build` 0 errors, `flutter analyze` 0 errors | **NGHIỆM THU** |

---

## 2. QUY CHUẨN MÃ HÓA DÀNH CHO ĐỘI NGŨ PHÁT TRIỂN PROGROUP_AI

Nhằm duy trì chất lượng hiển thị Unicode bền vững cho dự án ProGroup_AI, toàn bộ thành viên đội ngũ phát triển phải tuân thủ các quy tắc bắt buộc sau:

### 2.1. Quy chuẩn Cơ sở dữ liệu (Database Rules)
1. **Kiểu dữ liệu:** Luôn sử dụng `NVARCHAR(n)` hoặc `NVARCHAR(MAX)` cho tất cả các trường lưu trữ văn bản có dấu (Tên, Họ tên, Mô tả, Địa chỉ, Nội dung, v.v.). Tuyệt đối không dùng `VARCHAR`.
2. **Cú pháp SQL:** Mọi hằng số chuỗi Unicode phải luôn có tiền tố `N` viết hoa phía trước (ví dụ: `SET @Ten = N'Nguyễn Văn A'`).
3. **Mã hóa tệp Script:** Mọi tập tin `.sql` phải được lưu dưới định dạng **UTF-8 with BOM** hoặc **UTF-8**.

### 2.2. Quy chuẩn Backend ASP.NET Core (Backend Rules)
1. **Tuần tự hóa JSON:** Luôn sử dụng `JavaScriptEncoder.Create(UnicodeRanges.All)` trong cấu hình `AddJsonOptions`.
2. **Xử lý File Upload:** Khi đọc luồng văn bản từ request hoặc tệp tải lên, luôn chỉ định rõ ràng `Encoding.UTF8` (ví dụ: `new StreamReader(stream, Encoding.UTF8)`).
3. **Header phản hồi:** Đảm bảo mọi phản hồi JSON đều mang header `Content-Type: application/json; charset=utf-8`.

### 2.3. Quy chuẩn Frontend Flutter (Frontend Rules)
1. **Mã hóa tệp mã nguồn:** 100% tệp tin `.dart` phải được lưu dưới dạng UTF-8.
2. **Giải mã mạng:** Luôn sử dụng `utf8.decode(response.bodyBytes)` khi phân tích cú pháp dữ liệu từ máy chủ. Không bao giờ sử dụng trực tiếp `response.body`.
3. **Xuất tệp CSV:** Luôn chèn ký tự UTF-8 BOM `\uFEFF` ở đầu chuỗi dữ liệu trước khi lưu trữ hoặc chia sẻ tệp CSV để đảm bảo Microsoft Excel hiển thị đúng tiếng Việt.

---

### Xác nhận hoàn thành:
Chiến dịch **GLOBAL UTF-8 ENCODING AUDIT & MOJIBAKE REMEDIATION** của dự án ProGroup_AI đã được thực hiện toàn diện, chuyên nghiệp, thành công 100% và sẵn sàng cho việc triển khai sản xuất.
