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

  factory AdminAccountModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] ?? json['trangThai'];
    String statusStr = 'Đang hoạt động';
    if (rawStatus is bool) {
      statusStr = rawStatus ? 'Đang hoạt động' : 'Đã khóa';
    } else if (rawStatus != null) {
      final s = rawStatus.toString().toLowerCase();
      if (s.contains('khoa') || s.contains('locked') || s.contains('false') || s == '0') {
        statusStr = 'Đã khóa';
      }
    }

    return AdminAccountModel(
      id: json['id'] as int? ?? json['nguoiDungId'] as int? ?? 0,
      userCode: json['userCode'] as String? ?? json['maNguoiDung'] as String? ?? json['mssv'] as String? ?? json['maGiangVien'] as String? ?? '',
      username: json['username'] as String? ?? json['tenDangNhap'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['hoTen'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? json['tenVaiTro'] as String? ?? json['maVaiTro'] as String? ?? 'SINHVIEN',
      status: statusStr,
      password: json['password'] as String? ?? '',
      phone: json['phone'] as String? ?? json['soDienThoai'] as String? ?? '',
      avatar: json['avatar'] as String? ?? json['avatarUrl'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['ngayTao'] != null ? DateTime.tryParse(json['ngayTao'].toString()) : null),
    );
  }

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
