class AdminAccountModel {
  const AdminAccountModel({
    required this.id,
    required this.userCode,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.password,
    this.phone = '',
    this.avatar = '',
    this.createdAt,
  });

  final int id;
  final String userCode;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String status;
  final String password;
  final String phone;
  final String avatar;
  final DateTime? createdAt;

  bool get isActive => status == 'Đang hoạt động';

  AdminAccountModel copyWith({
    int? id,
    String? userCode,
    String? username,
    String? fullName,
    String? email,
    String? role,
    String? status,
    String? password,
    String? phone,
    String? avatar,
    DateTime? createdAt,
  }) => AdminAccountModel(
    id: id ?? this.id,
    userCode: userCode ?? this.userCode,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    role: role ?? this.role,
    status: status ?? this.status,
    password: password ?? this.password,
    phone: phone ?? this.phone,
    avatar: avatar ?? this.avatar,
    createdAt: createdAt ?? this.createdAt,
  );
}
