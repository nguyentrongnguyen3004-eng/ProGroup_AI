# 04. BÁO CÁO XÁC MINH BẢO MẬT CHUYÊN SÂU (SECURITY DEEP-DIVE VERIFICATION)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Kiểm toán toàn diện tất cả các khía cạnh an ninh thông tin, mật mã học, phân quyền và kiểm soát dữ liệu.  

---

## 1. KIỂM TOÁN CƠ CHẾ OTP (ONE-TIME PASSWORD)

### 1.1. Thuật toán sinh số ngẫu nhiên (OTP Generation)
- **Hiện trạng mã nguồn:**
  ```csharp
  // AuthController.cs (Dòng 127 & 246)
  var otpCode = Random.Shared.Next(100000, 999999).ToString();
  ```
- **Đánh giá:** `Random.Shared` là một Pseudo-Random Number Generator (PRNG) thông thường dựa trên thuật toán xoshiro256**. Nó KHÔNG PHẢI là Cryptographically Secure PRNG (CSPRNG). Kẻ tấn công có thể đoán được chuỗi số tiếp theo nếu biết seed hoặc các giá trị trước đó.
- **Khuyến nghị nâng cấp:** Sử dụng `System.Security.Cryptography.RandomNumberGenerator.GetInt32(100000, 1000000).ToString()`.

### 1.2. Lưu trữ OTP trong Cơ sở dữ liệu (OTP Storage)
- **Hiện trạng mã nguồn:** Mã OTP mới sinh được băm qua BCrypt:
  ```csharp
  var otpHash = BCrypt.Net.BCrypt.HashPassword(otpCode);
  otpRecord.OtpCodeHash = otpHash;
  ```
- **Hiện trạng dữ liệu thực tế:** Truy vấn bảng `PasswordResetOtps` phát hiện:
  - Bản ghi mới: Lưu chuỗi hash BCrypt độ dài 60 ký tự.
  - Bản ghi cũ (Id 1 và 2): Lưu plaintext `123456` và `654321`. Khi hàm `BCrypt.Verify(request.Otp, validOtp.OtpCodeHash)` thực thi trên bản ghi cũ sẽ ném ngoại lệ `SaltParseException: Invalid salt version`.
- **Khuyến nghị:** Chạy câu lệnh SQL xóa các bản ghi cũ `DELETE FROM PasswordResetOtps WHERE LEN(OtpCodeHash) < 20`.

### 1.3. Thời hạn hiệu lực và Sử dụng một lần (Expiration & Single-Use)
- **Hạn dùng:** 5 phút (`DateTime.Now.AddMinutes(5)`).
- **Vô hiệu hóa:** Đánh dấu `IsUsed = true` sau khi xác thực thành công hoặc khi người dùng yêu cầu mã mới (`old.IsUsed = true`).
- **Đánh giá:** **ĐẠT (PASS)**.

### 1.4. Chống vét cạn (Brute-force Protection)
- **Cơ chế:** Kiểm tra `SoLanThu >= 5` -> Hủy mã (`IsUsed = true`) và khóa thử lại.
- **Đánh giá:** **ĐẠT (PASS)**.

### 1.5. Giới hạn tần suất gọi (Rate Limiting)
- **Hiện trạng:** Chưa có Middleware IP Rate Limiting trên các endpoint `/api/auth/forgot-password/send-otp` và `/api/auth/change-email/send-otp`.
- **Rủi ro:** Kẻ tấn công có thể spam liên tục gây cạn kiệt hạn ngạch gửi mail của tài khoản Gmail SMTP hoặc làm nghẽn dịch vụ.
- **Khuyến nghị:** Bổ sung `AspNetCoreRateLimit` hoặc IP/User sliding window rate limit (tối đa 3 request OTP / 5 phút / IP).

---

## 2. KIỂM TOÁN QUẢN LÝ KHÓA BÍ MẬT (SECRET MANAGEMENT & GIT HISTORY)

- **Trạng thái Working Tree:**
  - `appsettings.json`: Đã xóa mật khẩu Gmail (`"Password": ""`).
  - `Program.cs`: Đọc `JWT_KEY` từ biến môi trường.
  - `CloudflareR2Service.cs`: Đọc R2 keys từ biến môi trường.
- **Trạng thái Git Commit History:**
  - Kiểm tra lệnh `git log -S "<Gmail App Password>" --oneline`:
    Phát hiện chuỗi mật khẩu Gmail VẪN TỒN TẠI trong commit `fde6239` và `7a354ba`.
- **Mức độ rủi ro:** **CRITICAL**. Nếu repository được đưa lên GitHub, các bot quét tự động sẽ thu thập được mật khẩu này trong vòng vài giây.
- **Hành động bắt buộc:** Chạy BFG Repo-Cleaner hoặc `git filter-repo --invert-paths` để xóa triệt để lịch sử commit chứa secret.

---

## 3. KIỂM TOÁN PHÂN QUYỀN VAI TRÒ (RBAC & IDOR)

- **Kiểm tra thực tế:**
  - Sinh viên mang token role `SINHVIEN` gọi API Quản trị `GET /api/admin/overview`:
    Hệ thống trả về chính xác **HTTP 403 Forbidden**.
  - Kiểm tra phân quyền `[Authorize(Roles = "ADMIN,PHONGDAOTAO,GIAOVUKHOA")]` trên `POST /api/admin/users/import`:
    Cán bộ đào tạo (`daotao01`) gọi thành công trả về **HTTP 200 OK**.
- **Đánh giá:** **ĐẠT (PASS)**.

---

## 4. KIỂM TOÁN TẢI LÊN TẬP TIN & DUNG LƯỢNG (FILE UPLOAD SECURITY)

- **Kiểm tra thực tế:** Gửi payload avatar base64 dung lượng 15MB (> 10MB limit):
  Backend `ProfileController` giải mã kích thước byte thực tế và chặn ngay lập tức với **HTTP 400 Bad Request**.
- **Kiểm tra Magic Bytes:** Chặn các định dạng file thực thi (.exe, .sh), chỉ cho phép whitelist ảnh.
- **Đánh giá:** **ĐẠT (PASS)**.

---

## 5. KIỂM TOÁN SQL INJECTION & NHẤT QUÁN CSDL

- Hệ thống sử dụng 100% Entity Framework Core LINQ to Entities với câu lệnh được tham số hóa (Parameterized SQL).
- Không có bất kỳ câu lệnh nối chuỗi trực tiếp (`FromSqlRaw("SELECT ... " + input)`) nào trong toàn bộ dự án Backend.
- **Đánh giá:** **ĐẠT (PASS)**.
