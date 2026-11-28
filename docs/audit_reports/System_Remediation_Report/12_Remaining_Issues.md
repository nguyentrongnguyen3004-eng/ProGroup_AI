# BÁO CÁO CÁC VẤN ĐỀ TỒN ĐỌNG VÀ KHUYẾN NGHỊ (REMAINING ISSUES & RECOMMENDATIONS)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Liệt kê các điểm cần lưu ý, tối ưu hóa bổ sung trước khi triển khai vận hành chính thức trên hạ tầng Cloud / Production.  

---

## 1. CÁC ĐIỂM CẦN LƯU Ý KHI TRIỂN KHAI (DEPLOYMENT PREREQUISITES)

### 1.1. Cấu hình Biến môi trường (Environment Variables)
Sau khi loại bỏ hardcoded secrets trong file cấu hình, khi deploy Backend lên server thực tế (IIS, Docker, Azure App Service hoặc Linux VM), quản trị viên bắt buộc phải cấu hình các biến môi trường sau:
- `JWT_KEY`: Khóa bí mật ký JWT Token (tối thiểu 32 ký tự ngẫu nhiên).
- `SMTP_PASSWORD`: Mật khẩu ứng dụng Gmail hoặc API Key dịch vụ gửi mail (SendGrid, Mailgun, Amazon SES).
- `SMTP_SERVER`: Server SMTP (Mặc định: `smtp.gmail.com`).
- `SMTP_PORT`: Cổng SMTP (Mặc định: `587`).
- `SMTP_SENDER_EMAIL`: Địa chỉ email gửi thông báo hệ thống.
- `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET_NAME`, `R2_PUBLIC_URL`: Thông tin tài khoản Cloudflare R2 nếu sử dụng lưu trữ đám mây.

---

## 2. KHUYẾN NGHỊ TỐI ƯU HÓA TRONG GIAI ĐOẠN TIẾP THEO

### 2.1. Nâng cấp Thư viện Phụ thuộc (Dependency Upgrades)
- **NuGet Package:** Cập nhật package `System.Security.Cryptography.Pkcs` lên phiên bản >= 9.0.12 hoặc mới nhất để giải quyết triệt để cảnh báo bảo mật NU1902 và NU1903.
- **Firebase Admin SDK:** Trong `FirebaseNotificationService.cs`, cập nhật từ phương thức cũ `GoogleCredential.FromFile()` sang `CredentialFactory` theo khuyến nghị của Google SDK để loại bỏ cảnh báo CS0618.

### 2.2. Hoàn thiện Bộ Test Tự động CI/CD (Test Automation)
- Bổ sung `MockClient` cho các Widget Tests trong Flutter để có thể chạy kiểm thử giao diện hoàn toàn offline trong quy trình GitHub Actions / GitLab CI mà không bị chặn bởi `TestWidgetsFlutterBinding`.

### 2.3. Cải tiến Gợi ý Đề tài bằng AI (AI Recommendation Service)
- Mở rộng tích hợp trực tiếp với Google Gemini Pro API / Vertex AI thông qua Gemini API SDK để tự động phân tích CV, bảng điểm và sở thích nghiên cứu của sinh viên nhằm đưa ra điểm tương thích đề tài (Match Score) chính xác hơn.
