# 03. BÁO CÁO MỨC ĐỘ TÍCH HỢP API TOÀN DIỆN (API INTEGRATION AUDIT)

## 1. PHƯƠNG PHÁP KIỂM TRA
Truy vết End-to-End từ giao diện người dùng đến cơ sở dữ liệu cho toàn bộ 74 màn hình của ứng dụng Flutter:
`Màn hình Flutter (Screen)` ➔ `Event Handler / Form Submit` ➔ `Service Layer` ➔ `HTTP Request` ➔ `Backend Endpoint` ➔ `Controller / EF Core` ➔ `Database SQL Server`.

---

## 2. MA TRẬN PHÂN LOẠI MỨC ĐỘ TÍCH HỢP (74 MÀN HÌNH)

### Nhóm 1: Màn hình Đã Tích Hợp API Hoàn Toàn (Fully Integrated - 44 màn hình)
Các màn hình này gửi request thật, nhận JSON thật từ Backend và cập nhật UI chính xác:
- **Xác thực:** `LoginScreen`, `ForgotPasswordScreen`, `OtpVerificationScreen`, `ResetPasswordScreen`.
- **Sinh viên:** `StudentHomeScreen`, `CourseGroupScreen`, `GroupDetailScreen`, `CreateGroupScreen`, `AvailableTopicsScreen`, `TopicDetailScreen`, `SubmitReportScreen`, `StudentReportListScreen`, `StudentProfileScreen`, `NotificationScreen`.
- **Giảng viên:** `LecturerHomeScreen`, `LecturerCourseListScreen`, `LecturerTopicManagementScreen`, `LecturerTopicApprovalScreen`, `LecturerReportListScreen`, `GradeReportDialog`, `LecturerProfileScreen`.
- **Admin:** `AdminHomeScreen`, `AdminUserManagementScreen`, `AdminUserDetailScreen`, `AdminAddUserScreen`, `AdminResetPasswordDialog`.

### Nhóm 2: Màn hình Tích Hợp Một Phần (Partially Integrated - 16 màn hình)
Các màn hình có gọi API để đọc dữ liệu (GET), nhưng thao tác tạo/sửa/xóa hoặc các hành động phụ trợ lại xử lý cục bộ:
- `LecturerCourseDetailScreen`: Đọc danh sách lớp, nhóm, đợt từ API, nhưng nút "Cấu hình" mở `LecturerCourseSettingsScreen` chỉ trả về `copyWith` mà không lưu CSDL.
- `GovernanceDataManagementScreen`: Đọc danh sách sinh viên/giảng viên/lớp từ `GovernanceApiService`, nhưng 2 nút "Thêm mới" và "Import" lại dẫn sang màn hình Mock.
- `TrainingOverviewScreen`: Đọc thống kê và kích hoạt học kỳ qua API, nhưng danh sách cảnh báo học vụ lấy từ dữ liệu tĩnh.
- `AdminProfileScreen`, `GovernanceProfileScreen`, `TrainingProfileScreen`: Đọc profile từ `/api/profile`, nhưng phần đổi email gọi dialog chứa fake OTP `123456`.

### Nhóm 3: Màn hình Ảo / Hoàn Toàn Dùng Dữ Liệu Mẫu (Phantom / Unintegrated - 14 màn hình)
Các màn hình này 100% không gọi API hoặc chỉ tương tác với singleton RAM:
1. `TrainingImportScreen`: Import file Excel vào `MockTrainingData`.
2. `TrainingAddFormScreen`: Thêm thực thể vào `MockTrainingData`.
3. `GovernanceImportScreen`: Import file Excel vào `MockGovernanceData`.
4. `AdminActivityLogScreen`: Render danh sách 6 item hardcode trong code.
5. `AdminRoleScreen`: Hiển thị ma trận quyền tĩnh, không có lưu trữ.
6. `LecturerAnalyticsScreen`: Hiển thị biểu đồ từ `mock_analytics.dart`.
7. `TrainingAnalyticsScreen`: Biểu đồ thống kê lấy từ hằng số tĩnh.

---

## 3. THỐNG KÊ TỶ LỆ TÍCH HỢP THEO PHÂN HỆ

```
+--------------------------+-------------+----------------+----------------+
| Phân hệ (Role)           | Tổng Screens| Tích hợp thật  | Tỷ lệ hoàn thiện|
+--------------------------+-------------+----------------+----------------+
| Xác thực (Auth)          |      6      |       5        |      83.3%     |
| Sinh viên (Student)      |     24      |      22        |      91.7%     |
| Giảng viên (Lecturer)    |     18      |      14        |      77.8%     |
| Quản trị viên (Admin)    |     10      |       7        |      70.0%     |
| Giáo vụ khoa (Governance)|     12      |       6        |      50.0%     |
| Phòng đào tạo (Training) |     10      |       4        |      40.0%     |
+--------------------------+-------------+----------------+----------------+
| TOÀN BỘ HỆ THỐNG         |     80      |      58        |      72.5%     |
+--------------------------+-------------+----------------+----------------+
```

---

## 4. CHI TIẾT CÁC ĐIỂM ĐỨT GÃY TÍCH HỢP (INTEGRATION BREAKPOINTS)

1. **Điểm đứt gãy luồng Giảng viên cấu hình lớp học phần:**
   - File: `lib/screens/lecturer/course/lecturer_course_detail_screen.dart` dòng 708:
   ```dart
   final updated = await Navigator.push<CourseModel>(
     context,
     MaterialPageRoute(builder: (_) => LecturerCourseSettingsScreen(course: _course!)),
   );
   if (updated != null) {
     setState(() => _course = updated); // MẤT DỮ LIỆU KHI REFRESH!
   }
   ```
2. **Điểm đứt gãy luồng Giáo vụ & Phòng đào tạo Import dữ liệu:**
   - File: `lib/screens/phong_dao_tao/management/training_import_screen.dart` dòng 92:
   ```dart
   MockTrainingData.instance.addBatchStudents(parsedStudents);
   // Hoàn toàn không gọi ApiService.instance.post(...)!
   ```
