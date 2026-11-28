# 03. BÁO CÁO ĐỐI CHIẾU TRẠNG THÁI CHI TIẾT (AUDIT STATUS)

Báo cáo đối chiếu chi tiết giữa trạng thái ban đầu ghi nhận trên Google Sheets và trạng thái thực tế sau kiểm thử code hiện tại:

| Mã TC | Sheet | Tính năng | Trạng thái cũ (Sheet) | Trạng thái Audit | Căn cứ xác nhận & Bằng chứng kỹ thuật |
|---|---|---|---|---|---|
| `TC_AUTH_001` | 2. Xác thực & Hệ thống | Đăng nhập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_002` | 2. Xác thực & Hệ thống | Đăng nhập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_003` | 2. Xác thực & Hệ thống | Đăng nhập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_004` | 2. Xác thực & Hệ thống | Đăng nhập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_005` | 2. Xác thực & Hệ thống | Đăng nhập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_006` | 2. Xác thực & Hệ thống | Validate form | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_007` | 2. Xác thực & Hệ thống | Validate form | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_008` | 2. Xác thực & Hệ thống | Validate form | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_009` | 2. Xác thực & Hệ thống | Xác thực sai | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_010` | 2. Xác thực & Hệ thống | Xác thực sai | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_011` | 2. Xác thực & Hệ thống | Bảo mật | Fail | **FIXED** | Backend AuthController trả HTTP 401 khi TrangThai == false ("Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động."). Frontend AuthService & LoginScreen re-throw ApiException và hiển thị SnackBar cảnh báo đỏ rõ ràng. |
| `TC_AUTH_012` | 2. Xác thực & Hệ thống | Bảo mật | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_013` | 2. Xác thực & Hệ thống | UI Đăng nhập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_014` | 2. Xác thực & Hệ thống | Lưu phiên | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_015` | 2. Xác thực & Hệ thống | Đăng xuất | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_016` | 2. Xác thực & Hệ thống | Mạng & Server | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_017` | 2. Xác thực & Hệ thống | Mạng & Server | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_018` | 2. Xác thực & Hệ thống | Mạng & Server | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_019` | 2. Xác thực & Hệ thống | UI Đăng nhập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_020` | 2. Xác thực & Hệ thống | Phím tắt Dev | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_021` | 2. Xác thực & Hệ thống | Cấu hình Server | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_022` | 2. Xác thực & Hệ thống | Giao diện | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_023` | 2. Xác thực & Hệ thống | Giao diện | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_024` | 2. Xác thực & Hệ thống | Đa ngôn ngữ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_025` | 2. Xác thực & Hệ thống | Cập nhật OTA | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_026` | 2. Xác thực & Hệ thống | Nhập liệu | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_027` | 2. Xác thực & Hệ thống | Chống Spam | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_AUTH_028` | 2. Xác thực & Hệ thống | Tự phục hồi | Fail | **FIXED** | Frontend ApiService được tái cấu trúc sử dụng persistent http.Client() với HTTP Keep-Alive, hỗ trợ AuthService.reAuthenticate() tự động làm mới token và phục hồi kết nối khi thiết bị có mạng trở lại mà không bị lỗi 403. |
| `TC_STU_001` | 3. Phân hệ Sinh viên | Trang chủ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_002` | 3. Phân hệ Sinh viên | Trang chủ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_003` | 3. Phân hệ Sinh viên | Trang chủ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_004` | 3. Phân hệ Sinh viên | Trang chủ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_005` | 3. Phân hệ Sinh viên | Lớp học phần | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_006` | 3. Phân hệ Sinh viên | Lớp học phần | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_007` | 3. Phân hệ Sinh viên | Lớp học phần | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_008` | 3. Phân hệ Sinh viên | Lớp học phần | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_009` | 3. Phân hệ Sinh viên | Quản lý nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_010` | 3. Phân hệ Sinh viên | Quản lý nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_011` | 3. Phân hệ Sinh viên | Quản lý nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_012` | 3. Phân hệ Sinh viên | Quản lý nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_013` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_014` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_015` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_016` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_017` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_018` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_019` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Fail | **FIXED** | Hệ thống đã chuẩn hóa số thành viên tối thiểu là 2 (từ DB schema MinMembers = 2 đến TopicDetailScreen và GroupsController). Nhóm 1 thành viên bị chặn và hiển thị rõ thông báo yêu cầu tối thiểu 2 thành viên. |
| `TC_STU_020` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_021` | 3. Phân hệ Sinh viên | Hủy đăng ký | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_022` | 3. Phân hệ Sinh viên | Hủy đăng ký | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_023` | 3. Phân hệ Sinh viên | Đề xuất đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_024` | 3. Phân hệ Sinh viên | Đề xuất đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_025` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Fail | **FIXED** | GroupProgressReportScreen hiển thị đầy đủ danh sách các cột mốc nộp báo cáo tiến độ đồ án với 3 trạng thái chuẩn: Chưa nộp, Đã nộp, Đã chấm kèm điểm số và nhận xét. |
| `TC_STU_026` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_027` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Fail | **FIXED** | GroupProgressReportScreen triển khai hàm kiểm tra định dạng URL _isValidUrl(url) bắt buộc giao thức http:// hoặc https:// và định dạng domain hợp lệ trước khi cho phép nộp link báo cáo. |
| `TC_STU_028` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_029` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_030` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_031` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_032` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Fail | **FIXED** | AiTopicScreen và ChatScreen bọc toàn bộ lời gọi Gemini AI trong khối try-catch SocketException/TimeoutException, hiển thị thông báo lỗi thân thiện và nút Thử lại trực quan mà không gây crash app. |
| `TC_STU_033` | 3. Phân hệ Sinh viên | Thông báo | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_034` | 3. Phân hệ Sinh viên | Thông báo | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_035` | 3. Phân hệ Sinh viên | Thông báo | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_036` | 3. Phân hệ Sinh viên | Hồ sơ cá nhân | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_037` | 3. Phân hệ Sinh viên | Hồ sơ cá nhân | Pass | **FIXED** | ProfileScreen sinh viên đã được bổ sung hàng Số điện thoại liên hệ kèm dialog cập nhật gọi trực tiếp API PUT /api/profile đồng bộ với CSDL SQL Server. |
| `TC_STU_038` | 3. Phân hệ Sinh viên | Avatar cá nhân | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_039` | 3. Phân hệ Sinh viên | Chống Spam | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_040` | 3. Phân hệ Sinh viên | Avatar cá nhân | Untested | **FIXED** | ProfileAvatarPickerHelper và ProfileController đã thiết lập bộ lọc kiểm tra đuôi ảnh (JPG, PNG, WEBP) và chặn ảnh vượt quá giới hạn 10MB trước khi mã hóa Base64 và tải lên server. |
| `TC_STU_041` | 3. Phân hệ Sinh viên | Avatar cá nhân | Fail | **FIXED** | AvatarService.saveAvatar bọc gọi API trong try-catch, tự động rollback về avatar cũ nếu mất mạng hoặc lỗi máy chủ, bảo đảm dữ liệu UI và SharedPreferences không bị lỗi thời. |
| `TC_STU_042` | 3. Phân hệ Sinh viên | Push Notification | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_043` | 3. Phân hệ Sinh viên | Tìm kiếm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_044` | 3. Phân hệ Sinh viên | Trợ lý AI | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_045` | 3. Phân hệ Sinh viên | Chat nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_046` | 3. Phân hệ Sinh viên | Chat nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_047` | 3. Phân hệ Sinh viên | Chat nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_048` | 3. Phân hệ Sinh viên | Chat nhóm | Fail | **FIXED** | ChatScreen thiết lập Firebase Realtime Stream kết hợp Polling Fallback 3 giây tự động cập nhật tin nhắn mới mà không cần thao tác vuốt refresh. |
| `TC_STU_049` | 3. Phân hệ Sinh viên | Chat nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_050` | 3. Phân hệ Sinh viên | Chat nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_051` | 3. Phân hệ Sinh viên | Chat nhóm | Fail | **FIXED** | Thẻ Join Request Card trong ChatScreen đã liên kết đúng endpoint GroupsController /api/groups/{id}/join-requests và /join-requests/{requestId}, giải quyết triệt để lỗi 404. |
| `TC_STU_052` | 3. Phân hệ Sinh viên | Chat nhóm | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_053` | 3. Phân hệ Sinh viên | Chat nhóm | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_054` | 3. Phân hệ Sinh viên | Chat nhóm | Fail | **FIXED** | ChatScreen trang bị SQLite/In-memory message caching, cho phép lưu trữ tin nhắn tạm thời khi thiết bị offline và tự động gửi lại khi có mạng. |
| `TC_STU_055` | 3. Phân hệ Sinh viên | Chat nhóm | Fail | **FIXED** | ChatScreen triển khai Timer định kỳ 60s làm mới nhãn thời gian tương đối (Vừa xong -> 1 phút trước -> 5 phút trước) chính xác theo thời gian thực. |
| `TC_STU_056` | 3. Phân hệ Sinh viên | Chat nhóm | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_STU_057` | 3. Phân hệ Sinh viên | Chat nhóm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_001` | 4. Phân hệ Giảng viên | Trang chủ GV | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_002` | 4. Phân hệ Giảng viên | Lớp học phần | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_003` | 4. Phân hệ Giảng viên | Chi tiết LHP | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_004` | 4. Phân hệ Giảng viên | Chi tiết LHP | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_005` | 4. Phân hệ Giảng viên | Tạo đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_006` | 4. Phân hệ Giảng viên | Validate đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_007` | 4. Phân hệ Giảng viên | Sửa đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_008` | 4. Phân hệ Giảng viên | Sửa đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_009` | 4. Phân hệ Giảng viên | Xóa đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_010` | 4. Phân hệ Giảng viên | Xóa đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_011` | 4. Phân hệ Giảng viên | Duyệt đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_012` | 4. Phân hệ Giảng viên | Từ chối đề tài | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_013` | 4. Phân hệ Giảng viên | Duyệt đề xuất | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_014` | 4. Phân hệ Giảng viên | Duyệt đề xuất | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_015` | 4. Phân hệ Giảng viên | Từ chối đề xuất | Fail | **FIXED** | LecturerTopicProposalScreen và NotificationService đã bổ sung trường LyDoTuChoi khi từ chối đề xuất, hiển thị đầy đủ góp ý của giảng viên trong thông báo của sinh viên. |
| `TC_LEC_016` | 4. Phân hệ Giảng viên | Chấm báo cáo | Fail | **FIXED** | LecturerReviewReportsScreen hiển thị danh sách các nhóm nộp báo cáo kèm chip ActionChip đính kèm fileUrl, GitHub repo và Demo URL có thể xem và sao chép liên kết. |
| `TC_LEC_017` | 4. Phân hệ Giảng viên | Chấm báo cáo | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_018` | 4. Phân hệ Giảng viên | Validate điểm | Fail | **FIXED** | LecturerReviewReportsScreen tích hợp TextInputFormatter chặn nhập điểm ngoài khoảng 0.0 - 10.0, đồng thời Backend BaoCaoTienDoController xác thực [Range(0.0, 10.0)]. |
| `TC_LEC_019` | 4. Phân hệ Giảng viên | Mở đợt đăng ký | Fail | **FIXED** | LecturerCourseSettingsScreen đã đồng bộ logic thời gian giữa đợt lập nhóm và đợt đăng ký đề tài, bảo đảm thời hạn đăng ký đề tài diễn ra sau hoặc trùng khớp với thời gian hoàn tất nhóm. |
| `TC_LEC_020` | 4. Phân hệ Giảng viên | Validate đợt | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_021` | 4. Phân hệ Giảng viên | Đóng đợt | Fail | **FIXED** | Khi đợt đăng ký chuyển sang "Đã đóng", DotDangKyDoAns cập nhật TrangThai = "Đã đóng", API khóa quyền đăng ký và toàn bộ sinh viên đều thấy trạng thái Đã đóng. |
| `TC_LEC_022` | 4. Phân hệ Giảng viên | AI Hỗ trợ GV | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_023` | 4. Phân hệ Giảng viên | Thống kê LHP | Fail | **FIXED** | LecturerStatisticsScreen tính toán tỷ lệ hoàn thành đăng ký dựa trên tổng số nhóm thực tế trong LHP (soNhomCoDeTai / tongSoNhom * 100), không còn mặc định 100% khi chỉ có 1 nhóm. |
| `TC_LEC_024` | 4. Phân hệ Giảng viên | Thông báo GV | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_025` | 4. Phân hệ Giảng viên | Hồ sơ Giảng viên | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_026` | 4. Phân hệ Giảng viên | Đồng thời | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_027` | 4. Phân hệ Giảng viên | Validate đợt | Fail | **FIXED** | LecturerCourseSettingsScreen và LecturerCourseDetailScreen đặt firstDate: DateTime.now() trong showDatePicker và kiểm tra _groupStart.isBefore(today), chặn hoàn toàn chọn ngày bắt đầu trong quá khứ. |
| `TC_LEC_028` | 4. Phân hệ Giảng viên | Chấm báo cáo | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_029` | 4. Phân hệ Giảng viên | Bộ lọc đề tài | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_LEC_030` | 4. Phân hệ Giảng viên | Export bảng điểm | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_001` | 5. Giáo vụ khoa | Dashboard Khoa | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_002` | 5. Giáo vụ khoa | Dashboard Khoa | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_003` | 5. Giáo vụ khoa | Quản lý LHP | Fail | **FIXED** | GovernanceCourseScreen gọi API /api/governance/courses tải toàn bộ danh mục lớp học phần thuộc khoa quản lý, hỗ trợ phân trang và tìm kiếm. |
| `TC_GVK_004` | 5. Giáo vụ khoa | Tìm kiếm LHP | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_005` | 5. Giáo vụ khoa | Lọc LHP | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_006` | 5. Giáo vụ khoa | Chi tiết LHP | Fail | **FIXED** | GovernanceCourseDetailScreen hiển thị danh sách sinh viên ghi danh, danh sách các nhóm đã thành lập và đề tài tương ứng của từng nhóm. |
| `TC_GVK_007` | 5. Giáo vụ khoa | Phân công GV | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_008` | 5. Giáo vụ khoa | Phân công GV | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_009` | 5. Giáo vụ khoa | Đổi phân công | Fail | **FIXED** | GovernanceAssignmentScreen đã liên kết đúng endpoint PUT /api/governance/classes/{id}/assign-lecturer, cập nhật Giảng viên phụ trách và làm mới trạng thái hiển thị ngay lập tức. |
| `TC_GVK_010` | 5. Giáo vụ khoa | Hủy phân công | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_011` | 5. Giáo vụ khoa | Đồng bộ GV | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_012` | 5. Giáo vụ khoa | Giám sát đăng ký | Fail | **FIXED** | GovernanceRegistrationOverviewScreen thống kê tổng quan toàn khoa: số nhóm có đề tài, số nhóm chưa có đề tài, tỷ lệ duyệt đề tài và cảnh báo sinh viên chưa có nhóm. |
| `TC_GVK_013` | 5. Giáo vụ khoa | Thống kê đề tài | Fail | **NOT FIXED** | Báo cáo danh mục đề tài phân rã theo Bộ môn chuyên ngành (Chưa có phân cấp Bộ môn trong CSDL). |
| `TC_GVK_014` | 5. Giáo vụ khoa | Danh sách SV | Fail | **NOT FIXED** | Màn hình tra cứu tập trung toàn bộ sinh viên toàn khoa (Hiện tại tra cứu theo từng Lớp học phần). |
| `TC_GVK_015` | 5. Giáo vụ khoa | Tìm kiếm SV | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_016` | 5. Giáo vụ khoa | Lọc Khóa SV | Fail | **NOT FIXED** | Bộ lọc sinh viên theo Khóa niên chế K20, K21, K22 (Chưa bổ sung cột NienKhoa trong bảng SinhViens). |
| `TC_GVK_017` | 5. Giáo vụ khoa | Danh sách GV | Fail | **FIXED** | GovernanceLecturerScreen đồng bộ chuẩn hóa trường HocVi và ChuyenMon từ bảng GiangViens, hiển thị chính xác thông tin chuyên môn giảng viên. |
| `TC_GVK_018` | 5. Giáo vụ khoa | Tìm kiếm GV | Fail | **FIXED** | GovernanceLecturerScreen tích hợp thanh tìm kiếm SearchBar theo cả Tên giảng viên và Chuyên môn nghiên cứu đa tiêu chí. |
| `TC_GVK_019` | 5. Giáo vụ khoa | AI Phân tích | Fail | **NOT FIXED** | Tính năng AI Gemini phân tích khối lượng học vụ giáo vụ khoa (Module AI nâng cao nằm ngoài phạm vi sprint hiện tại). |
| `TC_GVK_020` | 5. Giáo vụ khoa | AI Phân tích | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_021` | 5. Giáo vụ khoa | Cảnh báo trễ hạn | Fail | **NOT FIXED** | Màn hình nhắc nhở các nhóm chưa nộp báo cáo tiến độ toàn khoa (Hiện tại do Giảng viên quản lý trực tiếp). |
| `TC_GVK_022` | 5. Giáo vụ khoa | Thông báo Khoa | Fail | **NOT FIXED** | Hệ thống thông báo đẩy tự động khi bổ sung giảng viên mới vào khoa (Chưa tích hợp event bus thông báo này). |
| `TC_GVK_023` | 5. Giáo vụ khoa | Hồ sơ Giáo vụ | Fail | **FIXED** | GovernanceProfileScreen đã hiển thị trường Số điện thoại và cung cấp dialog cập nhật số điện thoại gọi PUT /api/profile. |
| `TC_GVK_024` | 5. Giáo vụ khoa | Avatar Giáo vụ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_GVK_025` | 5. Giáo vụ khoa | Bảo mật Khoa | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_PDT_001` | 6. Phòng đào tạo | Dashboard Toàn trường | Fail | **FIXED** | TrainingOverviewScreen hiển thị số liệu toàn trường (liên khoa): Tổng số khoa, Tổng số sinh viên làm đồ án, Tổng số đề tài được duyệt, Tỷ lệ hoàn thành đồ án. |
| `TC_PDT_002` | 6. Phòng đào tạo | Dashboard Toàn trường | Fail | **NOT FIXED** | Biểu đồ trực quan so sánh số lượng đồ án giữa các Khoa (Cần bổ sung component BarChart liên khoa). |
| `TC_PDT_003` | 6. Phòng đào tạo | Dashboard Toàn trường | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_PDT_004` | 6. Phòng đào tạo | Cấu hình Học kỳ | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_PDT_005` | 6. Phòng đào tạo | Cấu hình Học kỳ | Fail | **NOT FIXED** | Giao diện chuyển đổi Học kỳ hiện tại (Active Semester) trên Mobile (Hiện cấu hình qua SQL Script). |
| `TC_PDT_006` | 6. Phòng đào tạo | Khung thời gian | Fail | **NOT FIXED** | Khung thời gian kế hoạch đồ án toàn trường (Timeline Gantt chart liên khoa). |
| `TC_PDT_007` | 6. Phòng đào tạo | Quản lý LHP cấp trường | Fail | **FIXED** | TrainingDataManagementScreen hiển thị danh mục tất cả LHP toàn trường, lọc theo Khoa và hiển thị chính xác tên giảng viên phụ trách từ CSDL. |
| `TC_PDT_008` | 6. Phòng đào tạo | Lọc LHP theo Khoa | Fail | **FIXED** | TrainingDataManagementScreen tích hợp DropdownFilter lọc danh sách LHP theo từng Khoa cụ thể. |
| `TC_PDT_009` | 6. Phòng đào tạo | Giám sát tiến độ | Fail | **NOT FIXED** | Danh sách giám sát riêng các LHP chưa mở đợt đăng ký (Hiện xem gộp chung trong danh mục LHP). |
| `TC_PDT_010` | 6. Phòng đào tạo | Giám sát tiến độ | Fail | **NOT FIXED** | Dashboard phân tích chuyên sâu tỷ lệ hoàn thành đồ án toàn trường theo từng đợt. |
| `TC_PDT_011` | 6. Phòng đào tạo | AI Dự báo đào tạo | Fail | **NOT FIXED** | AI Gemini dự báo nhu cầu đào tạo và đồ án cho Phòng Đào tạo. |
| `TC_PDT_012` | 6. Phòng đào tạo | AI Dự báo công nghệ | Fail | **NOT FIXED** | AI Gemini phân tích xu hướng đề tài sinh viên quan tâm (Data Mining). |
| `TC_PDT_013` | 6. Phòng đào tạo | AI Dự báo lỗi mạng | Fail | **NOT FIXED** | Xử lý ngoại lệ kết nối mạng cho module AI Phòng đào tạo. |
| `TC_PDT_014` | 6. Phòng đào tạo | Toàn vẹn dữ liệu | Fail | **NOT FIXED** | Bộ lọc kiểm tra sinh viên mồ côi (chưa thuộc khoa nào) trên giao diện mobile. |
| `TC_PDT_015` | 6. Phòng đào tạo | Quyền hạn độc lập | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_PDT_016` | 6. Phòng đào tạo | Báo cáo tổng kết | Fail | **NOT FIXED** | Biểu đồ thống kê phổ điểm đồ án toàn trường (Grade Distribution Chart cho PDT). |
| `TC_PDT_017` | 6. Phòng đào tạo | Thông báo Đào tạo | Fail | **NOT FIXED** | Thông báo đẩy tự động tới PDT khi có đợt đăng ký mới kích hoạt. |
| `TC_PDT_018` | 6. Phòng đào tạo | Hồ sơ Đào tạo | Fail | **FIXED** | TrainingProfileScreen hiển thị thông tin cán bộ Phòng Đào tạo kèm tính năng cập nhật Số điện thoại qua dialog và API PUT /api/profile. |
| `TC_PDT_019` | 6. Phòng đào tạo | Avatar Đào tạo | Fail | **FIXED** | AvatarService và UserAvatarView đã cô lập bộ nhớ đệm avatar theo username của tài khoản đang đăng nhập, chấm dứt hoàn toàn hiện tượng rò rỉ avatar giữa Giáo vụ khoa và Phòng đào tạo. |
| `TC_PDT_020` | 6. Phòng đào tạo | Bảo mật Đào tạo | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_001` | 7. Quản trị hệ thống | Dashboard Admin | Fail | **FIXED** | AdminOverviewScreen trích xuất chính xác tổng số tài khoản, sinh viên, giảng viên, lớp học phần từ endpoint /api/admin/overview và danh sách người dùng thực tế. |
| `TC_ADM_002` | 7. Quản trị hệ thống | Biểu đồ vai trò | Fail | **FIXED** | AdminOverviewScreen đã chuẩn hóa cơ chế đếm vai trò theo các mã vai trò maVaiTro và tenVaiTro, tính toán chính xác tỷ lệ phần trăm phân bổ 5 vai trò trên biểu đồ Stacked Bar Chart đạt chuẩn 100%. |
| `TC_ADM_003` | 7. Quản trị hệ thống | Danh sách User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_004` | 7. Quản trị hệ thống | Tìm kiếm User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_005` | 7. Quản trị hệ thống | Lọc vai trò | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_006` | 7. Quản trị hệ thống | Thêm User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_007` | 7. Quản trị hệ thống | Validate User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_008` | 7. Quản trị hệ thống | Validate User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_009` | 7. Quản trị hệ thống | Khóa tài khoản | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_010` | 7. Quản trị hệ thống | Mở khóa User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_011` | 7. Quản trị hệ thống | Reset mật khẩu | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_012` | 7. Quản trị hệ thống | Import User | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_013` | 7. Quản trị hệ thống | Import User | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_014` | 7. Quản trị hệ thống | Import User | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_015` | 7. Quản trị hệ thống | Import User | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_016` | 7. Quản trị hệ thống | Import User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_017` | 7. Quản trị hệ thống | Import User | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_018` | 7. Quản trị hệ thống | Nhật ký hệ thống | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_019` | 7. Quản trị hệ thống | Validate SĐT | Fail | **FIXED** | AdminUserFormScreen áp dụng FilteringTextInputFormatter.digitsOnly, giới hạn độ dài 10-11 ký tự, và Backend AdminController xác thực Regex ^[0-9]{10,11}$ ngăn chặn số điện thoại sai định dạng. |
| `TC_ADM_020` | 7. Quản trị hệ thống | Import User | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_021` | 7. Quản trị hệ thống | Import User | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_022` | 7. Quản trị hệ thống | Đổi Vai trò | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_023` | 7. Quản trị hệ thống | Xóa tài khoản | Untested | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_ADM_024` | 7. Quản trị hệ thống | Tìm kiếm nâng cao | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_001` | 8. Phi chức năng & Bảo mật | Bảo mật API | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_002` | 8. Phi chức năng & Bảo mật | Bảo mật Token | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_003` | 8. Phi chức năng & Bảo mật | Phân quyền RBAC | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_004` | 8. Phi chức năng & Bảo mật | Phân quyền RBAC | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_005` | 8. Phi chức năng & Bảo mật | Xử lý mất mạng | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_006` | 8. Phi chức năng & Bảo mật | Hiệu năng USB | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_007` | 8. Phi chức năng & Bảo mật | Hiệu năng Wi-Fi | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_008` | 8. Phi chức năng & Bảo mật | Responsive UI | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_009` | 8. Phi chức năng & Bảo mật | Xoay màn hình | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_010` | 8. Phi chức năng & Bảo mật | Sao lưu CSDL | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_011` | 8. Phi chức năng & Bảo mật | Khôi phục CSDL | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_012` | 8. Phi chức năng & Bảo mật | Bảo mật Avatar | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_013` | 8. Phi chức năng & Bảo mật | Bàn phím ảo | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_014` | 8. Phi chức năng & Bảo mật | Cử chỉ Back | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_015` | 8. Phi chức năng & Bảo mật | Bộ nhớ & RAM | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| `TC_NFR_016` | 8. Phi chức năng & Bảo mật | Khôi phục State | Pass | **FIXED** | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
