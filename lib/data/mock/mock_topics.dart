import '../../models/topic_model.dart';

class MockTopics {
  static const List<TopicModel> topics = [
    // ============================================================
    // HỌC PHẦN: LẬP TRÌNH DI ĐỘNG - courseId = 1
    // ============================================================
    TopicModel(
      id: 1,
      courseId: 1,
      title: 'Ứng dụng quản lý đăng ký đồ án',
      description:
          'Xây dựng ứng dụng hỗ trợ sinh viên đăng ký nhóm và đồ án môn học.',
      objective:
          'Hỗ trợ sinh viên tạo nhóm, tham gia nhóm và đăng ký đề tài môn học.',
      scope:
          'Sinh viên, giảng viên và quản lý việc đăng ký nhóm và đồ án môn học.',
      technology: 'Flutter, ASP.NET Core, SQL Server',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 2,
      courseId: 1,
      title: 'Ứng dụng quản lý chi tiêu cá nhân',
      description:
          'Xây dựng ứng dụng giúp người dùng quản lý và theo dõi các khoản chi tiêu.',
      objective:
          'Giúp người dùng theo dõi thu chi và thống kê tình hình tài chính cá nhân.',
      scope: 'Quản lý khoản thu, khoản chi, danh mục và thống kê.',
      technology: 'Flutter, Firebase',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 3,
      courseId: 1,
      title: 'Ứng dụng đặt lịch học',
      description:
          'Xây dựng ứng dụng hỗ trợ sinh viên theo dõi và quản lý lịch học.',
      objective:
          'Giúp sinh viên quản lý lịch học và nhận thông báo về các buổi học.',
      scope: 'Quản lý lịch học, thông báo và lịch cá nhân.',
      technology: 'Flutter, Firebase',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 4,
      courseId: 1,
      title: 'Ứng dụng bản đồ thông minh',
      description:
          'Xây dựng ứng dụng bản đồ hỗ trợ tìm kiếm địa điểm và hiển thị tuyến đường.',
      objective: 'Hỗ trợ người dùng tìm kiếm địa điểm và xác định tuyến đường.',
      scope: 'Tìm kiếm địa điểm, xác định vị trí và hiển thị tuyến đường.',
      technology: 'Flutter, Google Maps API',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    // ============================================================
    // HỌC PHẦN: NHẬP MÔN BIG DATA - courseId = 2
    // ============================================================
    TopicModel(
      id: 5,
      courseId: 2,
      title: 'Phân tích dữ liệu sinh viên',
      description:
          'Phân tích dữ liệu học tập nhằm tìm ra các xu hướng và thông tin hữu ích.',
      objective:
          'Sử dụng dữ liệu sinh viên để phân tích kết quả và hành vi học tập.',
      scope: 'Dữ liệu điểm số, quá trình học tập và thông tin liên quan.',
      technology: 'Python, Pandas, Spark',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 6,
      courseId: 2,
      title: 'Phân tích dữ liệu bán hàng',
      description:
          'Phân tích dữ liệu bán hàng để xác định xu hướng mua sắm của khách hàng.',
      objective: 'Khai thác dữ liệu giao dịch để hỗ trợ phân tích kinh doanh.',
      scope: 'Dữ liệu sản phẩm, khách hàng và giao dịch bán hàng.',
      technology: 'Python, Spark, Power BI',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 7,
      courseId: 2,
      title: 'Hệ thống gợi ý sản phẩm',
      description:
          'Xây dựng hệ thống gợi ý sản phẩm dựa trên dữ liệu tương tác của người dùng.',
      objective: 'Đề xuất các sản phẩm phù hợp dựa trên hành vi người dùng.',
      scope: 'Phân tích lịch sử xem, tìm kiếm và mua sản phẩm.',
      technology: 'Python, Machine Learning, Spark',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    // ============================================================
    // HỌC PHẦN: INTERNET OF THINGS - courseId = 3
    // ============================================================
    TopicModel(
      id: 8,
      courseId: 3,
      title: 'Hệ thống cảnh báo rò rỉ gas và cháy',
      description:
          'Xây dựng mô hình mô phỏng hệ thống phát hiện rò rỉ gas và cháy.',
      objective: 'Phát hiện nguy cơ rò rỉ gas hoặc cháy và đưa ra cảnh báo.',
      scope: 'Giám sát nồng độ gas, phát hiện lửa và cảnh báo người dùng.',
      technology: 'ESP32, MQ-2, Flame Sensor, Blynk',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 9,
      courseId: 3,
      title: 'Hệ thống tưới cây tự động',
      description:
          'Xây dựng hệ thống theo dõi độ ẩm đất và tự động điều khiển tưới cây.',
      objective: 'Tự động duy trì độ ẩm phù hợp cho cây trồng.',
      scope: 'Đo độ ẩm đất và điều khiển máy bơm.',
      technology: 'ESP32, Soil Moisture Sensor',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 10,
      courseId: 3,
      title: 'Hệ thống giám sát nhiệt độ',
      description:
          'Theo dõi nhiệt độ môi trường và cảnh báo khi nhiệt độ vượt ngưỡng.',
      objective: 'Giám sát nhiệt độ theo thời gian thực.',
      scope: 'Đo nhiệt độ và gửi cảnh báo khi vượt ngưỡng.',
      technology: 'ESP32, DHT11, Blynk',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),

    TopicModel(
      id: 11,
      courseId: 3,
      title: 'Mô hình nhà thông minh',
      description:
          'Xây dựng mô hình nhà thông minh có khả năng giám sát và điều khiển thiết bị.',
      objective: 'Điều khiển các thiết bị trong nhà thông qua hệ thống IoT.',
      scope: 'Điều khiển đèn, quạt và các thiết bị điện.',
      technology: 'ESP32, Relay, Blynk',
      source: 'Giảng viên đề xuất',
      status: 'Chưa đăng ký',
    ),
  ];

  // ============================================================
  // LẤY ĐỀ TÀI THEO HỌC PHẦN
  // ============================================================

  static List<TopicModel> getByCourse(int courseId) {
    return topics.where((topic) => topic.courseId == courseId).toList();
  }

  // ============================================================
  // LẤY ĐỀ TÀI THEO ID
  // ============================================================

  static TopicModel? getById(int topicId) {
    try {
      return topics.firstWhere((topic) => topic.id == topicId);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ĐẾM ĐỀ TÀI CỦA HỌC PHẦN
  // ============================================================

  static int countByCourse(int courseId) {
    return topics.where((topic) => topic.courseId == courseId).length;
  }
}
