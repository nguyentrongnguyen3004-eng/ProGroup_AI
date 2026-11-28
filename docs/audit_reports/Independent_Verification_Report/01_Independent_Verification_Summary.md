# 01. BÁO CÁO TỔNG QUAN XÁC MINH ĐỘC LẬP (INDEPENDENT VERIFICATION SUMMARY)
**Dự án:** ProGroup_AI – Hệ thống Phân nhóm & Đăng ký Đề tài Tốt nghiệp/Đồ án Học phần tích hợp AI  
**Ngày thực hiện kiểm định:** 26/11/2026  
**Đơn vị thực hiện:** Senior Software Architect, QA Lead, Security Engineer & Independent Verification Team  

---

## 1. BỐI CẢNH VÀ MỤC ĐÍCH KIỂM ĐỊNH ĐỘC LẬP

Trước đó, một đợt khắc phục hệ thống (Full System Remediation) đã diễn ra và xuất bản thư mục `System_Remediation_Report/` chứa các tuyên bố:
- 200/200 Test Case đạt trạng thái PASS.
- Backend ASP.NET Core 10 biên dịch thành công 0 lỗi.
- Frontend Flutter đạt 0 lỗi, 0 cảnh báo.
- 4 luồng nghiệp vụ E2E đã hoàn thành.
- 27 tệp tin mã nguồn đã được chỉnh sửa.
- Hệ thống đạt chứng nhận sẵn sàng phát hành Production (Approved for Production Release).

Tuy nhiên, do quá trình thực hiện trước đó có ghi nhận sự cố gián đoạn HTTP 503 từ Gemini API, đợt **INDEPENDENT VERIFICATION** này được tiến hành với nguyên tắc tối thượng:
> **NGUYÊN TẮC: KHÔNG HỢP THỨC HÓA BÁO CÁO CŨ, KHÔNG TỰ ĐỘNG CÔNG NHẬN PASS, ĐỐI CHẤU TRỰC TIẾP TRÊN MÃ NGUỒN, LIVE DATABASE VÀ TEST EXCEL GỐC.**

---

## 2. KẾT QUẢ ĐỐI SOÁT TRỌNG YẾU (EXECUTIVE FINDINGS)

### 2.1. Đính chính sự thật về 200 Test Case gốc
- **Tập tin kiểm thử gốc:** `PROGROUP_AI_TESTCASES.xlsx` gồm đúng **8 Sheet**.
- **Hiện trạng Sheet 1 (Tổng quan & Dashboard):** Bảng theo dõi tiến độ tại Sheet 1 liệt kê 7 phân hệ với tổng số Test Case ghi là **187** (trong đó Phân hệ Sinh viên ghi 44 TC). Trên thực tế, Sheet 3 (Phân hệ Sinh viên) chứa **57 TC hợp lệ** (13 TC đã được bổ sung thêm sau khi lập bảng tổng hợp Sheet 1). Do đó, tổng số Test Case hợp lệ trên thực tế chính xác là **200 TC**.
- **Trạng thái thực tế trong file Excel gốc:** 100% cột Trạng thái (Col 11) trong file Excel gốc đều mang giá trị `None` (chưa từng được ghi nhận kết quả kiểm thử thực địa trực tiếp vào file Excel).
- **Kết quả xác minh độc lập 200 Test Case:**
  - **183 Test Case (91.5%):** **PASS** (Đã kiểm tra thực tế trên Live API, CSDL SQL Server và Logic mã nguồn).
  - **17 Test Case (8.5%):** **NOT APPLICABLE / BLOCKED** (Gồm 6 TC ở Phân hệ Giáo vụ khoa và 11 TC ở Phân hệ Phòng đào tạo liên quan đến tính năng tương lai: Gemini AI dự báo học vụ và Cây phân cấp Bộ môn chuyên ngành chưa có trong CSDL).
  - Tuyên bố "200/200 PASS" trong báo cáo cũ là **CHƯA CHÍNH XÁC KHÁCH QUAN** vì đã tính gộp cả 17 tính năng backlog ngoài phạm vi.

### 2.2. Đính chính về số lượng tệp tin thay đổi
- Báo cáo cũ tuyên bố chỉ có **27 tệp tin** thay đổi.
- Qua kiểm tra Git Log tại commit `927bf4962cac67315fdc5f1bac8e303862bce38e`, trên thực tế có đến **144 tệp tin** bị thay đổi hoặc tạo mới (9,230 dòng thêm, 1,952 dòng xóa). Ngoài 27 tệp tin nghiệp vụ được báo cáo, còn có các controller (`BaoCaoTienDoController`, `ProfileController`, `StudentController`), các service mới (`ChatStorageService`, `DataCacheService`), các script python và hàng loạt báo cáo markdown.

### 2.3. Hiện trạng Cơ sở dữ liệu Live SQL Server (`ProjectRegistrationDB`)
- Kết nối thành công tới máy chủ `LAPTOP-3RHN15E2\SQLEXPRESS`.
- Tổng số tài khoản `NguoiDungs` thực tế là **264 người dùng** (Báo cáo cũ ghi 284 tài khoản), gồm:
  - Sinh viên: 252 tài khoản.
  - Giảng viên: 6 tài khoản.
  - Quản trị viên: 2 tài khoản (`admin.demo`, `admin01`).
  - Giáo vụ khoa: 2 tài khoản (`giaovu.demo`, `giaovu01`).
  - Phòng đào tạo: 2 tài khoản (`daotao.demo`, `daotao01`).
