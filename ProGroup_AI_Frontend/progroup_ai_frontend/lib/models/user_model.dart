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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['nguoiDungId'] as int? ?? json['id'] as int? ?? 1,
      username: json['tenDangNhap'] as String? ?? json['username'] as String? ?? '',
      fullName: json['hoTen'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: (json['maVaiTro'] as String? ?? json['role'] as String? ?? 'SINHVIEN').toUpperCase(),
      roleName: json['tenVaiTro'] as String? ?? json['roleName'] as String? ?? 'Sinh viên',
      mssv: json['mssv'] as String? ?? json['MSSV'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? fullName,
    String? email,
    String? role,
    String? roleName,
    String? mssv,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      roleName: roleName ?? this.roleName,
      mssv: mssv ?? this.mssv,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
