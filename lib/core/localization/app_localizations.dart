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
    };

    if (!isEnglish) return value;

    return map[value] ?? value;
  }

  static String source(String value) {
    const map = {
      'Giảng viên': 'Lecturer',
      'Sinh viên đề xuất': 'Student proposal',
    };

    if (!isEnglish) return value;

    return map[value] ?? value;
  }

  static String role(String value) {
    const map = {
      'Sinh viên': 'Student',
      'Trưởng nhóm': 'Group Leader',
      'Thành viên': 'Member',
      'Giảng viên': 'Lecturer',
      'Giáo vụ khoa': 'Faculty Academic Officer',
      'Phòng đào tạo': 'Academic Affairs Office',
      'Quản trị viên': 'Administrator',
    };

    if (!isEnglish) return value;

    return map[value] ?? value;
  }

  static String courseName(String value) {
    const map = {
      'Lập trình di động': 'Mobile Application Development',
      'Nhập môn Big Data': 'Introduction to Big Data',
      'Internet of Things': 'Internet of Things',
    };

    if (!isEnglish) return value;

    return map[value] ?? value;
  }

  static String topicText(String value) {
    const map = {
      'Ứng dụng quản lý đăng ký đồ án':
          'Project Registration Management Application',

      'Xây dựng ứng dụng hỗ trợ sinh viên đăng ký nhóm và đồ án môn học.':
          'Build an application that supports students in registering groups and course projects.',

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
    };

    if (!isEnglish) return value;

    return map[value] ?? value;
  }

  static String groupName(String value) {
    const map = {
      'Nhóm ProGroup': 'ProGroup Group',
      'Nhóm Mobile Team': 'Mobile Team',
    };

    if (!isEnglish) return value;

    return map[value] ?? value;
  }

  static String memberCount(int current, int max) {
    if (isEnglish) {
      return '$current/$max members';
    }

    return '$current/$max thành viên';
  }

  static String courseCode(String value) {
    return value;
  }

  static String lecturer(String value) {
    return value;
  }

  static String semester(String value) {
    return value;
  }

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
    'adminDemo': 'Admin: admin / Admin@123',

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
    'adminDemo': 'Admin: admin / Admin@123',

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
