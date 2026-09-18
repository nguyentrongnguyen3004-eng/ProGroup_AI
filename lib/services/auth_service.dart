import '../core/constants/app_constants.dart';
import '../data/mock/mock_user.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel?> login(
    String username,
    String password,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (username == AppConstants.mockStudentUsername &&
        password == AppConstants.mockStudentPassword) {
      return MockUser.student;
    }

    if (username == AppConstants.mockUsername &&
        password == AppConstants.mockPassword) {
      return MockUser.admin;
    }

    return null;
  }
}