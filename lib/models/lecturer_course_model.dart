class LecturerCourseModel {
  final int id;
  final int courseId;
  final String code;
  final String name;
  final String classCode;
  final String semester;
  final int studentCount;
  final int groupCount;
  final int topicCount;
  final String groupRegistrationStart;
  final String groupRegistrationEnd;
  final String topicRegistrationStart;
  final String topicRegistrationEnd;
  final int minMembers;
  final int maxMembers;
  final String status;

  const LecturerCourseModel({
    required this.id,
    required this.courseId,
    required this.code,
    required this.name,
    required this.classCode,
    required this.semester,
    required this.studentCount,
    required this.groupCount,
    required this.topicCount,
    required this.groupRegistrationStart,
    required this.groupRegistrationEnd,
    required this.topicRegistrationStart,
    required this.topicRegistrationEnd,
    required this.minMembers,
    required this.maxMembers,
    required this.status,
  });

  factory LecturerCourseModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? json['lopHocPhanId'] as int? ?? json['courseId'] as int? ?? 1;
    final courseId = json['courseId'] as int? ?? json['lopHocPhanId'] as int? ?? id;
    final code = json['code'] as String? ?? json['maHocPhan'] as String? ?? json['maLopHocPhan'] as String? ?? 'HP';
    final name = json['name'] as String? ?? json['tenHocPhan'] as String? ?? json['tenLopHocPhan'] as String? ?? 'Lớp học phần';
    final classCode = json['classCode'] as String? ?? json['maLopHocPhan'] as String? ?? 'LHP-$id';
    final semester = json['semester'] as String? ??
        (json['tenHocKy'] != null && json['namHoc'] != null
            ? '${json['tenHocKy']} - ${json['namHoc']}'
            : (json['tenHocKy'] as String? ?? 'HK1 - 2026-2027'));
    final studentCount = json['studentCount'] as int? ?? json['soLuongToiDa'] as int? ?? 45;
    final groupCount = json['groupCount'] as int? ?? 0;
    final topicCount = json['topicCount'] as int? ?? 0;
    final groupRegistrationStart = json['groupRegistrationStart'] as String? ?? '01/09/2026';
    final groupRegistrationEnd = json['groupRegistrationEnd'] as String? ?? '20/09/2026';
    final topicRegistrationStart = json['topicRegistrationStart'] as String? ?? '21/09/2026';
    final topicRegistrationEnd = json['topicRegistrationEnd'] as String? ?? '30/09/2026';
    final minMembers = json['minMembers'] as int? ?? 3;
    final maxMembers = json['maxMembers'] as int? ?? 5;
    final status = json['status'] as String? ?? 'Đang mở đăng ký';

    return LecturerCourseModel(
      id: id,
      courseId: courseId,
      code: code,
      name: name,
      classCode: classCode,
      semester: semester,
      studentCount: studentCount,
      groupCount: groupCount,
      topicCount: topicCount,
      groupRegistrationStart: groupRegistrationStart,
      groupRegistrationEnd: groupRegistrationEnd,
      topicRegistrationStart: topicRegistrationStart,
      topicRegistrationEnd: topicRegistrationEnd,
      minMembers: minMembers,
      maxMembers: maxMembers,
      status: status,
    );
  }

  LecturerCourseModel copyWith({
    String? groupRegistrationStart,
    String? groupRegistrationEnd,
    String? topicRegistrationStart,
    String? topicRegistrationEnd,
    int? minMembers,
    int? maxMembers,
  }) {
    return LecturerCourseModel(
      id: id,
      courseId: courseId,
      code: code,
      name: name,
      classCode: classCode,
      semester: semester,
      studentCount: studentCount,
      groupCount: groupCount,
      topicCount: topicCount,
      groupRegistrationStart:
          groupRegistrationStart ?? this.groupRegistrationStart,
      groupRegistrationEnd: groupRegistrationEnd ?? this.groupRegistrationEnd,
      topicRegistrationStart:
          topicRegistrationStart ?? this.topicRegistrationStart,
      topicRegistrationEnd: topicRegistrationEnd ?? this.topicRegistrationEnd,
      minMembers: minMembers ?? this.minMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      status: status,
    );
  }
}
