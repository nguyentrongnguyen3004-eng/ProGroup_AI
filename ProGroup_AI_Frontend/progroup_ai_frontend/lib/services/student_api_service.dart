import 'dart:async';

import '../models/course_model.dart';
import '../models/group_model.dart';
import '../models/topic_model.dart';
import '../models/user_profile_model.dart';
import 'api_service.dart';

class StudentApiService {
  StudentApiService._();
  static final StudentApiService instance = StudentApiService._();

  /// Tải danh sách lớp học phần của sinh viên
  Future<List<CourseModel>> fetchMyCourses() async {
    dynamic res;
    try {
      res = await ApiService.instance.get('/api/student/courses');
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        res = await ApiService.instance.get('/api/lop-hoc-phan');
      } else {
        rethrow;
      }
    }

    final List<dynamic> list;
    if (res is List) {
      list = res;
    } else if (res is Map && res['value'] is List) {
      list = res['value'] as List;
    } else if (res is Map && res['data'] is List) {
      list = res['data'] as List;
    } else {
      list = [];
    }

    return list
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tải danh sách nhóm của sinh viên
  Future<List<GroupModel>> fetchMyGroups() async {
    dynamic res;
    try {
      res = await ApiService.instance.get('/api/student/groups');
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        try {
          res = await ApiService.instance.get('/api/groups/mine');
        } on ApiException catch (inner) {
          if (inner.statusCode == 404) {
            res = await ApiService.instance.get('/api/groups');
          } else {
            rethrow;
          }
        }
      } else {
        rethrow;
      }
    }

    final List<dynamic> list;
    if (res is List) {
      list = res;
    } else if (res is Map && res['value'] is List) {
      list = res['value'] as List;
    } else if (res is Map && res['data'] is List) {
      list = res['data'] as List;
    } else {
      list = [];
    }

    return list
        .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tải danh sách đề tài đồ án
  Future<List<TopicModel>> fetchTopics({int? dotDangKyId}) async {
    final path = dotDangKyId != null
        ? '/api/de-tai?dotDangKyId=$dotDangKyId'
        : '/api/de-tai';
    final res = await ApiService.instance.get(path);

    final List<dynamic> list;
    if (res is List) {
      list = res;
    } else if (res is Map && res['value'] is List) {
      list = res['value'] as List;
    } else if (res is Map && res['data'] is List) {
      list = res['data'] as List;
    } else {
      list = [];
    }

    return list
        .map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tải thông tin hồ sơ sinh viên
  Future<UserProfileModel> fetchProfile() async {
    dynamic res;
    try {
      res = await ApiService.instance.get('/api/profile');
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        res = await ApiService.instance.get('/api/auth/me');
      } else {
        rethrow;
      }
    }

    if (res is Map<String, dynamic>) {
      return UserProfileModel.fromJson(res);
    }
    throw ApiException('Dữ liệu hồ sơ người dùng không hợp lệ.');
  }

