# Khảo sát codebase Flutter ProGroup AI

> Phạm vi: khảo sát tĩnh source hiện có tại thư mục frontend; không thay đổi Dart, cấu hình hay dữ liệu. Các nhận định dưới đây dựa trên nội dung file, không coi giao diện hoặc tên file là bằng chứng API đã chạy.

## 1. Tổng quan

- Gốc frontend thực tế: `D:\TRONGNGUYEN_HK7\PhatTrienUngDungDiDong\ProGroup_AI_Frontend\progroup_ai_frontend`.
- Flutter app tên package `progroup_ai_frontend`, tên hiển thị trong `MaterialApp` là **ProGroup AI**; package constraint Dart `^3.12.2`.
- `lib/` có **143 tệp Dart**, gồm **74 tệp màn hình** (màn hình nghiệp vụ/auth), 24 model, 5 service và 20 tệp data/mock, cùng core và widget dùng chung. Số lượng màn hình tính theo tệp; hai tệp trợ giúp và thẻ khóa học trong `screens/` không tính là màn hình.
- Có năm vai trò trong luồng đăng nhập: sinh viên (`SINHVIEN`), giảng viên (`LECTURER`), giáo vụ khoa (`GIAOVU`), phòng đào tạo (`PHONG_DAO_TAO`) và admin (`ADMIN`). Điều hướng được kiểm tra role ở route màn hình chính; kiểm tra này chỉ dùng object truyền trong navigation, không thay thế phân quyền backend.
- State chủ yếu là `StatefulWidget`/`setState`, singleton mock giữ state trong bộ nhớ và `AppSettings extends ChangeNotifier`. Không thấy Provider, Bloc, Riverpod, GetX hoặc repository/API layer trong source.
- Chưa có HTTP client được khai báo trực tiếp trong `pubspec.yaml`, base URL, gọi API thực, lưu JWT hay persistence. Package `http`/`dio` xuất hiện trong lockfile không chứng minh app đang dùng chúng (có thể là phụ thuộc bắc cầu).
- Backend dự kiến `http://localhost:5094` không được xác minh trong frontend. Có thư mục `ProGroup_AI.API`, nhưng khảo sát thấy chỉ có `obj` với artifacts NuGet; không thấy `.cs`, `.csproj`, Swagger/OpenAPI hoặc DTO/controller trong workspace này. Do đó chưa thể xác minh endpoint/contract, JWT, CORS hoặc quy tắc quyền.

## 2. Cây thư mục thực tế (phần liên quan)

```text
.
├── pubspec.yaml / pubspec.lock / analysis_options.yaml / README.md
├── assets/icon/logo.png
├── lib/
│   ├── main.dart
│   ├── core/{constants,localization,routes,settings,theme}/
│   ├── data/mock/                 # 20 tệp dữ liệu giả lập
│   ├── models/                    # 24 model
│   ├── services/                  # 5 service (không có HTTP service)
│   ├── screens/
│   │   ├── common/{auth,splash}/
│   │   ├── sinh_vien/{chat,course,group,home,notification,profile,topic}/
│   │   ├── giang_vien/{course,group,home,main,notification,profile,topic,topic_proposal,topic_registration}/
│   │   ├── giao_vu/{course,home,lecturer,main,notification,profile,registration,student,tools}/
│   │   ├── phong_dao_tao/{home,main,management,notification,profile}/
│   │   └── admin/{activity,data,home,main,notification,profile,role,user}/
│   └── widgets/{governance,lecturer}/ + widget chung
├── android/ / ios/ / web/ / windows/ / macos/ / linux/
├── test/                           # widget/unit tests hiện có
└── ProGroup_AI.API/obj/            # artifacts; không thấy source backend
```

`build/`, `.dart_tool/`, `.gradle/` và `.git/` là thư mục sinh tự động/metadata, không phải source nghiệp vụ. `README.md` còn nội dung template Flutter và dấu xung đột merge (`<<<<<<<`, `=======`, `>>>>>>>`); ghi nhận như vấn đề tài liệu, không sửa trong đợt khảo sát.

## 3. Công nghệ và cấu hình

