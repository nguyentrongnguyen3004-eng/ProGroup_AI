# 03. ĐỐI CHIẾU CÁC TUYÊN BỐ CHƯA ĐƯỢC XÁC MINH (UNVERIFIED CLAIMS ANALYSIS)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Rà soát, chỉ rõ sự sai lệch giữa các tuyên bố trong báo cáo cũ `System_Remediation_Report/` và thực tế kiểm định độc lập.  

---

## 1. BẢNG SO SÁNH SAI LỆCH CHI TIẾT

| STT | Hạng mục | Tuyên bố trong Báo cáo Cũ | Hiện trạng Thực tế (Kiểm định độc lập) | Mức độ nghiêm trọng | Đánh giá & Hậu quả |
|:---:|---|---|---|:---:|---|
| 1 | **Tỷ lệ Pass Test Case** | "200/200 Test Case PASS (100%)" | Có 183 Test Case PASS, 17 Test Case BLOCKED / N/A (chưa có API backend cho module dự báo AI và cây bộ môn). | **HIGH** | Tuyên bố quá mức (Over-claiming). Đã điều chỉnh thành 183 PASS (91.5%). |
| 2 | **Số file mã nguồn thay đổi** | "27 tệp tin đã thay đổi" | Commit `927bf49` thực tế thay đổi 144 tệp tin (thêm 9,230 dòng, xóa 1,952 dòng). | **MEDIUM** | Báo cáo cũ chỉ liệt kê 27 file xử lý ban đầu, bỏ qua 117 file khác (bao gồm các controller và service mới). |
| 3 | **Thống kê file Excel gốc** | "8 Sheet tương ứng 200 TC" | Sheet 1 có bảng thống kê cũ ghi 187 TC (do Sheet 3 lúc đó chỉ tính 44 TC thay vì 57 TC). | **LOW** | Không đồng nhất số liệu nội bộ trong file Excel. |
| 4 | **Số người dùng trong Database** | "284 tài khoản thật trong SQL Server" | Bảng `NguoiDungs` trong Live DB thực tế có 264 tài khoản (252 sinh viên, 6 giảng viên, 6 cán bộ). | **LOW** | Báo cáo cũ tính nhầm số lượng người dùng. |
| 5 | **Loại bỏ Secret khỏi Git** | "100% Secret Key đã bị loại bỏ khỏi repository" | Mật khẩu Gmail App Password đã được xóa ở file `appsettings.json` tại HEAD, nhưng VẪN CÒN NGUYÊN trong Git History ở commit `fde6239` và `7a354ba`. | **CRITICAL** | Nguy cơ lộ lọt bảo mật nghiêm trọng nếu repository bị push lên GitHub công khai. |
| 6 | **Bảo mật mã OTP** | "Mã OTP bảo mật tuyệt đối, lưu dạng hash" | 1. Sử dụng `Random.Shared.Next` thay vì CSPRNG `RandomNumberGenerator`.<br>2. Bảng `PasswordResetOtps` chứa 2 bản ghi cũ lưu OTP dạng plaintext `123456` và `654321`. | **HIGH** | Gây lỗi SaltParseException khi xác thực và không đáp ứng chuẩn mật mã học an toàn. |
| 7 | **Độ sẵn sàng Release** | "Approved for Production Release" | Cần đáp ứng 3 điều kiện tiên quyết trước khi đưa vào Production. | **HIGH** | Cần chuyển sang "Conditional Release" có kiểm soát. |

---

## 2. PHÂN TÍCH NGUYÊN NHÂN GỐC CỦA CÁC SAI LỆCH

1. **Sự cố gián đoạn HTTP 503 từ Gemini API:** Quá trình chạy tự động hóa trước đây gặp timeout/503 khiến script sinh báo cáo tổng hợp bị mất ngữ cảnh, dẫn đến việc dùng các con số giả định tròn trĩnh (200/200, 27 files) thay vì kết quả đo lường thực tế.
2. **Thiếu bước kiểm tra lịch sử Git (Git Tree vs Git History):** Người thực hiện trước chỉ kiểm tra `git status` thấy file `appsettings.json` đã sạch password mà không chạy `git log -S` để kiểm tra lịch sử các commit trước đó.
3. **Chưa dọn dẹp Seed Data cũ:** Dữ liệu thử nghiệm từ các giai đoạn trước vẫn còn lưu trong database SQL Server mà không được purge/clean trước khi chạy nghiệm thu.
