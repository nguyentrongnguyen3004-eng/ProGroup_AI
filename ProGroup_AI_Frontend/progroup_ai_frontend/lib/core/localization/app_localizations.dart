import '../settings/app_settings.dart';

class AppLocalizations {
  static String get language => AppSettings.instance.language;

  static bool get isEnglish => language == 'en';

  static String t(String key) {
    final map = isEnglish ? _en : _vi;
    return map[key] ?? key;
  }

  static String text(String vi, {required String en}) {
    return isEnglish ? en : vi;
  }

  /// Tự động dịch một chuỗi tiếng Việt sang tiếng Anh nếu đang bật English
  static String tr(String vi) {
    if (!isEnglish) return vi;
    return _viToEn[vi.trim()] ?? vi;
  }

  static String status(String value) {
    const map = {
      'Đang đăng ký': 'Registration open',
      'Chưa mở': 'Not open',
      'Đang hoạt động': 'Active',
      'Chưa đăng ký': 'Not registered',
      'Chờ duyệt': 'Pending approval',
      'Đã duyệt': 'Approved',
      'Từ chối': 'Rejected',
      'Cần chỉnh sửa': 'Needs revision',
      'Đang học': 'Studying',
      'Đã nghỉ': 'Inactive',
      'Đang công tác': 'Working',
      'Đang giảng dạy': 'Teaching',
      'Tạm ngưng': 'Suspended',
      'Đã khóa': 'Locked',
      'Không hoạt động': 'Inactive',
    };

    if (!isEnglish) return value;
    return map[value.trim()] ?? _viToEn[value.trim()] ?? value;
  }

  static String source(String value) {
    const map = {
      'Giảng viên': 'Lecturer',
      'Sinh viên đề xuất': 'Student proposal',
    };

    if (!isEnglish) return value;
    return map[value.trim()] ?? value;
  }

  static String role(String value) {
    const map = {
      'Sinh viên': 'Student',
      'Trưởng nhóm': 'Group Leader',
      'Thành viên': 'Member',
      'Giảng viên': 'Lecturer',
      'Giáo vụ khoa': 'Faculty Academic Officer',
      'Phòng đào tạo': 'Academic Affairs Office',
      'Phòng Đào tạo': 'Academic Affairs Office',
      'Quản trị viên': 'Administrator',
      'Admin': 'Administrator',
    };

    if (!isEnglish) return value;
    return map[value.trim()] ?? value;
  }

  static String courseName(String value) {
    const map = {
      'Lập trình di động': 'Mobile Application Development',
      'Nhập môn Big Data': 'Introduction to Big Data',
      'Internet of Things': 'Internet of Things',
    };

    if (!isEnglish) return value;
    return map[value.trim()] ?? value;
  }