| Khu vực | Bằng chứng trong source | Ghi chú tích hợp |
|---|---|---|
| UI | Flutter Material; `MaterialApp`, widget Material | Dùng light/dark theme tại `lib/core/theme/app_theme.dart`. |
| Điều hướng | `initialRoute` + `onGenerateRoute` trong `lib/main.dart`; nhiều màn hình con dùng `Navigator.push(MaterialPageRoute)` | Không có router package/deep-link/auth guard tập trung. Route ép kiểu arguments ở một số nhánh có thể lỗi runtime nếu truyền sai kiểu. |
| State | `setState`; một số singleton `ChangeNotifier`; `AnimatedBuilder` | Không có DI/repository abstraction. Mock singleton có thể giữ dữ liệu tới khi app process dừng, không lưu bền. |
| Localization | `AppLocalizations` với map VI/EN; `AppSettings` mặc định vi | `AppSettings` chỉ giữ state RAM, chưa thấy persistence. Mức dịch tùy màn hình; không có package intl/localization generation được khai báo. |
| Package trực tiếp | `cupertino_icons`, `csv`, `file_picker`, `file_saver`, `image_picker`, `excel`, `flutter_launcher_icons`; dev: `flutter_test`, `flutter_lints` | CSV/Excel/file picker phục vụ import/export; `image_picker` cho avatar. Không có HTTP, secure storage hoặc shared preferences trong pubspec. |
| Asset/font | `assets/icon/logo.png`; Material icons | Không khai báo custom font. |
| Android | Manifest chính không có `android.permission.INTERNET` khai báo rõ | Cần rà soát permission và policy HTTP cleartext khi cấu hình kết nối Android. Không sửa ở giai đoạn này. Emulator thường dùng `10.0.2.2:5094`; thiết bị thật cần IP LAN. |
| Web | `web/index.html` template, chưa có cấu hình API/CORS | Browser gọi khác origin cần backend bật CORS phù hợp. |
| iOS | `ios/Runner/Info.plist` không ghi cấu hình API | ATS/HTTP local cần kiểm tra khi chọn URL HTTP; không suy ra đã hỗ trợ. |
| Môi trường | Không thấy flavor/env/base URL trong lib/config | Cần phân tách emulator, thiết bị, web và môi trường triển khai. Không đặt secret trong app client. |

`analysis_options.yaml` include `flutter_lints/flutter.yaml`, loại build và các platform directories khỏi analyzer. Không chạy analyzer/test trong nhiệm vụ khảo sát.

## 4. Danh mục màn hình

Trạng thái mặc định trong bảng: **UI + logic cục bộ/mock**, không gọi API. “Vào” mô tả điểm truy cập nhìn thấy trong source; nhiều màn hình mở bằng callback/`MaterialPageRoute` từ tab hoặc màn nghiệp vụ, không đăng ký ở `AppRoutes`. Input/output là arguments hoặc kết quả cục bộ quan sát được; “—” nghĩa không thấy dữ liệu trả về có ý nghĩa ra backend.

### Chung và xác thực

| Màn hình (file) | Vai trò; chức năng | Vào → tiếp | Input → output | Hiện trạng |
|---|---|---|---|---|
| Splash (`common/splash/splash_screen.dart`) | Chung; màn khởi động | `/` → login | — → — | Chờ cục bộ rồi chuyển login; không kiểm tra session |
| Login (`common/auth/login/login_screen.dart`) | Tất cả role; đăng nhập | splash → dashboard theo role / forgot password | username/password → `UserModel` mock | Auth giả lập |
| Forgot password (`common/auth/forgot_password/forgot_password_screen.dart`) | Chung; yêu cầu OTP | login → OTP | email → email route argument | `MockService.sendOtp` giả lập |
| OTP (`common/auth/otp/otp_screen.dart`) | Chung; xác nhận mã | forgot → reset password | email + mã → email | OTP cố định `123456` trong mock |
| Reset password (`common/auth/reset_password/reset_password_screen.dart`) | Chung | OTP → login | email + mật khẩu mới → thông báo | Cập nhật giả lập; không ràng buộc tài khoản |

### Sinh viên