- Đề tài đồ án (`DeTaiDoAns`): 52 đề tài (39 Chưa sử dụng, 13 Đã đăng ký).
- Nhóm đồ án (`NhomDoAns`): 28 nhóm đang hoạt động.
- Tính toàn vẹn: **0 Orphan records** trong `ThanhVienNhoms` và `DangKyDeTais`. Không có đăng ký đề tài trùng lặp.

### 2.4. Phát hiện Bảo mật quan trọng (Security Audit Findings)
1. **Lộ Secret Key trong lịch sử Git:** Chuỗi mật khẩu Gmail App Password đã được xóa sạch trong commit HEAD `appsettings.json`, nhưng **VẪN CÒN TỒN TẠI TRONG LỊCH SỬ GIT** tại các commit `fde6239` và `7a354ba`. Cần chạy công cụ lọc git filter-repo trước khi push public.
2. **Thuật toán sinh OTP:** Mã OTP đang sử dụng `Random.Shared.Next(100000, 999999)` (Bộ sinh số giả ngẫu nhiên PRNG thông thường), **CHƯA ĐẠT CHUẨN MẬT MÃ (CSPRNG)** như `RandomNumberGenerator`.
3. **Dữ liệu OTP cũ dạng Plaintext:** Kiểm tra bảng `PasswordResetOtps` phát hiện 2 bản ghi cũ lưu OTP dạng plaintext `123456` và `654321` vào cột `OtpCodeHash`. Khi gọi `BCrypt.Verify` sẽ gây lỗi `SaltParseException`. Các OTP mới đã được băm BCrypt chuẩn.
4. **Thiếu Rate Limiting:** Chưa có giới hạn số lần gọi API gửi OTP (`send-otp`), có nguy cơ bị spam flood hòm thư SMTP.

---

## 3. BẢNG TỔNG KẾT ĐỐI SOÁT KIỂM ĐỊNH

| Hạng mục kiểm tra | Tuyên bố Báo cáo Cũ | Kết quả Xác minh Độc lập | Đánh giá sai lệch |
|---|:---:|:---:|:---:|
| **Số lượng Test Case** | 200 TC (Sheet 2-8) | Đúng 200 TC (Sheet 1 thống kê sai 187) | Đã làm rõ nguyên nhân |
| **Tỷ lệ Test Case PASS** | 200/200 (100%) | 183 PASS (91.5%), 17 N/A (8.5%) | Báo cáo cũ chưa chính xác |
| **Số file thay đổi** | 27 files | 144 files (Commit 927bf49) | Báo cáo cũ thiếu 117 files |
| **Số tài khoản DB** | 284 users | 264 users | Sai lệch 20 users |
| **Bảo mật Secret Git** | Đã xóa 100% | Vẫn còn trong Git History | Lỗ hổng bảo mật cần vá |
| **OTP Security** | An toàn tuyệt đối | Dùng PRNG, DB có plaintext cũ | Cần khắc phục |
| **Backend Build** | 0 Errors | **ĐẠT (0 Errors)** | Xác nhận chính xác |
| **Frontend Analyze** | 0 Errors, 0 Warnings | **ĐẠT (0 Errors, 0 Warnings)** | Xác nhận chính xác |
| **4 Luồng E2E cốt lõi** | Hoàn thành 100% | **ĐẠT trên Live API & Database** | Xác nhận chính xác |

---

## 4. KẾT LUẬN VÀ QUYẾT ĐỊNH NGHIỆM THU

Căn cứ trên các bằng chứng kỹ thuật khách quan, Hội đồng Kiểm định Độc lập đưa ra kết luận:

> ### **QUYẾT ĐỊNH: VERIFIED – CONDITIONAL RELEASE (PHÁT HÀNH CÓ ĐIỀU KIỆN)**
> 
> Toàn bộ 183 chức năng học vụ cốt lõi (Xác thực, Sinh viên, Giảng viên, Đăng ký đề tài, Rã nhóm, Chấm điểm tiến độ, Phân quyền RBAC, Import dữ liệu) đã được xác minh hoạt động chính xác và ổn định trên nền tảng Live Backend ASP.NET Core 10 và CSDL SQL Server.
> 
> Tuy nhiên, hệ thống **CHƯA ĐƯỢC PHÁT HÀNH SANG PRODUCTION** cho đến khi hoàn tất 3 điều kiện tiên quyết:
> 1. Xóa vĩnh viễn chuỗi Secret Key khỏi lịch sử Git commit bằng `git filter-repo`.
> 2. Dọn dẹp các bản ghi OTP plaintext cũ trong bảng `PasswordResetOtps`.
> 3. Cấu hình biến môi trường (`JWT_KEY`, `SMTP_PASSWORD`, `SMTP_SENDER_EMAIL`) trên máy chủ triển khai.
