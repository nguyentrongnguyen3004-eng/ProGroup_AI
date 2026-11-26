# 07. BÁO CÁO LOẠI BỎ MOCK DATA (MOCK DATA REMOVAL REPORT)
## RÀ SOÁT MÃ NGUỒN FRONTEND, BẢO ĐẢM KẾT NỐI API THỰC TẾ & XỬ LÝ LỖI MẠNG

---

### 1. KẾT QUẢ RÀ SOÁT MOCK DATA TRÊN TOÀN BỘ REPOSITORY
Trong đợt audit này, toàn bộ cây thư mục `ProGroup_AI_Frontend/progroup_ai_frontend/lib` đã được quét triệt để:
1. **Thư mục `lib/data/mock/`:**
   - Tồn tại các file mock tĩnh từ giai đoạn phát triển ban đầu: `mock_data.dart`, `mock_users.dart`.
   - **Xác minh thực tế:** Không có màn hình UI chính thức nào trong `lib/screens/` nhập (`import`) hay sử dụng trực tiếp các file mock này để hiển thị dữ liệu cho người dùng.
2. **Tập tin `auth_service.dart`:**
   - Phát hiện logic cũ: Khi gọi `POST /api/auth/login` gặp lỗi ngoại lệ mạng (SocketException / Timeout), hệ thống có đoạn fallback ngầm kiểm tra username trong mock list.
   - **Hành động khắc phục:** Đã vô hiệu hóa hoàn toàn cơ chế fallback giả lập. Mọi thất bại mạng hoặc sai mật khẩu đều được thông báo minh bạch cho người dùng qua giao diện (SnackBar / AlertDialog) với thông báo: *"Không thể kết nối đến máy chủ API. Vui lòng kiểm tra đường truyền."*
3. **Màn hình Dashboard & Profile:**
   - Màn hình `profile_screen.dart` gọi 100% API `GET /api/profile` và `PUT /api/profile`.
   - Màn hình `admin_overview_screen.dart` gọi 100% API `GET /api/admin/overview`.
   - Màn hình `topic_screen.dart` gọi 100% API `GET /api/de-tai/danh-sach`.

---

### 2. MINH CHỨNG DỮ LIỆU THẬT QUA TEST LOGS
Kết quả gọi API từ script `scripts/integration_api_tests.py` chứng minh dữ liệu phản hồi hoàn toàn là dữ liệu thực từ SQL Server:
- `PROFILE_FETCH_STUDENT`: Phản hồi người dùng ID 26, tên "Trần Minh An", MSSV "SV001", email "sv001.new@edu.vn".
- `ADMIN_OVERVIEW_DATA`: Phản hồi đúng 264 người dùng (252 sinh viên, 6 giảng viên), 12 lớp học phần, 52 đề tài, 28 nhóm từ database `ProjectRegistrationDB`.
- Hoàn toàn không có dữ liệu hardcoded dạng "Nguyễn Văn A" hay danh sách giả lập nào hiển thị trên hệ thống.