| Màn hình (file) | Chức năng / cách vào và điều hướng | Input → output | Hiện trạng |
|---|---|---|---|
| `sinh_vien/home/student_main_screen.dart` | Shell 4 tab: home, nhóm, thông báo, cá nhân | tab index → nội dung tab | State cục bộ |
| `sinh_vien/home/home_screen.dart` | Tổng quan, học phần, thông báo; mở chi tiết course | mock courses → course detail/notification | Mock |
| `sinh_vien/course/course_screen.dart` | Danh sách học phần; vào từ luồng học phần | `MockCourses` → course detail | Mock; có màn nhưng tab chính dùng home |
| `sinh_vien/course/course_detail_screen.dart` | Chi tiết học phần; mở nhóm, đề tài, tạo/tham gia nhóm | `CourseModel` → nhóm/đề tài/create group | Mock |
| `sinh_vien/group/group_screen.dart` | Nhóm của sinh viên; tab nhóm | `MockGroups`, mock user → chi tiết/nhóm học phần | Mock |
| `sinh_vien/group/course_group_screen.dart` | Nhóm theo học phần; tạo/xem nhóm | `CourseModel` → create/detail/join request/invitation | Mock state |
| `sinh_vien/group/create_group_screen.dart` | Tạo nhóm, kiểm tra tên trùng/số lượng | course → `GroupModel`/cập nhật mock | Logic local, không lưu backend |
| `sinh_vien/group/group_detail_screen.dart` | Chi tiết, thành viên, mời/quản lý và đăng ký topic | `GroupModel` → chat/topic/invitation | Mock |
| `sinh_vien/group/join_group_screen.dart` | Tìm nhóm/tham gia | text → nhóm trả về cho caller | Mock; comment nêu endpoint tương lai, không được gọi |
| `sinh_vien/group/join_request_screen.dart` | Danh sách/xử lý yêu cầu vào nhóm | mock requests/groups → trạng thái chấp nhận/từ chối | Mock mutable |
| `sinh_vien/group/invitation_management_screen.dart` | Xem/xử lý lời mời | danh sách mock → trạng thái phản hồi | Mock mutable |
| `sinh_vien/topic/topic_screen.dart` | Danh sách/lọc đề tài, đề xuất, AI | course tùy chọn + mock topics → detail/propose/AI | Mock/local |
| `sinh_vien/topic/topic_detail_screen.dart` | Chi tiết đề tài, đăng ký nhóm | topic/course → cập nhật registration mock | Mock |
| `sinh_vien/topic/propose_topic_screen.dart` | Tạo đề xuất topic | form → map kết quả trả caller | Local; comment gợi ý `POST /api/topics/proposals` chưa xác minh |
| `sinh_vien/topic/ai_topic_screen.dart` | Thu thập tiêu chí, gợi ý đề tài, feedback | request + topics mock → recommendation/feedback | Thuật toán local, không phải AI/backend |
| `sinh_vien/chat/chat_screen.dart` | Giao diện chat nhóm | tên nhóm → tin nhắn cục bộ | Không có transport/realtime; local |
| `sinh_vien/notification/notification_screen.dart` | Lọc/đọc/xóa thông báo | mock notifications → cập nhật local | Mock |
| `sinh_vien/profile/profile_screen.dart` | Hồ sơ, avatar, cài đặt, đăng xuất | user mock + AppSettings → local changes/login | Không lưu hồ sơ bền/backend |

### Giảng viên

| Màn hình (file) | Chức năng / cách vào và điều hướng | Input → output | Hiện trạng |
|---|---|---|---|
| `giang_vien/main/lecturer_main_screen.dart` | Shell navigation giảng viên | tab → home/course/group/notifications/profile; shortcut topic & registrations | Local |
| `giang_vien/home/lecturer_home_screen.dart` | Tổng quan, shortcuts tới học phần, nhóm, topic, đăng ký | mock aggregates → màn tương ứng | Mock |
| `giang_vien/home/lecturer_statistics_screen.dart` | Thống kê/lọc theo course | mock courses/data → biểu đồ/chỉ số | Mock |
| `giang_vien/course/lecturer_course_screen.dart` | Danh sách học phần được phân công | `MockLecturerCourses` → chi tiết | Mock |
| `giang_vien/course/lecturer_course_detail_screen.dart` | Chi tiết học phần; groups/topics/settings | course → các màn con | Mock |
| `giang_vien/course/lecturer_course_settings_screen.dart` | Cấu hình thời gian/quy mô nhóm, topic | course → `copyWith` result | Local |
| `giang_vien/group/lecturer_group_screen.dart` | Danh sách nhóm theo lớp | mock groups → group detail | Mock |
| `giang_vien/group/lecturer_group_detail_screen.dart` | Chi tiết nhóm, thành viên/đề tài | group → topic/registration | Mock |
| `giang_vien/topic/lecturer_topic_screen.dart` | Quản lý topic theo lớp; import/add/assistant | course → detail/add/import/assistant | Mock/local |
| `giang_vien/topic/lecturer_topic_detail_screen.dart` | Chi tiết topic; chỉnh sửa/xóa | `TopicModel` → edit/update mock | Local/mock |
| `giang_vien/topic/add_topic_screen.dart` | Tạo topic | form/course → `TopicModel` | Local/mock |
| `giang_vien/topic/edit_topic_screen.dart` | Chỉnh topic | topic → `copyWith`/kết quả | Local/mock |
| `giang_vien/topic/import_topic_screen.dart` | Đọc và phân tích file CSV/Excel | file, course → preview | File parsing cục bộ |
| `giang_vien/topic/import_topic_preview_screen.dart` | Xác nhận import các dòng | preview rows → cập nhật mock topics | Local; import không đồng nghĩa đồng bộ API |
| `giang_vien/topic/lecturer_topic_assistant_screen.dart` | Gợi ý đề tài cho giảng viên | course/field/technology/keywords → suggestion | `LecturerTopicSuggestionService` sinh template cục bộ |
| `giang_vien/topic_proposal/lecturer_topic_proposal_screen.dart` | Duyệt/từ chối đề xuất sinh viên | mock proposals → status/reason | Mock mutable |
| `giang_vien/topic_registration/topic_registration_screen.dart` | Danh sách đăng ký đề tài, lọc trạng thái | mock registrations → detail | Mock |
| `giang_vien/topic_registration/topic_registration_detail_screen.dart` | Duyệt/từ chối đăng ký | registration → status/reason | Mock mutable |
| `giang_vien/notification/lecturer_notification_screen.dart` | Danh sách/đánh dấu thông báo | mock → cập nhật read | Mock |
| `giang_vien/profile/lecturer_profile_screen.dart` | Hồ sơ/cài đặt/đăng xuất | `MockLecturer`, settings → local changes/login | Không có persistence/API |

