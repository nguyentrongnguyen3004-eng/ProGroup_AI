# 04. DANH SÁCH TEST CASE ĐÃ ĐƯỢC KHẮC PHỤC HOÀN TOÀN (FIXED: 183 TCs)

| STT | Mã TC | Sheet | Tính năng | Giải pháp khắc phục & Minh chứng kiểm thử |
|---|---|---|---|---|
| 1 | `TC_AUTH_001` | 2. Xác thực & Hệ thống | Đăng nhập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 2 | `TC_AUTH_002` | 2. Xác thực & Hệ thống | Đăng nhập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 3 | `TC_AUTH_003` | 2. Xác thực & Hệ thống | Đăng nhập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 4 | `TC_AUTH_004` | 2. Xác thực & Hệ thống | Đăng nhập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 5 | `TC_AUTH_005` | 2. Xác thực & Hệ thống | Đăng nhập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 6 | `TC_AUTH_006` | 2. Xác thực & Hệ thống | Validate form | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 7 | `TC_AUTH_007` | 2. Xác thực & Hệ thống | Validate form | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 8 | `TC_AUTH_008` | 2. Xác thực & Hệ thống | Validate form | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 9 | `TC_AUTH_009` | 2. Xác thực & Hệ thống | Xác thực sai | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 10 | `TC_AUTH_010` | 2. Xác thực & Hệ thống | Xác thực sai | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 11 | `TC_AUTH_011` | 2. Xác thực & Hệ thống | Bảo mật | Backend AuthController trả HTTP 401 khi TrangThai == false ("Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động."). Frontend AuthService & LoginScreen re-throw ApiException và hiển thị SnackBar cảnh báo đỏ rõ ràng. |
| 12 | `TC_AUTH_012` | 2. Xác thực & Hệ thống | Bảo mật | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 13 | `TC_AUTH_013` | 2. Xác thực & Hệ thống | UI Đăng nhập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 14 | `TC_AUTH_014` | 2. Xác thực & Hệ thống | Lưu phiên | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 15 | `TC_AUTH_015` | 2. Xác thực & Hệ thống | Đăng xuất | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 16 | `TC_AUTH_016` | 2. Xác thực & Hệ thống | Mạng & Server | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 17 | `TC_AUTH_017` | 2. Xác thực & Hệ thống | Mạng & Server | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 18 | `TC_AUTH_018` | 2. Xác thực & Hệ thống | Mạng & Server | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 19 | `TC_AUTH_019` | 2. Xác thực & Hệ thống | UI Đăng nhập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 20 | `TC_AUTH_020` | 2. Xác thực & Hệ thống | Phím tắt Dev | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 21 | `TC_AUTH_021` | 2. Xác thực & Hệ thống | Cấu hình Server | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 22 | `TC_AUTH_022` | 2. Xác thực & Hệ thống | Giao diện | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 23 | `TC_AUTH_023` | 2. Xác thực & Hệ thống | Giao diện | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 24 | `TC_AUTH_024` | 2. Xác thực & Hệ thống | Đa ngôn ngữ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 25 | `TC_AUTH_025` | 2. Xác thực & Hệ thống | Cập nhật OTA | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 26 | `TC_AUTH_026` | 2. Xác thực & Hệ thống | Nhập liệu | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 27 | `TC_AUTH_027` | 2. Xác thực & Hệ thống | Chống Spam | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 28 | `TC_AUTH_028` | 2. Xác thực & Hệ thống | Tự phục hồi | Frontend ApiService được tái cấu trúc sử dụng persistent http.Client() với HTTP Keep-Alive, hỗ trợ AuthService.reAuthenticate() tự động làm mới token và phục hồi kết nối khi thiết bị có mạng trở lại mà không bị lỗi 403. |
| 29 | `TC_STU_001` | 3. Phân hệ Sinh viên | Trang chủ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 30 | `TC_STU_002` | 3. Phân hệ Sinh viên | Trang chủ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 31 | `TC_STU_003` | 3. Phân hệ Sinh viên | Trang chủ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 32 | `TC_STU_004` | 3. Phân hệ Sinh viên | Trang chủ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 33 | `TC_STU_005` | 3. Phân hệ Sinh viên | Lớp học phần | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 34 | `TC_STU_006` | 3. Phân hệ Sinh viên | Lớp học phần | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 35 | `TC_STU_007` | 3. Phân hệ Sinh viên | Lớp học phần | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 36 | `TC_STU_008` | 3. Phân hệ Sinh viên | Lớp học phần | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 37 | `TC_STU_009` | 3. Phân hệ Sinh viên | Quản lý nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 38 | `TC_STU_010` | 3. Phân hệ Sinh viên | Quản lý nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 39 | `TC_STU_011` | 3. Phân hệ Sinh viên | Quản lý nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 40 | `TC_STU_012` | 3. Phân hệ Sinh viên | Quản lý nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 41 | `TC_STU_013` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 42 | `TC_STU_014` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 43 | `TC_STU_015` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 44 | `TC_STU_016` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 45 | `TC_STU_017` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 46 | `TC_STU_018` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 47 | `TC_STU_019` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Hệ thống đã chuẩn hóa số thành viên tối thiểu là 2 (từ DB schema MinMembers = 2 đến TopicDetailScreen và GroupsController). Nhóm 1 thành viên bị chặn và hiển thị rõ thông báo yêu cầu tối thiểu 2 thành viên. |
| 48 | `TC_STU_020` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 49 | `TC_STU_021` | 3. Phân hệ Sinh viên | Hủy đăng ký | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 50 | `TC_STU_022` | 3. Phân hệ Sinh viên | Hủy đăng ký | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 51 | `TC_STU_023` | 3. Phân hệ Sinh viên | Đề xuất đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 52 | `TC_STU_024` | 3. Phân hệ Sinh viên | Đề xuất đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 53 | `TC_STU_025` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | GroupProgressReportScreen hiển thị đầy đủ danh sách các cột mốc nộp báo cáo tiến độ đồ án với 3 trạng thái chuẩn: Chưa nộp, Đã nộp, Đã chấm kèm điểm số và nhận xét. |
| 54 | `TC_STU_026` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 55 | `TC_STU_027` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | GroupProgressReportScreen triển khai hàm kiểm tra định dạng URL _isValidUrl(url) bắt buộc giao thức http:// hoặc https:// và định dạng domain hợp lệ trước khi cho phép nộp link báo cáo. |
| 56 | `TC_STU_028` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 57 | `TC_STU_029` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 58 | `TC_STU_030` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 59 | `TC_STU_031` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 60 | `TC_STU_032` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | AiTopicScreen và ChatScreen bọc toàn bộ lời gọi Gemini AI trong khối try-catch SocketException/TimeoutException, hiển thị thông báo lỗi thân thiện và nút Thử lại trực quan mà không gây crash app. |
| 61 | `TC_STU_033` | 3. Phân hệ Sinh viên | Thông báo | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 62 | `TC_STU_034` | 3. Phân hệ Sinh viên | Thông báo | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 63 | `TC_STU_035` | 3. Phân hệ Sinh viên | Thông báo | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 64 | `TC_STU_036` | 3. Phân hệ Sinh viên | Hồ sơ cá nhân | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 65 | `TC_STU_037` | 3. Phân hệ Sinh viên | Hồ sơ cá nhân | ProfileScreen sinh viên đã được bổ sung hàng Số điện thoại liên hệ kèm dialog cập nhật gọi trực tiếp API PUT /api/profile đồng bộ với CSDL SQL Server. |
| 66 | `TC_STU_038` | 3. Phân hệ Sinh viên | Avatar cá nhân | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 67 | `TC_STU_039` | 3. Phân hệ Sinh viên | Chống Spam | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 68 | `TC_STU_040` | 3. Phân hệ Sinh viên | Avatar cá nhân | ProfileAvatarPickerHelper và ProfileController đã thiết lập bộ lọc kiểm tra đuôi ảnh (JPG, PNG, WEBP) và chặn ảnh vượt quá giới hạn 10MB trước khi mã hóa Base64 và tải lên server. |
| 69 | `TC_STU_041` | 3. Phân hệ Sinh viên | Avatar cá nhân | AvatarService.saveAvatar bọc gọi API trong try-catch, tự động rollback về avatar cũ nếu mất mạng hoặc lỗi máy chủ, bảo đảm dữ liệu UI và SharedPreferences không bị lỗi thời. |
| 70 | `TC_STU_042` | 3. Phân hệ Sinh viên | Push Notification | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 71 | `TC_STU_043` | 3. Phân hệ Sinh viên | Tìm kiếm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 72 | `TC_STU_044` | 3. Phân hệ Sinh viên | Trợ lý AI | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 73 | `TC_STU_045` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 74 | `TC_STU_046` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 75 | `TC_STU_047` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 76 | `TC_STU_048` | 3. Phân hệ Sinh viên | Chat nhóm | ChatScreen thiết lập Firebase Realtime Stream kết hợp Polling Fallback 3 giây tự động cập nhật tin nhắn mới mà không cần thao tác vuốt refresh. |
| 77 | `TC_STU_049` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 78 | `TC_STU_050` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 79 | `TC_STU_051` | 3. Phân hệ Sinh viên | Chat nhóm | Thẻ Join Request Card trong ChatScreen đã liên kết đúng endpoint GroupsController /api/groups/{id}/join-requests và /join-requests/{requestId}, giải quyết triệt để lỗi 404. |
| 80 | `TC_STU_052` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 81 | `TC_STU_053` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 82 | `TC_STU_054` | 3. Phân hệ Sinh viên | Chat nhóm | ChatScreen trang bị SQLite/In-memory message caching, cho phép lưu trữ tin nhắn tạm thời khi thiết bị offline và tự động gửi lại khi có mạng. |
| 83 | `TC_STU_055` | 3. Phân hệ Sinh viên | Chat nhóm | ChatScreen triển khai Timer định kỳ 60s làm mới nhãn thời gian tương đối (Vừa xong -> 1 phút trước -> 5 phút trước) chính xác theo thời gian thực. |
| 84 | `TC_STU_056` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 85 | `TC_STU_057` | 3. Phân hệ Sinh viên | Chat nhóm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 86 | `TC_LEC_001` | 4. Phân hệ Giảng viên | Trang chủ GV | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 87 | `TC_LEC_002` | 4. Phân hệ Giảng viên | Lớp học phần | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 88 | `TC_LEC_003` | 4. Phân hệ Giảng viên | Chi tiết LHP | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 89 | `TC_LEC_004` | 4. Phân hệ Giảng viên | Chi tiết LHP | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 90 | `TC_LEC_005` | 4. Phân hệ Giảng viên | Tạo đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 91 | `TC_LEC_006` | 4. Phân hệ Giảng viên | Validate đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 92 | `TC_LEC_007` | 4. Phân hệ Giảng viên | Sửa đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 93 | `TC_LEC_008` | 4. Phân hệ Giảng viên | Sửa đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 94 | `TC_LEC_009` | 4. Phân hệ Giảng viên | Xóa đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 95 | `TC_LEC_010` | 4. Phân hệ Giảng viên | Xóa đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 96 | `TC_LEC_011` | 4. Phân hệ Giảng viên | Duyệt đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 97 | `TC_LEC_012` | 4. Phân hệ Giảng viên | Từ chối đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 98 | `TC_LEC_013` | 4. Phân hệ Giảng viên | Duyệt đề xuất | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 99 | `TC_LEC_014` | 4. Phân hệ Giảng viên | Duyệt đề xuất | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 100 | `TC_LEC_015` | 4. Phân hệ Giảng viên | Từ chối đề xuất | LecturerTopicProposalScreen và NotificationService đã bổ sung trường LyDoTuChoi khi từ chối đề xuất, hiển thị đầy đủ góp ý của giảng viên trong thông báo của sinh viên. |
| 101 | `TC_LEC_016` | 4. Phân hệ Giảng viên | Chấm báo cáo | LecturerReviewReportsScreen hiển thị danh sách các nhóm nộp báo cáo kèm chip ActionChip đính kèm fileUrl, GitHub repo và Demo URL có thể xem và sao chép liên kết. |
| 102 | `TC_LEC_017` | 4. Phân hệ Giảng viên | Chấm báo cáo | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 103 | `TC_LEC_018` | 4. Phân hệ Giảng viên | Validate điểm | LecturerReviewReportsScreen tích hợp TextInputFormatter chặn nhập điểm ngoài khoảng 0.0 - 10.0, đồng thời Backend BaoCaoTienDoController xác thực [Range(0.0, 10.0)]. |
| 104 | `TC_LEC_019` | 4. Phân hệ Giảng viên | Mở đợt đăng ký | LecturerCourseSettingsScreen đã đồng bộ logic thời gian giữa đợt lập nhóm và đợt đăng ký đề tài, bảo đảm thời hạn đăng ký đề tài diễn ra sau hoặc trùng khớp với thời gian hoàn tất nhóm. |
| 105 | `TC_LEC_020` | 4. Phân hệ Giảng viên | Validate đợt | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 106 | `TC_LEC_021` | 4. Phân hệ Giảng viên | Đóng đợt | Khi đợt đăng ký chuyển sang "Đã đóng", DotDangKyDoAns cập nhật TrangThai = "Đã đóng", API khóa quyền đăng ký và toàn bộ sinh viên đều thấy trạng thái Đã đóng. |
| 107 | `TC_LEC_022` | 4. Phân hệ Giảng viên | AI Hỗ trợ GV | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 108 | `TC_LEC_023` | 4. Phân hệ Giảng viên | Thống kê LHP | LecturerStatisticsScreen tính toán tỷ lệ hoàn thành đăng ký dựa trên tổng số nhóm thực tế trong LHP (soNhomCoDeTai / tongSoNhom * 100), không còn mặc định 100% khi chỉ có 1 nhóm. |
| 109 | `TC_LEC_024` | 4. Phân hệ Giảng viên | Thông báo GV | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 110 | `TC_LEC_025` | 4. Phân hệ Giảng viên | Hồ sơ Giảng viên | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 111 | `TC_LEC_026` | 4. Phân hệ Giảng viên | Đồng thời | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 112 | `TC_LEC_027` | 4. Phân hệ Giảng viên | Validate đợt | LecturerCourseSettingsScreen và LecturerCourseDetailScreen đặt firstDate: DateTime.now() trong showDatePicker và kiểm tra _groupStart.isBefore(today), chặn hoàn toàn chọn ngày bắt đầu trong quá khứ. |
| 113 | `TC_LEC_028` | 4. Phân hệ Giảng viên | Chấm báo cáo | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 114 | `TC_LEC_029` | 4. Phân hệ Giảng viên | Bộ lọc đề tài | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 115 | `TC_LEC_030` | 4. Phân hệ Giảng viên | Export bảng điểm | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 116 | `TC_GVK_001` | 5. Giáo vụ khoa | Dashboard Khoa | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 117 | `TC_GVK_002` | 5. Giáo vụ khoa | Dashboard Khoa | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 118 | `TC_GVK_003` | 5. Giáo vụ khoa | Quản lý LHP | GovernanceCourseScreen gọi API /api/governance/courses tải toàn bộ danh mục lớp học phần thuộc khoa quản lý, hỗ trợ phân trang và tìm kiếm. |
| 119 | `TC_GVK_004` | 5. Giáo vụ khoa | Tìm kiếm LHP | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 120 | `TC_GVK_005` | 5. Giáo vụ khoa | Lọc LHP | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 121 | `TC_GVK_006` | 5. Giáo vụ khoa | Chi tiết LHP | GovernanceCourseDetailScreen hiển thị danh sách sinh viên ghi danh, danh sách các nhóm đã thành lập và đề tài tương ứng của từng nhóm. |
| 122 | `TC_GVK_007` | 5. Giáo vụ khoa | Phân công GV | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 123 | `TC_GVK_008` | 5. Giáo vụ khoa | Phân công GV | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 124 | `TC_GVK_009` | 5. Giáo vụ khoa | Đổi phân công | GovernanceAssignmentScreen đã liên kết đúng endpoint PUT /api/governance/classes/{id}/assign-lecturer, cập nhật Giảng viên phụ trách và làm mới trạng thái hiển thị ngay lập tức. |
| 125 | `TC_GVK_010` | 5. Giáo vụ khoa | Hủy phân công | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 126 | `TC_GVK_011` | 5. Giáo vụ khoa | Đồng bộ GV | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 127 | `TC_GVK_012` | 5. Giáo vụ khoa | Giám sát đăng ký | GovernanceRegistrationOverviewScreen thống kê tổng quan toàn khoa: số nhóm có đề tài, số nhóm chưa có đề tài, tỷ lệ duyệt đề tài và cảnh báo sinh viên chưa có nhóm. |
| 128 | `TC_GVK_015` | 5. Giáo vụ khoa | Tìm kiếm SV | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 129 | `TC_GVK_017` | 5. Giáo vụ khoa | Danh sách GV | GovernanceLecturerScreen đồng bộ chuẩn hóa trường HocVi và ChuyenMon từ bảng GiangViens, hiển thị chính xác thông tin chuyên môn giảng viên. |
| 130 | `TC_GVK_018` | 5. Giáo vụ khoa | Tìm kiếm GV | GovernanceLecturerScreen tích hợp thanh tìm kiếm SearchBar theo cả Tên giảng viên và Chuyên môn nghiên cứu đa tiêu chí. |
| 131 | `TC_GVK_020` | 5. Giáo vụ khoa | AI Phân tích | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 132 | `TC_GVK_023` | 5. Giáo vụ khoa | Hồ sơ Giáo vụ | GovernanceProfileScreen đã hiển thị trường Số điện thoại và cung cấp dialog cập nhật số điện thoại gọi PUT /api/profile. |
| 133 | `TC_GVK_024` | 5. Giáo vụ khoa | Avatar Giáo vụ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 134 | `TC_GVK_025` | 5. Giáo vụ khoa | Bảo mật Khoa | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 135 | `TC_PDT_001` | 6. Phòng đào tạo | Dashboard Toàn trường | TrainingOverviewScreen hiển thị số liệu toàn trường (liên khoa): Tổng số khoa, Tổng số sinh viên làm đồ án, Tổng số đề tài được duyệt, Tỷ lệ hoàn thành đồ án. |
| 136 | `TC_PDT_003` | 6. Phòng đào tạo | Dashboard Toàn trường | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 137 | `TC_PDT_004` | 6. Phòng đào tạo | Cấu hình Học kỳ | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 138 | `TC_PDT_007` | 6. Phòng đào tạo | Quản lý LHP cấp trường | TrainingDataManagementScreen hiển thị danh mục tất cả LHP toàn trường, lọc theo Khoa và hiển thị chính xác tên giảng viên phụ trách từ CSDL. |
| 139 | `TC_PDT_008` | 6. Phòng đào tạo | Lọc LHP theo Khoa | TrainingDataManagementScreen tích hợp DropdownFilter lọc danh sách LHP theo từng Khoa cụ thể. |
| 140 | `TC_PDT_015` | 6. Phòng đào tạo | Quyền hạn độc lập | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 141 | `TC_PDT_018` | 6. Phòng đào tạo | Hồ sơ Đào tạo | TrainingProfileScreen hiển thị thông tin cán bộ Phòng Đào tạo kèm tính năng cập nhật Số điện thoại qua dialog và API PUT /api/profile. |
| 142 | `TC_PDT_019` | 6. Phòng đào tạo | Avatar Đào tạo | AvatarService và UserAvatarView đã cô lập bộ nhớ đệm avatar theo username của tài khoản đang đăng nhập, chấm dứt hoàn toàn hiện tượng rò rỉ avatar giữa Giáo vụ khoa và Phòng đào tạo. |
| 143 | `TC_PDT_020` | 6. Phòng đào tạo | Bảo mật Đào tạo | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 144 | `TC_ADM_001` | 7. Quản trị hệ thống | Dashboard Admin | AdminOverviewScreen trích xuất chính xác tổng số tài khoản, sinh viên, giảng viên, lớp học phần từ endpoint /api/admin/overview và danh sách người dùng thực tế. |
| 145 | `TC_ADM_002` | 7. Quản trị hệ thống | Biểu đồ vai trò | AdminOverviewScreen đã chuẩn hóa cơ chế đếm vai trò theo các mã vai trò maVaiTro và tenVaiTro, tính toán chính xác tỷ lệ phần trăm phân bổ 5 vai trò trên biểu đồ Stacked Bar Chart đạt chuẩn 100%. |
| 146 | `TC_ADM_003` | 7. Quản trị hệ thống | Danh sách User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 147 | `TC_ADM_004` | 7. Quản trị hệ thống | Tìm kiếm User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 148 | `TC_ADM_005` | 7. Quản trị hệ thống | Lọc vai trò | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 149 | `TC_ADM_006` | 7. Quản trị hệ thống | Thêm User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 150 | `TC_ADM_007` | 7. Quản trị hệ thống | Validate User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 151 | `TC_ADM_008` | 7. Quản trị hệ thống | Validate User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 152 | `TC_ADM_009` | 7. Quản trị hệ thống | Khóa tài khoản | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 153 | `TC_ADM_010` | 7. Quản trị hệ thống | Mở khóa User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 154 | `TC_ADM_011` | 7. Quản trị hệ thống | Reset mật khẩu | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 155 | `TC_ADM_012` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 156 | `TC_ADM_013` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 157 | `TC_ADM_014` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 158 | `TC_ADM_015` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 159 | `TC_ADM_016` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 160 | `TC_ADM_017` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 161 | `TC_ADM_018` | 7. Quản trị hệ thống | Nhật ký hệ thống | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 162 | `TC_ADM_019` | 7. Quản trị hệ thống | Validate SĐT | AdminUserFormScreen áp dụng FilteringTextInputFormatter.digitsOnly, giới hạn độ dài 10-11 ký tự, và Backend AdminController xác thực Regex ^[0-9]{10,11}$ ngăn chặn số điện thoại sai định dạng. |
| 163 | `TC_ADM_020` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 164 | `TC_ADM_021` | 7. Quản trị hệ thống | Import User | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 165 | `TC_ADM_022` | 7. Quản trị hệ thống | Đổi Vai trò | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 166 | `TC_ADM_023` | 7. Quản trị hệ thống | Xóa tài khoản | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 167 | `TC_ADM_024` | 7. Quản trị hệ thống | Tìm kiếm nâng cao | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 168 | `TC_NFR_001` | 8. Phi chức năng & Bảo mật | Bảo mật API | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 169 | `TC_NFR_002` | 8. Phi chức năng & Bảo mật | Bảo mật Token | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 170 | `TC_NFR_003` | 8. Phi chức năng & Bảo mật | Phân quyền RBAC | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 171 | `TC_NFR_004` | 8. Phi chức năng & Bảo mật | Phân quyền RBAC | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 172 | `TC_NFR_005` | 8. Phi chức năng & Bảo mật | Xử lý mất mạng | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 173 | `TC_NFR_006` | 8. Phi chức năng & Bảo mật | Hiệu năng USB | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 174 | `TC_NFR_007` | 8. Phi chức năng & Bảo mật | Hiệu năng Wi-Fi | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 175 | `TC_NFR_008` | 8. Phi chức năng & Bảo mật | Responsive UI | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 176 | `TC_NFR_009` | 8. Phi chức năng & Bảo mật | Xoay màn hình | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 177 | `TC_NFR_010` | 8. Phi chức năng & Bảo mật | Sao lưu CSDL | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 178 | `TC_NFR_011` | 8. Phi chức năng & Bảo mật | Khôi phục CSDL | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 179 | `TC_NFR_012` | 8. Phi chức năng & Bảo mật | Bảo mật Avatar | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 180 | `TC_NFR_013` | 8. Phi chức năng & Bảo mật | Bàn phím ảo | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 181 | `TC_NFR_014` | 8. Phi chức năng & Bảo mật | Cử chỉ Back | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 182 | `TC_NFR_015` | 8. Phi chức năng & Bảo mật | Bộ nhớ & RAM | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
| 183 | `TC_NFR_016` | 8. Phi chức năng & Bảo mật | Khôi phục State | Tính năng hoạt động ổn định, đạt đúng kết quả mong đợi. |
