class GovernanceProfileModel {
  final String fullName;
  final String staffCode;
  final String roleName;
  final String faculty;
  final String email;
  final String phone;
  final String accountStatus;
  final String avatarBase64;

  const GovernanceProfileModel({
    required this.fullName,
    required this.staffCode,
    required this.roleName,
    required this.faculty,
    required this.email,
    required this.phone,
    required this.accountStatus,
    this.avatarBase64 = '',
  });

  String get position => roleName;

  bool get isActive =>
      accountStatus.trim().toLowerCase() == 'đang hoạt động';

  GovernanceProfileModel copyWith({
    String? fullName,
    String? staffCode,
    String? roleName,
    String? faculty,
    String? email,
    String? phone,
    String? accountStatus,
    String? avatarBase64,
  }) {
    return GovernanceProfileModel(
      fullName: fullName ?? this.fullName,
      staffCode: staffCode ?? this.staffCode,
      roleName: roleName ?? this.roleName,
      faculty: faculty ?? this.faculty,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      accountStatus: accountStatus ?? this.accountStatus,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
    );
  }
}