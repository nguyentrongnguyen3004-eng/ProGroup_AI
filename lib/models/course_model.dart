class CourseModel {
  final int id;
  final String code;
  final String name;
  final String classCode;
  final String semester;
  final String lecturer;
  final String status;

  const CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.classCode,
    required this.semester,
    required this.lecturer,
    required this.status,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    String lecturerName = json['giangVienTen'] ?? json['lecturer'] ?? '';
    if (json['giangVienHocVi'] != null && json['giangVienHocVi'].toString().isNotEmpty && lecturerName.isNotEmpty && !lecturerName.startsWith(json['giangVienHocVi'].toString())) {
      lecturerName = '${json['giangVienHocVi']}. $lecturerName';
    }
    if (lecturerName.isEmpty) {
      lecturerName = 'Chưa phân công';
    }

    String status = 'Đang mở';
    if (json['trangThai'] is String) {
      status = json['trangThai'];
    } else if (json['trangThai'] is bool) {
      status = json['trangThai'] ? 'Đang mở' : 'Đã đóng';
    }

    String semesterStr = json['semester'] ?? '';
    if (json['tenHocKy'] != null) {
      semesterStr = json['namHoc'] != null && json['namHoc'].toString().isNotEmpty
          ? '${json['tenHocKy']} - ${json['namHoc']}'
          : json['tenHocKy'].toString();
    }

    return CourseModel(
      id: json['lopHocPhanId'] ?? json['id'] ?? 0,
      code: json['maHocPhan'] ?? json['code'] ?? '',
      name: json['tenHocPhan'] ?? json['name'] ?? '',
      classCode: json['maLopHocPhan'] ?? json['classCode'] ?? '',
      semester: semesterStr,
      lecturer: lecturerName,
      status: status,
    );
  }
}