  static String topicText(String value) {
    const map = {
      'Ứng dụng quản lý đăng ký đồ án':
          'Project Registration Management Application',
      'Xây dựng ứng dụng hỗ trợ sinh viên đăng ký nhóm và đồ án môn học.':
          'Build an application that supports students in registering groups and course projects.',
      'Hỗ trợ sinh viên tạo nhóm, tham gia nhóm và đăng ký đề tài môn học.':
          'Help students create groups, join groups, and register for course topics.',
      'Sinh viên, giảng viên và quản lý việc đăng ký nhóm và đồ án môn học.':
          'Students, lecturers, and management of group and course project registrations.',
      'Quản lý nhóm, đề tài và quá trình đăng ký đồ án.':
          'Manage groups, topics, and the project registration process.',
      'Sinh viên, giảng viên và quản lý trong phạm vi một khoa.':
          'Students, lecturers, and administrators within a faculty.',
      'Ứng dụng quản lý công việc nhóm': 'Group Task Management Application',
      'Ứng dụng hỗ trợ các thành viên theo dõi công việc trong nhóm.':
          'An application that helps members track tasks within a group.',
      'Theo dõi tiến độ và phân công công việc.':
          'Track progress and assign tasks.',
      'Các nhóm sinh viên thực hiện đồ án.':
          'Student groups working on course projects.',
      'Hệ thống gợi ý đề tài bằng AI': 'AI-Powered Topic Recommendation System',
      'Ứng dụng sử dụng AI để hỗ trợ sinh viên tìm kiếm và xây dựng ý tưởng đề tài.':
          'An AI-powered application that helps students find and develop project ideas.',
      'Hỗ trợ sinh viên phát triển ý tưởng đề tài phù hợp.':
          'Help students develop suitable project ideas.',
      'Sinh viên và giảng viên.': 'Students and lecturers.',
      'Ứng dụng quản lý nhóm đồ án': 'Project Group Management App',
      'Ứng dụng hỗ trợ sinh viên tạo nhóm và quản lý thành viên.':
          'Application to help students create groups and manage members.',
      'Quản lý nhóm và thành viên trong lớp học phần.':
          'Manage groups and members in course sections.',
      'Sinh viên trong lớp học phần.': 'Students in the course section.',
      'Ứng dụng quản lý học tập': 'Study Management Application',
      'Ứng dụng hỗ trợ sinh viên quản lý lịch học và nhiệm vụ.':
          'Application helping students manage class schedules and tasks.',
      'Hỗ trợ sinh viên theo dõi hoạt động học tập.':
          'Support students in tracking academic activities.',
      'Sinh viên đại học.': 'University students.',
      'Ứng dụng điểm danh thông minh': 'Smart Attendance Application',
      'Ứng dụng hỗ trợ điểm danh bằng mã QR.':
          'Application supporting attendance check via QR code.',
      'Giảm thời gian điểm danh trong lớp học.':
          'Reduce attendance checking time in class.',
      'Lớp học phần.': 'Course section.',
      'Hệ thống cảnh báo rò rỉ gas': 'Gas Leak Warning System',
      'Hệ thống cảnh báo rò rỉ gas và cháy': 'Gas Leak and Fire Warning System',
      'Hệ thống mô phỏng phát hiện khí gas và cảnh báo.':
          'Simulation system detecting gas leakage and alerting.',
      'Xây dựng mô hình mô phỏng hệ thống phát hiện rò rỉ gas và cháy.':
          'Build simulation model for gas leakage and fire detection.',
      'Phát hiện nguy cơ rò rỉ gas hoặc cháy và đưa ra cảnh báo.':
          'Detect risks of gas leaks or fires and issue warnings.',
      'Giám sát nồng độ gas, phát hiện lửa và cảnh báo người dùng.':
          'Monitor gas concentration, detect flame, and alert users.',
      'Phát hiện và cảnh báo tình trạng rò rỉ gas.':
          'Detect and warn against gas leakage.',
      'Mô hình IoT mô phỏng.': 'IoT simulation model.',
      'Hệ thống sử dụng AI để hỗ trợ sinh viên lựa chọn đề tài.':
          'System using AI to assist students in selecting topics.',
      'Đề xuất đề tài phù hợp dựa trên yêu cầu của sinh viên.':
          'Propose suitable topics based on student requirements.',
      'Ứng dụng hỗ trợ sinh viên.': 'Application supporting students.',
      'AI đề xuất': 'AI Suggestion',
      'Ứng dụng quản lý chi tiêu cá nhân': 'Personal Expense Tracker App',
      'Xây dựng ứng dụng giúp người dùng quản lý và theo dõi các khoản chi tiêu.':
          'Build an application to help users manage and track personal expenses.',
      'Giúp người dùng theo dõi thu chi và thống kê tình hình tài chính cá nhân.':
          'Help users track income/expense and view financial statistics.',
      'Quản lý khoản thu, khoản chi, danh mục và thống kê.':
          'Manage income, expense, categories, and financial statistics.',
      'Ứng dụng đặt lịch học': 'Class Schedule Booking App',
      'Xây dựng ứng dụng hỗ trợ sinh viên theo dõi và quản lý lịch học.':
          'Build an application to help students track and manage class schedules.',
      'Giúp sinh viên quản lý lịch học và nhận thông báo về các buổi học.':
          'Help students manage schedules and receive notifications for classes.',
      'Quản lý lịch học, thông báo và lịch cá nhân.':
          'Manage class schedules, notifications, and personal calendars.',
      'Ứng dụng bản đồ thông minh': 'Smart Map Application',
      'Xây dựng ứng dụng bản đồ hỗ trợ tìm kiếm địa điểm và hiển thị tuyến đường.':
          'Build a map app supporting location search and route display.',
      'Hỗ trợ người dùng tìm kiếm địa điểm và xác định tuyến đường.':
          'Help users search locations and identify routes.',
      'Tìm kiếm địa điểm, xác định vị trí và hiển thị tuyến đường.':
          'Search places, determine locations, and display routes.',
      'Phân tích dữ liệu sinh viên': 'Student Data Analytics',
      'Phân tích dữ liệu học tập nhằm tìm ra các xu hướng và thông tin hữu ích.':
          'Analyze learning data to uncover trends and useful insights.',
      'Sử dụng dữ liệu sinh viên để phân tích kết quả và hành vi học tập.':
          'Use student data to analyze learning performance and behavior.',
      'Dữ liệu điểm số, quá trình học tập và thông tin liên quan.':
          'Grade records, study progress, and relevant information.',
      'Phân tích dữ liệu bán hàng': 'Sales Data Analytics',
      'Phân tích dữ liệu bán hàng để xác định xu hướng mua sắm của khách hàng.':
          'Analyze sales data to determine customer shopping trends.',
      'Khai thác dữ liệu giao dịch để hỗ trợ phân tích kinh doanh.':
          'Mine transactional data to support business analytics.',
      'Dữ liệu sản phẩm, khách hàng và giao dịch bán hàng.':
          'Product catalog, customer profiles, and sales transactions.',
      'Hệ thống gợi ý sản phẩm': 'Product Recommendation System',
      'Xây dựng hệ thống gợi ý sản phẩm dựa trên dữ liệu tương tác của người dùng.':
          'Build a product recommendation system based on user interaction data.',
      'Đề xuất các sản phẩm phù hợp dựa trên hành vi người dùng.':
          'Suggest relevant products based on user behavior.',
      'Phân tích lịch sử xem, tìm kiếm và mua sản phẩm.':
          'Analyze viewing, search, and purchase histories.',
      'Hệ thống tưới cây tự động': 'Automated Plant Watering System',
      'Xây dựng hệ thống theo dõi độ ẩm đất và tự động điều khiển tưới cây.':
          'Build a system to monitor soil moisture and automate irrigation.',
      'Tự động duy trì độ ẩm phù hợp cho cây trồng.':
          'Automatically maintain appropriate moisture for crops.',
      'Đo độ ẩm đất và điều khiển máy bơm.':
          'Measure soil moisture and control water pump.',
      'Hệ thống giám sát nhiệt độ': 'Temperature Monitoring System',
      'Theo dõi nhiệt độ môi trường và cảnh báo khi nhiệt độ vượt ngưỡng.':
          'Monitor ambient temperature and alert when thresholds are exceeded.',
      'Giám sát nhiệt độ theo thời gian thực.':
          'Real-time temperature monitoring.',
      'Đo nhiệt độ và gửi cảnh báo khi vượt ngưỡng.':
          'Measure temperature and send alert upon exceeding threshold.',
      'Mô hình nhà thông minh': 'Smart Home Model',
      'Xây dựng mô hình nhà thông minh có khả năng giám sát và điều khiển thiết bị.':
          'Build a smart home model capable of monitoring and controlling appliances.',
      'Điều khiển các thiết bị trong nhà thông qua hệ thống IoT.':
          'Control home appliances through an IoT system.',
      'Điều khiển đèn, quạt và các thiết bị điện.':
          'Control lights, fans, and electrical appliances.',
    };

    if (!isEnglish) return value;
    return map[value.trim()] ?? _viToEn[value.trim()] ?? value;
  }

