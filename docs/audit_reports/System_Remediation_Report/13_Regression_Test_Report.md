# 13. BÁO CÁO KIỂM THỬ HỒI QUY (REGRESSION TEST REPORT)
## ĐÁNH GIÁ TÁC ĐỘNG CỦA CÁC THAY ĐỔI MÃ NGUỒN VÀ BẢO ĐẢM TÍNH ỔN ĐỊNH

---

### 1. PHẠM VI KIỂM THỬ HỒI QUY
Sau khi áp dụng các chỉnh sửa sửa lỗi P0, P1, P2 trên cả Backend và Frontend, toàn bộ các chức năng liên quan đã được kiểm tra hồi quy:
1. **Module Xác thực:** Đăng nhập 5 vai trò, cấp token, đổi mật khẩu.
2. **Module Hồ sơ cá nhân (Profile):** Lấy thông tin, cập nhật họ tên, cập nhật số điện thoại, đổi avatar.
3. **Module Nhóm đồ án:** Tạo nhóm, xem danh sách nhóm, đổi tên nhóm, mời thành viên.
4. **Module Đề tài đồ án:** Xem chi tiết đề tài, đề xuất đề tài mới, đăng ký đề tài.
5. **Module Quản trị (Admin):** Màn hình overview, danh sách người dùng.

---

### 2. KẾT QUẢ KIỂM THỬ HỒI QUY CHI TIẾT

| Chức năng kiểm tra | Tác động từ bản vá lỗi | Kết quả kiểm thử | Đánh giá |
|---|---|:---:|:---:|
| **Đăng nhập & Auth Token** | Không ảnh hưởng đến luồng sinh token | **PASSED** | Ổn định, không phát sinh lỗi |
| **Cập nhật Profile cá nhân** | Bổ sung thêm trường SĐT và kiểm tra dung lượng Avatar | **PASSED** | Hoạt động trơn tru, lưu DB thành công |
| **Hiển thị Avatar người dùng** | Đã phân lập Cache Key theo ID | **PASSED** | Triệt tiêu lỗi dính avatar cũ |
| **Đăng ký Đề tài** | Sửa logic chọn nhóm đại diện & Serializable lock | **PASSED** | Hiển thị đúng nhóm, chống tranh chấp |
| **Admin Dashboard Overview** | Sửa mapping role enum | **PASSED** | Dữ liệu hiển thị trực quan, đúng 100% |
| **Biên dịch Frontend** | Sửa async method & currentCloudflareUrl | **PASSED** | Không còn compilation error |

**Kết luận:** Quá trình khắc phục lỗi không gây ra bất kỳ hiệu ứng phụ (side-effects) tiêu cực nào lên các chức năng sẵn có của hệ thống.
