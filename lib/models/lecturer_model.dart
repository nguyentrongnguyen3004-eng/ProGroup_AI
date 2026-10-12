class LecturerModel {
  final int id;
  final String lecturerCode;
  final String fullName;
  final String email;
  final String faculty;
  final String department;
  final String avatar;

  const LecturerModel({
    required this.id,
    required this.lecturerCode,
    required this.fullName,
    required this.email,
    required this.faculty,
    required this.department,
    required this.avatar,
  });

  LecturerModel copyWith({
    int? id,
    String? lecturerCode,
    String? fullName,
    String? email,
    String? faculty,
    String? department,
    String? avatar,
  }) {
    return LecturerModel(
      id: id ?? this.id,
      lecturerCode: lecturerCode ?? this.lecturerCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      avatar: avatar ?? this.avatar,
    );
  }
}