### Giáo vụ khoa

| Màn hình (file) | Chức năng / cách vào và điều hướng | Input → output | Hiện trạng |
|---|---|---|---|
| `giao_vu/main/governance_main_screen.dart` | Shell điều hướng role | tab → overview/data/notifications/profile (xác nhận theo `_pages`) | Local |
| `giao_vu/home/governance_overview_screen.dart` | Số liệu tổng quan và shortcuts | singleton mock → students/lecturers/courses/tools | Mock |
| `giao_vu/main/governance_data_management_screen.dart` | Chọn nhóm dữ liệu quản lý | kind → màn quản lý phù hợp | Mock/local |
| `giao_vu/main/governance_add_form_screen.dart` | Form thêm record theo loại | kind + form → cập nhật mock | Local |
| `giao_vu/student/governance_student_screen.dart` | Tìm/lọc/quản lý sinh viên | mock students → detail/action | Mock |
| `giao_vu/lecturer/governance_lecturer_screen.dart` | Danh sách/quản lý giảng viên | mock lecturers → form/detail/action | Mock |
| `giao_vu/course/governance_course_screen.dart` | Tìm/lọc học phần | mock courses → chi tiết/chọn loại | Mock |
| `giao_vu/registration/governance_registration_overview_screen.dart` | Tổng quan đăng ký | mock group/topic data → overview | Mock; quyền/nghiệp vụ backend chưa rõ |
| `giao_vu/tools/governance_tools_screen.dart` | Mở công cụ phân công/import | shortcuts → assignment/import | Local |
| `giao_vu/tools/governance_assignment_screen.dart` | Giao/phân công dữ liệu | mock → cập nhật trong app | Mock; contract chưa xác minh |
| `giao_vu/tools/governance_import_screen.dart` | Import dữ liệu | file → preview/record mock | Cục bộ |
| `giao_vu/notification/governance_notification_screen.dart` | Đọc/đánh dấu thông báo | mock → read state | Mock |
| `giao_vu/profile/governance_profile_screen.dart` | Hồ sơ/cài đặt/đăng xuất | profile mock + settings → local | Không persistence/API |

### Phòng đào tạo

| Màn hình (file) | Chức năng / cách vào và điều hướng | Input → output | Hiện trạng |
|---|---|---|---|
| `phong_dao_tao/main/training_main_screen.dart` | Shell role | tab → overview/data/notifications/profile | Local |
| `phong_dao_tao/home/training_overview_screen.dart` | Thống kê tổng quan | mock training data → shortcuts | Mock |
| `phong_dao_tao/management/training_data_management_screen.dart` | Danh sách/quản lý dữ liệu đào tạo | loại/query → detail/add/import | Mock |
| `phong_dao_tao/management/training_add_form_screen.dart` | Thêm học phần/record | form → mock data | Local/mock |
| `phong_dao_tao/management/training_import_screen.dart` | Chọn và phân tích file nhập | file CSV/Excel → preview/import record | File parsing/local |
| `phong_dao_tao/notification/training_notification_screen.dart` | Thông báo | mock → read state | Mock |
| `phong_dao_tao/profile/training_profile_screen.dart` | Hồ sơ/cài đặt/đăng xuất | profile mock + settings → local | Không persistence/API |

### Admin

