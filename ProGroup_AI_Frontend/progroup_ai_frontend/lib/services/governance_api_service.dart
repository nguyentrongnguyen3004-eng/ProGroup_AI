import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'admin_api_service.dart';
import 'data_cache_service.dart';

class GovernanceApiService {
  GovernanceApiService._();
  static final GovernanceApiService instance = GovernanceApiService._();

  /// Bộ đếm thay đổi dữ liệu Giáo vụ để các tab trong IndexedStack tự đồng bộ
  final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

  void notifyDataChanged() {
    DataCacheService.instance.invalidateAll();
    dataVersion.value = dataVersion.value + 1;
  }

  Future<List<Map<String, dynamic>>> fetchKhoas({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_khoas',
      () async {
        try {
          final res = await ApiService.instance.get('/api/governance/khoas');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCourses({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_courses',
      () async {
        try {
          final res = await ApiService.instance.get('/api/governance/courses');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        try {
          final res = await ApiService.instance.get('/api/lop-hoc-phan');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> fetchStudents({
    String? khoaCode,
    bool forceRefresh = false,
  }) async {
    final key = 'gov_students_${khoaCode ?? 'all'}';
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      key,
      () async {
        try {
          final path = (khoaCode != null && khoaCode.isNotEmpty)
              ? '/api/governance/students?khoaCode=${Uri.encodeComponent(khoaCode)}'
              : '/api/governance/students';
          final res = await ApiService.instance.get(path);
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  /// Danh sách SV trong 1 lớp học phần (đầy đủ: MSSV, Họ tên, Lớp niên chế, Email, SĐT, Nhóm/Đề tài)
  Future<List<Map<String, dynamic>>> fetchClassStudents(
    int lopHocPhanId, {
    bool forceRefresh = false,
  }) async {
    final key = 'gov_class_students_$lopHocPhanId';
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      key,
      () async {
        try {
          final res = await ApiService.instance
              .get('/api/governance/class-students?lopHocPhanId=$lopHocPhanId');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  /// Danh sách nhóm đã thành lập của lớp kèm thành viên & đề tài tương ứng
  Future<List<Map<String, dynamic>>> fetchClassGroups(
    int lopHocPhanId, {
    bool forceRefresh = false,
  }) async {
    final key = 'gov_class_groups_$lopHocPhanId';
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      key,
      () async {
        try {
          final res = await ApiService.instance
              .get('/api/governance/class-groups?lopHocPhanId=$lopHocPhanId');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  /// SV chưa đăng ký nhóm hoặc chưa có đề tài (toàn khoa hoặc theo lớp)
  Future<List<Map<String, dynamic>>> fetchStudentsWithoutGroup({
    int? lopHocPhanId,
    bool includeWithoutTopic = true,
  }) async {
    try {
      final params = <String>[
        'includeWithoutTopic=$includeWithoutTopic',
        if (lopHocPhanId != null) 'lopHocPhanId=$lopHocPhanId',
      ];
      final res = await ApiService.instance
          .get('/api/governance/students-without-group?${params.join('&')}');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Danh sách nhóm chưa nộp báo cáo tiến độ
  Future<List<Map<String, dynamic>>> fetchGroupsNotSubmitted({int? lopHocPhanId}) async {
    try {
      final path = lopHocPhanId != null
          ? '/api/governance/groups-not-submitted?lopHocPhanId=$lopHocPhanId'
          : '/api/governance/groups-not-submitted';
      final res = await ApiService.instance.get(path);
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Gửi thông báo đôn đốc nộp báo cáo tiến độ tới các nhóm chưa nộp
  Future<Map<String, dynamic>> sendGroupReminders({
    List<int>? nhomIds,
    int? lopHocPhanId,
    String? message,
  }) async {
    final res = await ApiService.instance.post('/api/governance/remind-groups', {
      if (nhomIds != null && nhomIds.isNotEmpty) 'nhomIds': nhomIds,
      'lopHocPhanId': ?lopHocPhanId,
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    });
    notifyDataChanged();
    if (res is Map) return Map<String, dynamic>.from(res);
    return {'success': true};
  }

  /// Thống kê tổng quan Giáo vụ (tỷ lệ GV/SV đề xuất, duyệt thực tế, nhóm chưa đề tài, SV chưa nhóm...)
  Future<Map<String, dynamic>> fetchGovernanceOverview({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<Map<String, dynamic>>(
      'gov_overview',
      () async {
        try {
          final res = await ApiService.instance.get('/api/governance/overview');
          if (res is Map) return Map<String, dynamic>.from(res);
        } catch (_) {}
        return <String, dynamic>{};
      },
      forceRefresh: forceRefresh,
    );
  }

  /// Giảng viên theo hướng nghiên cứu
  Future<List<Map<String, dynamic>>> fetchLecturersByResearch({String? keyword}) async {
    try {
      final path = keyword != null && keyword.isNotEmpty
          ? '/api/governance/lecturers-by-research?keyword=${Uri.encodeComponent(keyword)}'
          : '/api/governance/lecturers-by-research';
      final res = await ApiService.instance.get(path);
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchLecturers({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_lecturers',
      () async {
        try {
          final res = await ApiService.instance.get('/api/governance/lecturers');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAssignments({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_assignments',
      () async {
        try {
          final res = await ApiService.instance.get('/api/governance/assignments');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<void> assignLecturer(int lopHocPhanId, int giangVienId) async {
    await ApiService.instance.post('/api/governance/assignments', {
      'lopHocPhanId': lopHocPhanId,
      'giangVienId': giangVienId,
    });
    notifyDataChanged();
  }

  Future<void> updateAssignment(int lopHocPhanId, int giangVienId) async {
    await ApiService.instance.put('/api/governance/assignments', {
      'lopHocPhanId': lopHocPhanId,
      'giangVienId': giangVienId,
    });
    notifyDataChanged();
  }

  Future<void> deleteAssignment(int lopHocPhanId) async {
    await ApiService.instance.delete('/api/governance/assignments/$lopHocPhanId');
    notifyDataChanged();
  }

  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> payload) async {
    final res = await ApiService.instance.post('/api/governance/students', payload);
    notifyDataChanged();
    if (res is Map) return Map<String, dynamic>.from(res);
    return {'success': true};
  }

  Future<Map<String, dynamic>> createLecturer(Map<String, dynamic> payload) async {
    final res = await ApiService.instance.post('/api/governance/lecturers', payload);
    notifyDataChanged();
    if (res is Map) return Map<String, dynamic>.from(res);
    return {'success': true};
  }

  Future<Map<String, dynamic>> fetchOverview({bool forceRefresh = false}) {
    return AdminApiService.instance.fetchOverview(forceRefresh: forceRefresh);
  }

  Future<List<Map<String, dynamic>>> fetchGroups({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_groups',
      () async {
        try {
          final res = await ApiService.instance.get('/api/groups');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> fetchTopicRegistrations({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_topic_regs',
      () async {
        try {
          final res = await ApiService.instance.get('/api/dang-ky-de-tai');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> fetchNotifications({bool forceRefresh = false}) {
    return AdminApiService.instance.fetchNotifications(forceRefresh: forceRefresh);
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await ApiService.instance.put('/api/notifications/$notificationId/read');
    } catch (_) {}
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    await ApiService.instance.put('/api/auth/change-password', {
      'currentPassword': currentPassword,
      'oldPassword': currentPassword,
      'newPassword': newPassword,
    });
    return true;
  }

  Future<bool> changeEmail(String newEmail, [String? otp]) async {
    await ApiService.instance.put('/api/auth/change-email', {
      'email': newEmail,
      if (otp != null && otp.isNotEmpty) 'otp': otp,
    });
    return true;
  }

  Future<void> createCourseClass(Map<String, dynamic> data) async {
    await ApiService.instance.post('/api/lop-hoc-phan', data);
    notifyDataChanged();
  }

  Future<List<Map<String, dynamic>>> fetchRegistrationPeriods([int? lopHocPhanId]) async {
    try {
      final path = lopHocPhanId != null
          ? '/api/dot-dang-ky?lopHocPhanId=$lopHocPhanId'
          : '/api/dot-dang-ky';
      final res = await ApiService.instance.get(path);
      if (res is List) return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {}
    return [];
  }

  Future<void> updatePeriodStatus(int periodId, String newStatus) async {
    await ApiService.instance.put('/api/dot-dang-ky/$periodId/trang-thai', {
      'trangThai': newStatus,
    });
    notifyDataChanged();
  }
}
