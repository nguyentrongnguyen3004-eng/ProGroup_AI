class LecturerModel {
  final int id;
  final String lecturerCode;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String faculty;
  final String department;
  final String avatar;

  const LecturerModel({
    required this.id,
    required this.lecturerCode,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    required this.faculty,
    required this.department,
    required this.avatar,
  });

  LecturerModel copyWith({String? email, String? phoneNumber, String? avatar}) {
    return LecturerModel(
      id: id,
      lecturerCode: lecturerCode,
      fullName: fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      faculty: faculty,
      department: department,
      avatar: avatar ?? this.avatar,
    );
  }
}