| Màn hình (file) | Chức năng / cách vào và điều hướng | Input → output | Hiện trạng |
|---|---|---|---|
| `admin/main/admin_main_screen.dart` | Shell admin; overview/users/data/roles/activity/notification/profile | `UserModel` → tab children | `MockAdminData` |
| `admin/home/admin_overview_screen.dart` | KPI/hoạt động và dữ liệu tổng quan | mock admin/training/groups → thống kê | Mock |
| `admin/user/admin_user_screen.dart` | Tìm/lọc danh sách tài khoản; mở form/detail/roles/activity | mock accounts → child screens | Mock CRUD |
| `admin/user/admin_user_form_screen.dart` | Tạo/sửa tài khoản, role/status | account tùy chọn → lưu mock | Local, có trường password mock |
| `admin/user/admin_user_detail_screen.dart` | Chi tiết, khóa/mở/xóa account | accountId → mutate mock | Mock |
| `admin/role/admin_role_screen.dart` | Danh sách/diễn giải quyền theo role | dữ liệu tĩnh → — | Tĩnh; không phải enforcement |
| `admin/data/admin_data_management_screen.dart` | Danh mục dữ liệu cần quản trị | chọn loại → detail | Mock |
| `admin/data/admin_data_detail_screen.dart` | Xem dữ liệu theo loại | type → cập nhật/xem record mock | Mock |
| `admin/activity/admin_activity_log_screen.dart` | Tìm/lọc nhật ký hoạt động | mock activity → filtered list | Mock |
| `admin/notification/admin_notification_screen.dart` | Thông báo admin | mock → read state | Mock |
| `admin/profile/admin_profile_screen.dart` | Hồ sơ, avatar/cài đặt/logout | user + mock admin/settings → local | Không persistence/API |

`lib/screens/sinh_vien/course/course_card.dart` là widget trùng vai trò với `lib/widgets/course_card.dart`; chưa thấy bằng chứng class này được dùng làm màn hình. `AppRoutes.course` và `AppRoutes.courseDetail` đều vào `CourseDetailScreen`; một số luồng mở màn hình bằng route trực tiếp nên danh sách route hằng số không bao quát toàn app.

## 5. Điều hướng và luồng nghiệp vụ đã xác minh

1. `main()` → `ProGroupApp` → `MaterialApp` → `/` (`SplashScreen`) → `/login`. Không thấy khôi phục session.
2. Login gọi `AuthService.login` với delay và danh sách credential/mock; role map sang một trong năm màn hình chính. `ADMIN_LEGACY` được trả từ nhánh credential legacy nhưng không được switch điều hướng nên hiện báo role chưa hỗ trợ. `main.dart` kiểm tra loại `UserModel` và role cho route dashboard.
3. Sinh viên: home/tab học phần → course detail → danh sách nhóm/đề tài; từ nhóm có tạo nhóm, tìm/join, xem chi tiết, mời/yêu cầu; detail topic có đăng ký bằng mock. Topic có luồng đề xuất tới màn duyệt của giảng viên, và AI gợi ý local. Chat và notification là UI/state local.
4. Giảng viên: main/home → course → group/topic; cấu hình học phần, CRUD topic, import CSV/Excel, gợi ý local; xem và quyết định proposal/topic registration. Thay đổi qua singleton mutable mock và trả kết quả qua Navigator; không có server transaction.
5. Giáo vụ: shell → overview/data management/tools; danh sách student/lecturer/course và import/assignment qua mock. Phòng đào tạo: shell → overview/data management/add/import. Admin: shell → overview/users/data/roles/activity. Các màn quản trị có thao tác cục bộ; role/permission chỉ thể hiện trong giao diện.
6. Quên mật khẩu → send OTP giả lập → OTP cố định → reset giả lập → login. Không xác minh email với server, token khôi phục, giới hạn thử hoặc cập nhật password account.

## 6. Model, state và nguồn dữ liệu

### Model

Các model là Dart object thuần, không thấy `fromJson`/`toJson`, code generation hoặc mapping DTO. Các trường chính:

| Nhóm | Model | Trường/dữ liệu chính |
|---|---|---|
| Identity/admin | `UserModel` | id, username, fullName, email, role, roleName, mssv/avatarUrl tùy chọn |
| | `AdminAccountModel` | userCode, username, fullName, email, role/status, password, phone/avatar/createdAt; password đang có trong model mock và không nên ánh xạ nguyên trạng từ API |
| | `AdminActivityModel`, `AdminNotificationModel` | actor/action/target/time/status; title/message/read/time |
| Course/academic | `CourseModel` | code/name/classCode/semester/lecturer/status |
| | `LecturerCourseModel` | course identifiers, counts, registration dates, min/max members, status; `copyWith` cho settings |
| | `TrainingSubjectModel`, `TrainingImportRecordModel` | subject code/name/credits/department/status; thống kê file import |
| Group/topic | `GroupModel` | courseId/name/leader/memberCount/maxMembers/status/members |
| | `GroupInvitationModel`, `GroupJoinRequestModel` | group/student identifiers, status, createdAt; status mutable |
| | `TopicModel`, `TopicRegistrationModel`, `LecturerTopicProposalModel` | title/description/objective/scope/technology/status/source; đăng ký và lý do quyết định |
| Lecturer/governance | `LecturerModel`, `GovernanceStudentModel`, `GovernanceProfileModel`, `TrainingProfileModel` | mã, liên hệ, đơn vị/khoa, role/status/avatar; profile `copyWith` một phần |
| AI local | `AiTopicRequestModel`, `AiTopicRecommendationModel`, `AiChatMessageModel`, `AiFeedbackModel`, `LecturerTopicSuggestionModel` | tiêu chí yêu cầu, điểm xếp hạng, message/feedback và text suggestion |
| Notification | `TrainingNotificationModel` | type/title/content/time/icon/read; `IconData` không phải dữ liệu DTO phù hợp trực tiếp |

