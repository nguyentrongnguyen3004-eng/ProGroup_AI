import '../../models/topic_model.dart';

class MockLecturerTopics {
  static final List<TopicModel> topics = [
    TopicModel(
      id: 1,
      courseId: 1,
      title: 'Ứng dụng quản lý nhóm đồ án',
      description: 'Ứng dụng hỗ trợ sinh viên tạo nhóm và quản lý thành viên.',
      objective: 'Quản lý nhóm và thành viên trong lớp học phần.',
      scope: 'Sinh viên trong lớp học phần.',
      technology: 'Flutter, ASP.NET Core, SQL Server',
      source: 'Giảng viên',
      status: 'Đang hoạt động',
    ),
    TopicModel(
      id: 2,
      courseId: 1,
      title: 'Hệ thống gợi ý đề tài bằng AI',
      description: 'Hệ thống sử dụng AI để hỗ trợ sinh viên lựa chọn đề tài.',
      objective: 'Đề xuất đề tài phù hợp dựa trên yêu cầu của sinh viên.',
      scope: 'Ứng dụng hỗ trợ sinh viên.',
      technology: 'Flutter, ASP.NET Core, AI',
      source: 'Giảng viên',
      status: 'Đang hoạt động',
    ),
    TopicModel(
      id: 3,
      courseId: 1,
      title: 'Ứng dụng quản lý học tập',
      description: 'Ứng dụng hỗ trợ sinh viên quản lý lịch học và nhiệm vụ.',
      objective: 'Hỗ trợ sinh viên theo dõi hoạt động học tập.',
      scope: 'Sinh viên đại học.',
      technology: 'Flutter, Firebase',
      source: 'Sinh viên đề xuất',
      status: 'Đã khóa',
    ),
    TopicModel(
      id: 4,
      courseId: 1,
      title: 'Ứng dụng điểm danh thông minh',
      description: 'Ứng dụng hỗ trợ điểm danh bằng mã QR.',
      objective: 'Giảm thời gian điểm danh trong lớp học.',
      scope: 'Lớp học phần.',
      technology: 'Flutter, QR Code, Firebase',
      source: 'AI đề xuất',
      status: 'Chờ duyệt',
    ),
    TopicModel(
      id: 8,
      courseId: 3,
      title: 'Hệ thống cảnh báo rò rỉ gas',
      description: 'Hệ thống mô phỏng phát hiện khí gas và cảnh báo.',
      objective: 'Phát hiện và cảnh báo tình trạng rò rỉ gas.',
      scope: 'Mô hình IoT mô phỏng.',
      technology: 'ESP32, MQ-2, Flutter',
      source: 'Giảng viên',
      status: 'Đang hoạt động',
    ),
  ];

  static List<TopicModel> getByCourse(int courseId) {
    return topics.where((topic) => topic.courseId == courseId).toList();
  }

  static TopicModel? getById(int id) {
    try {
      return topics.firstWhere((topic) => topic.id == id);
    } catch (_) {
      return null;
    }
  }

  static void add(TopicModel topic) {
    topics.add(topic);
  }

  static void update(TopicModel topic) {
    final index = topics.indexWhere((item) => item.id == topic.id);

    if (index != -1) {
      topics[index] = topic;
    }
  }

  static void updateStatus(int id, String status) {
    final index = topics.indexWhere((item) => item.id == id);

    if (index == -1) return;

    final topic = topics[index];
    topics[index] = TopicModel(
      id: topic.id,
      courseId: topic.courseId,
      title: topic.title,
      description: topic.description,
      objective: topic.objective,
      scope: topic.scope,
      technology: topic.technology,
      source: topic.source,
      status: status,
    );
  }

  static void delete(int id) {
    topics.removeWhere((topic) => topic.id == id);
  }
}
