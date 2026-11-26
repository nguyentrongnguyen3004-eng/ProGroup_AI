# 02. DANH MỤC TOÀN BỘ 200 TEST CASE CHUẨN HÓA

| STT | Mã TC | Sheet | Phân hệ / Tính năng | Kịch bản kiểm thử (Scenario) | Kết quả mong đợi | Trạng thái Audit |
|---|---|---|---|---|---|---|
| 1 | `TC_AUTH_001` | 2. Xác thực & Hệ thống | Đăng nhập | Đăng nhập thành công với tài khoản Sinh viên | Đăng nhập thành công, lưu JWT Token vào SharedPreferences, v... | **FIXED** |
| 2 | `TC_AUTH_002` | 2. Xác thực & Hệ thống | Đăng nhập | Đăng nhập thành công với tài khoản Giảng viên | Chuyển hướng chính xác vào Trang chủ Giảng viên với menu quả... | **FIXED** |
| 3 | `TC_AUTH_003` | 2. Xác thực & Hệ thống | Đăng nhập | Đăng nhập thành công với tài khoản Giáo vụ khoa | Vào Dashboard Giáo vụ khoa, hiển thị quản lý LHP toàn khoa v... | **FIXED** |
| 4 | `TC_AUTH_004` | 2. Xác thực & Hệ thống | Đăng nhập | Đăng nhập thành công với tài khoản Phòng đào tạo | Vào Dashboard Phòng đào tạo với số liệu thống kê đồ án toàn ... | **FIXED** |
| 5 | `TC_AUTH_005` | 2. Xác thực & Hệ thống | Đăng nhập | Đăng nhập thành công với tài khoản Quản trị viên (Admin) | Vào Dashboard Admin với đầy đủ quyền quản lý tài khoản, impo... | **FIXED** |
| 6 | `TC_AUTH_006` | 2. Xác thực & Hệ thống | Validate form | Để trống Tên đăng nhập và bấm Đăng nhập | Hiển thị thông báo: 'Vui lòng nhập tên đăng nhập', không gửi... | **FIXED** |
| 7 | `TC_AUTH_007` | 2. Xác thực & Hệ thống | Validate form | Để trống Mật khẩu và bấm Đăng nhập | Hiển thị thông báo: 'Vui lòng nhập mật khẩu', không gửi requ... | **FIXED** |
| 8 | `TC_AUTH_008` | 2. Xác thực & Hệ thống | Validate form | Để trống cả Tên đăng nhập và Mật khẩu | Cảnh báo lỗi cả hai trường dữ liệu, không thực hiện gọi API.... | **FIXED** |
| 9 | `TC_AUTH_009` | 2. Xác thực & Hệ thống | Xác thực sai | Đăng nhập với Tên đăng nhập không tồn tại | Hiển thị lỗi: 'Tên đăng nhập hoặc mật khẩu không chính xác'.... | **FIXED** |
| 10 | `TC_AUTH_010` | 2. Xác thực & Hệ thống | Xác thực sai | Đăng nhập với Mật khẩu không chính xác | Hiển thị lỗi thông báo sai mật khẩu (HTTP 401 hoặc 400).... | **FIXED** |
| 11 | `TC_AUTH_011` | 2. Xác thực & Hệ thống | Bảo mật | Đăng nhập với tài khoản đang bị Khóa (Trạng thái = False) | Báo lỗi: 'Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động'... | **FIXED** |
| 12 | `TC_AUTH_012` | 2. Xác thực & Hệ thống | Bảo mật | Thử nghiệm tấn công SQL Injection vào ô Đăng nhập | Backend xử lý bằng Entity Framework Core (tham số hóa an toà... | **FIXED** |
| 13 | `TC_AUTH_013` | 2. Xác thực & Hệ thống | UI Đăng nhập | Kiểm tra nút ẩn / hiện mật khẩu (Obscure text) | Mặc định che mật khẩu bằng dấu chấm tròn. Bấm mắt hiển thị k... | **FIXED** |
| 14 | `TC_AUTH_014` | 2. Xác thực & Hệ thống | Lưu phiên | Tự động khôi phục phiên đăng nhập khi tắt và mở lại app | App tự động khôi phục token và vào thẳng trang chủ tương ứng... | **FIXED** |
| 15 | `TC_AUTH_015` | 2. Xác thực & Hệ thống | Đăng xuất | Đăng xuất tài khoản an toàn | Hủy phiên, xóa sạch JWT Token trong SharedPreferences, chuyể... | **FIXED** |
| 16 | `TC_AUTH_016` | 2. Xác thực & Hệ thống | Mạng & Server | Tự động nhận diện máy chủ qua cáp USB (ADB Reverse) | Kết nối thành công trong < 1 giây, gán làm BaseUrl chính.... | **FIXED** |
| 17 | `TC_AUTH_017` | 2. Xác thực & Hệ thống | Mạng & Server | Tự động nhận diện máy chủ qua mạng Wi-Fi LAN | Tự động fallback và kết nối tới IP LAN của máy tính, app hoạ... | **FIXED** |
| 18 | `TC_AUTH_018` | 2. Xác thực & Hệ thống | Mạng & Server | Xử lý khi máy tính chưa bật Backend API | Timeout sau 2-5 giây, app hiển thị thông báo không thể kết n... | **FIXED** |
| 19 | `TC_AUTH_019` | 2. Xác thực & Hệ thống | UI Đăng nhập | Kiểm tra nút 'Máy chủ' đã được ẩn trên giao diện Đăng nhập | Không còn nút 'Máy chủ' nào hiển thị, giao diện sạch sẽ, chu... | **FIXED** |
| 20 | `TC_AUTH_020` | 2. Xác thực & Hệ thống | Phím tắt Dev | Mở hộp thoại Cấu hình Máy chủ bằng cách nhấn giữ Logo | Hộp thoại ServerConfigDialog hiện lên cho phép Dev kiểm tra ... | **FIXED** |
| 21 | `TC_AUTH_021` | 2. Xác thực & Hệ thống | Cấu hình Server | Thử nghiệm ping và lưu IP máy chủ mới trong dialog | Báo kết quả ping thành công/thất bại trực quan. Bấm lưu sẽ c... | **FIXED** |
| 22 | `TC_AUTH_022` | 2. Xác thực & Hệ thống | Giao diện | Chuyển đổi giao diện Tối (Dark Mode) và lưu cấu hình | Toàn bộ background đổi sang xanh đen slate, chữ chuyển màu t... | **FIXED** |
| 23 | `TC_AUTH_023` | 2. Xác thực & Hệ thống | Giao diện | Chuyển đổi giao diện Sáng (Light Mode) | Nền đổi về trắng xám nhẹ, thanh AppBar giữ gradient xanh nav... | **FIXED** |
| 24 | `TC_AUTH_024` | 2. Xác thực & Hệ thống | Đa ngôn ngữ | Đổi ngôn ngữ sang Tiếng Anh (English) | Toàn bộ nhãn, tiêu đề màn hình, nút bấm đổi sang tiếng Anh (... | **FIXED** |
| 25 | `TC_AUTH_025` | 2. Xác thực & Hệ thống | Cập nhật OTA | Kiểm tra phiên bản ứng dụng từ Backend | Nếu là bản mới nhất: Báo 'Ứng dụng đang ở phiên bản mới nhất... | **FIXED** |
| 26 | `TC_AUTH_026` | 2. Xác thực & Hệ thống | Nhập liệu | Tự động cắt khoảng trắng thừa (Auto-trim whitespace) khi nhập tài khoản | App tự động trim bỏ khoảng trắng thừa, gửi 'sv001' lên serve... | **FIXED** |
| 27 | `TC_AUTH_027` | 2. Xác thực & Hệ thống | Chống Spam | Chống bấm liên tục (Spam Click / Debounce) vào nút 'Đăng nhập' | Nút đăng nhập hiển thị vòng quay loading và bị khóa tạm thời... | **FIXED** |
| 28 | `TC_AUTH_028` | 2. Xác thực & Hệ thống | Tự phục hồi | Tự động kết nối lại khi thiết bị có mạng trở lại mà không cần khởi động lại app | App tự động kiểm tra lại server và nạp dữ liệu bình thường m... | **FIXED** |
| 29 | `TC_STU_001` | 3. Phân hệ Sinh viên | Trang chủ | Hiển thị thông tin cá nhân và Avatar trên Header | Hiển thị đúng lời chào 'Xin chào, Trần Minh An', ảnh Avatar ... | **FIXED** |
| 30 | `TC_STU_002` | 3. Phân hệ Sinh viên | Trang chủ | Kiểm tra 3 thẻ thống kê tổng quan (Lớp học, Nhóm, Đề tài) | Thẻ hiển thị đúng: Số lớp học phần đang học, Trạng thái nhóm... | **FIXED** |
| 31 | `TC_STU_003` | 3. Phân hệ Sinh viên | Trang chủ | Banner Trợ lý AI gợi ý đề tài trên trang chủ | Chuyển ngay sang màn hình Trợ lý AI tư vấn đề tài.... | **FIXED** |
| 32 | `TC_STU_004` | 3. Phân hệ Sinh viên | Trang chủ | Làm mới dữ liệu trang chủ bằng thao tác kéo (Pull-to-refresh) | Icon loading xoay tròn, gọi lại đồng thời các API lấy lớp họ... | **FIXED** |
| 33 | `TC_STU_005` | 3. Phân hệ Sinh viên | Lớp học phần | Xem danh sách các LHP sinh viên đang theo học | Hiển thị danh sách card LHP: Mã lớp, Tên môn học, Học kỳ, Tê... | **FIXED** |
| 34 | `TC_STU_006` | 3. Phân hệ Sinh viên | Lớp học phần | Tìm kiếm LHP theo Tên môn học hoặc Mã lớp | Danh sách chỉ hiển thị các LHP có tên hoặc mã chứa từ khóa '... | **FIXED** |
| 35 | `TC_STU_007` | 3. Phân hệ Sinh viên | Lớp học phần | Xem chi tiết một Lớp học phần | Mở màn hình chi tiết: xem giảng viên phụ trách, danh sách đợ... | **FIXED** |
| 36 | `TC_STU_008` | 3. Phân hệ Sinh viên | Lớp học phần | Hiển thị empty state khi sinh viên chưa có LHP nào | Hiển thị icon minh họa và text: 'Bạn chưa tham gia lớp học p... | **FIXED** |
| 37 | `TC_STU_009` | 3. Phân hệ Sinh viên | Quản lý nhóm | Xem thông tin nhóm đồ án hiện tại của sinh viên | Hiển thị: Tên nhóm, Trưởng nhóm (có huy hiệu nhóm trưởng), D... | **FIXED** |
| 38 | `TC_STU_010` | 3. Phân hệ Sinh viên | Quản lý nhóm | Trưởng nhóm đổi tên nhóm đồ án thành công | Cập nhật tên nhóm thành công trên UI và Backend. Thông báo '... | **FIXED** |
| 39 | `TC_STU_011` | 3. Phân hệ Sinh viên | Quản lý nhóm | Thành viên thường không có quyền đổi tên nhóm | Không hiển thị icon chỉnh sửa tên nhóm (chỉ trưởng nhóm mới ... | **FIXED** |
| 40 | `TC_STU_012` | 3. Phân hệ Sinh viên | Quản lý nhóm | Báo lỗi khi đổi tên nhóm để trống hoặc chỉ có khoảng trắng | Hiển thị cảnh báo: 'Tên nhóm không được để trống'. Không gửi... | **FIXED** |
| 41 | `TC_STU_013` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Xem danh sách đề tài đồ án do Giảng viên công bố | Hiển thị danh sách card đề tài: Tên đề tài, Giảng viên ra đề... | **FIXED** |
| 42 | `TC_STU_014` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Tìm kiếm đề tài theo Tên đề tài hoặc Công nghệ | Lập tức lọc danh sách đề tài chứa công nghệ Flutter hoặc AI.... | **FIXED** |
| 43 | `TC_STU_015` | 3. Phân hệ Sinh viên | Ngân hàng đề tài | Xem chi tiết nội dung đề tài đồ án | Hiển thị đầy đủ: Mục tiêu nghiên cứu, Phạm vi đồ án, Công ng... | **FIXED** |
| 44 | `TC_STU_016` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Trưởng nhóm đăng ký đề tài thành công khi thỏa mãn điều kiện | Đăng ký thành công, trạng thái chuyển sang 'Chờ duyệt', slot... | **FIXED** |
| 45 | `TC_STU_017` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Thành viên thường bấm Đăng ký đề tài bị chặn | Báo lỗi: 'Chỉ có Nhóm trưởng mới có quyền đăng ký đề tài cho... | **FIXED** |
| 46 | `TC_STU_018` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Chặn đăng ký khi nhóm đã có đề tài được duyệt chính thức | Nút đăng ký bị vô hiệu hóa hoặc hệ thống báo lỗi: 'Nhóm của ... | **FIXED** |
| 47 | `TC_STU_019` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Chặn đăng ký khi nhóm chưa đủ số thành viên tối thiểu | Báo lỗi: 'Nhóm của bạn chưa đủ số thành viên tối thiểu (yêu ... | **FIXED** |
| 48 | `TC_STU_020` | 3. Phân hệ Sinh viên | Đăng ký đề tài | Chặn đăng ký khi đề tài đã hết slot (Đã đủ số nhóm) | Báo lỗi: 'Đề tài này đã đủ số lượng nhóm đăng ký, vui lòng c... | **FIXED** |
| 49 | `TC_STU_021` | 3. Phân hệ Sinh viên | Hủy đăng ký | Hủy đăng ký đề tài thành công khi đang ở trạng thái 'Chờ duyệt' | Hủy đăng ký thành công, trạng thái nhóm quay lại Chưa đăng k... | **FIXED** |
| 50 | `TC_STU_022` | 3. Phân hệ Sinh viên | Hủy đăng ký | Không cho phép hủy đăng ký khi đề tài đã được Giảng viên Duyệt | Nút Hủy đăng ký không hiển thị hoặc bị vô hiệu hóa (muốn đổi... | **FIXED** |
| 51 | `TC_STU_023` | 3. Phân hệ Sinh viên | Đề xuất đề tài | Sinh viên tự đề xuất đề tài mới cho nhóm thành công | Tạo đề xuất thành công, trạng thái 'Chờ duyệt', đề tài xuất ... | **FIXED** |
| 52 | `TC_STU_024` | 3. Phân hệ Sinh viên | Đề xuất đề tài | Validate form đề xuất đề tài (bắt buộc nhập đủ trường) | Báo lỗi màu đỏ dưới các trường bắt buộc, không gửi request l... | **FIXED** |
| 53 | `TC_STU_025` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Xem danh sách các cột mốc nộp báo cáo tiến độ đồ án | Hiển thị danh sách các mốc báo cáo kèm hạn chót (Deadline), ... | **FIXED** |
| 54 | `TC_STU_026` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Nộp báo cáo tiến độ đồ án đúng hạn kèm link tài liệu | Nộp thành công, trạng thái chuyển sang 'Đã nộp - Chờ đánh gi... | **FIXED** |
| 55 | `TC_STU_027` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Validate định dạng URL link báo cáo | Hiển thị cảnh báo: 'Vui lòng nhập đường dẫn URL hợp lệ (bắt ... | **FIXED** |
| 56 | `TC_STU_028` | 3. Phân hệ Sinh viên | Báo cáo tiến độ | Xem điểm số và nhận xét đánh giá từ Giảng viên | Hiển thị điểm số (9.0/10), trạng thái 'Đạt', hiển thị chi ti... | **FIXED** |
| 57 | `TC_STU_029` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Tư vấn gợi ý đề tài với số lượng 3 đề tài (Mặc định) | AI sinh ra chính xác 3 đề tài có cấu trúc: Tên đề tài, Tính ... | **FIXED** |
| 58 | `TC_STU_030` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Tùy chọn số lượng đề tài AI sinh ra (1, 2, 5, 10 đề tài) | AI phản hồi danh sách gồm đúng 5 đề tài tương ứng, được đánh... | **FIXED** |
| 59 | `TC_STU_031` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Chat trực tiếp với Trợ lý AI về định hướng đồ án | AI phản hồi thông minh, giải thích lộ trình kiến thức (OpenC... | **FIXED** |
| 60 | `TC_STU_032` | 3. Phân hệ Sinh viên | Trợ lý AI Gemini | Xử lý lỗi khi mất mạng trong lúc gọi Trợ lý AI | Báo lỗi thân thiện: 'Không thể kết nối Gemini AI. Vui lòng k... | **FIXED** |
| 61 | `TC_STU_033` | 3. Phân hệ Sinh viên | Thông báo | Nhận thông báo khi Giảng viên Duyệt đề tài | Xuất hiện thông báo: 'Đề tài [Tên đề tài] của nhóm bạn đã đư... | **FIXED** |
| 62 | `TC_STU_034` | 3. Phân hệ Sinh viên | Thông báo | Đánh dấu 1 thông báo là đã đọc khi bấm vào | Thông báo mất chấm xanh, chuyển sang trạng thái đã đọc, số l... | **FIXED** |
| 63 | `TC_STU_035` | 3. Phân hệ Sinh viên | Thông báo | Bấm 'Đánh dấu tất cả đã đọc' | Tất cả thông báo chuyển sang trạng thái đã đọc, badge chuông... | **FIXED** |
| 64 | `TC_STU_036` | 3. Phân hệ Sinh viên | Hồ sơ cá nhân | Xem thông tin chi tiết sinh viên (MSSV, Ngày sinh, Khoa) | Hiển thị đúng MSSV, Họ tên, Ngày sinh, Giới tính, Khoa Công ... | **FIXED** |
| 65 | `TC_STU_037` | 3. Phân hệ Sinh viên | Hồ sơ cá nhân | Cập nhật Số điện thoại liên hệ cá nhân | Cập nhật thành công, số điện thoại mới hiển thị trên hồ sơ.... | **FIXED** |
| 66 | `TC_STU_038` | 3. Phân hệ Sinh viên | Avatar cá nhân | Đổi ảnh đại diện từ thư viện ảnh thiết bị thành công | Ảnh tải lên Backend (POST /api/profile/avatar), Avatar tại t... | **FIXED** |
| 67 | `TC_STU_039` | 3. Phân hệ Sinh viên | Chống Spam | Chống spam click vào nút 'Đăng ký đề tài' | Nút hiển thị vòng quay loading và bị khóa tạm thời, chỉ gửi ... | **FIXED** |
| 68 | `TC_STU_040` | 3. Phân hệ Sinh viên | Avatar cá nhân | Chặn tải lên file Avatar quá dung lượng (> 10MB) hoặc sai định dạng | App hiển thị cảnh báo: 'Dung lượng ảnh tối đa là 5MB và phải... | **FIXED** |
| 69 | `TC_STU_041` | 3. Phân hệ Sinh viên | Avatar cá nhân | Xử lý khi mất mạng trong lúc đang tải ảnh Avatar lên server | App xử lý ngoại lệ, thông báo 'Tải ảnh thất bại, vui lòng ki... | **FIXED** |
| 70 | `TC_STU_042` | 3. Phân hệ Sinh viên | Push Notification | Nhận thông báo đẩy Firebase (FCM) khi app đang chạy ngầm / khóa màn hình | Điện thoại rung/chuông và hiện banner thông báo trên thanh t... | **FIXED** |
| 71 | `TC_STU_043` | 3. Phân hệ Sinh viên | Tìm kiếm | Tìm kiếm đề tài không phân biệt chữ hoa, chữ thường và dấu tiếng Việt | Vẫn tìm kiếm và lọc ra chính xác đề tài 'Trí tuệ nhân tạo' v... | **FIXED** |
| 72 | `TC_STU_044` | 3. Phân hệ Sinh viên | Trợ lý AI | Sao chép nội dung gợi ý của AI vào bộ nhớ tạm (Clipboard) | Thông báo 'Đã sao chép nội dung vào bộ nhớ tạm', dán ra đầy ... | **FIXED** |
| 73 | `TC_STU_045` | 3. Phân hệ Sinh viên | Chat nhóm | Mở màn hình Đoạn chat nhóm từ trang Chi tiết nhóm đồ án | Chuyển sang màn hình Chat nhóm. Header hiển thị đúng tên nhó... | **FIXED** |
| 74 | `TC_STU_046` | 3. Phân hệ Sinh viên | Chat nhóm | Hiển thị thông báo chào mừng mặc định khi phòng chat chưa có tin nhắn | Hiển thị bubble tin nhắn hệ thống ở giữa màn hình: 'Đoạn cha... | **FIXED** |
| 75 | `TC_STU_047` | 3. Phân hệ Sinh viên | Chat nhóm | Gửi tin nhắn văn bản thành công qua Cloud Firestore Stream | Gọi FirebaseService.sendMessage(). Ô nhập tin nhắn được làm ... | **FIXED** |
| 76 | `TC_STU_048` | 3. Phân hệ Sinh viên | Chat nhóm | Nhận tin nhắn thời gian thực (Real-time Stream) từ thành viên khác mà không cần tải lại trang | Sinh viên A thấy tin nhắn của Sinh viên B xuất hiện tức thời... | **FIXED** |
| 77 | `TC_STU_049` | 3. Phân hệ Sinh viên | Chat nhóm | Chặn gửi tin nhắn rỗng hoặc chuỗi chỉ chứa khoảng trắng (Whitespace validation) | Hàm _sendMessage() chặn thao tác (return ngay), không gửi dữ... | **FIXED** |
| 78 | `TC_STU_050` | 3. Phân hệ Sinh viên | Chat nhóm | Tự động cuộn xuống cuối màn hình (Auto-scroll to bottom) khi có tin nhắn mới | ScrollController tự động animate mượt mà cuộn xuống đáy danh... | **FIXED** |
| 79 | `TC_STU_051` | 3. Phân hệ Sinh viên | Chat nhóm | Hiển thị thẻ Yêu cầu tham gia nhóm (Join Request Card) trực tiếp trong luồng chat | Hiển thị thẻ Card tương tác đặc biệt: Tiêu đề 'Yêu cầu xin g... | **FIXED** |
| 80 | `TC_STU_052` | 3. Phân hệ Sinh viên | Chat nhóm | Trưởng nhóm bấm 'Duyệt tham gia' trực tiếp từ thẻ yêu cầu trong khung chat | Gọi Firestore cập nhật status='Đã chấp nhận'. Thẻ chuyển san... | **FIXED** |
| 81 | `TC_STU_053` | 3. Phân hệ Sinh viên | Chat nhóm | Trưởng nhóm bấm 'Từ chối' yêu cầu tham gia trực tiếp từ thẻ yêu cầu trong khung chat | Gọi Firestore cập nhật status='Đã từ chối'. Thẻ chuyển badge... | **FIXED** |
| 82 | `TC_STU_054` | 3. Phân hệ Sinh viên | Chat nhóm | Chế độ ngoại tuyến (Offline fallback): Gửi tin nhắn khi mất mạng hoặc Firebase chưa sẵn sàng | Ứng dụng kích hoạt nhánh Fallback cục bộ: Tin nhắn được đưa ... | **FIXED** |
| 83 | `TC_STU_055` | 3. Phân hệ Sinh viên | Chat nhóm | Định dạng hiển thị thời gian tin nhắn chuẩn xác theo logic tương đối và tuyệt đối | Hiển thị đúng: Gửi < 60 giây -> 'Vừa xong'; Gửi 1-59 phút ->... | **FIXED** |
| 84 | `TC_STU_056` | 3. Phân hệ Sinh viên | Chat nhóm | Điều hướng đến màn hình Duyệt yêu cầu tập trung từ icon trên AppBar | Điều hướng sang JoinRequestScreen với danh sách chi tiết tất... | **FIXED** |
| 85 | `TC_STU_057` | 3. Phân hệ Sinh viên | Chat nhóm | Hiển thị tin nhắn văn bản dài nhiều dòng, emoji và ký tự đặc biệt | Bubble tin nhắn tự động co giãn kích thước linh hoạt (maxWid... | **FIXED** |
| 86 | `TC_LEC_001` | 4. Phân hệ Giảng viên | Trang chủ GV | Hiển thị lời chào, học vị và thống kê tổng quan | Hiển thị lời chào: 'Xin chào, ThS. Nguyễn Văn A', thẻ: Lớp h... | **FIXED** |
| 87 | `TC_LEC_002` | 4. Phân hệ Giảng viên | Lớp học phần | Xem danh sách các LHP được phân công giảng dạy | Hiển thị danh sách card LHP: Mã lớp, Tên môn, Học kỳ, Số lượ... | **FIXED** |
| 88 | `TC_LEC_003` | 4. Phân hệ Giảng viên | Chi tiết LHP | Xem danh sách nhóm sinh viên trong một LHP cụ thể | Hiển thị danh sách tất cả các nhóm trong lớp, trưởng nhóm, s... | **FIXED** |
| 89 | `TC_LEC_004` | 4. Phân hệ Giảng viên | Chi tiết LHP | Xem danh sách đề tài thuộc về LHP | Hiển thị danh sách các đề tài đã công bố cho lớp này và tiến... | **FIXED** |
| 90 | `TC_LEC_005` | 4. Phân hệ Giảng viên | Tạo đề tài | Giảng viên tạo đề tài mới thành công cho đợt đăng ký | Tạo thành công, đề tài xuất hiện trong danh sách của GV và h... | **FIXED** |
| 91 | `TC_LEC_006` | 4. Phân hệ Giảng viên | Validate đề tài | Báo lỗi khi tạo đề tài để trống Tên đề tài hoặc Mục tiêu | Hiển thị thông báo: 'Tên đề tài không được để trống'. Không ... | **FIXED** |
| 92 | `TC_LEC_007` | 4. Phân hệ Giảng viên | Sửa đề tài | Chỉnh sửa nội dung đề tài chưa có nhóm đăng ký | Cập nhật thành công thông tin đề tài, sinh viên thấy thông t... | **FIXED** |
| 93 | `TC_LEC_008` | 4. Phân hệ Giảng viên | Sửa đề tài | Cảnh báo khi sửa đề tài đã có nhóm đăng ký được duyệt | Hệ thống hiển thị cảnh báo đề tài đã có nhóm nhận, yêu cầu x... | **FIXED** |
| 94 | `TC_LEC_009` | 4. Phân hệ Giảng viên | Xóa đề tài | Xóa đề tài thành công khi chưa có nhóm đăng ký | Xóa thành công, đề tài biến mất khỏi danh sách.... | **FIXED** |
| 95 | `TC_LEC_010` | 4. Phân hệ Giảng viên | Xóa đề tài | Chặn không cho xóa đề tài đã có nhóm được duyệt | Báo lỗi: 'Không thể xóa đề tài đã có nhóm sinh viên đăng ký ... | **FIXED** |
| 96 | `TC_LEC_011` | 4. Phân hệ Giảng viên | Duyệt đề tài | Phê duyệt đơn đăng ký đề tài của Nhóm sinh viên | Trạng thái đơn chuyển thành 'Đã duyệt'. Tự động gửi thông bá... | **FIXED** |
| 97 | `TC_LEC_012` | 4. Phân hệ Giảng viên | Từ chối đề tài | Từ chối đơn đăng ký đề tài kèm lý do phản hồi | Đơn chuyển sang 'Từ chối'. Gửi thông báo kèm lý do cho nhóm ... | **FIXED** |
| 98 | `TC_LEC_013` | 4. Phân hệ Giảng viên | Duyệt đề xuất | Xem danh sách các đề tài do Sinh viên tự đề xuất | Hiển thị danh sách đề xuất: Tên đề tài, Nhóm đề xuất, Mô tả,... | **FIXED** |
| 99 | `TC_LEC_014` | 4. Phân hệ Giảng viên | Duyệt đề xuất | Phê duyệt đề tài đề xuất của Sinh viên | Đề xuất chuyển thành Đề tài chính thức được duyệt của nhóm, ... | **FIXED** |
| 100 | `TC_LEC_015` | 4. Phân hệ Giảng viên | Từ chối đề xuất | Từ chối đề xuất của Sinh viên kèm góp ý chỉnh sửa | Trạng thái chuyển thành 'Từ chối', sinh viên nhận được thông... | **FIXED** |
| 101 | `TC_LEC_016` | 4. Phân hệ Giảng viên | Chấm báo cáo | Xem danh sách các nhóm đã nộp báo cáo tiến độ | Hiển thị danh sách nhóm đã nộp, thời gian nộp, link tài liệu... | **FIXED** |
| 102 | `TC_LEC_017` | 4. Phân hệ Giảng viên | Chấm báo cáo | Chấm điểm và nhận xét báo cáo tiến độ của nhóm | Lưu kết quả thành công, sinh viên nhận được thông báo điểm v... | **FIXED** |
| 103 | `TC_LEC_018` | 4. Phân hệ Giảng viên | Validate điểm | Báo lỗi khi nhập điểm không hợp lệ (ngoài khoảng 0 - 10) | Báo lỗi: 'Điểm số phải nằm trong khoảng từ 0.0 đến 10.0'. Kh... | **FIXED** |
| 104 | `TC_LEC_019` | 4. Phân hệ Giảng viên | Mở đợt đăng ký | Tạo đợt đăng ký đồ án mới cho Lớp học phần | Tạo đợt đăng ký thành công, trạng thái 'Đang mở'. Sinh viên ... | **FIXED** |
| 105 | `TC_LEC_020` | 4. Phân hệ Giảng viên | Validate đợt | Báo lỗi khi Ngày kết thúc trước Ngày bắt đầu | Báo lỗi: 'Ngày kết thúc phải diễn ra sau ngày bắt đầu'.... | **FIXED** |
| 106 | `TC_LEC_021` | 4. Phân hệ Giảng viên | Đóng đợt | Chuyển trạng thái đợt đăng ký sang 'Đã đóng' | Đợt chuyển sang 'Đã đóng'. Sinh viên không thể đăng ký thêm ... | **FIXED** |
| 107 | `TC_LEC_022` | 4. Phân hệ Giảng viên | AI Hỗ trợ GV | Giảng viên dùng AI Gemini tạo danh sách đề tài mẫu | AI sinh ra danh sách đề tài chuẩn mực, GV có thể bấm 'Chọn d... | **FIXED** |
| 108 | `TC_LEC_023` | 4. Phân hệ Giảng viên | Thống kê LHP | Xem biểu đồ tiến độ đăng ký của các nhóm trong LHP | Hiển thị tỷ lệ % nhóm đã có đề tài chính thức, số nhóm đang ... | **FIXED** |
| 109 | `TC_LEC_024` | 4. Phân hệ Giảng viên | Thông báo GV | Nhận thông báo khi có sinh viên nộp báo cáo hoặc gửi đề xuất | Hiện thông báo: 'Nhóm [Tên nhóm] vừa nộp báo cáo tiến độ Tuầ... | **FIXED** |
| 110 | `TC_LEC_025` | 4. Phân hệ Giảng viên | Hồ sơ Giảng viên | Xem và cập nhật Chuyên môn, Học vị của Giảng viên | Cập nhật thành công, số liệu đồng bộ chính xác.... | **FIXED** |
| 111 | `TC_LEC_026` | 4. Phân hệ Giảng viên | Đồng thời | Xử lý xung đột đồng thời (Race condition) khi 2 nhóm cùng đăng ký 1 slot cuối cùng | Nhóm bấm trước được ghi nhận thành công, nhóm bấm sau nhận t... | **FIXED** |
| 112 | `TC_LEC_027` | 4. Phân hệ Giảng viên | Validate đợt | Chặn chọn Ngày bắt đầu của đợt đăng ký trong quá khứ | Hệ thống cảnh báo: 'Ngày bắt đầu không được ở trong quá khứ'... | **FIXED** |
| 113 | `TC_LEC_028` | 4. Phân hệ Giảng viên | Chấm báo cáo | Nhập điểm báo cáo bằng số thập phân (8.25 hoặc 9.5) và kiểm tra tính toán | Lưu đúng giá trị số thực 8.75 vào CSDL, hiển thị chính xác t... | **FIXED** |
| 114 | `TC_LEC_029` | 4. Phân hệ Giảng viên | Bộ lọc đề tài | Lọc đề tài theo Học kỳ và Lớp học phần đang phụ trách | Danh sách đề tài chuyển đổi chuẩn xác tương ứng với từng môn... | **FIXED** |
| 115 | `TC_LEC_030` | 4. Phân hệ Giảng viên | Export bảng điểm | Xem danh sách tổng hợp điểm tiến độ của toàn bộ các nhóm trong lớp | Hiển thị đầy đủ danh sách nhóm kèm điểm từng giai đoạn và đi... | **FIXED** |
| 116 | `TC_GVK_001` | 5. Giáo vụ khoa | Dashboard Khoa | Hiển thị số liệu tổng quan đào tạo của khoa CNTT | Hiển thị đúng tổng số: LHP thuộc khoa, Số sinh viên khoa, Số... | **FIXED** |
| 117 | `TC_GVK_002` | 5. Giáo vụ khoa | Dashboard Khoa | Làm mới dữ liệu Dashboard khoa bằng thao tác kéo (Pull-to-refresh) | Icon loading xoay tròn, tải lại số liệu mới nhất từ CSDL thà... | **FIXED** |
| 118 | `TC_GVK_003` | 5. Giáo vụ khoa | Quản lý LHP | Xem danh mục tất cả Lớp học phần do Khoa quản lý | Hiển thị đầy đủ: Mã lớp, Tên môn học, Học kỳ, Tên giảng viên... | **FIXED** |
| 119 | `TC_GVK_004` | 5. Giáo vụ khoa | Tìm kiếm LHP | Tìm kiếm LHP theo Mã môn hoặc Tên môn trong khoa | Danh sách lập tức lọc chính xác các LHP khớp từ khóa tìm kiế... | **FIXED** |
| 120 | `TC_GVK_005` | 5. Giáo vụ khoa | Lọc LHP | Lọc danh sách LHP theo Học kỳ niên khóa | Chỉ hiển thị các LHP được mở trong học kỳ đã chọn.... | **FIXED** |
| 121 | `TC_GVK_006` | 5. Giáo vụ khoa | Chi tiết LHP | Xem thông tin chi tiết một LHP khoa (Danh sách SV và Nhóm) | Hiển thị đầy đủ danh sách sinh viên trong lớp, danh sách các... | **FIXED** |
| 122 | `TC_GVK_007` | 5. Giáo vụ khoa | Phân công GV | Phân công Giảng viên phụ trách Lớp học phần thành công | Phân công thành công, hiển thị tên Giảng viên trên card LHP ... | **FIXED** |
| 123 | `TC_GVK_008` | 5. Giáo vụ khoa | Phân công GV | Chặn phân công trùng lặp cùng 1 giảng viên 2 lần vào 1 LHP | Hệ thống báo cảnh báo: 'Giảng viên này đã được phân công cho... | **FIXED** |
| 124 | `TC_GVK_009` | 5. Giáo vụ khoa | Đổi phân công | Thay đổi Giảng viên phụ trách LHP sang Giảng viên khác | Cập nhật thành công GV B phụ trách lớp. GV B đăng nhập vào s... | **FIXED** |
| 125 | `TC_GVK_010` | 5. Giáo vụ khoa | Hủy phân công | Hủy phân công giảng viên khỏi LHP khi chưa có nhóm đăng ký | Hủy thành công, LHP quay về trạng thái 'Chưa phân công giảng... | **FIXED** |
| 126 | `TC_GVK_011` | 5. Giáo vụ khoa | Đồng bộ GV | Kiểm tra Giảng viên được phân công thấy lớp ngay trên tài khoản của mình | LHP mới lập tức xuất hiện trong danh sách phụ trách của Giản... | **FIXED** |
| 127 | `TC_GVK_012` | 5. Giáo vụ khoa | Giám sát đăng ký | Xem màn hình Giám sát tổng quan đăng ký đồ án toàn khoa | Hiển thị tổng số nhóm đã đăng ký, số nhóm đã được duyệt, số ... | **FIXED** |
| 128 | `TC_GVK_013` | 5. Giáo vụ khoa | Thống kê đề tài | Xem báo cáo danh mục đề tài toàn khoa theo từng bộ môn | Thống kê rõ ràng tỷ lệ đề tài do GV đề xuất (80%) và SV tự đ... | **NOT FIXED** |
| 129 | `TC_GVK_014` | 5. Giáo vụ khoa | Danh sách SV | Tra cứu danh sách toàn bộ Sinh viên trong khoa | Hiển thị danh sách SV khoa CNTT: MSSV, Họ tên, Lớp niên chế,... | **NOT FIXED** |
| 130 | `TC_GVK_015` | 5. Giáo vụ khoa | Tìm kiếm SV | Tìm kiếm sinh viên theo MSSV hoặc Họ tên | Hiển thị đúng sinh viên Trần Minh An khớp với từ khóa tìm ki... | **FIXED** |
| 131 | `TC_GVK_016` | 5. Giáo vụ khoa | Lọc Khóa SV | Lọc danh sách sinh viên theo từng Khóa niên chế (K20, K21, K22) | Danh sách chỉ hiển thị các sinh viên thuộc khóa K21.... | **NOT FIXED** |
| 132 | `TC_GVK_017` | 5. Giáo vụ khoa | Danh sách GV | Tra cứu danh sách Giảng viên trong khoa | Hiển thị: Mã GV, Họ tên, Học vị (ThS, TS, PGS), Chuyên môn n... | **FIXED** |
| 133 | `TC_GVK_018` | 5. Giáo vụ khoa | Tìm kiếm GV | Tìm kiếm giảng viên theo Tên hoặc Chuyên môn | Lọc ra các giảng viên có hướng nghiên cứu về Trí tuệ nhân tạ... | **FIXED** |
| 134 | `TC_GVK_019` | 5. Giáo vụ khoa | AI Phân tích | Giáo vụ khoa dùng AI Gemini phân tích khối lượng học vụ | AI phân tích tỷ lệ SV/GV, cảnh báo LHP bị quá tải sinh viên,... | **NOT FIXED** |
| 135 | `TC_GVK_020` | 5. Giáo vụ khoa | AI Phân tích | Xử lý khi AI Gemini phân tích bị lỗi mạng hoặc timeout | Thẻ AI hiển thị lỗi màu đỏ thân thiện: 'Không thể kết nối Ge... | **FIXED** |
| 136 | `TC_GVK_021` | 5. Giáo vụ khoa | Cảnh báo trễ hạn | Giáo vụ xem danh sách các nhóm sinh viên chưa nộp báo cáo tiến độ | Hiển thị danh sách các nhóm chưa nộp bài để giáo vụ gửi thôn... | **NOT FIXED** |
| 137 | `TC_GVK_022` | 5. Giáo vụ khoa | Thông báo Khoa | Giáo vụ nhận thông báo khi có giảng viên mới được bổ sung | Nhận được thông báo: 'Tài khoản Giảng viên [Tên GV] vừa được... | **NOT FIXED** |
| 138 | `TC_GVK_023` | 5. Giáo vụ khoa | Hồ sơ Giáo vụ | Xem thông tin chi tiết và cập nhật Số điện thoại giáo vụ | Cập nhật thành công thông tin liên hệ giáo vụ khoa.... | **FIXED** |
| 139 | `TC_GVK_024` | 5. Giáo vụ khoa | Avatar Giáo vụ | Đổi ảnh đại diện cho tài khoản Giáo vụ khoa | Ảnh tải lên thành công, cập nhật avatar giáo vụ trên toàn bộ... | **FIXED** |
| 140 | `TC_GVK_025` | 5. Giáo vụ khoa | Bảo mật Khoa | Giáo vụ khoa chỉ được xem và phân công LHP thuộc khoa mình | Chỉ hiển thị các môn của khoa CNTT, không hiển thị và không ... | **FIXED** |
| 141 | `TC_PDT_001` | 6. Phòng đào tạo | Dashboard Toàn trường | Giám sát số liệu đồ án tổng thể toàn trường (Liên khoa) | Hiển thị chuẩn xác: Tổng số Khoa, Tổng số LHP toàn trường, T... | **FIXED** |
| 142 | `TC_PDT_002` | 6. Phòng đào tạo | Dashboard Toàn trường | Thống kê so sánh số lượng đồ án giữa các Khoa khác nhau | Hiển thị tỷ lệ số lượng đề tài giữa các khoa (CNTT: 60%, Điệ... | **NOT FIXED** |
| 143 | `TC_PDT_003` | 6. Phòng đào tạo | Dashboard Toàn trường | Làm mới số liệu giám sát đào tạo cấp trường | Tải lại toàn bộ số liệu thống kê liên khoa mới nhất từ CSDL.... | **FIXED** |
| 144 | `TC_PDT_004` | 6. Phòng đào tạo | Cấu hình Học kỳ | Xem danh mục các Học kỳ và Năm học trong hệ thống | Hiển thị danh sách học kỳ: HK1 2026-2027, HK2 2026-2027, HK ... | **FIXED** |
| 145 | `TC_PDT_005` | 6. Phòng đào tạo | Cấu hình Học kỳ | Thiết lập Học kỳ hiện tại (Active Semester) áp dụng toàn trường | Cập nhật thành công, tất cả các phân hệ khác (Sinh viên, Giả... | **NOT FIXED** |
| 146 | `TC_PDT_006` | 6. Phòng đào tạo | Khung thời gian | Xem khung thời gian kế hoạch đồ án toàn trường | Hiển thị lịch trình chuẩn mực theo quy chế đào tạo của nhà t... | **NOT FIXED** |
| 147 | `TC_PDT_007` | 6. Phòng đào tạo | Quản lý LHP cấp trường | Xem danh mục tất cả các LHP toàn trường (Liên khoa) | Hiển thị toàn bộ LHP của các khoa với đầy đủ mã môn, giảng v... | **FIXED** |
| 148 | `TC_PDT_008` | 6. Phòng đào tạo | Lọc LHP theo Khoa | Lọc danh sách LHP theo từng Khoa cụ thể | Danh sách lọc chuẩn xác các lớp thuộc về khoa đã chọn.... | **FIXED** |
| 149 | `TC_PDT_009` | 6. Phòng đào tạo | Giám sát tiến độ | Giám sát các LHP chưa mở đợt đăng ký đồ án | Hiển thị danh sách các lớp chưa mở đợt để phòng đào tạo nhắc... | **NOT FIXED** |
| 150 | `TC_PDT_010` | 6. Phòng đào tạo | Giám sát tiến độ | Xem tỷ lệ sinh viên hoàn thành đồ án toàn trường | Hiển thị tỷ lệ % sinh viên đạt yêu cầu đồ án so với tổng số ... | **NOT FIXED** |
| 151 | `TC_PDT_011` | 6. Phòng đào tạo | AI Dự báo đào tạo | Phòng đào tạo dùng AI Gemini dự báo nhu cầu đào tạo | AI phân tích xu hướng công nghệ (Flutter, AI, Cloud...) và đ... | **NOT FIXED** |
| 152 | `TC_PDT_012` | 6. Phòng đào tạo | AI Dự báo công nghệ | AI phân tích xu hướng đề tài sinh viên quan tâm | AI xếp hạng các công nghệ hot (AI: 40%, Mobile: 30%, Web: 20... | **NOT FIXED** |
| 153 | `TC_PDT_013` | 6. Phòng đào tạo | AI Dự báo lỗi mạng | Xử lý khi AI Gemini dự báo gặp sự cố mất mạng | Hiển thị thông báo lỗi màu đỏ kèm nút 'Thử lại'. Không bị vă... | **NOT FIXED** |
| 154 | `TC_PDT_014` | 6. Phòng đào tạo | Toàn vẹn dữ liệu | Kiểm tra không có sinh viên mồ côi (không thuộc khoa nào) | 100% sinh viên đều được gán đúng vào một Khoa cụ thể trong C... | **NOT FIXED** |
| 155 | `TC_PDT_015` | 6. Phòng đào tạo | Quyền hạn độc lập | Phòng đào tạo chỉ có quyền giám sát, không can thiệp duyệt đề tài cụ thể của GV | Không có nút Duyệt/Từ chối đề tài (đảm bảo tính tự chủ học t... | **FIXED** |
| 156 | `TC_PDT_016` | 6. Phòng đào tạo | Báo cáo tổng kết | Xem bảng tổng hợp phổ điểm đồ án toàn trường | Hiển thị biểu đồ phân bổ điểm: Xuất sắc (9-10), Giỏi (8-8.9)... | **NOT FIXED** |
| 157 | `TC_PDT_017` | 6. Phòng đào tạo | Thông báo Đào tạo | Nhận thông báo khi có đợt đăng ký đồ án mới được kích hoạt | Hiện thông báo: 'Đợt đăng ký đồ án cho LHP [Tên LHP] vừa đượ... | **NOT FIXED** |
| 158 | `TC_PDT_018` | 6. Phòng đào tạo | Hồ sơ Đào tạo | Xem và cập nhật thông tin cán bộ Phòng đào tạo | Cập nhật thành công, thông tin lưu trữ an toàn vào Backend.... | **FIXED** |
| 159 | `TC_PDT_019` | 6. Phòng đào tạo | Avatar Đào tạo | Đổi ảnh đại diện cho tài khoản Phòng đào tạo | Ảnh đại diện cán bộ phòng đào tạo được cập nhật tức thì trên... | **FIXED** |
| 160 | `TC_PDT_020` | 6. Phòng đào tạo | Bảo mật Đào tạo | Chặn Phòng đào tạo truy cập các màn hình quản trị hệ thống của Admin | Hệ thống từ chối với HTTP 403 Forbidden. Phân quyền vai trò ... | **FIXED** |
| 161 | `TC_ADM_001` | 7. Quản trị hệ thống | Dashboard Admin | Hiển thị số liệu tổng quan người dùng toàn hệ thống | Hiển thị đúng tổng số: Người dùng, Sinh viên, Giảng viên, Lớ... | **FIXED** |
| 162 | `TC_ADM_002` | 7. Quản trị hệ thống | Biểu đồ vai trò | Hiển thị Biểu đồ thanh ngang phân bổ vai trò (Role Distribution) | Hiển thị 5 thanh ngang 5 màu tương ứng: Sinh viên (Xanh lá),... | **FIXED** |
| 163 | `TC_ADM_003` | 7. Quản trị hệ thống | Danh sách User | Xem danh sách toàn bộ người dùng trong hệ thống | Hiển thị: Avatar, Họ tên, Tên đăng nhập, Email, Số ĐT, Vai t... | **FIXED** |
| 164 | `TC_ADM_004` | 7. Quản trị hệ thống | Tìm kiếm User | Tìm kiếm người dùng theo Họ tên hoặc Tên đăng nhập | Lọc chính xác người dùng có tên hoặc username khớp từ khóa t... | **FIXED** |
| 165 | `TC_ADM_005` | 7. Quản trị hệ thống | Lọc vai trò | Lọc danh sách người dùng theo Vai trò (Role Filter) | Danh sách lập tức lọc đúng chỉ những tài khoản có vai trò tư... | **FIXED** |
| 166 | `TC_ADM_006` | 7. Quản trị hệ thống | Thêm User | Tạo tài khoản người dùng mới thủ công thành công | Tạo tài khoản thành công, xuất hiện ngay trong danh sách, có... | **FIXED** |
| 167 | `TC_ADM_007` | 7. Quản trị hệ thống | Validate User | Báo lỗi khi tạo tài khoản có Tên đăng nhập đã tồn tại | Báo lỗi: 'Tên đăng nhập đã tồn tại trong hệ thống'. Không ch... | **FIXED** |
| 168 | `TC_ADM_008` | 7. Quản trị hệ thống | Validate User | Validate định dạng Email khi tạo tài khoản | Báo lỗi: 'Email không đúng định dạng'.... | **FIXED** |
| 169 | `TC_ADM_009` | 7. Quản trị hệ thống | Khóa tài khoản | Khóa tài khoản người dùng (Toggle Status sang False) | Trạng thái đổi thành 'Đã khóa' (màu đỏ). Thử lấy tài khoản n... | **FIXED** |
| 170 | `TC_ADM_010` | 7. Quản trị hệ thống | Mở khóa User | Mở khóa tài khoản người dùng (Toggle Status sang True) | Trạng thái chuyển thành 'Hoạt động' (màu xanh). Người dùng c... | **FIXED** |
| 171 | `TC_ADM_011` | 7. Quản trị hệ thống | Reset mật khẩu | Admin đặt lại mật khẩu mặc định cho người dùng | Mật khẩu của tài khoản được đặt lại về '123456', người dùng ... | **FIXED** |
| 172 | `TC_ADM_012` | 7. Quản trị hệ thống | Import User | Tải file mẫu template CSV chuẩn | Tải thành công file mẫu về máy với đúng header: TênĐăngNhập,... | **FIXED** |
| 173 | `TC_ADM_013` | 7. Quản trị hệ thống | Import User | Tải file mẫu template Excel (.xlsx) chuẩn | Tải về file Excel mẫu có định dạng bảng và các cột chuẩn.... | **FIXED** |
| 174 | `TC_ADM_014` | 7. Quản trị hệ thống | Import User | Chọn file và hiển thị bảng Xem trước dữ liệu (Preview Table) | Hệ thống parse file thành công, hiển thị bảng Preview 5 dòng... | **FIXED** |
| 175 | `TC_ADM_015` | 7. Quản trị hệ thống | Import User | Tiến hành Import hàng loạt người dùng vào CSDL thành công | Tạo thành công toàn bộ 10 tài khoản. Báo cáo: 'Thành công: 1... | **FIXED** |
| 176 | `TC_ADM_016` | 7. Quản trị hệ thống | Import User | Báo cáo lỗi khi file import chứa một số tài khoản bị trùng lặp | Import thành công 5 tài khoản mới, 2 tài khoản trùng báo thấ... | **FIXED** |
| 177 | `TC_ADM_017` | 7. Quản trị hệ thống | Import User | Báo lỗi khi nạp file sai cấu trúc cột quy định | Báo lỗi: 'Cấu trúc file không đúng định dạng. Vui lòng tải f... | **FIXED** |
| 178 | `TC_ADM_018` | 7. Quản trị hệ thống | Nhật ký hệ thống | Xem nhật ký hoạt động hệ thống (Activity Log) | Hiển thị chi tiết: Thời gian, Người thực hiện, Hành động, Đị... | **FIXED** |
| 179 | `TC_ADM_019` | 7. Quản trị hệ thống | Validate SĐT | Validate trường Số điện thoại khi thêm người dùng (chỉ nhận số, 10-11 ký tự) | Báo lỗi: 'Số điện thoại phải từ 10-11 chữ số và không chứa k... | **FIXED** |
| 180 | `TC_ADM_020` | 7. Quản trị hệ thống | Import User | Xử lý file Excel/CSV có dòng trống xen kẽ | Hệ thống tự động bỏ qua các dòng rỗng, import chính xác 5 dò... | **FIXED** |
| 181 | `TC_ADM_021` | 7. Quản trị hệ thống | Import User | Import file Excel có số lượng lớn (50-100 tài khoản) | Quá trình nạp hiển thị thanh % rõ ràng, hoàn tất nạp 100 tài... | **FIXED** |
| 182 | `TC_ADM_022` | 7. Quản trị hệ thống | Đổi Vai trò | Admin chuyển đổi vai trò của người dùng (Role Migration) | Cập nhật vai trò thành công, người dùng đăng nhập lại sẽ nhậ... | **FIXED** |
| 183 | `TC_ADM_023` | 7. Quản trị hệ thống | Xóa tài khoản | Chặn xóa tài khoản người dùng đã có dữ liệu ràng buộc (FK constraint) | Hệ thống từ chối xóa và khuyến nghị sử dụng chức năng 'Khóa ... | **FIXED** |
| 184 | `TC_ADM_024` | 7. Quản trị hệ thống | Tìm kiếm nâng cao | Kết hợp Tìm kiếm từ khóa và Lọc đồng thời theo Vai trò | Chỉ hiển thị các Giảng viên có tên chứa chữ 'Nguyễn', không ... | **FIXED** |
| 185 | `TC_NFR_001` | 8. Phi chức năng & Bảo mật | Bảo mật API | Chặn gọi API nghiệp vụ khi không có JWT Bearer Token | Máy chủ trả về HTTP 401 Unauthorized. Không để lộ bất kỳ thô... | **FIXED** |
| 186 | `TC_NFR_002` | 8. Phi chức năng & Bảo mật | Bảo mật Token | Chặn gọi API khi JWT Token đã hết hạn (Expired Token) | Backend từ chối với HTTP 401. Ứng dụng tự động điều hướng ng... | **FIXED** |
| 187 | `TC_NFR_003` | 8. Phi chức năng & Bảo mật | Phân quyền RBAC | Sinh viên không được gọi API của Giảng viên (HTTP 403 Forbidden) | Máy chủ từ chối với HTTP 403 Forbidden. Đảm bảo phân quyền v... | **FIXED** |
| 188 | `TC_NFR_004` | 8. Phi chức năng & Bảo mật | Phân quyền RBAC | Giảng viên không được gọi API Quản trị viên (Admin) | Máy chủ từ chối với HTTP 403 Forbidden.... | **FIXED** |
| 189 | `TC_NFR_005` | 8. Phi chức năng & Bảo mật | Xử lý mất mạng | Ứng dụng xử lý an toàn khi mất kết nối mạng đột ngột | Không bị crash/văng app. Hiển thị thông báo lỗi thân thiện '... | **FIXED** |
| 190 | `TC_NFR_006` | 8. Phi chức năng & Bảo mật | Hiệu năng USB | Đo độ trễ phản hồi API qua cầu nối cáp USB (ADB Reverse) | Thời gian phản hồi trung bình < 200ms, trải nghiệm tức thì, ... | **FIXED** |
| 191 | `TC_NFR_007` | 8. Phi chức năng & Bảo mật | Hiệu năng Wi-Fi | Đo độ trễ phản hồi API qua mạng Wi-Fi LAN | Thời gian phản hồi < 500ms, dữ liệu tải mượt mà.... | **FIXED** |
| 192 | `TC_NFR_008` | 8. Phi chức năng & Bảo mật | Responsive UI | Giao diện hiển thị tốt trên các kích thước màn hình khác nhau | Giao diện co giãn chuẩn nhờ SingleChildScrollView và LayoutB... | **FIXED** |
| 193 | `TC_NFR_009` | 8. Phi chức năng & Bảo mật | Xoay màn hình | Kiểm tra giao diện khi xoay ngang điện thoại (Landscape) | Nội dung cuộn trơn tru, bàn phím ảo không che khuất nút bấm ... | **FIXED** |
| 194 | `TC_NFR_010` | 8. Phi chức năng & Bảo mật | Sao lưu CSDL | Hệ thống tự động sao lưu CSDL SQL Server trước khi vận hành | Tự động sinh ra 1 file .bak mới có gắn timestamp ngày giờ tr... | **FIXED** |
| 195 | `TC_NFR_011` | 8. Phi chức năng & Bảo mật | Khôi phục CSDL | Khôi phục dữ liệu từ bản sao lưu .bak khi gặp sự cố | Khôi phục toàn bộ bảng và dữ liệu về trạng thái hoàn hảo 100... | **FIXED** |
| 196 | `TC_NFR_012` | 8. Phi chức năng & Bảo mật | Bảo mật Avatar | Chặn tải lên file độc hại giả dạng file ảnh (File Upload Security) | Backend kiểm tra định dạng và MIME type thực tế, từ chối tải... | **FIXED** |
| 197 | `TC_NFR_013` | 8. Phi chức năng & Bảo mật | Bàn phím ảo | Kiểm tra bàn phím ảo không che khuất các ô nhập liệu phía dưới | Màn hình tự động cuộn lên trên (ViewInsets padding), con trỏ... | **FIXED** |
| 198 | `TC_NFR_014` | 8. Phi chức năng & Bảo mật | Cử chỉ Back | Cử chỉ vuốt quay lại (Gesture Back) khi đang nhập dở dữ liệu form | Hiển thị hộp thoại xác nhận: 'Bạn có muốn hủy bỏ thông tin đ... | **FIXED** |
| 199 | `TC_NFR_015` | 8. Phi chức năng & Bảo mật | Bộ nhớ & RAM | Kiểm tra mức độ tiêu thụ RAM khi sử dụng app liên tục 30 phút | Dung lượng RAM ổn định trong khoảng 150MB - 250MB, không bị ... | **FIXED** |
| 200 | `TC_NFR_016` | 8. Phi chức năng & Bảo mật | Khôi phục State | Khôi phục trạng thái app khi bị đưa xuống nền (Background) trong thời gian dài | App phục hồi đúng ngay màn hình Chi tiết đề tài đang xem, kh... | **FIXED** |
