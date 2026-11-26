import 'api_service.dart';
import 'admin_api_service.dart';
import 'data_cache_service.dart';

class GovernanceApiService {
  GovernanceApiService._();
  static final GovernanceApiService instance = GovernanceApiService._();

  Future<List<Map<String, dynamic>>> fetchCourses({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_courses',
      () async {
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

  Future<List<Map<String, dynamic>>> fetchStudents({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'gov_students',
      () async {
        try {
          final res = await ApiService.instance.get('/api/governance/students');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      forceRefresh: forceRefresh,
    );
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
  }

  Future<List<Map<String, dynamic>>> fetchRegistrationPeriods([int? lopHocPhanId]) async {
    try {
      final path = lopHocPhanId != null ? '/api/dot-dang-ky?lopHocPhanId=$lopHocPhanId' : '/api/dot-dang-ky';
      final res = await ApiService.instance.get(path);
      if (res is List) return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {}
    return [];
  }

  Future<void> updatePeriodStatus(int periodId, String newStatus) async {
    await ApiService.instance.put('/api/dot-dang-ky/$periodId/trang-thai', {
      'trangThai': newStatus,
    });
  }
}
