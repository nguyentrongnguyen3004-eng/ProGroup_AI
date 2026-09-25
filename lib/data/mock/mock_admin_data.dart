import 'package:flutter/foundation.dart';

import '../../models/admin_account_model.dart';
import '../../models/admin_activity_model.dart';
import '../../models/admin_notification_model.dart';
import 'mock_lecturer.dart';
import 'mock_user.dart';

class MockAdminData extends ChangeNotifier {
  MockAdminData._();

  static final MockAdminData instance = MockAdminData._();

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
      id: MockUser.student.id,
      userCode: MockUser.student.mssv ?? 'SV001',
      username: MockUser.student.username,
      fullName: MockUser.student.fullName,
      email: MockUser.student.email,
      role: 'Sinh viên',
      status: activeStatus,
      password: '123456',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: MockUser.admin.id,
      userCode: 'SYS001',
      username: 'admin',
      fullName: 'Quản trị viên hệ thống',
      email: 'admin@progroup.local',
      role: 'Admin',
      status: activeStatus,
      password: '123456',
      phone: '0900 000 001',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: MockUser.governance.id,
      userCode: 'CBGV001',
      username: MockUser.governance.username,
      fullName: MockUser.governance.fullName,
      email: MockUser.governance.email,
      role: 'Giáo vụ khoa',
      status: activeStatus,
      password: '123456',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: MockUser.training.id,
      userCode: 'PDT001',
      username: MockUser.training.username,
      fullName: MockUser.training.fullName,
      email: MockUser.training.email,
      role: 'Phòng Đào tạo',
      status: activeStatus,
      password: '123456',
      createdAt: DateTime(2025, 9, 1),
    ),
    AdminAccountModel(
      id: 5,
      userCode: MockLecturer.current.lecturerCode,
      username: 'gv001',
      fullName: MockLecturer.current.fullName,
      email: MockLecturer.current.email,
      role: 'Giảng viên',
      status: activeStatus,
      password: '123456',
      createdAt: DateTime(2025, 9, 1),
    ),
  ];

  final List<AdminActivityModel> _activities = [
    AdminActivityModel(
      id: 1,
      time: DateTime(2025, 9, 25, 8),
      actor: 'Quản trị viên hệ thống',
      action: 'Import dữ liệu',
      target: 'Sinh viên',
      description: 'Đã import dữ liệu sinh viên mẫu.',
      role: 'Admin',
    ),
    AdminActivityModel(
      id: 2,
      time: DateTime(2025, 9, 24, 14),
      actor: 'Quản trị viên hệ thống',
      action: 'Cập nhật dữ liệu',
      target: 'Học phần',
      description: 'Đã đồng bộ danh mục học phần mẫu.',
      role: 'Admin',
    ),
    AdminActivityModel(
      id: 3,
      time: DateTime(2025, 9, 24, 9),
      actor: 'Quản trị viên hệ thống',
      action: 'Đăng nhập',
      target: 'Hệ thống',
      description: 'Tài khoản Admin đăng nhập thành công.',
      role: 'Admin',
    ),
  ];

  final List<AdminNotificationModel> _notifications = [
    AdminNotificationModel(
      id: 1,
      title: 'Chào mừng quản trị viên',
      message: 'Module quản trị hệ thống đã sẵn sàng.',
      createdAt: DateTime(2025, 9, 25, 8),
    ),
    AdminNotificationModel(
      id: 2,
      title: 'Tài khoản demo',
      message: 'Bạn có thể quản lý các tài khoản mock trong hệ thống.',
      createdAt: DateTime(2025, 9, 24, 16),
    ),
    AdminNotificationModel(
      id: 3,
      title: 'Lịch sử dữ liệu',
      message: 'Dữ liệu import được tổng hợp từ các module hiện có.',
      createdAt: DateTime(2025, 9, 24, 10),
      isRead: true,
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
  bool _legacyAdminCredentialEnabled = true;

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

  AdminAccountModel? findAdminCredentials(String username, String password) {
    final normalized = username.trim().toLowerCase();
    for (final account in _accounts) {
      if (account.username.toLowerCase() == normalized &&
          account.password == password &&
          account.status == activeStatus &&
          account.role == 'Admin') {
        return account;
      }
    }
    return null;
  }

  bool acceptsLegacyAdminCredential(String username, String password) =>
      _legacyAdminCredentialEnabled &&
      username == 'admin' &&
      password == 'Admin@123';

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
    if (_accounts.any(
      (item) =>
          item.id != editingId &&
          item.userCode.toLowerCase() == userCode.trim().toLowerCase(),
    )) {
      return 'Mã người dùng đã tồn tại.';
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
    if (_accounts.any(
      (item) =>
          item.username.toLowerCase() == account.username.toLowerCase() ||
          item.email.toLowerCase() == account.email.toLowerCase() ||
          item.userCode.toLowerCase() == account.userCode.toLowerCase(),
    )) {
      return false;
    }
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
    final duplicate = _accounts.any(
      (item) =>
          item.id != updated.id &&
          (item.username.toLowerCase() == updated.username.toLowerCase() ||
              item.email.toLowerCase() == updated.email.toLowerCase() ||
              item.userCode.toLowerCase() == updated.userCode.toLowerCase()),
    );
    if (duplicate) return false;
    final old = _accounts[index];
    if (old.id == MockUser.admin.id &&
        (old.username != updated.username ||
            old.password != updated.password)) {
      _legacyAdminCredentialEnabled = false;
    }
    _accounts[index] = updated;
    if (old.role != updated.role) {
      _log(
        'Thay đổi role',
        updated.fullName,
        'Đổi vai trò từ ${old.role} sang ${updated.role}.',
      );
    } else {
      _log('Sửa user', updated.fullName, 'Đã cập nhật thông tin tài khoản.');
    }
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
    if (current.status == nextStatus) return false;
    _accounts[index] = current.copyWith(status: nextStatus);
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
        id:
            _activities.fold<int>(
              0,
              (max, item) => item.id > max ? item.id : max,
            ) +
            1,
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