  static String groupName(String value) {
    const map = {
      'Nhóm ProGroup': 'ProGroup Group',
      'Nhóm Mobile Team': 'Mobile Team',
      'Nhóm Chưa Chọn Đề Tài': 'Unassigned Topic Group',
    };

    if (!isEnglish) return value;
    return map[value.trim()] ?? _viToEn[value.trim()] ?? value;
  }

  static String memberCount(int current, int max) {
    if (isEnglish) {
      return '$current/$max members';
    }
    return '$current/$max thành viên';
  }

  static String courseCode(String value) => value;
  static String lecturer(String value) => value;
  static String semester(String value) => value;

  /// Bản đồ dịch thuật tự động từ Tiếng Việt sang Tiếng Anh
  static const Map<String, String> _viToEn = {
    // Header & điều hướng
    'Trang chủ': 'Home',
    'Nhóm': 'Groups',
    'Thông báo': 'Notifications',
    'Cá nhân': 'Profile',
    'Tổng quan': 'Overview',
    'Lớp học phần': 'Course Classes',
    'Đề tài': 'Topics',
    'Dữ liệu': 'Data',
    'Công cụ': 'Tools',
    'Quản lý': 'Management',
    'Người dùng': 'Users',
    'Quản trị hệ thống': 'System Administration',
    'Phòng Đào tạo': 'Academic Affairs',
    'Phòng đào tạo': 'Academic Affairs',
    'Giáo vụ khoa': 'Faculty Academic Affairs',
    'Xin chào 👋': 'Hello 👋',
    'Cài đặt': 'Settings',
    'Phiên bản': 'Version',
    'Trợ giúp': 'Help',
    'Đăng xuất': 'Log Out',

    // Thẻ & Thống kê
    'Sinh viên': 'Students',
    'Giảng viên': 'Lecturers',
    'Đăng ký chờ duyệt': 'Pending Registrations',
    'Đăng ký đã duyệt': 'Approved Registrations',
    'Đăng ký đề tài': 'Topic Registrations',
    'Đề xuất sinh viên': 'Student Proposals',
    'Gợi ý đề tài': 'Topic Suggestions',
    'Thống kê nâng cao': 'Advanced Analytics',
    'Tổng quan dữ liệu khoa': 'Faculty Data Overview',
    'Tổng quan đào tạo': 'Academic Overview',
    'Tổng quan hệ thống': 'System Overview',
    'Lớp học phần của tôi': 'My Course Classes',
    'Lớp học phần phụ trách': 'Assigned Course Classes',
    'Thông báo gần đây': 'Recent Notifications',
    'Mã học phần': 'Course code',
    'Lớp': 'Class',
    'GV': 'Lecturer',
    'Trưởng nhóm': 'Group Leader',
    'Thành viên': 'Members',
    'Trạng thái': 'Status',
    'Học kỳ': 'Semester',
    'Chờ xử lý': 'Pending',
    'Học phần': 'Courses',
    'Nhật ký hoạt động': 'Activity Log',
    'Quản lý vai trò': 'Role Management',
    'Tài khoản': 'Accounts',
    'Tổng người dùng': 'Total Users',
    'Dữ liệu nền': 'System Data',
    'Nhóm/đồ án': 'Groups/Projects',
    'Trạng thái hệ thống': 'System Status',
    'Tài khoản đang hoạt động': 'Active Accounts',
    'Tài khoản đã khóa': 'Locked Accounts',
    'Tài khoản mới thêm': 'New Accounts Added',
    'Quản lý sinh viên': 'Manage Students',
    'Quản lý lớp học phần': 'Course Class Management',
    'Truy cập nhanh': 'Quick Access',
    'Tác vụ nhanh': 'Quick Actions',
    'Import dữ liệu': 'Import Data',
    'Phân công giảng viên': 'Assign Lecturers',
    'Theo dõi đăng ký đồ án': 'Track Project Registrations',
    'Quản lý danh sách, phân công và theo dõi đăng ký đồ án.':
        'Manage lists, assignments, and track project registrations.',
    'Nhập danh sách sinh viên, giảng viên hoặc lớp học phần.':
        'Import students, lecturers, or course classes.',
    'Xem và cập nhật giảng viên phụ trách lớp.':
        'View and update assigned lecturers for classes.',
    'Xem số nhóm và trạng thái đăng ký đề tài.':
        'View group count and topic registration status.',
    'Quản lý sinh viên, giảng viên và dữ liệu học tập toàn trường.':
        'Manage students, lecturers, and institution-wide academic data.',
    'Tìm kiếm hồ sơ và xem tình trạng học tập.':
        'Search records and review enrollment status.',
    'Theo dõi học kỳ và giảng viên phụ trách.':
        'Review semesters and assigned lecturers.',
    'Theo dõi lớp, nhóm và tiến độ đề tài.':
        'Track classes, groups, and topic progress.',
    'Chưa có lớp học phần được phân công.':
        'No assigned course classes yet.',
    'Chưa có lớp học phần.': 'No course classes yet.',
    'Chưa có thông báo mới.': 'No new notifications.',
    'Bạn chưa tham gia nhóm nào': 'You have not joined any group yet',
    'Hãy vào một lớp học phần để tạo hoặc tham gia nhóm.':
        'Open a course to create or join a group.',
    'Hoạt động gần đây': 'Recent Activity',
    'Bạn đang là trưởng nhóm.': 'You are the group leader.',
    'Lớp LTDD-01 đang mở đăng ký.': 'Class LTDD-01 is open for registration.',

    // Thông tin tài khoản
    'Họ và tên': 'Full Name',
    'MSSV': 'Student ID',
    'Mã cán bộ': 'Staff ID',
    'Mã GV': 'Lecturer ID',
    'Email': 'Email',
    'Điện thoại': 'Phone',
    'Khoa': 'Faculty',
    'Bộ môn': 'Department',
    'Khoa Công nghệ thông tin': 'Faculty of Information Technology',
    'Bộ môn Công nghệ phần mềm': 'Department of Software Engineering',
    'Bộ môn Hệ thống thông tin': 'Department of Information Systems',
    'Bộ môn Mạng máy tính': 'Department of Computer Networks',
    'Bộ môn Khoa học máy tính': 'Department of Computer Science',
    'Khoa Điện tử viễn thông': 'Faculty of Electronics & Telecommunications',
    'Khoa Kinh tế': 'Faculty of Economics',
    'Bộ môn Quản trị kinh doanh': 'Department of Business Administration',
    'Chức vụ': 'Position',
    'Chuyên viên đào tạo': 'Academic Affairs Specialist',
    'Chuyên viên giáo vụ': 'Faculty Academic Affairs Specialist',
    'Quản trị viên hệ thống': 'System Administrator',
    'Đơn vị': 'Unit',
    'Số điện thoại': 'Phone',
    'Học vị': 'Academic Degree',
    'Vai trò': 'Role',
    'Đổi mật khẩu': 'Change Password',
    'Đổi email': 'Change Email',
    'Bảo mật tài khoản': 'Account Security',
    'Giao diện': 'Theme',
    'Ngôn ngữ': 'Language',
    'Theo hệ thống': 'System default',
    'Sáng': 'Light',
    'Tối': 'Dark',
    'Đang hoạt động': 'Active',
    'Không hoạt động': 'Inactive',
    'Đã khóa': 'Locked',

    // Nút & Thao tác
    'Lưu': 'Save',
    'Hủy': 'Cancel',
    'Đóng': 'Close',
    'Xác nhận': 'Confirm',
    'Tiếp tục': 'Continue',
    'Quay lại': 'Back',
    'Tìm kiếm': 'Search',
    'Lọc': 'Filter',
    'Tất cả': 'All',
    'Thêm': 'Add',
    'Sửa': 'Edit',
    'Xóa': 'Delete',
    'Khóa': 'Lock',
    'Mở khóa': 'Unlock',
    'Import Excel': 'Import Excel',
    'Xuất báo cáo': 'Export Report',
    'Chi tiết': 'Details',
    'Xem chi tiết': 'View details',

    // Khóa bổ sung
    'Chi tiết lớp học phần': 'Course Details',
    'Thông tin đăng ký': 'Registration Information',
    'Số thành viên nhóm': 'Group size',
    'Đăng ký nhóm': 'Group registration',
    'Hạn đăng ký đề tài': 'Topic deadline',
    'Xem đề tài': 'View Topics',
    'Xem nhóm': 'View Groups',
    'Nhóm của tôi': 'My Groups',
    'Đăng ký đồ án': 'Project Registration',
    'Quản lý nhóm và lựa chọn đề tài cho môn học.':
        'Manage groups and choose topics for your course.',
    '3 - 5 sinh viên': '3 - 5 students',
    'Đổi email thành công': 'Email changed successfully',
    'Đổi email thành công.': 'Email changed successfully.',
    'Đổi mật khẩu thành công': 'Password changed successfully',
    'Đổi mật khẩu thành công.': 'Password changed successfully.',
    'Bạn có chắc chắn muốn đăng xuất không?':
        'Are you sure you want to log out?',
    'Cài đặt ứng dụng': 'App Settings',
    'Thông tin': 'Information',
    'Thông tin cá nhân': 'Personal Information',
    'Cập nhật mật khẩu đăng nhập': 'Update your login password',
    'OTP và xác thực email': 'OTP and email verification',
    'Trung tâm trợ giúp ProGroup AI.': 'ProGroup AI Help Center.',
    'Lịch sử hoạt động': 'Activity History',
    'Thêm người dùng': 'Add User',
    'Đang tải dữ liệu...': 'Loading data...',
    'Đang tải...': 'Loading...',
    'Không có dữ liệu': 'No data available',
    // Thao tác nhanh & Dashboard
    'Kho đề tài': 'Topic list',
    'Duyệt nhóm đăng ký': 'Group registrations',
    'Ý tưởng của SV': 'Student ideas',
    'Báo cáo phân tích': 'Analytics reports',
    'Gợi ý đề tài AI': 'AI Topic Assistant',
    'Trợ lý thông minh hỗ trợ tạo & gợi ý đề tài':
        'Smart assistant for topic generation & ideas',
    'HỌC KỲ HIỆN TẠI': 'CURRENT SEMESTER',
    'lớp': 'classes',

    // Thông báo & thời gian
    'Sinh viên đề xuất đề tài mới': 'Student proposed a new topic',
    'Nhóm sinh viên vừa gửi một đề tài mới cần bạn duyệt.':
        'A student group just submitted a new topic for your review.',
    'Có đăng ký đề tài mới': 'New topic registration',
    'Nhóm ProGroup đã đăng ký đề tài và đang chờ duyệt.':
        'ProGroup group registered a topic and is waiting for approval.',
    'Có nhóm mới': 'New group created',
    'Một nhóm mới đã được tạo trong lớp LTDD-01.':
        'A new group was created in class LTDD-01.',
    'Bạn được mời vào nhóm': 'You were invited to a group',
    'Nhóm ProGroup đã gửi lời mời tham gia nhóm.':
        'Group ProGroup sent you an invitation to join.',
    'Đăng ký đề tài đã được mở': 'Topic registration is now open',
    'Giảng viên đã mở thời gian đăng ký đề tài cho lớp LTDD-01.':
        'The lecturer has opened topic registration for class LTDD-01.',
    'Đề tài đã được duyệt': 'Topic has been approved',
    'Đề tài "Hệ thống gợi ý đề tài bằng AI" đã được duyệt.':
        'The topic "AI-Powered Topic Recommendation System" has been approved.',
    'Đăng nhập thành công': 'Login successful',
    'Tài khoản của bạn vừa đăng nhập trên thiết bị hiện tại.':
        'Your account was just logged in on the current device.',
    'Đã mở đăng ký lớp LTDD-01': 'Registration open for class LTDD-01',
    'Lớp Lập trình di động đã sẵn sàng để sinh viên đăng ký trong học kỳ HK7 - 2026.':
        'Mobile Application Development class is ready for student registration in semester HK7 - 2026.',
    'Cần rà soát phân công giảng dạy': 'Review teaching assignments',
    'Kiểm tra giảng viên phụ trách cho các lớp học phần trước khi chốt thời khóa biểu.':
        'Check assigned lecturers for course classes before finalizing the timetable.',
    'Danh sách sinh viên đã được cập nhật': 'Student list updated',
    'Dữ liệu sinh viên học kỳ hiện tại đã được cập nhật trong hệ thống.':
        'Current semester student data has been updated in the system.',
    'Đã cập nhật dữ liệu sinh viên': 'Student data updated',
    'Danh sách sinh viên đã được rà soát và đồng bộ trong dữ liệu Giáo vụ khoa.':
        'Student list has been reviewed and synced in Faculty Academic Affairs data.',
    'Có thay đổi phân công giảng viên': 'Lecturer assignment changed',
    'Phân công giảng viên cho một lớp học phần vừa được cập nhật.':
        'Lecturer assignment for a course class has just been updated.',
    'Có dữ liệu cần kiểm tra': 'Data needs review',
    'Một số dòng import chưa hợp lệ. Hãy mở màn hình import để xem lỗi theo dòng.':
        'Some imported rows are invalid. Open the import screen to view line errors.',
    'Danh sách lớp học phần đã sẵn sàng': 'Course class list ready',
    'Dữ liệu lớp học phần hiện có thể được tìm kiếm và xem chi tiết.':
        'Course class data can now be searched and viewed in detail.',
    'Chào mừng quản trị viên': 'Welcome Administrator',
    'Module quản trị hệ thống đã sẵn sàng.':
        'System administration module is ready.',
    'Bạn có thể quản lý các tài khoản mock trong hệ thống.':
        'You can manage mock accounts in the system.',
    'Lịch sử dữ liệu': 'Data history',
    'Dữ liệu import được tổng hợp từ các module hiện có.':
        'Imported data is aggregated from existing modules.',

    // Thời gian tương đối
    '10 phút trước': '10 minutes ago',
    '1 giờ trước': '1 hour ago',
    '2 giờ trước': '2 hours ago',
    'Hôm qua': 'Yesterday',
    '2 ngày trước': '2 days ago',
    '3 ngày trước': '3 days ago',
    '1 tuần trước': '1 week ago',
    'Vừa xong': 'Just now',
    'vừa xong': 'Just now',

    // Hoạt động & quyền hạn
    'Đăng nhập': 'Login',
    'Tài khoản Admin đăng nhập thành công.':
        'Admin account logged in successfully.',
    'Đã đồng bộ danh mục học phần mẫu.': 'Synced sample course list.',
    'Hệ thống': 'System',
    'Đăng ký lớp học phần': 'Register course classes',
    'Tạo và tham gia nhóm': 'Create and join groups',
    'Chọn đề tài': 'Select topics',
    'Chat nhóm': 'Group chat',
    'Quản lý profile': 'Manage profile',
    'Phân công giảng dạy': 'Teaching assignments',
    'Quản lý đề tài': 'Manage topics',
    'Duyệt đề tài': 'Approve topics',
    'Theo dõi tiến độ nhóm': 'Track group progress',
    'Đánh giá điểm': 'Grading',
    'Đăng ký nhóm & đồ án môn học': 'Group & project course registration',

    // Nhóm & đề tài chi tiết
    'Nhóm Chưa Chọn Đề Tài': 'Unassigned Topic Group',
    'Đã đủ thành viên': 'Full members',
    'Ứng dụng quản lý nhóm đồ án': 'Project Group Management App',
    'Ứng dụng hỗ trợ sinh viên tạo nhóm và quản lý thành viên.':
        'Application helping students create groups and manage members.',
    'Quản lý nhóm và thành viên trong lớp học phần.':
        'Manage groups and members in course classes.',
    'Sinh viên trong lớp học phần.': 'Students in course class.',
    'Ứng dụng quản lý học tập': 'Study Management Application',
    'Ứng dụng hỗ trợ sinh viên quản lý lịch học và nhiệm vụ.':
        'Application helping students manage class schedules and assignments.',
    'Hỗ trợ sinh viên theo dõi hoạt động học tập.':
        'Help students track academic activities.',
    'Sinh viên đại học.': 'University students.',
    'Ứng dụng điểm danh thông minh': 'Smart Attendance Application',
    'Ứng dụng hỗ trợ điểm danh bằng mã QR.':
        'Application supporting attendance check via QR code.',
    'Giảm thời gian điểm danh trong lớp học.':
        'Reduce attendance checking time in class.',
    'Lớp học phần.': 'Course class.',
    'Hệ thống cảnh báo rò rỉ gas': 'Gas Leak Warning System',
    'Hệ thống mô phỏng phát hiện khí gas và cảnh báo.':
        'Simulation system detecting gas leakage and alerting.',
    'Phát hiện và cảnh báo tình trạng rò rỉ gas.':
        'Detect and warn against gas leakage.',
    'Mô hình IoT mô phỏng.': 'IoT simulation model.',
    'Hệ thống sử dụng AI để hỗ trợ sinh viên lựa chọn đề tài.':
        'System using AI to assist students in selecting topics.',
    'Đề xuất đề tài phù hợp dựa trên yêu cầu của sinh viên.':
        'Propose suitable topics based on student requirements.',
    'Ứng dụng hỗ trợ sinh viên.': 'Application supporting students.',
    'AI đề xuất': 'AI Suggestion',

    // Import đề tài
    'Import đề tài': 'Import Topics',
    'Xem trước import': 'Import Preview',
    'Chọn lớp học phần': 'Select Course Class',
    'Chọn định dạng file': 'Select File Format',
    'Tải file mẫu': 'Download Template',
    'Chọn file': 'Select File',
    'Xem trước trước khi nhập': 'Preview Before Import',
    'Tải mẫu CSV': 'Download CSV Template',
    'Tải mẫu Excel': 'Download Excel Template',
    'Chọn file CSV': 'Choose CSV file',
    'Chọn file Excel (.xlsx)': 'Choose Excel (.xlsx) file',
    'Tiếp tục xem trước': 'Continue to preview',
    'File text': 'Text file',
    'Đọc được': 'Read',
    'Hợp lệ': 'Valid',
    'Lỗi': 'Errors',
    'Dòng': 'Row',
    'Không có dòng hợp lệ': 'No valid rows',
    'Xác nhận import': 'Confirm Import',
    'Không có dòng dữ liệu để xem trước.': 'No data rows to preview.',
    '(thiếu tên đề tài)': '(missing topic title)',
    'sẽ cấp khi hợp lệ': 'Assigned upon import',
    'Mã đề tài': 'Topic Code',
    'Tên đề tài': 'Topic Name',
    'Mục tiêu': 'Objectives',
    'Phạm vi': 'Scope',
    'Công nghệ sử dụng': 'Technologies',
    'Nguồn đề xuất': 'Proposed source',
    'Import đề tài thành công': 'Topic import successful',
    'Import đề tài không thành công': 'Topic import failed',
    'Không còn dòng hợp lệ để import. Hãy kiểm tra lại dữ liệu.':
        'No valid rows left to import. Please check data.',
    'Vui lòng chọn lớp học phần trước.': 'Please select a course class first.',
    'Vui lòng chọn file trước.': 'Please select a file first.',
    'Không có nội dung CSV để đọc.': 'No CSV content to read.',
    'Không có dữ liệu Excel để đọc.': 'No Excel data to read.',
    'File không có dòng đề tài để xem trước.':
        'File has no topic rows to preview.',
  };

