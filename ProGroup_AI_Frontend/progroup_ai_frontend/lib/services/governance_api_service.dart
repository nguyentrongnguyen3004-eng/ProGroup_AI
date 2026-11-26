import 'api_service.dart';

class GovernanceApiService {
  GovernanceApiService._();
  static final GovernanceApiService instance = GovernanceApiService._();

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    try {
      final res = await ApiService.instance.get('/api/lop-hoc-phan');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchStudents() async {
    try {
      final res = await ApiService.instance.get('/api/governance/students');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchLecturers() async {
    try {
      final res = await ApiService.instance.get('/api/governance/lecturers');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    try {
      final res = await ApiService.instance.get('/api/governance/assignments');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> assignLecturer(int lopHocPhanId, int giangVienId) async {
    await ApiService.instance.post('/api/governance/assignments', {
      'lopHocPhanId': lopHocPhanId,
      'giangVienId': giangVienId,
    });
  }

  Future<Map<String, dynamic>> fetchOverview() async {
    Map<String, dynamic>? raw;
    try {
      final res = await ApiService.instance.get('/api/admin/overview');
      if (res is Map) raw = Map<String, dynamic>.from(res);
    } catch (_) {}

    if (raw == null) {
      try {
        final res = await ApiService.instance.get('/api/admin/stats');
        if (res is Map) raw = Map<String, dynamic>.from(res);
      } catch (_) {}
    }

    raw ??= {};

    final students = raw['tongSinhVien'] ?? raw['TongSinhVien'] ?? raw['totalStudents'] ?? raw['sinhViens'] ?? 0;
    final lecturers = raw['tongGiangVien'] ?? raw['TongGiangVien'] ?? raw['totalLecturers'] ?? raw['giangViens'] ?? 0;
    final courses = raw['tongLopHocPhan'] ?? raw['TongLopHocPhan'] ?? raw['totalCourses'] ?? raw['totalClasses'] ?? raw['lopHocPhans'] ?? 0;
    final groups = raw['tongNhom'] ?? raw['TongNhom'] ?? raw['totalGroups'] ?? raw['nhoms'] ?? 0;
    final users = raw['tongNguoiDung'] ?? raw['TongNguoiDung'] ?? raw['totalUsers'] ?? raw['users'] ?? 0;
    final topics = raw['tongDeTai'] ?? raw['TongDeTai'] ?? raw['totalTopics'] ?? 0;

    raw['tongSinhVien'] = students;
    raw['totalStudents'] = students;
    raw['sinhViens'] = students;

    raw['tongGiangVien'] = lecturers;
    raw['totalLecturers'] = lecturers;
    raw['giangViens'] = lecturers;

    raw['tongLopHocPhan'] = courses;
    raw['totalCourses'] = courses;
    raw['totalClasses'] = courses;
    raw['lopHocPhans'] = courses;

    raw['tongNhom'] = groups;
    raw['totalGroups'] = groups;
    raw['nhoms'] = groups;

    raw['tongNguoiDung'] = users;
    raw['totalUsers'] = users;
    raw['users'] = users;

    raw['tongDeTai'] = topics;
    raw['totalTopics'] = topics;

    return raw;
  }

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    try {
      final res = await ApiService.instance.get('/api/groups');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchTopicRegistrations() async {
    try {
      final res = await ApiService.instance.get('/api/dang-ky-de-tai');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final res = await ApiService.instance.get('/api/notifications');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await ApiService.instance.put('/api/notifications/$notificationId/read');
    } catch (_) {}
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      await ApiService.instance.post('/api/auth/change-password', {
        'oldPassword': currentPassword,
        'newPassword': newPassword,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changeEmail(String newEmail) async {
    try {
      await ApiService.instance.put('/api/auth/change-email', {'email': newEmail});
      return true;
    } catch (_) {
      return false;
    }
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
