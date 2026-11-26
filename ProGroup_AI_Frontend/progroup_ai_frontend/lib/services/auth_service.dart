import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/mock/mock_admin_data.dart';
import '../data/mock/mock_lecturer.dart';
import '../data/mock/mock_user.dart';
import '../models/lecturer_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'avatar_service.dart';
import 'data_cache_service.dart';
import 'lecturer_api_service.dart';

class AuthService {
  static String? currentToken;
  static String? savedUsername;
  static String? savedPassword;
  static UserModel? _currentUser;
  static Future<bool>? _reAuthFuture;
  static UserModel get currentUser => _currentUser ?? MockUser.student;
  static set currentUser(UserModel? user) => _currentUser = user;

  static Future<void> loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentToken ??= prefs.getString('auth_token');
      savedUsername ??= prefs.getString('auth_username');
      if (prefs.containsKey('auth_password')) {
        await prefs.remove('auth_password');
      }
    } catch (_) {}
  }

  /// Khôi phục phiên đăng nhập từ JWT Token đã lưu trong SharedPreferences (TC_AUTH_014)
  static Future<UserModel?> restoreSession() async {
    if (currentToken == null || currentToken!.trim().isEmpty) {
      await loadSavedToken();
    }
    if (currentToken == null || currentToken!.trim().isEmpty) return null;
    if (_currentUser != null) return _currentUser;
    try {
      final res = await ApiService.instance
          .get('/api/auth/me')
          .timeout(const Duration(seconds: 3));
      if (res is Map<String, dynamic>) {
        final maVaiTro = (res['maVaiTro'] as String? ?? '').toUpperCase();
        final mappedRole = switch (maVaiTro) {
          'GIANGVIEN' => 'LECTURER',
          'SINHVIEN' => 'SINHVIEN',
          'GIAOVUKHOA' => 'GIAOVU',
          'PHONGDAOTAO' => 'PHONG_DAO_TAO',
          'ADMIN' => 'ADMIN',
          _ => maVaiTro,
        };
        final user = UserModel(
          id: res['nguoiDungId'] as int? ?? 1,
          username: res['tenDangNhap'] as String? ?? (savedUsername ?? ''),
          fullName: res['hoTen'] as String? ?? '',
          email: res['email'] as String? ?? '',
          role: mappedRole,
          roleName: res['tenVaiTro'] as String? ?? mappedRole,
          mssv: res['mssv'] as String?,
          avatarUrl: res['avatarUrl'] as String?,
        );
        currentUser = user;
        DataCacheService.instance.setUserScope('${user.username}_${user.role}');
        await AvatarService.instance.switchUser(user.username, user.avatarUrl);
        return user;
      }
    } catch (_) {
      // Token hết hạn hoặc không hợp lệ -> hủy phiên để bắt đăng nhập lại
      logout();
    }
    return null;
  }

  /// Tự động lấy token mới từ Backend nếu đang thiếu token hoặc token hết hạn/lỗi
  static Future<bool> ensureValidToken() async {
    if (currentToken != null && currentToken!.isNotEmpty) return true;
    return reAuthenticate();
  }

  /// Xác thực lại người dùng để cấp lại token khi gặp 401 hoặc 403 (có khóa chống gọi trùng lặp)
  static Future<bool> reAuthenticate() {
    if (_reAuthFuture != null) return _reAuthFuture!;
    _reAuthFuture = _reAuthenticateImpl().whenComplete(() {
      _reAuthFuture = null;
    });
    return _reAuthFuture!;
  }

  static Future<bool> _reAuthenticateImpl() async {
    currentToken = null;
    final u = savedUsername ?? _currentUser?.username;
    final p = savedPassword ?? '123456';
    if (u != null && u.trim().isNotEmpty) {
      try {
        final service = AuthService();
        final res = await service._loginViaApi(u.trim(), p);
        return res != null && currentToken != null;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<UserModel?> login(String username, String password) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    DataCacheService.instance.invalidateAll();
    DataCacheService.instance.setUserScope(cleanUsername);
    LecturerApiService.instance.clearCache();

    savedUsername = cleanUsername;
    savedPassword = cleanPassword;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_username', cleanUsername);
      await prefs.remove('auth_password');
    } catch (_) {}

    // 1. Ưu tiên gọi API Backend thực tế
    try {
      final userFromApi = await _loginViaApi(cleanUsername, cleanPassword);
      if (userFromApi != null) {
        currentUser = userFromApi;
        return userFromApi;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is Exception && !e.toString().contains('SocketException') && !e.toString().contains('TimeoutException')) {
        rethrow;
      }
    }

    // Kiểm tra tài khoản bị khóa trong hệ thống Admin / Mock
    final adminAccount = MockAdminData.instance.accounts
        .where((a) =>
            a.username.toLowerCase() == cleanUsername.toLowerCase() ||
            a.userCode.toLowerCase() == cleanUsername.toLowerCase())
        .firstOrNull;
    if (adminAccount != null &&
        (adminAccount.status == MockAdminData.lockedStatus ||
            adminAccount.status.toLowerCase().contains('khóa'))) {
      throw ApiException('Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động.', 401);
    }
    if (cleanUsername.toLowerCase().contains('khoa') ||
        cleanUsername.toLowerCase().contains('locked')) {
      throw ApiException('Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động.', 401);
    }

    // 2. Dự phòng tài khoản API nếu Backend chưa kết nối được
    await Future.delayed(const Duration(milliseconds: 300));

    // Xóa token cũ từ phiên đăng nhập trước nếu không gọi được API thật
    currentToken = null;

    // Sinh viên (sv001)
    if (cleanUsername.toLowerCase() == AppConstants.mockStudentUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockStudentPassword) {
      currentUser = MockUser.student;
      await AvatarService.instance.switchUser(MockUser.student.username, null);
      return MockUser.student;
    }

    // Giảng viên (gv001)
    if (cleanUsername.toLowerCase() == AppConstants.mockLecturerUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockLecturerPassword) {
      final lecturer = MockLecturer.current;
      final user = UserModel(
        id: lecturer.id,
        username: AppConstants.mockLecturerUsername,
        fullName: lecturer.fullName,
        email: lecturer.email,
        role: 'LECTURER',
        roleName: 'Giảng viên',
      );
      currentUser = user;
      await AvatarService.instance.switchUser(user.username, null);
      return user;
    }

    // Giáo vụ khoa (gvk.demo)
    if (cleanUsername.toLowerCase() == AppConstants.mockGovernanceUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockGovernancePassword) {
      currentUser = MockUser.governance;
      await AvatarService.instance.switchUser(MockUser.governance.username, null);
      return MockUser.governance;
    }

    // Phòng đào tạo (pdt.demo)
    if (cleanUsername.toLowerCase() == AppConstants.mockTrainingUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockTrainingPassword) {
      currentUser = MockUser.training;
      await AvatarService.instance.switchUser(MockUser.training.username, null);
      return MockUser.training;
    }

    // Admin hệ thống (admin.demo)
    if (cleanUsername.toLowerCase() == AppConstants.mockUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockPassword) {
      final admin = MockUser.admin;
      final user = UserModel(
        id: admin.id,
        username: AppConstants.mockUsername,
        fullName: admin.fullName,
        email: admin.email,
        role: 'ADMIN',
        roleName: admin.roleName,
      );
      currentUser = user;
      await AvatarService.instance.switchUser(user.username, null);
      return user;
    }

    return null;
  }

  Future<UserModel?> _loginViaApi(String username, String password) async {
    final urls = <String>[];
    if (ApiService.customBaseUrl != null && ApiService.customBaseUrl!.isNotEmpty) {
      urls.add(ApiService.customBaseUrl!);
    }
    if (ApiService.workingBaseUrl != null &&
        ApiService.workingBaseUrl!.isNotEmpty &&
        !urls.contains(ApiService.workingBaseUrl)) {
      urls.add(ApiService.workingBaseUrl!);
    }
    for (final u in ApiService.baseUrls) {
      if (!urls.contains(u)) {
        urls.add(u);
      }
    }

    for (final base in urls) {
      try {
        final uri = Uri.parse('$base/api/auth/login');
        final response = await ApiService.client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'tenDangNhap': username,
            'matKhau': password,
          }),
        ).timeout(const Duration(seconds: 10));

        final bodyStr = utf8.decode(response.bodyBytes);
        if (response.statusCode == 200) {
          final data = jsonDecode(bodyStr) as Map<String, dynamic>;
          currentToken = data['token'] as String?;
          ApiService.setWorkingBaseUrl(base);

          try {
            final prefs = await SharedPreferences.getInstance();
            if (currentToken != null) {
              await prefs.setString('auth_token', currentToken!);
            }
          } catch (_) {}

          final userJson = data['user'] as Map<String, dynamic>?;
          if (userJson != null) {
            final maVaiTro = (userJson['maVaiTro'] as String? ?? '').toUpperCase();
            final mappedRole = switch (maVaiTro) {
              'GIANGVIEN' => 'LECTURER',
              'SINHVIEN' => 'SINHVIEN',
              'GIAOVUKHOA' => 'GIAOVU',
              'PHONGDAOTAO' => 'PHONG_DAO_TAO',
              'ADMIN' => 'ADMIN',
              _ => maVaiTro,
            };

            if (mappedRole == 'LECTURER') {
              MockLecturer.setLecturer(LecturerModel(
                id: userJson['giangVienId'] as int? ?? userJson['nguoiDungId'] as int? ?? 1,
                lecturerCode: userJson['maGiangVien'] as String? ?? userJson['tenDangNhap'] as String? ?? 'GV001',
                fullName: userJson['hoTen'] as String? ?? username,
                email: userJson['email'] as String? ?? '',
                faculty: 'Khoa Công nghệ thông tin',
                department: 'Bộ môn Công nghệ phần mềm',
                avatar: '',
              ));
            }

            final loggedInUser = UserModel(
              id: userJson['nguoiDungId'] as int? ?? 1,
              username: userJson['tenDangNhap'] as String? ?? username,
              fullName: userJson['hoTen'] as String? ?? username,
              email: userJson['email'] as String? ?? '',
              role: mappedRole,
              roleName: userJson['tenVaiTro'] as String? ?? mappedRole,
              mssv: userJson['mssv'] as String?,
              avatarUrl: userJson['avatarUrl'] as String?,
            );
            currentUser = loggedInUser;
            DataCacheService.instance.setUserScope('${loggedInUser.username}_${loggedInUser.role}');
            await AvatarService.instance.switchUser(loggedInUser.username, loggedInUser.avatarUrl);
            return loggedInUser;
          }
        }

        // Nếu máy chủ phản hồi lỗi (400, 401, 403), đọc thông báo lỗi từ server để báo chính xác
        if (response.statusCode >= 400 && response.statusCode < 500) {
          try {
            final errData = jsonDecode(bodyStr);
            if (errData is Map) {
              final msg = errData['message'] ?? errData['Message'] ?? errData['title'] ?? errData['error'];
              if (msg != null && msg.toString().trim().isNotEmpty) {
                ApiService.setWorkingBaseUrl(base);
                throw ApiException(msg.toString().trim(), response.statusCode);
              }
            }
          } on ApiException {
            rethrow;
          } catch (_) {}
        }
      } on ApiException {
        rethrow;
      } catch (_) {
        // Thử địa chỉ tiếp theo
      }
    }
    return null;
  }

  static void logout() {
    currentToken = null;
    savedUsername = null;
    savedPassword = null;
    _currentUser = null;
    DataCacheService.instance.invalidateAll();
    DataCacheService.instance.setUserScope('guest');
    LecturerApiService.instance.clearCache();
    AvatarService.instance.reset();
    SharedPreferences.getInstance()
        .then((prefs) async {
          await prefs.remove('auth_token');
          await prefs.remove('auth_username');
          await prefs.remove('auth_password');
        })
        .catchError((_) {});
  }
}
