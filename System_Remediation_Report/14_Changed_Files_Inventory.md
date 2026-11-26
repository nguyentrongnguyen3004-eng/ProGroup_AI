# 14. DANH MỤC CÁC TỆP TIN THAY ĐỔI (CHANGED FILES INVENTORY)
## TỔNG HỢP MỌI TỆP TIN ĐÃ ĐƯỢC TẠO MỚI, CHỈNH SỬA VÀ TỐI ƯU HÓA

---

### 1. FRONTEND FLUTTER FILES

1. [topic_detail_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/topic/topic_detail_screen.dart)
   - *Thay đổi:* Xóa bỏ `foundGroup ?? myGroups.first`; thay thế bằng bộ lọc chính xác theo `dotDangKyId` và `isLeader`. Thêm cảnh báo nếu chưa có nhóm hợp lệ.
2. [topic_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/topic/topic_screen.dart)
   - *Thay đổi:* Đồng bộ hóa logic kiểm tra nhóm hợp lệ tương ứng với từng học phần đề tài.
3. [training_add_form_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/training_department/training_add_form_screen.dart)
   - *Thay đổi:* Sửa phương thức `void _save()` thành `Future<void> _save() async` khắc phục lỗi cú pháp biên dịch.
4. [api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/api_service.dart)
   - *Thay đổi:* Bổ sung hằng số `static const String currentCloudflareUrl` loại bỏ lỗi thiếu định nghĩa khi cấu hình server dialog.
5. [profile_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/profile/profile_screen.dart)
   - *Thay đổi:* Thêm trường hiển thị Số điện thoại và hộp thoại chỉnh sửa kết nối API `PUT /api/profile`.
6. [admin_overview_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/admin/admin_overview_screen.dart)
   - *Thay đổi:* Sửa ánh xạ `maVaiTro` chuẩn hóa dữ liệu biểu đồ phân bổ người dùng.
7. [avatar_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/avatar_service.dart)
   - *Thay đổi:* Bổ sung `cacheKey: 'user_${user.id}_${user.avatarUrl}'` chống dính bộ nhớ đệm ảnh đại diện.

---

### 2. BACKEND ASP.NET CORE FILES

1. [DeTaiController.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/DeTaiController.cs)
   - *Thay đổi:* Áp dụng `IsolationLevel.Serializable` trong transaction đăng ký đề tài và bổ sung kiểm tra tồn tại đề tài đang chờ duyệt/đã duyệt.
2. [ProfileController.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/ProfileController.cs)
   - *Thay đổi:* Giải mã byte nhị phân để thực thi giới hạn 10MB cho avatar upload, bổ sung whitelist phần mở rộng ảnh.

---

### 3. AUTOMATION & TEST SCRIPTS

1. [integration_api_tests.py](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/scripts/integration_api_tests.py)
   - *Tạo mới:* Bộ kiểm thử tự động gồm 13 kịch bản kiểm thử API, bảo mật, RBAC và concurrency.
2. [generate_system_remediation_reports.py](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/scripts/generate_system_remediation_reports.py)
   - *Tạo mới:* Script tự động sinh toàn bộ 16 báo cáo kiểm định chất lượng cao.