  static const Map<String, String> _vi = {
    'home': 'Trang chủ',
    'groups': 'Nhóm',
    'notifications': 'Thông báo',
    'profile': 'Cá nhân',
    'hello': 'Xin chào 👋',
    'projectRegistration': 'Đăng ký đồ án',
    'projectRegistrationDescription':
        'Quản lý nhóm và lựa chọn đề tài cho môn học của bạn.',
    'courseClasses': 'Lớp học phần',
    'quickAccess': 'Truy cập nhanh',
    'topic': 'Đề tài',
    'topics': 'Đề tài',
    'aiTopicSupport': 'AI hỗ trợ đề tài',
    'myGroup': 'Nhóm của tôi',
    'createGroup': 'Tạo nhóm',
    'joinGroup': 'Tham gia nhóm',
    'groupMembers': 'Thành viên',
    'groupStatus': 'Trạng thái nhóm',
    'openGroupChat': 'Mở chat nhóm',
    'groupChat': 'Chat nhóm',
    'groupLeader': 'Trưởng nhóm',
    'member': 'Thành viên',
    'course': 'Lớp học phần',
    'courseCode': 'Mã học phần',
    'class': 'Lớp',
    'lecturer': 'Giảng viên',
    'semester': 'Học kỳ',
    'topicDetail': 'Chi tiết đề tài',
    'topicDescription': 'Mô tả',
    'objective': 'Mục tiêu',
    'scope': 'Phạm vi',
    'technology': 'Công nghệ dự kiến',
    'searchTopic': 'Tìm kiếm đề tài...',
    'addTopic': 'Thêm đề tài',
    'proposeTopic': 'Đề xuất đề tài',
    'aiProposal': 'AI hỗ trợ đề xuất',
    'registerTopic': 'ĐĂNG KÝ ĐỀ TÀI',
    'registerTopicTitle': 'Đăng ký đề tài',
    'registerTopicQuestion': 'Bạn có chắc muốn đăng ký đề tài này cho nhóm?',
    'cancel': 'Hủy',
    'register': 'Đăng ký',
    'registrationSent': 'Đã gửi yêu cầu đăng ký.',
    'notificationsEmpty': 'Chưa có thông báo mới.',
    'notificationTitle': 'Thông báo',
    'topicApproved': 'Đề tài đã được duyệt',
    'topicApprovedDescription': 'Đề tài của nhóm bạn đã được giảng viên duyệt.',
    'groupInvitation': 'Lời mời tham gia nhóm',
    'groupInvitationDescription':
        'Bạn nhận được lời mời tham gia một nhóm đồ án.',
    'personalInformation': 'Thông tin cá nhân',
    'username': 'Tên đăng nhập',
    'email': 'Email',
    'role': 'Vai trò',
    'changePassword': 'Đổi mật khẩu',
    'editInformation': 'Chỉnh sửa thông tin',
    'language': 'Ngôn ngữ',
    'vietnamese': 'Tiếng Việt',
    'english': 'English',
    'theme': 'Giao diện',
    'system': 'Theo hệ thống',
    'light': 'Sáng',
    'dark': 'Tối',
    'notificationsSetting': 'Thông báo',
    'logout': 'Đăng xuất',
    'login': 'ĐĂNG NHẬP',
    'forgotPassword': 'Quên mật khẩu?',
    'loginErrorEmpty': 'Vui lòng nhập đầy đủ thông tin.',
    'loginErrorInvalid': 'Tên đăng nhập hoặc mật khẩu không đúng.',
    'demoAccount': 'Tài khoản demo',
    'studentDemo': 'Sinh viên: sv001 / 123456',
    'adminDemo': 'Admin: admin / 123456',
    'forgotPasswordTitle': 'Quên mật khẩu',
    'recoverPassword': 'Khôi phục mật khẩu',
    'recoverPasswordDescription':
        'Nhập email tài khoản. Mã OTP sẽ được gửi đến email của bạn.',
    'sendOtp': 'GỬI MÃ OTP',
    'emailRequired': 'Vui lòng nhập email.',
    'verifyOtp': 'Xác thực OTP',
    'enterOtp': 'Nhập mã OTP',
    'otpSent': 'Mã OTP đã được gửi đến',
    'otpInvalidLength': 'OTP phải gồm 6 chữ số.',
    'otpInvalid': 'Mã OTP không đúng.',
    'confirm': 'XÁC NHẬN',
    'demoOtp': 'Demo OTP: 123456',
    'resetPassword': 'Đặt lại mật khẩu',
    'createNewPassword': 'Tạo mật khẩu mới',
    'newPassword': 'Mật khẩu mới',
    'enterNewPassword': 'Nhập mật khẩu mới',
    'confirmPassword': 'Xác nhận mật khẩu',
    'enterPasswordAgain': 'Nhập lại mật khẩu',
    'resetPasswordButton': 'ĐẶT LẠI MẬT KHẨU',
    'passwordTooShort': 'Mật khẩu phải có ít nhất 6 ký tự.',
    'passwordNotMatch': 'Mật khẩu xác nhận không khớp.',
    'passwordResetSuccess': 'Đặt lại mật khẩu thành công.',
    'chatInput': 'Nhập tin nhắn...',
    'settings': 'Cài đặt',
    'version': 'Phiên bản',
  };

