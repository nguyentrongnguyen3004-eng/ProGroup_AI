import 'package:flutter/foundation.dart';

import '../models/admin_account_model.dart';
import '../models/admin_activity_model.dart';
import '../models/admin_notification_model.dart';
import 'admin_service.dart';

class AdminDataService extends ChangeNotifier {
  AdminDataService._();

  static final AdminDataService instance = AdminDataService._();

  static const String activeStatus = 'Đang hoạt động';
  static const String lockedStatus = 'Đã khóa';

  static const List<String> roles = [
    'Sinh viên',
    'Giảng viên',
    'Giáo vụ khoa',
    'Phòng Đào tạo',
    'Admin',
  ];

  final List<AdminAccountModel> _accounts = [
    AdminAccountModel(
      id: 1,
      userCode: 'SV001',
      username: 'sv001',
      fullName: 'Nguyễn Văn An',
      email: 'an.nguyen@example.com',
      role: 'Sinh viên',
      status: activeStatus,
      password: '******',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: 2,
      userCode: 'SYS001',
      username: 'admin',
      fullName: 'Quản trị viên hệ thống',
      email: 'admin@progroup.local',
      role: 'Admin',
      status: activeStatus,
      password: '******',
      phone: '0900 000 001',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: 3,
      userCode: 'CBGV001',
      username: 'giaovu',
      fullName: 'Trần Thị Thu Hà',
      email: 'ha.tran@progroup.local',
      role: 'Giáo vụ khoa',
      status: activeStatus,
      password: '******',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: 4,
      userCode: 'PDT001',
      username: 'daotao',
      fullName: 'Nguyễn Minh Anh',
      email: 'minh.anh@progroup.local',
      role: 'Phòng Đào tạo',
      status: activeStatus,
      password: '******',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: 5,
      userCode: 'GV001',
      username: 'gv001',
      fullName: 'Nguyễn Văn Bình',
      email: 'binh.nguyen@example.com',
      role: 'Giảng viên',
      status: activeStatus,
      password: '******',
      createdAt: DateTime(2025, 9, 1),
    ),
  ];

  final List<AdminActivityModel> _activities = [
    AdminActivityModel(
      id: 1,
      time: DateTime.now(),
      actor: 'Quản trị viên hệ thống',
      action: 'Khởi động hệ thống',
      target: 'Hệ thống',
      description: 'Hệ thống ProGroup AI hoạt động bình thường.',
      role: 'Admin',
    ),
  ];

  final List<AdminNotificationModel> _notifications = [
    AdminNotificationModel(
      id: 1,
      title: 'Chào mừng quản trị viên',
      message: 'Module quản trị hệ thống đã kết nối hoàn tất.',
      createdAt: DateTime.now(),
    ),
  ];

  List<AdminAccountModel> get accounts => List.unmodifiable(_accounts);
  List<AdminActivityModel> get activities => List.unmodifiable(
    List<AdminActivityModel>.of(_activities)
      ..sort((a, b) => b.time.compareTo(a.time)),
  );
  List<AdminNotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((item) => !item.isRead).length;
  int get activeCount =>
      _accounts.where((item) => item.status == activeStatus).length;
  int get lockedCount =>
      _accounts.where((item) => item.status == lockedStatus).length;
  int get newlyAddedCount => _newlyAddedCount;
  int _newlyAddedCount = 0;

  static const Map<String, List<String>> permissions = {
    'Sinh viên': [
      'Đăng ký lớp học phần',
      'Tạo và tham gia nhóm',
      'Chọn đề tài',
      'Chat nhóm',
      'Quản lý profile',
    ],
    'Giảng viên': [
      'Quản lý lớp học phần',
      'Quản lý nhóm và đề tài',
      'Duyệt đề tài',
      'Quản lý sinh viên',
      'Profile và thông báo',
    ],
    'Giáo vụ khoa': [
      'Quản lý sinh viên và giảng viên',
      'Import dữ liệu',
      'CRUD dữ liệu khoa',
      'Profile và thông báo',
    ],
    'Phòng Đào tạo': [
      'Quản lý sinh viên, giảng viên, học phần',
      'Quản lý lớp học phần',
      'Import dữ liệu',
      'Phân công giảng viên',
      'Profile và thông báo',
    ],
    'Admin': [
      'Quản lý người dùng và vai trò',
      'Theo dõi dữ liệu hệ thống',
      'Theo dõi hoạt động',
      'Quản lý thông báo',
      'Quản lý profile hệ thống',
    ],
  };

  int get nextAccountId =>
      _accounts.fold<int>(0, (max, item) => item.id > max ? item.id : max) + 1;

