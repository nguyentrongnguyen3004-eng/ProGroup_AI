import '../../models/topic_model.dart';

class MockTopics {
  static const List<TopicModel> topics = [
    TopicModel(
      id: 1,
      title: 'Ứng dụng quản lý đăng ký đồ án',
      description:
          'Xây dựng ứng dụng hỗ trợ sinh viên đăng ký nhóm và đồ án môn học.',
      objective:
          'Quản lý nhóm, đề tài và quá trình đăng ký đồ án.',
      scope:
          'Sinh viên, giảng viên và quản lý trong phạm vi một khoa.',
      technology:
          'Flutter, ASP.NET Core Web API, SQL Server',
      source: 'Giảng viên',
      status: 'Chưa đăng ký',
    ),
    TopicModel(
      id: 2,
      title: 'Ứng dụng quản lý công việc nhóm',
      description:
          'Ứng dụng hỗ trợ các thành viên theo dõi công việc trong nhóm.',
      objective:
          'Theo dõi tiến độ và phân công công việc.',
      scope:
          'Các nhóm sinh viên thực hiện đồ án.',
      technology:
          'Flutter, ASP.NET Core, SQL Server',
      source: 'Giảng viên',
      status: 'Chưa đăng ký',
    ),
    TopicModel(
      id: 3,
      title: 'Hệ thống gợi ý đề tài bằng AI',
      description:
          'Ứng dụng sử dụng AI để hỗ trợ sinh viên tìm kiếm và xây dựng ý tưởng đề tài.',
      objective:
          'Hỗ trợ sinh viên phát triển ý tưởng đề tài phù hợp.',
      scope:
          'Sinh viên và giảng viên.',
      technology:
          'Flutter, ASP.NET Core, AI API',
      source: 'Sinh viên đề xuất',
      status: 'Chờ duyệt',
    ),
  ];
}