  static const Map<String, String> _en = {
    'home': 'Home',
    'groups': 'Groups',
    'notifications': 'Notifications',
    'profile': 'Profile',
    'hello': 'Hello 👋',
    'projectRegistration': 'Project Registration',
    'projectRegistrationDescription':
        'Manage groups and choose topics for your course.',
    'courseClasses': 'Course Classes',
    'quickAccess': 'Quick Access',
    'topic': 'Topic',
    'topics': 'Topics',
    'aiTopicSupport': 'AI Topic Assistant',
    'myGroup': 'My Group',
    'createGroup': 'Create Group',
    'joinGroup': 'Join Group',
    'groupMembers': 'Members',
    'groupStatus': 'Group Status',
    'openGroupChat': 'Open Group Chat',
    'groupChat': 'Group Chat',
    'groupLeader': 'Group Leader',
    'member': 'Member',
    'course': 'Course Class',
    'courseCode': 'Course Code',
    'class': 'Class',
    'lecturer': 'Lecturer',
    'semester': 'Semester',
    'topicDetail': 'Topic Details',
    'topicDescription': 'Description',
    'objective': 'Objective',
    'scope': 'Scope',
    'technology': 'Expected Technology',
    'searchTopic': 'Search topics...',
    'addTopic': 'Add Topic',
    'proposeTopic': 'Propose Topic',
    'aiProposal': 'AI Topic Assistant',
    'registerTopic': 'REGISTER TOPIC',
    'registerTopicTitle': 'Register Topic',
    'registerTopicQuestion':
        'Are you sure you want to register this topic for your group?',
    'cancel': 'Cancel',
    'register': 'Register',
    'registrationSent': 'Registration request has been sent.',
    'notificationsEmpty': 'No new notifications.',
    'notificationTitle': 'Notifications',
    'topicApproved': 'Topic Approved',
    'topicApprovedDescription':
        'Your group topic has been approved by the lecturer.',
    'groupInvitation': 'Group Invitation',
    'groupInvitationDescription':
        'You have received an invitation to join a project group.',
    'personalInformation': 'Personal Information',
    'username': 'Username',
    'email': 'Email',
    'role': 'Role',
    'changePassword': 'Change Password',
    'editInformation': 'Edit Information',
    'language': 'Language',
    'vietnamese': 'Tiếng Việt',
    'english': 'English',
    'theme': 'Theme',
    'system': 'System',
    'light': 'Light',
    'dark': 'Dark',
    'notificationsSetting': 'Notifications',
    'logout': 'Log Out',
    'login': 'LOGIN',
    'forgotPassword': 'Forgot password?',
    'loginErrorEmpty': 'Please enter all required information.',
    'loginErrorInvalid': 'Incorrect username or password.',
    'demoAccount': 'Demo Account',
    'studentDemo': 'Student: sv001 / 123456',
    'adminDemo': 'Admin: admin / 123456',
    'forgotPasswordTitle': 'Forgot Password',
    'recoverPassword': 'Recover Password',
    'recoverPasswordDescription':
        'Enter your account email. An OTP code will be sent to your email.',
    'sendOtp': 'SEND OTP',
    'emailRequired': 'Please enter your email.',
    'verifyOtp': 'Verify OTP',
    'enterOtp': 'Enter OTP',
    'otpSent': 'The OTP code has been sent to',
    'otpInvalidLength': 'OTP must contain 6 digits.',
    'otpInvalid': 'Incorrect OTP code.',
    'confirm': 'CONFIRM',
    'demoOtp': 'Demo OTP: 123456',
    'resetPassword': 'Reset Password',
    'createNewPassword': 'Create New Password',
    'newPassword': 'New Password',
    'enterNewPassword': 'Enter new password',
    'confirmPassword': 'Confirm Password',
    'enterPasswordAgain': 'Enter password again',
    'resetPasswordButton': 'RESET PASSWORD',
    'passwordTooShort': 'Password must contain at least 6 characters.',
    'passwordNotMatch': 'Password confirmation does not match.',
    'passwordResetSuccess': 'Password reset successfully.',
    'chatInput': 'Enter a message...',
    'settings': 'Settings',
    'version': 'Version',
  };
}
