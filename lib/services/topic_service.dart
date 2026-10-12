import '../core/network/api_client.dart';
import '../models/topic_model.dart';

import '../models/topic_registration_model.dart';

class TopicService {
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
  ];

  static final List<TopicRegistrationModel> registrations = [
    TopicRegistrationModel(
      id: 1,
      groupId: 101,
      topicId: 1,
      status: 'Chờ duyệt',
      registeredAt: DateTime(2026, 9, 20),
    ),
    TopicRegistrationModel(
      id: 2,
      groupId: 102,
      topicId: 2,
      status: 'Đã duyệt',
      registeredAt: DateTime(2026, 9, 19),
    ),
    TopicRegistrationModel(
      id: 3,
      groupId: 104,
      topicId: 3,
      status: 'Từ chối',
      registeredAt: DateTime(2026, 9, 18),
      rejectionReason: 'Đề tài đã khóa do nhóm gửi đăng ký sau thời hạn.',
    ),
  ];

  Future<List<TopicModel>> getLecturerTopics({int? dotDangKyId}) async {
    try {
      final endpoint = dotDangKyId != null
          ? '/de-tai/lecturer-topics?dotDangKyId=$dotDangKyId'
          : '/de-tai/lecturer-topics';
      final response = await ApiClient.get(endpoint);
      final List<dynamic> data = response is List ? response : [];
      return data.map((json) => TopicModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải đề tài của giảng viên: $e');
    }
  }

  Future<TopicModel> createTopic(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.post('/de-tai', data);
      return TopicModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi tạo đề tài: $e');
    }
  }

  Future<TopicModel> updateTopic(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.put('/de-tai/$id', data);
      return TopicModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật đề tài: $e');
    }
  }

  Future<void> deleteTopic(int id) async {
    try {
      await ApiClient.delete('/de-tai/$id');
    } catch (e) {
      throw Exception('Lỗi khi xóa đề tài: $e');
    }
  }

  Future<List<TopicModel>> getTopicsByPeriod(int periodId) async {
    try {
      final response = await ApiClient.get('/de-tai?dotDangKyId=$periodId');
      final List<dynamic> data = response is List ? response : [];
      return data.map((json) => TopicModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đề tài: $e');
    }
  }

  Future<TopicModel> getTopicDetail(int id) async {
    try {
      final response = await ApiClient.get('/de-tai/$id');
      return TopicModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi lấy chi tiết đề tài: $e');
    }
  }

  Future<void> registerTopic({
    required int periodId,
    required int groupId,
    required int topicId,
  }) async {
    try {
      await ApiClient.post('/de-tai/dang-ky', {
        'nhomId': groupId,
        'deTaiId': topicId,
      });
    } catch (e) {
      throw Exception('Lỗi khi đăng ký đề tài: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopicRegistrations() async {
    try {
      final response = await ApiClient.get('/de-tai/registrations');
      final List<dynamic> data = response is List ? response : [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đăng ký đề tài: $e');
    }
  }

  Future<void> decideRegistration(int id, {required bool approve, String? note}) async {
    try {
      await ApiClient.put('/de-tai/registrations/$id/decide', {
        'dongY': approve,
        'ghiChu': note,
      });
    } catch (e) {
      throw Exception('Lỗi khi duyệt đăng ký đề tài: $e');
    }
  }
}
