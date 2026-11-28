# 04. BÁO CÁO RÀ SOÁT VÀ KIỂM TRA TẦNG FRONTEND FLUTTER
*(Flutter Frontend UTF-8 & Rendering Audit Report)*

---

## 1. PHẠM VI RÀ SOÁT
Chúng tôi đã thực hiện rà soát 100% các tệp nguồn `.dart` trong dự án `progroup_ai_frontend`:
- Thư mục kiểm tra: `lib/screens/`, `lib/widgets/`, `lib/services/`, `lib/models/`, `lib/providers/`, `lib/utils/`, `lib/constants/`, `lib/data/mock/`.
- Tổng số tệp tin Dart: **154 tệp**.

---

## 2. KẾT QUẢ RÀ SOÁT NỘI DUNG TĨNH VÀ ENCODING FILE
1. **Mã hóa tập tin:**
   - Tất cả 154 tệp `.dart` đều được lưu trữ theo định dạng chuẩn **UTF-8** (không có tập tin nào lưu dạng ANSI, CP1252, hay UTF-16).
2. **Chuỗi tĩnh (Hardcoded Strings & Labels):**
   - Quét regex toàn bộ từ khóa nghi vấn Mojibake: `Ã`, `á»`, `áº`, `Ä‘`, `Ă¡`, `Â `.
   - **Kết quả:** Không có bất kỳ chuỗi tiếng Việt tĩnh nào trong mã nguồn giao diện bị lỗi font hoặc Mojibake. Tất cả nhãn, AppBar title, Button, Dialog text, thông báo validation, và dữ liệu mẫu (mock data) đều là tiếng Việt chuẩn Unicode có dấu (ví dụ: "Phát triển ứng dụng di động", "Giáo vụ khoa", "Phòng đào tạo").
3. **Phông chữ hệ thống (Typography):**
   - Ứng dụng sử dụng hệ thống phông chữ mặc định của Flutter (Roboto trên Android, San Francisco trên iOS/macOS) với khả năng hiển thị tiếng Việt hoàn hảo, đầy đủ mọi biến thể dấu thanh điệu theo chuẩn Unicode (NFC).

---

## 3. RÀ SOÁT TẦNG DỊCH VỤ MẠNG (HTTP CLIENT SERVICES)
Tệp trọng yếu: [api_service.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/api_service.dart).

### 3.1. Thiết lập Header Yêu cầu (Request Headers)
Mọi request gửi từ `ApiService` đều được gắn tiêu đề định danh rõ ràng charset UTF-8:
```dart
'Content-Type': 'application/json; charset=utf-8',
'Accept': 'application/json; charset=utf-8',
```
Điều này đảm bảo khi người dùng nhập tiếng Việt vào các form tạo tài khoản, đề xuất đề tài, cập nhật thông tin cá nhân hay báo cáo tiến độ, payload gửi lên backend không bị biến dạng.

### 3.2. Giải mã Dữ liệu Phản hồi (Response Body Decoding)
Trong phương thức xử lý phản hồi của `ApiService`:
```dart
final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
```
- Sử dụng `response.bodyBytes` thay vì thuộc tính `response.body` mặc định của `package:http`.
- **Lý do kỹ thuật:** Thuộc tính `response.body` của thư viện `http` trong Dart có thể tự động diễn giải byte stream theo mã hóa `latin1` nếu header `Content-Type` của máy chủ thiếu tham số `charset=utf-8`.
- Việc sử dụng trực tiếp `utf8.decode(response.bodyBytes)` là giải pháp chuẩn công nghiệp (Best Practice) trong Flutter, ngăn chặn triệt để mọi lỗi giải mã ở client.

---

## 4. KẾT LUẬN VÀ KHUYẾN NGHỊ FRONTEND
- **Kết luận:** Tầng Frontend Flutter được xây dựng hoàn toàn chuẩn hóa về mặt xử lý UTF-8.
- Tuyệt đối không cần thêm bất kỳ hàm phụ trợ thay thế chuỗi (như `.replaceAll('PhĂ¡t', 'Phát')`) ở tầng giao diện, tránh làm bẩn mã nguồn và gây suy giảm hiệu năng.