  /// Đăng ký đề tài cho nhóm
  Future<void> registerTopic(int nhomId, int deTaiId) async {
    try {
      await ApiService.instance.post('/api/dang-ky-de-tai', {
        'nhomId': nhomId,
        'deTaiId': deTaiId,
      });
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        await ApiService.instance.post('/api/de-tai/dang-ky', {
          'nhomId': nhomId,
          'deTaiId': deTaiId,
        });
      } else {
        rethrow;
      }
    }
  }

  /// Tải danh sách thông báo
  Future<List<dynamic>> fetchNotifications() async {
    final res = await ApiService.instance.get('/api/notifications');
    if (res is List) {
      return res;
    } else if (res is Map && res['value'] is List) {
      return res['value'] as List;
    } else if (res is Map && res['data'] is List) {
      return res['data'] as List;
    }
    return [];
  }

  /// Tải số lượng thông báo chưa đọc
  Future<int> fetchUnreadCount() async {
    try {
      final res =
          await ApiService.instance.get('/api/notifications/unread-count');
      if (res is Map && res.containsKey('count')) {
        return res['count'] as int? ?? 0;
      }
      if (res is Map && res.containsKey('unreadCount')) {
        return res['unreadCount'] as int? ?? 0;
      }
      if (res is int) return res;
    } catch (_) {
      // Bỏ qua lỗi và chuyển sang đếm thủ công từ danh sách thông báo
    }

    try {
      final notifs = await fetchNotifications();
      return notifs.where((n) {
        if (n is Map) {
          final isRead = n['isRead'] as bool? ??
              !(n['unread'] as bool? ?? false);
          return !isRead;
        }
        return false;
      }).length;
    } catch (_) {
      return 0;
    }
  }

  /// Đề xuất đề tài mới từ sinh viên
  Future<void> proposeTopic({
    required int dotDangKyId,
    required String tenDeTai,
    String? moTa,
    String? mucTieu,
    String? phamVi,
    String? congNgheDuKien,
  }) async {
    await ApiService.instance.post('/api/de-tai/de-xuat', {
      'dotDangKyId': dotDangKyId,
      'tenDeTai': tenDeTai,
      'moTa': moTa,
      'mucTieu': mucTieu,
      'phamVi': phamVi,
      'congNgheDuKien': congNgheDuKien,
    });
  }

  /// Tạo nhóm mới trong đợt đăng ký đồ án
  Future<Map<String, dynamic>> createGroup({
    required int dotDangKyId,
    required String tenNhom,
  }) async {
    final res = await ApiService.instance.post('/api/groups', {
      'dotDangKyId': dotDangKyId,
      'tenNhom': tenNhom,
    });
    if (res is Map<String, dynamic>) {
      return res;
    }
    return {'tenNhom': tenNhom};
  }

  /// Tải thông tin chi tiết một nhóm
  Future<Map<String, dynamic>?> fetchGroupDetail(int nhomId) async {
    try {
      final res = await ApiService.instance.get('/api/groups/$nhomId');
      if (res is Map<String, dynamic>) return res;
    } catch (_) {}
    return null;
  }

  /// Tải thông tin đề tài đã đăng ký của nhóm
  Future<Map<String, dynamic>?> fetchGroupTopicRegistration(int nhomId) async {
    try {
      final res = await ApiService.instance.get('/api/dang-ky-de-tai/cua-nhom/$nhomId');
      if (res is List && res.isNotEmpty) {
        return res.first as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Tải danh sách lời mời của nhóm
  Future<List<Map<String, dynamic>>> fetchGroupInvitations(int nhomId) async {
    try {
      final res = await ApiService.instance.get('/api/groups/$nhomId/invitations');
      if (res is List) return res.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  /// Mời sinh viên vào nhóm bằng MSSV
  Future<void> inviteMember({required int nhomId, required String mssv}) async {
    await ApiService.instance.post('/api/groups/$nhomId/invitations', {
      'mssv': mssv,
    });
  }

  /// Hủy lời mời
  Future<void> cancelInvitation({required int nhomId, required int invitationId}) async {
    await ApiService.instance.delete('/api/groups/$nhomId/invitations/$invitationId');
  }

  /// Tải danh sách yêu cầu gia nhập nhóm
  Future<List<Map<String, dynamic>>> fetchGroupJoinRequests(int nhomId) async {
    try {
      final res = await ApiService.instance.get('/api/groups/$nhomId/join-requests');
      if (res is List) return res.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  /// Sinh viên gửi yêu cầu xin vào nhóm
  Future<void> requestToJoinGroup(int nhomId) async {
    await ApiService.instance.post('/api/groups/$nhomId/join-requests', {});
  }

  /// Trưởng nhóm duyệt hoặc từ chối yêu cầu gia nhập
  Future<void> respondJoinRequest({
    required int nhomId,
    required int requestId,
    required bool accept,
  }) async {
    await ApiService.instance.put('/api/groups/$nhomId/join-requests/$requestId', {
      'accept': accept,
    });
  }

  /// Đổi tên nhóm và lưu vào database
  Future<void> updateGroupName(int groupId, String newName) async {
    await ApiService.instance.put('/api/groups/$groupId', {
      'tenNhom': newName,
    });
  }

  /// Sinh viên rời nhóm
  Future<void> leaveGroup(int groupId) async {
    await ApiService.instance.post('/api/groups/$groupId/leave', {});
  }

  /// Trưởng nhóm giải tán nhóm
  Future<void> disbandGroup(int groupId) async {
    await ApiService.instance.delete('/api/groups/$groupId');
  }

  /// Hủy đăng ký đề tài khi đang chờ duyệt
  Future<void> cancelTopicRegistration(int registrationId) async {
    await ApiService.instance.delete('/api/dang-ky-de-tai/$registrationId');
  }

  /// Lấy danh sách báo cáo tiến độ của nhóm
  Future<List<Map<String, dynamic>>> fetchGroupReports(int groupId) async {
    try {
      final res = await ApiService.instance.get('/api/bao-cao/nhom/$groupId');
      if (res is List) return res.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  /// Sinh viên nộp báo cáo tiến độ
  Future<void> submitProgressReport({
    required int nhomId,
    required String tieuDe,
    String? noiDung,
    String? fileUrl,
    String? githubUrl,
    String? demoUrl,
    int tuanBaoCao = 1,
  }) async {
    await ApiService.instance.post('/api/bao-cao', {
      'nhomId': nhomId,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'fileUrl': fileUrl,
      'githubUrl': githubUrl,
      'demoUrl': demoUrl,
      'tuanBaoCao': tuanBaoCao,
    });
  }
}