  AdminAccountModel? accountById(int id) {
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Future<void> syncFromBackend() async {
    try {
      final users = await AdminService().getUsers();
      if (users.isNotEmpty) {
        _accounts.clear();
        for (final u in users) {
          _accounts.add(
            AdminAccountModel(
              id: u['nguoiDungId'] ?? 0,
              userCode: (u['tenDangNhap'] ?? '').toString().toUpperCase(),
              username: u['tenDangNhap'] ?? '',
              fullName: u['hoTen'] ?? '',
              email: u['email'] ?? '',
              role: u['roleName'] ?? u['role'] ?? 'Sinh viên',
              status: (u['trangThai'] == true || u['trangThai'] == 1)
                  ? activeStatus
                  : lockedStatus,
              password: '******',
              phone: u['soDienThoai'],
              createdAt: DateTime.tryParse(u['createdAt']?.toString() ?? '') ?? DateTime.now(),
            ),
          );
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  String? validateAccount({
    required String userCode,
    required String username,
    required String fullName,
    required String email,
    required String role,
    required String password,
    required String confirmPassword,
    int? editingId,
    bool requirePassword = true,
  }) {
    if ([
      userCode,
      username,
      fullName,
      email,
      role,
    ].any((value) => value.trim().isEmpty)) {
      return 'Vui lòng nhập đầy đủ các trường bắt buộc.';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      return 'Email không đúng định dạng.';
    }
    if (_accounts.any(
      (item) =>
          item.id != editingId &&
          item.username.toLowerCase() == username.trim().toLowerCase(),
    )) {
      return 'Tên đăng nhập đã tồn tại.';
    }
    if (_accounts.any(
      (item) =>
          item.id != editingId &&
          item.email.toLowerCase() == email.trim().toLowerCase(),
    )) {
      return 'Email đã tồn tại.';
    }
    if (requirePassword && password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (requirePassword && password != confirmPassword) {
      return 'Mật khẩu xác nhận không khớp.';
    }
    return null;
  }

  bool addAccount(AdminAccountModel account) {
    final added = account.copyWith(id: nextAccountId);
    _accounts.add(added);
    _newlyAddedCount++;
    _log('Thêm user', added.fullName, 'Đã tạo tài khoản ${added.username}.');
    notifyListeners();
    return true;
  }

  bool updateAccount(AdminAccountModel updated) {
    final index = _accounts.indexWhere((item) => item.id == updated.id);
    if (index < 0) return false;
    _accounts[index] = updated;
    _log('Sửa user', updated.fullName, 'Đã cập nhật thông tin tài khoản.');
    notifyListeners();
    return true;
  }

  bool deleteAccount(int id, {required int currentAdminId}) {
    if (id == currentAdminId) return false;
    final index = _accounts.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    final removed = _accounts.removeAt(index);
    _log('Xóa user', removed.fullName, 'Đã xóa tài khoản ${removed.username}.');
    notifyListeners();
    return true;
  }

  bool setAccountLocked(
    int id, {
    required bool locked,
    required int currentAdminId,
  }) {
    if (id == currentAdminId) return false;
    final index = _accounts.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    final current = _accounts[index];
    final nextStatus = locked ? lockedStatus : activeStatus;
    _accounts[index] = current.copyWith(status: nextStatus);
    AdminService().updateUserStatus(id, !locked).catchError((_) {});
    _log(
      locked ? 'Khóa user' : 'Mở khóa user',
      current.fullName,
      locked ? 'Đã khóa tài khoản.' : 'Đã mở khóa tài khoản.',
    );
    notifyListeners();
    return true;
  }

  List<AdminAccountModel> filterAccounts({
    String query = '',
    String? role,
    String? status,
  }) {
    final normalized = query.trim().toLowerCase();
    return _accounts.where((item) {
      final matchesQuery =
          normalized.isEmpty ||
          [
            item.fullName,
            item.username,
            item.email,
            item.userCode,
          ].any((value) => value.toLowerCase().contains(normalized));
      final matchesRole = role == null || role == 'Tất cả' || item.role == role;
      final matchesStatus =
          status == null || status == 'Tất cả' || item.status == status;
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  void recordActivity({
    required String action,
    required String target,
    required String description,
    String role = 'Admin',
  }) {
    _log(action, target, description, role: role);
    notifyListeners();
  }

  void markNotificationRead(int id) {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index < 0 || _notifications[index].isRead) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    if (unreadCount == 0) return;
    for (var index = 0; index < _notifications.length; index++) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void _log(
    String action,
    String target,
    String description, {
    String role = 'Admin',
  }) {
    _activities.insert(
      0,
      AdminActivityModel(
        id: _activities.fold<int>(0, (max, item) => item.id > max ? item.id : max) + 1,
        time: DateTime.now(),
        actor: 'Quản trị viên hệ thống',
        action: action,
        target: target,
        description: description,
        role: role,
      ),
    );
  }
}
