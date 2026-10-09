import '../../models/lecturer_course_model.dart';

class MockLecturerCourses {
  static final List<LecturerCourseModel> courses = [
    LecturerCourseModel(
      id: 1,
      courseId: 1,
      code: 'LTDD',
      name: 'Lập trình di động',
      classCode: 'LTDD-01',
      semester: 'HK7 - 2026',
      studentCount: 38,
      groupCount: 4,
      topicCount: 4,
      groupRegistrationStart: '01/09/2026',
      groupRegistrationEnd: '15/09/2026',
      topicRegistrationStart: '16/09/2026',
      topicRegistrationEnd: '20/09/2026',
      minMembers: 3,
      maxMembers: 5,
      status: 'Đang đăng ký',
    ),
    LecturerCourseModel(
      id: 2,
      courseId: 3,
      code: 'IOT',
      name: 'Internet of Things',
      classCode: 'IOT-01',
      semester: 'HK7 - 2026',
      studentCount: 32,
      groupCount: 1,
      topicCount: 1,
      groupRegistrationStart: '01/09/2026',
      groupRegistrationEnd: '15/09/2026',
      topicRegistrationStart: '16/09/2026',
      topicRegistrationEnd: '22/09/2026',
      minMembers: 3,
      maxMembers: 5,
      status: 'Đang đăng ký',
    ),
  ];

  static LecturerCourseModel? getByCourseId(int courseId) {
    for (final course in courses) {
      if (course.courseId == courseId) return course;
    }
    return null;
  }

  static void update(LecturerCourseModel updated) {
    final index = courses.indexWhere(
      (course) => course.courseId == updated.courseId,
    );
    if (index != -1) courses[index] = updated;
  }
}
