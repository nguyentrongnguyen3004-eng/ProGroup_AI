import 'package:flutter/foundation.dart';

import '../../models/course_model.dart';
import '../../models/governance_student_model.dart';
import '../../models/lecturer_model.dart';
import '../../models/training_import_record_model.dart';
import '../../models/training_profile_model.dart';
import '../../models/training_subject_model.dart';
import 'mock_courses.dart';
import 'mock_governance_data.dart';

class MockTrainingData extends ChangeNotifier {
  MockTrainingData._();

  static final MockTrainingData instance = MockTrainingData._();

  TrainingProfileModel profile = const TrainingProfileModel(
    fullName: 'Nguyễn Minh Anh',
    staffCode: 'PDT001',
    roleName: 'Chuyên viên đào tạo',
    unit: 'Phòng Đào tạo',
    email: 'minh.anh@progroup.local',
    phone: '0908 123 456',
    position: 'Chuyên viên',
    accountStatus: 'Đang hoạt động',
  );

  // Copy the existing mock records into role-local collections. The models
  // are immutable; changes made here do not mutate the faculty-governance data.
  final List<GovernanceStudentModel> students = [
    ...MockGovernanceData.instance.students,
  ];

  final List<LecturerModel> lecturers = [
    ...MockGovernanceData.instance.lecturers,
  ];

  final List<CourseModel> courseClasses = [...MockCourses.courses];

  final List<TrainingSubjectModel> subjects = [
    TrainingSubjectModel(
      code: 'LTDD',
      name: 'Lập trình di động',
      credits: 3,
      department: 'Công nghệ phần mềm',
      status: 'Đang giảng dạy',
    ),
    TrainingSubjectModel(
      code: 'BDL',
      name: 'Nhập môn Big Data',
      credits: 3,
      department: 'Khoa học dữ liệu',
      status: 'Đang giảng dạy',
    ),
    TrainingSubjectModel(
      code: 'IOT',
      name: 'Internet of Things',
      credits: 4,
      department: 'Hệ thống thông tin',
      status: 'Đang giảng dạy',
    ),
    TrainingSubjectModel(
      code: 'CTDL',
      name: 'Cấu trúc dữ liệu và giải thuật',
      credits: 4,
      department: 'Công nghệ phần mềm',
      status: 'Tạm ngưng',
    ),
  ];

  final List<TrainingImportRecordModel> importHistory = [];

  final Map<String, String> lecturerStatuses = {
    'GV001': 'Đang công tác',
    'GV002': 'Đang công tác',
    'GV003': 'Đang công tác',
  };

  void updateEmail(String email) {
    profile = profile.copyWith(email: email);
    notifyListeners();
  }

  void updateAvatar(String avatar) {
    profile = profile.copyWith(avatar: avatar);
    notifyListeners();
  }

  String lecturerStatus(LecturerModel lecturer) =>
      lecturerStatuses[lecturer.lecturerCode] ?? 'Đang công tác';

  int get nextStudentId => _nextId(students.map((item) => item.id));

  int get nextLecturerId => _nextId(lecturers.map((item) => item.id));

  int get nextCourseClassId => _nextId(courseClasses.map((item) => item.id));

  static int _nextId(Iterable<int> ids) =>
      ids.fold<int>(0, (maxId, id) => id > maxId ? id : maxId) + 1;

  void addStudents(Iterable<GovernanceStudentModel> rows) {
    students.addAll(rows);
    notifyListeners();
  }

  void updateStudent(GovernanceStudentModel student) {
    final index = students.indexWhere((item) => item.id == student.id);
    if (index < 0) return;
    students[index] = student;
    notifyListeners();
  }

  void removeStudent(int id) {
    final previousLength = students.length;
    students.removeWhere((item) => item.id == id);
    if (students.length != previousLength) notifyListeners();
  }

