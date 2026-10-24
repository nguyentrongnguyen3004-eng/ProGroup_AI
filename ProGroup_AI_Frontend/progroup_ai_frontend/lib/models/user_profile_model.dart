class UserProfileModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String roleName;
  final String mssv;
  final String dateOfBirth;
  final String gender;
  final String faculty;
  final String className;
  final String phoneNumber;
  final String avatarUrl;

  const UserProfileModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    this.roleName = 'Sinh viên',
    this.mssv = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.faculty = 'Khoa Công nghệ thông tin',
    this.className = '',
    this.phoneNumber = '',
    this.avatarUrl = '',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['nguoiDungId'] as int? ??
          json['sinhVienId'] as int? ??
          json['id'] as int? ??
          1,
      username: json['tenDangNhap'] as String? ??
          json['username'] as String? ??
          '',
      fullName: json['hoTen'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: (json['maVaiTro'] as String? ?? json['role'] as String? ?? 'SINHVIEN').toUpperCase(),
      roleName: json['tenVaiTro'] as String? ??
          json['roleName'] as String? ??
          'Sinh viên',
      mssv: json['mssv'] as String? ?? json['MSSV'] as String? ?? '',
      dateOfBirth: json['ngaySinh'] as String? ??
          json['dateOfBirth'] as String? ??
          '',
      gender: json['gioiTinh'] as String? ?? json['gender'] as String? ?? '',
      faculty: json['tenKhoa'] as String? ??
          json['khoa'] as String? ??
          json['faculty'] as String? ??
          'Khoa Công nghệ thông tin',
      className: json['lop'] as String? ??
          json['maLop'] as String? ??
          json['className'] as String? ??
          '',
      phoneNumber: json['soDienThoai'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  UserProfileModel copyWith({
    int? id,
    String? username,
    String? fullName,
    String? email,
    String? role,
    String? roleName,
    String? mssv,
    String? dateOfBirth,
    String? gender,
    String? faculty,
    String? className,
    String? phoneNumber,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      roleName: roleName ?? this.roleName,
      mssv: mssv ?? this.mssv,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      faculty: faculty ?? this.faculty,
      className: className ?? this.className,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
