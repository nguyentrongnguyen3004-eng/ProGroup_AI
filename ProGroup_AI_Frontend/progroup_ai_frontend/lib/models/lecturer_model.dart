class LecturerModel {
  final int id;
  final String lecturerCode;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String faculty;
  final String department;
  final String avatar;
  final String hocVi;
  final String chuyenMon;
  final int soLopPhuTrach;

  const LecturerModel({
    required this.id,
    required this.lecturerCode,
    required this.fullName,
    required this.email,
    this.phoneNumber = '0909123456',
    required this.faculty,
    required this.department,
    required this.avatar,
    this.hocVi = 'ThS.',
    this.chuyenMon = 'Công nghệ phần mềm & Di động',
    this.soLopPhuTrach = 2,
  });

  LecturerModel copyWith({
    String? email,
    String? phoneNumber,
    String? avatar,
    String? hocVi,
    String? chuyenMon,
    int? soLopPhuTrach,
  }) {
    return LecturerModel(
      id: id,
      lecturerCode: lecturerCode,
      fullName: fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      faculty: faculty,
      department: department,
      avatar: avatar ?? this.avatar,
      hocVi: hocVi ?? this.hocVi,
      chuyenMon: chuyenMon ?? this.chuyenMon,
      soLopPhuTrach: soLopPhuTrach ?? this.soLopPhuTrach,
    );
  }
}