### State và mock stores

- `lib/data/mock/mock_admin_data.dart`: singleton `ChangeNotifier`; account/activity/notification và các thao tác CRUD/credential.
- `mock_governance_data.dart`, `mock_training_data.dart`: singleton có profile, sinh viên, giảng viên, môn/học phần, import data; training liên hệ governance mock.
- `mock_lecturer.dart`: thông tin lecturer singleton; `mock_lecturer_courses.dart`, `mock_lecturer_groups.dart`, `mock_lecturer_topics.dart`, `mock_lecturer_topic_proposals.dart`, `mock_lecturer_topic_registrations.dart`: danh sách static/mutable; proposal/notif có thể phát thông báo local.
- `mock_courses.dart`, `mock_groups.dart`, `mock_topics.dart`, `mock_topic_registrations.dart`, `mock_group_invitations.dart`, `mock_group_join_requests.dart`: seed lists; các thao tác cập nhật chủ yếu thay đổi trong RAM.
- `mock_user.dart`: user seed cho các role.
- `mock_notifications.dart`, `mock_lecturer_notifications.dart`, `mock_governance_notifications.dart`, `mock_training_notifications.dart`: singleton notification state, thường `ChangeNotifier`.
- `AppSettings`: singleton `ChangeNotifier` theme/language/notifications, không persistence.
- `AiTopicRecommendationService`: tính điểm theo keyword/heuristic/cosine similarity trên topic mock. `AiFeedbackService` giữ list trong instance. `LecturerTopicSuggestionService` trả 3 chuỗi template sau delay; không gọi mô hình AI.
- `AuthService` và `MockService`: auth/OTP/password fake có delay. Không có session/token.

Màn hình thường đọc trực tiếp singleton/list và tự gọi `setState`; ranh giới data-access không đồng nhất, không có loading/error state chuẩn dùng chung, retry/refresh protocol hay stale-data policy. Tích hợp API sẽ cần DTO parsing, xử lý null/date/status, repository/service và cập nhật UI thống nhất. Dữ liệu seed và credential demo chỉ được dùng như mock; không đưa credential/password vào tài liệu API.

## 7. Dữ liệu tĩnh, mock và mức hoàn thiện

- Đăng nhập role, OTP, reset password: hoàn thiện tương tác UI và kiểm tra form cục bộ; không xác thực/ghi dữ liệu backend.
- Học phần, nhóm, invitation/join request, topic/proposal/registration, user admin, cấu hình và notification: thao tác có logic cục bộ trên seed/mock; trạng thái mất khi app dừng và không đồng bộ giữa client.
- Import/export: package CSV/Excel/file picker hỗ trợ xử lý file cục bộ. Kết quả import và record history mock; chưa upload API.
- AI sinh viên và lecturer assistant: gợi ý heuristic/template chạy trong app trên seed topic/đầu vào; feedback list in-memory; không kết luận là dịch vụ AI thật.
- Chat: giao diện/tin nhắn local, chưa thấy socket/HTTP/realtime hoặc persistence.
- Profile/avatar/settings: một số tương tác UI và chọn ảnh; AppSettings/profile không có lưu bền hoặc endpoint cập nhật.
- Giao vụ/Admin role/permission: màn hình quản trị và bảng quyền hiển thị không chứng minh backend enforce authorization.

## 8. Kiểm kê khả năng API

| Khả năng | Kết luận từ source |
|---|---|
| HTTP client gọi từ `lib` | **Chưa có** (không thấy import/client/request). |
| Base URL/flavor/environment | **Chưa có**; không thấy `localhost:5094` trong app. |
| API service/repository | **Chưa có**; service hiện có là auth mock, mock OTP, heuristic AI, feedback local, lecturer suggestion. |
| Auth API, JWT header, token storage/refresh | **Chưa có**. Không thấy JWT, Authorization, secure storage/preferences. |
| HTTP error mapping 401/403/404/409/500 | **Chưa có**. Catch trong auth/reset UI chỉ hiển thị message chung cho exception local. |
| Timeout/network/json parsing | **Chưa có**. Không có JSON DTO mapper trong model. |
| Loading/error/empty | Có một số trạng thái per-screen và thông báo local; **chưa có quy ước API dùng chung**. |
| Refresh | Một số màn hình đọc lại mock khi build/return từ màn con; **chưa có cơ chế đồng bộ server**. |
| Android permission/HTTP | Manifest chính không khai báo INTERNET rõ; backend URL HTTP nên cần kiểm tra permission/cleartext policy theo target/build. |
| Web CORS | Chưa xác minh; phải lấy cấu hình backend và test khi API có mặt. |
| Endpoint comments | `join_group_screen.dart` có comment `GET /api/groups/search?...` và `POST /api/groups/{groupId}/join`; `propose_topic_screen.dart` có `POST /api/topics/proposals`. Đây chỉ là phác thảo trong comment, request body ví dụ không xác minh với server và **không phải endpoint đã xác minh**. |

