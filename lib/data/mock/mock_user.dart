import '../../models/user_model.dart';

class MockUser {
  static const UserModel student = UserModel(
    id: 1,
    username: 'sv001',
    fullName: 'Nguyễn Văn An',
    email: 'an.nguyen@example.com',
    role: 'SINHVIEN',
    roleName: 'Sinh viên',
    mssv: '22110001',
  );

  static const UserModel admin = UserModel(
    id: 2,
    username: 'admin',
    fullName: 'Quản trị viên',
    email: 'admin@progroup.local',
    role: 'ADMIN',
    roleName: 'Quản trị viên',
  );
}