  void addLecturers(
    Iterable<LecturerModel> rows, {
    Map<String, String> statuses = const {},
  }) {
    for (final lecturer in rows) {
      lecturers.add(lecturer);
      lecturerStatuses[lecturer.lecturerCode] =
          statuses[lecturer.lecturerCode] ?? 'Đang công tác';
    }
    notifyListeners();
  }

  void updateLecturer(LecturerModel lecturer, {required String status}) {
    final index = lecturers.indexWhere((item) => item.id == lecturer.id);
    if (index < 0) return;
    final previous = lecturers[index];
    if (previous.lecturerCode != lecturer.lecturerCode) {
      lecturerStatuses.remove(previous.lecturerCode);
    }
    lecturers[index] = lecturer;
    lecturerStatuses[lecturer.lecturerCode] = status;
    if (previous.fullName != lecturer.fullName) {
      _replaceCourseLecturer(previous.fullName, lecturer.fullName);
    }
    notifyListeners();
  }

  void removeLecturer(int id) {
    final index = lecturers.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final removed = lecturers.removeAt(index);
    lecturerStatuses.remove(removed.lecturerCode);
    _replaceCourseLecturer(removed.fullName, '');
    notifyListeners();
  }

  void _replaceCourseLecturer(String previous, String next) {
    for (var index = 0; index < courseClasses.length; index++) {
      final course = courseClasses[index];
      if (course.lecturer != previous) continue;
      courseClasses[index] = CourseModel(
        id: course.id,
        code: course.code,
        name: course.name,
        classCode: course.classCode,
        semester: course.semester,
        lecturer: next,
        status: course.status,
      );
    }
  }

  void addCourseClasses(Iterable<CourseModel> rows) {
    courseClasses.addAll(rows);
    notifyListeners();
  }

  void updateCourseClass(CourseModel course) {
    final index = courseClasses.indexWhere((item) => item.id == course.id);
    if (index < 0) return;
    courseClasses[index] = course;
    notifyListeners();
  }

  void removeCourseClass(int id) {
    final previousLength = courseClasses.length;
    courseClasses.removeWhere((item) => item.id == id);
    if (courseClasses.length != previousLength) notifyListeners();
  }

  void addSubjects(Iterable<TrainingSubjectModel> rows) {
    subjects.addAll(rows);
    notifyListeners();
  }

  void updateSubject(String previousCode, TrainingSubjectModel subject) {
    final index = subjects.indexWhere((item) => item.code == previousCode);
    if (index < 0) return;
    subjects[index] = subject;
    for (
      var courseIndex = 0;
      courseIndex < courseClasses.length;
      courseIndex++
    ) {
      final course = courseClasses[courseIndex];
      if (course.code != previousCode) continue;
      courseClasses[courseIndex] = CourseModel(
        id: course.id,
        code: subject.code,
        name: subject.name,
        classCode: course.classCode,
        semester: course.semester,
        lecturer: course.lecturer,
        status: course.status,
      );
    }
    notifyListeners();
  }

  int removeSubject(String code) {
    final subjectIndex = subjects.indexWhere((item) => item.code == code);
    if (subjectIndex < 0) return 0;
    subjects.removeAt(subjectIndex);
    final previousLength = courseClasses.length;
    courseClasses.removeWhere((item) => item.code == code);
    final removedClasses = previousLength - courseClasses.length;
    notifyListeners();
    return removedClasses;
  }

  void recordImport(TrainingImportRecordModel record) {
    importHistory.insert(0, record);
    notifyListeners();
  }

  void assignLecturer(int courseId, String lecturerName) {
    final index = courseClasses.indexWhere((course) => course.id == courseId);
    if (index < 0) return;
    final course = courseClasses[index];
    courseClasses[index] = CourseModel(
      id: course.id,
      code: course.code,
      name: course.name,
      classCode: course.classCode,
      semester: course.semester,
      lecturer: lecturerName,
      status: course.status,
    );
    notifyListeners();
  }
}
