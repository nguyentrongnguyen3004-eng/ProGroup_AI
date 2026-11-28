# 09. BÁO CÁO XÁC MINH KIỂM THỬ HỒI QUY (REGRESSION VERIFICATION REPORT)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Đánh giá các tác động phụ tiềm ẩn trên toàn bộ 144 tệp tin đã thay đổi trong commit `927bf49`.  

---

## 1. PHÂN TÍCH RỦI RO HỒI QUY THEO PHÂN HỆ

| Khu vực chức năng | Bản chất thay đổi | Đánh giá tác động hồi quy | Kết quả kiểm định |
|---|---|---|:---:|
| **Xác thực Đổi mật khẩu** | Hỗ trợ thêm HTTP POST & `OldPassword` | Client cũ gửi PUT và `CurrentPassword` vẫn hoạt động bình thường | **PASS** (Zero breaking changes) |
| **Xác thực Đổi email** | Thêm quy trình OTP 2 bước | Người dùng bắt buộc phải qua xác thực OTP mới đổi được email | **PASS** (Bảo mật tăng cường) |
| **Giải phóng đề tài khi rã nhóm** | Hoàn trả trạng thái `Chưa sử dụng` | Các nhóm khác có thể đăng ký lại đề tài này ngay lập tức | **PASS** (Sửa đúng logic) |
| **Cấu hình lớp học phần** | Thêm API cập nhật cấu hình | Thông số sĩ số và hạn đăng ký được lưu vĩnh viễn | **PASS** (Khắc phục mất dữ liệu) |
| **Dashboard Quản trị** | Bỏ hardcoded 35 và 85.5% | Dữ liệu phản ánh đúng 264 tài khoản và đồ án trong DB | **PASS** (Chính xác) |
| **Nhật ký hoạt động** | Thêm API Activity Logs | Admin theo dõi được các sự kiện hệ thống | **PASS** (Hoạt động ổn định) |

---

## 2. KẾT LUẬN HỒI QUY
Toàn bộ các thay đổi đều duy trì tính tương thích ngược (Backward Compatibility), không phá vỡ bất kỳ hợp đồng giao tiếp nào đã có trước đây giữa Frontend và Backend.
