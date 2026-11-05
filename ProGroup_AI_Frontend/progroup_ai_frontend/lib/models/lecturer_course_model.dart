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
  final int? dotDangKyId;
  final String dotDangKyName;
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
    this.dotDangKyId,
    this.dotDangKyName = 'Đợt đăng ký',
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

    final studentCount = json['soSinhVien'] as int? ??
        json['studentCount'] as int? ??
        json['SoSinhVien'] as int? ??
        0;
    final groupCount = json['soNhom'] as int? ??
        json['groupCount'] as int? ??
        json['SoNhom'] as int? ??
        0;
    final topicCount = json['soDeTai'] as int? ??
        json['topicCount'] as int? ??
        json['SoDeTai'] as int? ??
        0;

    int? dotDangKyId;
    String dotDangKyName = 'Chưa mở đợt';
    String groupRegistrationStart = '01/09/2026';
    String groupRegistrationEnd = '20/09/2026';
    String topicRegistrationStart = '01/09/2026';
    String topicRegistrationEnd = '20/09/2026';
    int minMembers = json['minMembers'] as int? ?? 3;
    int maxMembers = json['maxMembers'] as int? ?? 5;
    String status = json['status'] as String? ?? 'Chưa mở';

    if (json['dotDangKys'] is List && (json['dotDangKys'] as List).isNotEmpty) {
      final dots = (json['dotDangKys'] as List).whereType<Map<String, dynamic>>().toList();
      if (dots.isNotEmpty) {
        final activeDot = dots.firstWhere(
          (d) => d['trangThai'] == 'Đang mở',
          orElse: () => dots.first,
        );
        dotDangKyId = activeDot['dotDangKyId'] as int? ?? activeDot['id'] as int?;
        dotDangKyName = activeDot['tenDot']?.toString() ?? 'Đợt đăng ký đồ án';
        status = activeDot['trangThai']?.toString() ?? 'Đang mở';
        minMembers = activeDot['minMembers'] as int? ?? minMembers;
        maxMembers = activeDot['maxMembers'] as int? ?? maxMembers;

        String fmtDate(dynamic d) {
          if (d == null) return '';
          final dt = d is DateTime ? d : DateTime.tryParse(d.toString());
          if (dt == null) return d.toString();
          return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        }

        final startStr = fmtDate(activeDot['ngayBatDau']);
        final endStr = fmtDate(activeDot['ngayKetThuc']);
        if (startStr.isNotEmpty) {
          groupRegistrationStart = startStr;
          topicRegistrationStart = startStr;
        }
        if (endStr.isNotEmpty) {
          groupRegistrationEnd = endStr;
          topicRegistrationEnd = endStr;
        }
      }
    } else {
      if (json['groupRegistrationStart'] != null) {
        groupRegistrationStart = json['groupRegistrationStart'].toString();
      }
      if (json['groupRegistrationEnd'] != null) {
        groupRegistrationEnd = json['groupRegistrationEnd'].toString();
      }
      if (json['topicRegistrationStart'] != null) {
        topicRegistrationStart = json['topicRegistrationStart'].toString();
      }
      if (json['topicRegistrationEnd'] != null) {
        topicRegistrationEnd = json['topicRegistrationEnd'].toString();
      }
    }

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
      dotDangKyId: dotDangKyId,
      dotDangKyName: dotDangKyName,
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
    int? dotDangKyId,
    String? dotDangKyName,
    String? groupRegistrationStart,
    String? groupRegistrationEnd,
    String? topicRegistrationStart,
    String? topicRegistrationEnd,
    int? minMembers,
    int? maxMembers,
    String? status,
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
      dotDangKyId: dotDangKyId ?? this.dotDangKyId,
      dotDangKyName: dotDangKyName ?? this.dotDangKyName,
      groupRegistrationStart:
          groupRegistrationStart ?? this.groupRegistrationStart,
      groupRegistrationEnd: groupRegistrationEnd ?? this.groupRegistrationEnd,
      topicRegistrationStart:
          topicRegistrationStart ?? this.topicRegistrationStart,
      topicRegistrationEnd: topicRegistrationEnd ?? this.topicRegistrationEnd,
      minMembers: minMembers ?? this.minMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      status: status ?? this.status,
    );
  }
}
