# 08. BÁO CÁO KIỂM THỬ BỘ DỮ LIỆU UNICODE TIẾNG VIỆT ĐẶC THÙ
*(Special Vietnamese Unicode Test Suite & Boundary Validation)*

---

## 1. MỤC TIÊU BÀI TEST
Tiếng Việt là một trong những ngôn ngữ có cấu trúc dấu phức tạp nhất trong hệ thống chữ viết Latinh:
- 5 dấu thanh: Sắc (´), Huyền (`), Hỏi (ˀ), Ngã (~), Nặng (.).
- Các nguyên âm có mũ/móc: Â, Ă, Ê, Ô, Ơ, Ư.
- Phụ âm Đ/đ.
- Dấu đôi (vừa có mũ/móc vừa có thanh điệu): ế, ề, ể, ễ, ệ, ố, ồ, ổ, ỗ, ộ, ớ, ờ, ở, ỡ, ợ, ứ, ừ, sử, chữ, ự.
- 2 dạng chuẩn hóa Unicode: **NFC** (Normalization Form C - Dựng sẵn) và **NFD** (Normalization Form D - Tổ hợp).

---

## 2. BỘ TEST CASES VÀ KẾT QUẢ ĐÁNH GIÁ

| Mã Test Case | Loại ký tự / Dải Unicode | Chuỗi kiểm thử mẫu | Kết quả SQL Server (NVARCHAR) | Kết quả API JSON (.NET 10) | Kết quả Flutter UI (Text Widget) | Đánh giá |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **TC-UNI-01** | Nguyên âm có dấu đôi (mũ + thanh điệu) | `Nguyễn Thị Kiều Diễm` | Lưu đúng `U+1EC5`, `U+1EC1`, `U+1EC5` | Xuất raw UTF-8 `"Nguyễn Thị Kiều Diễm"` | Render chuẩn, không lệch dấu | **PASS** |
| **TC-UNI-02** | Nguyên âm móc + ngã/nặng | `Lớp Kỹ thuật phần mềm & Trí tuệ nhân tạo` | Lưu đúng `U+1EF9`, `U+1EC7` | Xuất raw UTF-8 | Hiển thị trơn tru trên mọi màn hình | **PASS** |
| **TC-UNI-03** | Chữ hoa có dấu đặc biệt | `ĐẠI HỌC BÁCH KHOA - ĐOÀN ĐẠI BIỂU` | Lưu đúng `Đ` (`U+0110`), `Ạ` (`U+1EA0`) | Xuất raw UTF-8 | Khung hiển thị không bị vỡ layout | **PASS** |
| **TC-UNI-04** | Dấu thanh nặng ở vị trí cuối | `Học phần Thực tập tốt nghiệp & Đồ án` | Lưu đúng `U+1ECD`, `U+1EF1`, `U+1EC7` | Xuất raw UTF-8 | TextSpan hiển thị trọn vẹn | **PASS** |
| **TC-UNI-05** | Ký tự kết hợp dấu ngoặc và gạch nối | `Phát triển ứng dụng Web - Nhóm 01` | Lưu đúng `Phát triển ứng dụng Web - Nhóm 01` | Xuất raw UTF-8 | **Sửa triệt để lỗi cũ (ID 17)** | **PASS** |
| **TC-UNI-06** | Chuỗi giới tính sinh viên | `Nữ` | Lưu đúng `Nữ` (`0x4E 0x169`) | Xuất raw UTF-8 `"Nữ"` | **Khắc phục triệt để lỗi cũ `Ná»¯`** | **PASS** |
| **TC-UNI-07** | Tên học phần có ký tự `&`, `+` | `C++ & Lập trình Hướng đối tượng` | Lưu đúng, không bị escape HTML | Xuất raw UTF-8 | Hiển thị chính xác ký hiệu | **PASS** |
| **TC-UNI-08** | Văn bản dài có xuống dòng (`\n`) | Mô tả đề tài đồ án dài 500 từ chứa đầy đủ 89 ký tự tiếng Việt | Lưu đúng toàn văn | Xuất raw UTF-8 với `\n` | Tự động xuống dòng chuẩn trên thẻ Card | **PASS** |

---

## 3. ĐÁNH GIÁ CHUẨN HÓA NFC VS NFD
- **Hiện tượng:** Nếu một người dùng nhập liệu bằng bộ gõ Unikey theo chuẩn "Unicode tổ hợp" (NFD) và người khác nhập bằng "Unicode dựng sẵn" (NFC), câu lệnh `WHERE Ten = '...'` trên SQL Server với collation `Vietnamese_CI_AS` hoặc `SQL_Latin1_General_CP1_CI_AS` có thể đánh giá tương đương về mặt tìm kiếm.
- **Khuyến nghị tương lai:** Cân nhắc tích hợp hàm `input.Normalize(NormalizationForm.FormC)` tại tầng Backend DTO Validators để đảm bảo 100% dữ liệu lưu trữ thuần nhất ở dạng NFC.
