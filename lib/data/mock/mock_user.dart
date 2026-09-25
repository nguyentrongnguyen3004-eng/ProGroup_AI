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

  static const UserModel governance = UserModel(
    id: 3,
    username: 'giaovu',
    fullName: 'Giáo vụ khoa',
    email: 'giaovu@progroup.local',
    role: 'GIAOVU',
    roleName: 'Giáo vụ khoa',
  );

  static const UserModel training = UserModel(
    id: 4,
    username: 'daotao',
    fullName: 'Phòng Đào tạo',
    email: 'daotao@progroup.local',
    role: 'PHONG_DAO_TAO',
    roleName: 'Phòng Đào tạo',
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
