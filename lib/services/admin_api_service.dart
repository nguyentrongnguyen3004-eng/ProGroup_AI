import 'api_service.dart';

class AdminApiService {
  AdminApiService._();
  static final AdminApiService instance = AdminApiService._();

  Future<List<Map<String, dynamic>>> fetchUsers({String? role, String? search}) async {
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

    try {
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
    } catch (_) {
      rethrow;
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchOverview() async {
    try {
      final res = await ApiService.instance.get('/api/admin/overview');
      if (res is Map) return Map<String, dynamic>.from(res);
    } catch (_) {}
    try {
      final res = await ApiService.instance.get('/api/admin/stats');
      if (res is Map) return Map<String, dynamic>.from(res);
    } catch (_) {}
    return {};
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
}
