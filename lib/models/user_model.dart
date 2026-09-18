class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String roleName;
  final String? mssv;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    required this.roleName,
    this.mssv,
    this.avatarUrl,
  });
}