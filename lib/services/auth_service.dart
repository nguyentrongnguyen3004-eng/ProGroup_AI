import '../core/constants/app_constants.dart';
import '../data/mock/mock_admin_data.dart';
import '../data/mock/mock_lecturer.dart';
import '../data/mock/mock_user.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel?> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (username == AppConstants.mockLecturerUsername &&
        password == AppConstants.mockLecturerPassword) {
      final lecturer = MockLecturer.current;
      return UserModel(
        id: lecturer.id,
        username: AppConstants.mockLecturerUsername,
        fullName: lecturer.fullName,
        email: lecturer.email,
        role: 'LECTURER',
        roleName: 'Giảng viên',
      );
    }

    if (username == AppConstants.mockStudentUsername &&
        password == AppConstants.mockStudentPassword) {
      return MockUser.student;
    }

    if (username == AppConstants.mockGovernanceUsername &&
        password == AppConstants.mockGovernancePassword) {
      return MockUser.governance;
    }

    if (username == AppConstants.mockTrainingUsername &&
        password == AppConstants.mockTrainingPassword) {
      return MockUser.training;
    }

    final admin = MockAdminData.instance.findAdminCredentials(username, password);
    if (admin != null) {
      return UserModel(
        id: admin.id,
        username: admin.username,
        fullName: admin.fullName,
        email: admin.email,
        role: 'ADMIN',
        roleName: admin.role,
      );
    }

    if (username == AppConstants.mockUsername &&
        MockAdminData.instance.acceptsLegacyAdminCredential(username, password) &&
        password == AppConstants.mockPassword) {
      final legacyAdmin = MockUser.admin;
      return UserModel(
        id: legacyAdmin.id,
        username: legacyAdmin.username,
        fullName: legacyAdmin.fullName,
        email: legacyAdmin.email,
        role: 'ADMIN_LEGACY',
        roleName: legacyAdmin.roleName,
      );
    }

    return null;
  }
}
