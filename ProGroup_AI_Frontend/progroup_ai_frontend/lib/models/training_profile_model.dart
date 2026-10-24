class TrainingProfileModel {
  final String fullName;
  final String staffCode;
  final String roleName;
  final String unit;
  final String email;
  final String phone;
  final String position;
  final String accountStatus;
  final String avatar;

  const TrainingProfileModel({
    required this.fullName,
    required this.staffCode,
    required this.roleName,
    required this.unit,
    required this.email,
    required this.phone,
    required this.position,
    required this.accountStatus,
    this.avatar = '',
  });

  TrainingProfileModel copyWith({String? email, String? avatar}) {
    return TrainingProfileModel(
      fullName: fullName,
      staffCode: staffCode,
      roleName: roleName,
      unit: unit,
      email: email ?? this.email,
      phone: phone,
      position: position,
      accountStatus: accountStatus,
      avatar: avatar ?? this.avatar,
    );
  }
}
