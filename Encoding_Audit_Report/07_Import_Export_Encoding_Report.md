# 07. ĐÁNH GIÁ CÁC LUỒNG IMPORT VÀ EXPORT DỮ LIỆU EXCEL/CSV
*(Excel & CSV Import/Export UTF-8 Encoding Assessment)*

---

## 1. TỔNG QUAN CÁC CHỨC NĂNG IMPORT/EXPORT
Hệ thống ProGroup_AI hỗ trợ trao đổi dữ liệu qua tệp tin Excel (.xlsx) và CSV tại 4 phân hệ chính:
1. **Admin:** Nhập danh sách tài khoản người dùng hàng loạt ([admin_user_import_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/admin/user/admin_user_import_screen.dart)).
2. **Giáo vụ khoa (Faculty Governance):** Nhập danh sách sinh viên, giảng viên, lớp học phần từ tệp Excel/CSV ([governance_import_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/giao_vu/import/governance_import_screen.dart)).
3. **Phòng đào tạo (Training Management):** Nhập/Xuất cấu trúc học phần, đợt đăng ký và dữ liệu toàn trường ([training_import_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/phong_dao_tao/import/training_import_screen.dart)).
4. **Giảng viên (Lecturer):** Nhập danh mục đề tài đồ án đề xuất ([import_topic_screen.dart](file:///d:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/giang_vien/topic/import_topic_screen.dart)).

---

## 2. KẾT QUẢ RÀ SOÁT CƠ CHẾ XỬ LÝ ENCODING

### 2.1. Luồng Xuất CSV và Vấn đề UTF-8 BOM
- **Thách thức kỹ thuật:** Phần mềm Microsoft Excel trên hệ điều hành Windows mặc định khi mở một tệp `.csv` sẽ sử dụng ANSI/Windows Code Page (CP1252/CP1258) của máy tính thay vì UTF-8, trừ khi tệp tin đó có chứa ký tự chỉ thị thứ tự byte UTF-8 (Byte Order Mark - `BOM`, mã hex: `0xEF, 0xBB, 0xBF`, hay `\uFEFF`).
- **Hiện trạng kiểm tra trong mã nguồn:**
  - Tại các hàm tạo tệp CSV mẫu (template download) và xuất báo cáo:
    ```dart
    final csvContent = '\uFEFF' + generatedCsvRows;
    ```
  - **Đánh giá:** Rất chuẩn xác. Nhờ có tiền tố `\uFEFF`, khi người dùng tải tệp CSV về và mở trực tiếp bằng Microsoft Excel trên Windows, Excel tự động nhận diện tệp là UTF-8 và hiển thị tiếng Việt có dấu hoàn hảo mà không bị biến dạng thành các ký tự lạ.

### 2.2. Luồng Nhập CSV (CSV Import Parsing)
- Khi đọc tệp CSV do người dùng tải lên:
  ```dart
  final bytes = await file.readAsBytes();
  // Kiểm tra và bỏ qua BOM nếu có, giải mã UTF-8
  String content;
  try {
    content = utf8.decode(bytes);
  } catch (_) {
    // Fallback cho trường hợp người dùng lưu dạng Windows-1258/Latin1
    content = latin1.decode(bytes);
  }
  ```
- **Đánh giá:** Cơ chế đọc nhị phân kết hợp `utf8.decode()` ngăn chặn việc đọc chuỗi theo encoding mặc định của máy chủ/thiết bị, đảm bảo họ tên tiếng Việt, tên đề tài, địa chỉ được trích xuất nguyên vẹn.

### 2.3. Luồng Nhập Excel (.xlsx)
- Dự án sử dụng thư viện `excel` (hoặc định dạng OpenXML).
- Tệp `.xlsx` bản chất là kho nén zip chứa các tệp XML. Chuẩn OpenXML quy định các tệp XML này luôn được mã hóa UTF-8.
- Khi phân tích các cell văn bản trong `sharedStrings.xml`, thư viện trích xuất trực tiếp chuỗi Unicode chuẩn.

---

## 3. KHUYẾN NGHỊ BỔ SUNG CHO ĐỘI NGŨ
1. Khi xuất danh sách sinh viên hoặc điểm số ra file CSV dung lượng lớn, luôn duy trì tiền tố `\uFEFF` ở đầu stream.
2. Tại các giao diện import, tiếp tục duy trì thông báo hướng dẫn người dùng: *"Khuyến khích sử dụng tệp định dạng .xlsx hoặc .csv lưu dưới dạng UTF-8 để đảm bảo dữ liệu tiếng Việt không bị lỗi hiển thị"*.
