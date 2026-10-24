import 'package:flutter/foundation.dart';
import '../../models/lecturer_course_model.dart';

class MockLecturerCourses extends ChangeNotifier {
  MockLecturerCourses._();
  static final MockLecturerCourses instance = MockLecturerCourses._();

  static List<LecturerCourseModel> _courses = [
    const LecturerCourseModel(
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
    const LecturerCourseModel(
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

  static List<LecturerCourseModel> get courses => _courses;

  static void setCourses(List<LecturerCourseModel> newCourses) {
    _courses = List.from(newCourses);
    instance.notifyListeners();
  }

  static LecturerCourseModel? getByCourseId(int courseId) {
    for (final course in _courses) {
      if (course.courseId == courseId) return course;
    }
    return null;
  }

  static void update(LecturerCourseModel updated) {
    final index = _courses.indexWhere(
      (course) => course.courseId == updated.courseId,
    );
    if (index != -1) {
      _courses[index] = updated;
      instance.notifyListeners();
    }
  }
}
