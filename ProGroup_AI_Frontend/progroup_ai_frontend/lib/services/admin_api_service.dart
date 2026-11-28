import 'api_service.dart';
import 'data_cache_service.dart';

class AdminApiService {
  AdminApiService._();
  static final AdminApiService instance = AdminApiService._();

  Future<List<Map<String, dynamic>>> fetchUsers({
    String? role,
    String? search,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'admin_users_${role ?? 'all'}_${search ?? ''}';
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      cacheKey,
      () async {
        var path = '/api/admin/users';
        final params = <String>[];
        if (role != null && role.isNotEmpty && role != 'all') {
          params.add('role=${Uri.encodeComponent(role)}');
        }
        if (search != null && search.isNotEmpty) {
          params.add('search=${Uri.encodeComponent(search)}');
        }
        if (params.isNotEmpty) {
          path += '?${params.join("&")}';
        }

        final res = await ApiService.instance.get(path);
        if (res is List) {
          var list = res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (role != null && role.isNotEmpty && role != 'all') {
            final target = role.toLowerCase().replaceAll('_', '');
            list = list.where((u) {
              final ma = (u['maVaiTro'] ?? u['role'] ?? '').toString().toLowerCase().replaceAll('_', '');
              final ten = (u['tenVaiTro'] ?? u['roleName'] ?? '').toString().toLowerCase();
              return ma == target ||
                  ma.contains(target) ||
                  (target == 'sinhvien' && (ma.contains('sv') || ten.contains('sinh viên'))) ||
                  (target == 'giangvien' && (ma.contains('gv') || ten.contains('giảng viên'))) ||
                  (target == 'giaovukhoa' && (ma.contains('gvk') || ma.contains('giaovu') || ten.contains('giáo vụ'))) ||
                  (target == 'phongdaotao' && (ma.contains('pdt') || ma.contains('daotao') || ten.contains('đào tạo'))) ||
                  (target == 'admin' && (ma.contains('admin') || ten.contains('quản trị')));
            }).toList();
          }
          if (search != null && search.isNotEmpty) {
            final s = search.toLowerCase();
            list = list.where((u) {
              final name = (u['hoTen'] ?? '').toString().toLowerCase();
              final username = (u['tenDangNhap'] ?? '').toString().toLowerCase();
              final email = (u['email'] ?? '').toString().toLowerCase();
              return name.contains(s) || username.contains(s) || email.contains(s);
            }).toList();
          }
          return list;
        }
        return [];
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<Map<String, dynamic>> fetchOverview({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<Map<String, dynamic>>(
      'admin_overview',
      () async {
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

        // Chuẩn hóa tất cả các biến thể key (tiếng Việt, tiếng Anh, PascalCase, camelCase)
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
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<void> toggleUserStatus(int userId, {bool? currentStatus}) async {
    try {
      await ApiService.instance.put('/api/admin/users/$userId/toggle-status', {});
    } catch (_) {
      final newStatus = currentStatus != null ? !currentStatus : false;
      await ApiService.instance.put('/api/admin/users/$userId/status', {
        'trangThai': newStatus,
      });
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await ApiService.instance.post('/api/admin/users', data);
  }

  Future<List<Map<String, dynamic>>> fetchNotifications({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'admin_notifications',
      () async {
        try {
          final res = await ApiService.instance.get('/api/notifications');
          if (res is List) {
            return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } catch (_) {}
        return [];
      },
      ttl: const Duration(seconds: 15),
      forceRefresh: forceRefresh,
    );
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await ApiService.instance.put('/api/notifications/$notificationId/read');
      DataCacheService.instance.invalidateKey('admin_notifications');
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

  Future<Map<String, dynamic>> importUsersBatch(List<Map<String, dynamic>> users) async {
    final res = await ApiService.instance.post('/api/admin/users/import', {
      'users': users,
    });
    if (res is Map<String, dynamic>) return res;
    if (res is Map) return Map<String, dynamic>.from(res);
    return {};
  }

  /// Đặt lại mật khẩu cho người dùng
  Future<Map<String, dynamic>> resetUserPassword(int userId, [String? newPassword]) async {
    final body = <String, dynamic>{};
    if (newPassword != null && newPassword.isNotEmpty) {
      body['newPassword'] = newPassword;
    }
    final res = await ApiService.instance.put('/api/admin/users/$userId/reset-password', body);
    if (res is Map<String, dynamic>) return res;
    return {'success': true, 'message': 'Đã đặt lại mật khẩu.'};
  }

  /// Lấy danh sách nhật ký hoạt động hệ thống
  Future<List<Map<String, dynamic>>> fetchActivityLogs([int limit = 50]) async {
    try {
      final res = await ApiService.instance.get('/api/admin/activity-logs?limit=$limit');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Tạo bản sao lưu CSDL SQL Server ngay lập tức (TC_ADMIN_BACKUP)
  Future<Map<String, dynamic>> createBackup() async {
    final res = await ApiService.instance.post('/api/admin/backup', {});
    if (res is Map<String, dynamic>) return res;
    if (res is Map) return Map<String, dynamic>.from(res);
    return {'success': false, 'message': 'Không nhận được phản hồi từ máy chủ.'};
  }

  /// Lấy danh sách lịch sử các bản sao lưu CSDL (.bak)
  Future<List<Map<String, dynamic>>> fetchBackups() async {
    try {
      final res = await ApiService.instance.get('/api/admin/backups');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }
}
