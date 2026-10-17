class CourseModel {
  final int id;
  final String code;
  final String name;
  final String classCode;
  final String semester;
  final String lecturer;
  final String status;
  final int? courseId;
  final int studentCount;
  final int groupCount;
  final int topicCount;

  const CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.classCode,
    required this.semester,
    required this.lecturer,
    required this.status,
    this.courseId,
    this.studentCount = 0,
    this.groupCount = 0,
    this.topicCount = 0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
<<<<<<< HEAD
    final id = json['id'] as int? ?? json['lopHocPhanId'] as int? ?? 0;
    final courseId = json['courseId'] as int? ?? json['hocPhanId'] as int? ?? id;
    final code = json['code'] as String? ??
        json['maHocPhan'] as String? ??
        json['maLopHocPhan'] as String? ??
        '';
    final name = json['name'] as String? ??
        json['tenHocPhan'] as String? ??
        json['tenLopHocPhan'] as String? ??
        '';
    final classCode = json['classCode'] as String? ??
        json['maLopHocPhan'] as String? ??
        '';

    String semester = json['semester'] as String? ?? '';
    if (semester.isEmpty && (json['tenHocKy'] != null || json['namHoc'] != null)) {
      semester = '${json['tenHocKy'] ?? ''} ${json['namHoc'] ?? ''}'.trim();
    }
    if (semester.isEmpty) {
      semester = 'HK1 2026-2027';
    }

    final lecturer = json['lecturer'] as String? ??
        json['giangVien'] as String? ??
        'Giảng viên phụ trách';
    final status = json['status'] as String? ??
        json['trangThai'] as String? ??
        'Đang đăng ký';
    final studentCount = json['studentCount'] as int? ??
        json['soLuongSinhVien'] as int? ??
        json['soLuongToiDa'] as int? ??
        0;
    final groupCount = json['groupCount'] as int? ??
        json['soLuongNhom'] as int? ??
        0;
    final topicCount = json['topicCount'] as int? ??
        json['soLuongDeTai'] as int? ??
        0;

    return CourseModel(
      id: id,
      courseId: courseId,
      code: code,
      name: name,
      classCode: classCode,
      semester: semester,
      lecturer: lecturer,
      status: status,
      studentCount: studentCount,
      groupCount: groupCount,
      topicCount: topicCount,
    );
  }

  CourseModel copyWith({
    int? id,
    String? code,
    String? name,
    String? classCode,
    String? semester,
    String? lecturer,
    String? status,
    int? courseId,
    int? studentCount,
    int? groupCount,
    int? topicCount,
  }) {
    return CourseModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      classCode: classCode ?? this.classCode,
      semester: semester ?? this.semester,
      lecturer: lecturer ?? this.lecturer,
      status: status ?? this.status,
      courseId: courseId ?? this.courseId,
      studentCount: studentCount ?? this.studentCount,
      groupCount: groupCount ?? this.groupCount,
      topicCount: topicCount ?? this.topicCount,
=======
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
>>>>>>> origin/Frontend
    );
  }
}
