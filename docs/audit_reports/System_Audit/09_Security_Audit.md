# 09. BÁO CÁO ĐÁNH GIÁ AN TOÀN THÔNG TIN & BẢO MẬT (SECURITY AUDIT)

## 1. TỔNG QUAN
Báo cáo an toàn thông tin được thực hiện dựa trên các tiêu chuẩn kiểm thử thâm nhập của **OWASP Top 10** và chuẩn an toàn thông tin cho ứng dụng di động/web API. Chúng tôi đã phát hiện **nhiều lỗ hổng bảo mật ở mức độ THẢM HỌA (CRITICAL / HIGH)** có thể dẫn đến việc chiếm quyền điều khiển toàn bộ hệ thống hoặc rò rỉ dữ liệu nhạy cảm của người dùng.

---

## 2. DANH SÁCH LỖ HỔNG BẢO MẬT NGHIÊM TRỌNG

### 2.1. Lộ Toàn Bộ Khóa Bí Mật & Thông Tin Xác Thực Đám Mây Trong Mã Nguồn Git (SECRETS LEAK)
- **Mức độ:** 🚨 **CRITICAL (Rủi ro tức thì)**
- **Chi tiết các bí mật bị lộ:**
  1. **Tài khoản Google App Password (Gửi mail OTP):**
     - File: `ProGroup_AI.API/appsettings.json`, dòng 28:
       ```json
       "EmailSettings": {
         "SenderEmail": "trongnguyen10072004@gmail.com",
         "Password": "fdwv lpjz pakd cifz",
         "SmtpServer": "smtp.gmail.com",
         "Port": 587
       }
       ```
     - Rủi ro: Bất kỳ ai clone mã nguồn đều có quyền truy cập hòm thư Gmail của quản trị viên và gửi email nặc danh dưới tên trường học.
  2. **Cloudflare R2 Storage Credentials (Lưu trữ file):**
     - File: `ProGroup_AI.API/appsettings.json`, dòng 34-36:
       ```json
       "CloudflareR2": {
         "AccountId": "b2c9df7643f07a726ea89255018617f6",
         "AccessKeyId": "0e8ee95a94043936a7ea4b7890ecb352",
         "SecretAccessKey": "7fbc6c1e13baefabcf050beba14ff44eeedccdeeaeb49cb37a4c11488c032bb9",
         "BucketName": "progroupai",
         "PublicUrl": "https://pub-273a0df454fe47a0af059d6e4df9d2bb.r2.dev"
       }
       ```
     - Rủi ro: Kẻ tấn công có thể xóa toàn bộ bucket, đánh cắp toàn bộ tài liệu báo cáo đồ án, avatar hoặc tải mã độc lên bucket.
  3. **Google Firebase Admin Private Key (Push Notifications):**
     - File: `ProGroup_AI.API/Properties/firebase-admin-sdk.json`:
       Chứa đầy đủ Private Key dạng RSA PEM (`-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC6...`).
     - Rủi ro: Toàn quyền truy cập dự án Firebase của nhà trường, có thể gửi thông báo độc hại đến hàng nghìn sinh viên.
  4. **JWT Signing Secret Key:**
     - File: `ProGroup_AI.API/appsettings.json`, dòng 7:
       `"Key": "ProGroupAI_Development_Key_2026_Change_This_To_A_Strong_Key"`.
     - Rủi ro: Giả mạo token Admin để truy cập toàn bộ API.

---

### 2.2. Backdoor Bypass OTP Đổi Email Bằng Mã Hardcode `123456`
- **Mức độ:** 🚨 **CRITICAL**
- **Vị trí:** `lib/widgets/common/change_email_dialog.dart`, dòng 126:
  ```dart
  if (otp != '123456') {
    _showError('Mã OTP không chính xác!');
    return;
  }
  ```
- **Khai thác:** Không cần nhận OTP từ email, bất kỳ ai cũng có thể đổi email người dùng thành công bằng cách nhập `123456`.

---

### 2.3. Thiếu Rate Limiting Trên Các API Nhạy Cảm (Brute-Force Vulnerability)
- **Mức độ:** ⚠️ **HIGH**
- **Vị trí:** `AuthController.cs` (`/api/Auth/login`, `/api/Auth/forgot-password/send-otp`, `/api/Auth/forgot-password/verify-otp`).
- **Rủi ro:** Kẻ tấn công có thể dùng công cụ tự động gửi hàng triệu request mỗi phút để dò mật khẩu tài khoản hoặc gửi spam làm cạn kiệt hạn ngạch email SMTP của hệ thống.

---

### 2.4. Phơi Bày Thông Tin Lỗi Nội Bộ (Internal Stack Trace Disclosure)
- **Mức độ:** ⚠️ **MEDIUM**
- Một số endpoint bắt lỗi `try-catch` và trả về trực tiếp `StatusCode(500, ex.Message)` hoặc `ex.ToString()`, để lộ tên bảng, cấu trúc cột CSDL và đường dẫn thư mục mã nguồn cho kẻ tấn công.
