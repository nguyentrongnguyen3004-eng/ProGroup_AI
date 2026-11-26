# 03. BÁO CÁO KIỂM TOÁN AN NINH (SECURITY AUDIT)
## BẢO MẬT XÁC THỰC, PHÂN QUYỀN RBAC, QUẢN LÝ TÀI NGUYÊN & PHÒNG CHỐNG TẤN CÔNG

---

### 1. BẢO MẬT XÁC THỰC (AUTHENTICATION & JWT)
- **Cơ chế Token:** Hệ thống sử dụng JWT (JSON Web Token) với thuật toán ký `HMAC-SHA256` (`HmacSha256Signature`).
- **Thời hạn sống của Token:** Cấu hình chuẩn 7 ngày, chứa đầy đủ Claims:
  - `ClaimTypes.NameIdentifier`: ID người dùng (`NguoiDungId`).
  - `ClaimTypes.Name`: Tên đăng nhập (`TenDangNhap`).
  - `ClaimTypes.Role`: Mã vai trò chuẩn (`ADMIN`, `SINHVIEN`, `GIANGVIEN`, `GIAOVUKHOA`, `PHONGDAOTAO`).
- **Lưu trữ mật khẩu:** Mật khẩu trong cơ sở dữ liệu `ProjectRegistrationDB` được băm bằng thuật toán `BCrypt` với Salt tự động sinh, ngăn chặn hoàn toàn nguy cơ rò rỉ mật khẩu qua bảng Rainbow Tables.
- **Xác thực OTP:** Khôi phục mật khẩu sử dụng mã OTP ngẫu nhiên 6 chữ số có thời hạn hiệu lực 5 phút, lưu trữ mã hóa trong database kèm thời gian hết hạn (`OtpExpiresAt`).

---

### 2. KIỂM SOÁT TRUY CẬP DỰA TRÊN VAI TRÒ (RBAC MATRIX)

| API Controller / Endpoint | Sinh viên | Trưởng nhóm | Giảng viên | Giáo vụ khoa | Phòng đào tạo | Quản trị viên |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `POST /api/auth/login` | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép |
| `GET /api/profile` | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép |
| `PUT /api/profile` | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép |
| `POST /api/profile/upload-avatar` | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép | Cho phép |
| `POST /api/nhom/tao-nhom` | Cho phép | Cho phép | Chặn (403) | Chặn (403) | Chặn (403) | Chặn (403) |
| `POST /api/de-tai/dang-ky` | Chặn (403) | Cho phép | Chặn (403) | Chặn (403) | Chặn (403) | Chặn (403) |
| `POST /api/de-tai/duyet` | Chặn (403) | Chặn (403) | Cho phép | Chặn (403) | Chặn (403) | Cho phép |
| `POST /api/bao-cao-tien-do/cham-diem`| Chặn (403) | Chặn (403) | Cho phép | Chặn (403) | Chặn (403) | Cho phép |
| `GET /api/admin/overview` | Chặn (403) | Chặn (403) | Chặn (403) | Chặn (403) | Chặn (403) | Cho phép |
| `GET /api/giaovukhoa/thong-ke` | Chặn (403) | Chặn (403) | Chặn (403) | Cho phép | Chặn (403) | Cho phép |
| `GET /api/phongdaotao/thong-ke` | Chặn (403) | Chặn (403) | Chặn (403) | Chặn (403) | Cho phép | Cho phép |

*Thực nghiệm an ninh:* Script kiểm thử `scripts/integration_api_tests.py` đã gửi request với JWT của Sinh viên (`sv001`) đến endpoint quản trị `/api/admin/overview`. Kết quả máy chủ trả về chính xác **HTTP 403 Forbidden**, chứng minh cơ chế RBAC hoạt động hoàn hảo.

---

### 3. KIỂM SOÁT AN NINH FILE UPLOAD (AVATAR & ĐÍNH KÈM)
- **Giới hạn kích thước (Payload Size Limit):**
  - Trước đây: Kiểm tra dựa trên số ký tự chuỗi base64 có thể bị bypass nếu header base64 sai lệch.
  - Đã khắc phục: Giải mã byte nhị phân thực tế và áp dụng kiểm tra nghiêm ngặt `bytes.Length > 10 * 1024 * 1024` (10MB).
  - *Thực nghiệm an ninh:* Đã gửi file dung lượng giả lập 15MB base64 (~11.25MB nhị phân), API trả về **HTTP 400 Bad Request** với thông báo lỗi: *"Ảnh đại diện không được vượt quá 10MB."*
- **Kiểm soát định dạng (MIME & Extension Whitelist):**
  - Chỉ chấp nhận các định dạng ảnh hợp lệ: `.jpg`, `.jpeg`, `.png`, `.webp`.
  - Từ chối các file thực thi `.exe`, `.dll`, `.sh`, `.php`, `.jsp` hay script mã độc.
- **Lưu trữ đám mây an toàn:**
  - File được đẩy lên Cloudflare R2 qua API nội bộ, không lưu file trực tiếp trong thư mục web root của máy chủ (ngăn ngừa triệt để lỗi Remote Code Execution - RCE).

---

### 4. BẢO VỆ CHỐNG IDOR & TRUY CẬP TRÁI PHÉP ĐỐI TƯỢNG (OBJECT-LEVEL AUTHORIZATION)
- **Phê duyệt đề tài & Chấm điểm báo cáo:**
  - Controller luôn kiểm tra `GiangVienId` của người dùng hiện tại có đúng là người hướng dẫn của Đề tài hoặc Đồ án đó hay không.
  - Ngăn chặn giảng viên A chấm điểm hoặc duyệt báo cáo của nhóm do giảng viên B hướng dẫn.
- **Thao tác Nhóm đồ án:**
  - Thao tác xóa nhóm, mời thành viên, đăng ký đề tài chỉ được thực thi khi `TruongNhomId == currentStudentId`.
