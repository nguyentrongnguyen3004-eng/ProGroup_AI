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