## 9. Đối chiếu backend / hợp đồng API

Không có endpoint nào được xác minh. `ProGroup_AI.API` trong workspace chỉ thấy `obj` artifacts; không có mã nguồn API đọc được. Không dùng `localhost:5094` để giả định contract. Bảng trạng thái:

| Nhóm endpoint | Method/endpoint, role, request/response, lỗi | Màn hình/model frontend dự kiến |
|---|---|---|
| Auth/account | **Chưa xác minh**; cần AuthController, DTO và cấu hình JWT | Login/forgot/OTP/reset/profile; `UserModel` cần DTO mapping/session model |
| Course/semester/subject/class | **Chưa xác minh** | Student/lecturer/governance/training course screens; `CourseModel`, `LecturerCourseModel`, `TrainingSubjectModel` |
| Groups/members/invitations/requests | **Chưa xác minh**. Hai comment endpoint ở trên không phải bằng chứng API | Student/lecturer group screens; group/invitation/request models |
| Topics/proposals/registrations | **Chưa xác minh**. Comment POST proposal chỉ là dự kiến | Student/lecturer topic screens; topic/proposal/registration models |
| Governance/training/admin | **Chưa xác minh** | Data management/import/user/role screens; models hiện tại |
| Notification/chat/OTP/AI | **Chưa xác minh** | Notification/chat/AI screens; không giả định backend có các capability này |

Để xác minh cần cung cấp source backend/API riêng hoặc OpenAPI JSON/YAML và tối thiểu: `Program.cs`/startup, AuthController, controllers liên quan course/group/topic/student/lecturer/admin, request/response DTO, enums/status, JWT/authz policies/role claims, quy tắc nghiệp vụ và response lỗi. Cần xác nhận endpoint/verb/body/query/path, pagination, success envelope, nullable/date formats, mã lỗi, role scope và cách refresh token. Không ghi thông tin secret/connection string.

## 10. Kế hoạch tích hợp đề xuất theo source thực tế

Không có đường dẫn API hiện hữu để thay thế trực tiếp; các file screen và mock data dưới đây là vùng dự kiến cần chuyển dần. Tên file mới mang tính đề xuất, cần chốt sau khi có contract backend.

| Giai đoạn | File hiện có dự kiến sửa | File mới dự kiến | Phụ thuộc / tiêu chí hoàn thành / rủi ro |
|---|---|---|---|
| 0. Chốt contract & môi trường | `pubspec.yaml` (chỉ ở giai đoạn triển khai, sau khi duyệt package); `main.dart`; Android manifest/platform config | config/env, API error types, env docs | Contract backend và nền tảng đích. URL phân biệt Android emulator `10.0.2.2`, thiết bị LAN, web; không commit secret. Xác minh kết nối từng platform. |
| 1. HTTP foundation | `main.dart` (khởi tạo/DI nếu chọn); screen/service cũ chỉ khi thay từng phần | `lib/core/network/api_client.dart`, config, exception/interceptor; folder `repositories/` (chưa tồn tại) | Chọn HTTP package, timeout, JSON/error mapping, logging không lộ token. Hoàn thành khi kiểm tra một GET thật, timeout và mapping lỗi có contract. |
| 2. Auth/session/profile | `services/auth_service.dart`, `mock_service.dart`, `login_screen.dart`, forgot/OTP/reset; profile screens; `user_model.dart`; main route | auth DTO, auth repository, token/session store, auth state/guard | JWT contract, claim/role mapping, refresh/revoke và secure storage. Hoàn thành login/401/logout/khởi động lại không lộ token. Tránh coi route argument là authorization. |
| 3. Danh mục học phần | mock course files + sinh viên/giảng viên/course; governance/training course screens | course DTO/repository | Backend pagination/semester/status. Thay seed read path; loading/error/empty/retry. |
| 4. Nhóm và thành viên | `mock_groups`, invitation/request mocks; student group screens; lecturer group screens | group/member/invitation DTO + repository | Role rules, giới hạn thành viên, cạnh tranh create/join, trạng thái invitation. Backend mới là nguồn quyết định. |
| 5. Đề tài/đăng ký | `mock_topics`, registrations/proposals; student & lecturer topic screens | topic/proposal/registration DTO/repository | Xác nhận lifecycle/status, duplicate/conflict (409), approve/reject semantics. AI recommendation vẫn tách riêng nếu chưa có backend API. |
| 6. Giảng viên | lecturer mock stores, course settings/topic/group/registration/proposal screens | lecturer/dashboard DTO/repositories | Authorization server-side; không gửi counters hoặc quyền do client tự xác định như sự thật. |
| 7. Giáo vụ / phòng đào tạo / admin | `mock_governance_data`, `mock_training_data`, `mock_admin_data`; screens theo role | DTO/repositories/import upload service | Bulk import validation, audit, pagination, role policy, response từng dòng. Upload API chỉ sau khi contract xác nhận. |
| 8. OTP, chat, AI, notification | mock services, screens tương ứng | service/repository chuyên biệt (chat realtime nếu backend xác nhận) | Chỉ triển khai capability đã có; kiểm tra retry/idempotency/rate limits và privacy. Không gọi local heuristic là API AI. |
| 9. Tích hợp tổng thể | route guards, tất cả màn đã chuyển, platform config | tests integration/mocks nếu quy trình repo yêu cầu | Test role matrix, 401/403/404/409/500, offline/timeout, CORS, emulator/device/web, regression của import/local flows. |

