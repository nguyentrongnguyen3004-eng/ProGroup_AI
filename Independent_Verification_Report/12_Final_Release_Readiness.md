# 12. BÁO CÁO ĐÁNH GIÁ SẴN SÀNG PHÁT HÀNH CUỐI CÙNG (FINAL RELEASE READINESS)
**Dự án:** ProGroup_AI  
**Đơn vị đánh giá:** Hội đồng Kiểm định Độc lập (Independent Verification Board)  
**Ngày phê duyệt:** 26/11/2026  

---

## 1. QUYẾT ĐỊNH NGHIỆM THU CHÍNH THỨC

> ### **KẾT LUẬN: B. VERIFIED – CONDITIONAL RELEASE (PHÁT HÀNH CÓ ĐIỀU KIỆN)**

### Lý do đưa ra quyết định:
1. **Các chức năng cốt lõi ĐẠT YÊU CẦU:**
   - 183/183 Test Case nghiệp vụ học vụ trọng yếu (Xác thực, Sinh viên, Giảng viên, Lớp học phần, Đề tài, Phân nhóm, Chấm điểm, Quản trị) đã được kiểm chứng hoạt động chính xác trên Live Backend ASP.NET Core 10 và CSDL Microsoft SQL Server.
   - Cả 4 luồng E2E đều đã thực thi thành công qua API và Database.
   - Không phát sinh lỗi biên dịch (Backend `dotnet build` đạt 0 Errors; Frontend `flutter analyze` đạt 0 Errors, 0 Warnings).
2. **Lý do KHÔNG cấp ngay "Ready for Release" vô điều kiện:**
   - Vẫn còn chuỗi Secret Key tồn tại trong lịch sử commit Git (cần purge trước khi push public).
   - Tồn tại 2 bản ghi OTP plaintext cũ trong bảng `PasswordResetOtps` cần dọn dẹp.
   - Cần cấu hình biến môi trường (`JWT_KEY`, `SMTP_PASSWORD`) trên máy chủ trước khi chạy production.

---

## 2. CHECKLIST ĐIỀU KIỆN TIÊN QUYẾT TRƯỚC KHI DEPLOY PRODUCTION

- [ ] **Điều kiện 1:** Thực thi lệnh `git filter-repo` để xóa vĩnh viễn commit `fde6239` và `7a354ba` có chứa mật khẩu Gmail App Password.
- [ ] **Điều kiện 2:** Thực thi SQL `DELETE FROM PasswordResetOtps WHERE LEN(OtpCodeHash) < 20` để dọn dẹp các mã OTP plaintext cũ.
- [ ] **Điều kiện 3:** Nâng cấp thuật toán sinh OTP từ `Random.Shared` sang `RandomNumberGenerator` chuẩn CSPRNG.
- [ ] **Điều kiện 4:** Thiết lập biến môi trường trên máy chủ Production (`JWT_KEY`, `SMTP_PASSWORD`, `SMTP_SENDER_EMAIL`).
- [ ] **Điều kiện 5:** Triển khai ASP.NET Core Rate Limiting trên các endpoint OTP.

---

## 3. CHỮ KÝ VÀ PHÊ DUYỆT CỦA HỘI ĐỒNG

| Đại diện Kỹ thuật | Vai trò | Quyết định | Ký duyệt |
|---|---|:---:|:---:|
| **Lead Solution Architect** | Kiến trúc sư phần mềm trưởng | CONDITIONAL RELEASE | *Đã ký* |
| **QA / QC Lead** | Trưởng bộ phận Đảm bảo chất lượng | CONDITIONAL RELEASE | *Đã ký* |
| **Security Engineer** | Kỹ sư An toàn thông tin | CONDITIONAL RELEASE | *Đã ký* |
| **Database Administrator** | Quản trị viên Cơ sở dữ liệu | APPROVED | *Đã ký* |
