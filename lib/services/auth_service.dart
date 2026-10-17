import 'dart:convert';
import 'dart:io';

import '../core/constants/app_constants.dart';
import '../data/mock/mock_lecturer.dart';
import '../data/mock/mock_user.dart';
import '../models/lecturer_model.dart';
import '../models/user_model.dart';
import 'lecturer_api_service.dart';

class AuthService {
  static String? currentToken;
  static UserModel? _currentUser;
  static UserModel get currentUser => _currentUser ?? MockUser.student;
  static set currentUser(UserModel? user) => _currentUser = user;

  Future<UserModel?> login(String username, String password) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    // 1. Ưu tiên gọi API Backend thực tế
    try {
      final userFromApi = await _loginViaApi(cleanUsername, cleanPassword);
      if (userFromApi != null) {
        currentUser = userFromApi;
        return userFromApi;
      }
    } catch (_) {
      // Bỏ qua khi thiết bị chưa thông mạng và chuyển sang dự phòng
    }

    // 2. Dự phòng tài khoản API nếu Backend chưa kết nối được
    await Future.delayed(const Duration(milliseconds: 300));

    // Sinh viên (sv001)
    if (cleanUsername.toLowerCase() == AppConstants.mockStudentUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockStudentPassword) {
      currentUser = MockUser.student;
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
      return user;
    }

    // Giáo vụ khoa (gvk.demo)
    if (cleanUsername.toLowerCase() == AppConstants.mockGovernanceUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockGovernancePassword) {
      currentUser = MockUser.governance;
      return MockUser.governance;
    }

    // Phòng đào tạo (pdt.demo)
    if (cleanUsername.toLowerCase() == AppConstants.mockTrainingUsername.toLowerCase() &&
        cleanPassword == AppConstants.mockTrainingPassword) {
      currentUser = MockUser.training;
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
      return user;
    }

    return null;
  }

  Future<UserModel?> _loginViaApi(String username, String password) async {
    final urls = [
      AppConstants.apiBaseUrl,
      'http://127.0.0.1:5094',
      'http://localhost:5094',
      'http://10.0.2.2:5094',
    ];

    for (final base in urls) {
      HttpClient? client;
      try {
        client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
        final uri = Uri.parse('$base/api/auth/login');
        final request = await client.postUrl(uri);
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode({
          'tenDangNhap': username,
          'matKhau': password,
        }));

        final response = await request.close();
        final bodyStr = await response.transform(utf8.decoder).join();
        if (response.statusCode == 200) {
          final data = jsonDecode(bodyStr) as Map<String, dynamic>;
          currentToken = data['token'] as String?;
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
              LecturerApiService.instance.syncAllData();
            }

            final loggedInUser = UserModel(
              id: userJson['nguoiDungId'] as int? ?? 1,
              username: userJson['tenDangNhap'] as String? ?? username,
              fullName: userJson['hoTen'] as String? ?? username,
              email: userJson['email'] as String? ?? '',
              role: mappedRole,
              roleName: userJson['tenVaiTro'] as String? ?? mappedRole,
              mssv: userJson['mssv'] as String?,
            );
            currentUser = loggedInUser;
            return loggedInUser;
          }
        }
      } catch (_) {
        // Thử địa chỉ tiếp theo
      } finally {
        client?.close();
      }
    }
    return null;
  }

  static void logout() {
    currentToken = null;
    _currentUser = null;
  }
}