Các package cần cân nhắc sau khi biết API: HTTP client và secure token storage; không thêm trong giai đoạn khảo sát. Có thể giữ model UI và tạo DTO riêng để tránh làm hỏng màn hình đang tiêu thụ dữ liệu mock. Chuyển từng workflow, không xóa mocks trước khi có phương án test/demo thay thế.

## 11. Rủi ro và điểm chưa xác minh

1. Không có backend source/OpenAPI nên mọi endpoint, request/response, auth, role policy, status code và CORS đều chưa xác minh. Comment endpoint trong hai màn sinh viên là ý tưởng, không phải hợp đồng.
2. Nếu giữ URL HTTP cần xem Android INTERNET/cleartext policy và iOS ATS; production cần HTTPS. Thiết bị thật không dùng localhost của máy phát triển.
3. Model UI có field password trong mock admin; không ánh xạ trường này vào log/API response/client production. Không đưa demo credentials vào tài liệu.
4. Role cục bộ và menu permission không có giá trị bảo mật nếu backend không kiểm tra claim/role. Kiểu role legacy hiện không có dashboard route.
5. Mutability/in-memory singleton và direct mock access trong widget gây khó test, stale screen và xung đột khi chuyển API; cần xác định nguồn dữ liệu chuẩn và refresh/invalidation.
6. Không có DTO JSON, chuẩn ngày/enum, nullability, phân trang hoặc error envelope. Chốt contract trước khi định nghĩa parser.
7. Import CSV/Excel có đường xử lý file local; backend upload cần giới hạn dung lượng, validation và báo lỗi từng dòng. Không giả định import hiện tại đã upload.
8. Chat/AI/avatar/notification chỉ có UI/local logic; khả năng backend hỗ trợ chưa biết.
9. Thư mục `ProGroup_AI.API` có artifacts build nhưng không có source; không đọc artifacts để suy luận schema/API.
10. README có conflict markers và nội dung template, không đáng tin làm hướng dẫn chạy.

## 12. Các vị trí quan trọng để tiếp tục

- Entry, theme, routes/settings: `lib/main.dart`, `lib/core/routes/app_routes.dart`, `lib/core/settings/app_settings.dart`, `lib/core/theme/app_theme.dart`.
- Auth mock: `lib/services/auth_service.dart`, `lib/services/mock_service.dart`, `lib/core/constants/app_constants.dart`.
- Data/model: `lib/data/mock/`, `lib/models/`.
- AI heuristic/template: `lib/services/ai_topic_recommendation_service.dart`, `lib/services/lecturer_topic_suggestion_service.dart`, `lib/services/ai_feedback_service.dart`.
- Dependency/platform: `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `web/index.html`.

## 13. Phạm vi và kiểm tra tài liệu

Đã khảo sát tĩnh **143/143 tệp Dart trong `lib/`** qua inventory và nội dung source theo nhóm core, model, mock, service, widget, màn hình/luồng; đọc cấu hình package, analyzer, README và manifest Android/iOS/Web. Có đối chiếu các dấu hiệu HTTP/navigation/mock và xác nhận số tệp. Không chạy app, build, analyzer hoặc test; không xác minh endpoint bằng mạng. `test/` có các bài widget/service nhưng không thực thi. Các artifact backend ngoài source (`ProGroup_AI.API/obj`) không được xem là tài liệu API. Những điều còn chưa xác minh được ghi rõ ở mục 9 và 11.

