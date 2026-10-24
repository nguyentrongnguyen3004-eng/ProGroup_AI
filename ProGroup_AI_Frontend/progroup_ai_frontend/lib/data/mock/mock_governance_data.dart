import 'package:flutter/foundation.dart';

import '../../models/course_model.dart';
import '../../models/governance_profile_model.dart';
import '../../models/governance_student_model.dart';
import '../../models/lecturer_model.dart';
import '../../models/training_import_record_model.dart';
import 'mock_courses.dart';
import 'mock_lecturer.dart';
import 'mock_user.dart';

/// Local roster owned by the faculty-governance module.
///
/// Existing Student and Lecturer mock collections remain untouched.
class MockGovernanceData extends ChangeNotifier {
  MockGovernanceData._();

  static final MockGovernanceData instance = MockGovernanceData._();

  static GovernanceProfileModel get current => instance.profile;

  static void updateAvatar(String avatar) {
    instance.updateProfile(avatarBase64: avatar);
  }

  static void updateEmail(String email) {
    instance.updateProfile(email: email);
  }

  GovernanceProfileModel profile = GovernanceProfileModel(
    fullName: MockUser.governance.fullName,
    staffCode: 'CBGV001',
    roleName: 'Giáo vụ khoa',
    faculty: 'Khoa Công nghệ thông tin',
    email: MockUser.governance.email,
    phone: '0901 234 567',
    accountStatus: 'Đang hoạt động',
    avatarBase64: '',
  );

  void updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? avatarBase64,
  }) {
    profile = profile.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      avatarBase64: avatarBase64,
    );

    notifyListeners();
  }

  final List<GovernanceStudentModel> students = [
    const GovernanceStudentModel(
      id: 1,
      studentCode: '22110001',
      fullName: 'Nguyễn Văn An',
      email: 'an.nguyen@example.com',
      classCode: 'LTDD-01',
      status: 'Đang học',
    ),
    const GovernanceStudentModel(
      id: 2,
      studentCode: '22110002',
      fullName: 'Trần Văn Minh',
      email: 'minh.tran@example.com',
      classCode: 'LTDD-01',
      status: 'Đang học',
    ),
    const GovernanceStudentModel(
      id: 3,
      studentCode: '22110003',
      fullName: 'Lê Hoàng Nam',
      email: 'nam.le@example.com',
      classCode: 'LTDD-01',
      status: 'Đang học',
    ),
    const GovernanceStudentModel(
      id: 4,
      studentCode: '22110004',
      fullName: 'Phạm Quốc Huy',
      email: 'huy.pham@example.com',
      classCode: 'LTDD-01',
      status: 'Đang học',
    ),
    const GovernanceStudentModel(
      id: 5,
      studentCode: '22120001',
      fullName: 'Nguyễn Thị Mai',
      email: 'mai.nguyen@example.com',
      classCode: 'BDL-02',
      status: 'Đang học',
    ),
    const GovernanceStudentModel(
      id: 6,
      studentCode: '22120002',
      fullName: 'Lê Văn Phúc',
      email: 'phuc.le@example.com',
      classCode: 'BDL-02',
      status: 'Đang học',
    ),
    const GovernanceStudentModel(
      id: 7,
      studentCode: '22130001',
      fullName: 'Trần Minh Đức',
      email: 'duc.tran@example.com',
      classCode: 'IOT-01',
      status: 'Đang học',
    ),
    const GovernanceStudentModel(
      id: 8,
      studentCode: '22130002',
      fullName: 'Võ Thành Đạt',
      email: 'dat.vo@example.com',
      classCode: 'IOT-01',
      status: 'Đang học',
    ),
  ];

  final List<LecturerModel> lecturers = [
    MockLecturer.current,
    const LecturerModel(
      id: 2,
      lecturerCode: 'GV002',
      fullName: 'Trần Thị Lan',
      email: 'lan.tran@example.com',
      faculty: 'Khoa Công nghệ thông tin',
      department: 'Bộ môn Khoa học dữ liệu',
      avatar: '',
    ),
    const LecturerModel(
      id: 3,
      lecturerCode: 'GV003',
      fullName: 'Lê Minh Tuấn',
      email: 'tuan.le@example.com',
      faculty: 'Khoa Công nghệ thông tin',
      department: 'Bộ môn Hệ thống thông tin',
      avatar: '',
    ),
  ];

  final List<CourseModel> courses = List<CourseModel>.of(MockCourses.courses);

  final Map<String, String> lecturerStatuses = {
    'GV001': 'Đang công tác',
    'GV002': 'Đang công tác',
    'GV003': 'Đang công tác',
  };

  final List<TrainingImportRecordModel> importHistory = [];

  int get nextStudentId => _nextId(students.map((item) => item.id));

  int get nextLecturerId => _nextId(lecturers.map((item) => item.id));

  int get nextCourseId => _nextId(courses.map((item) => item.id));

  static int _nextId(Iterable<int> ids) {
    return ids.fold<int>(0, (maxId, id) => id > maxId ? id : maxId) + 1;
  }

  LecturerModel? lecturerByCode(String code) {
    for (final lecturer in lecturers) {
      if (lecturer.lecturerCode.toLowerCase() == code.trim().toLowerCase()) {
        return lecturer;
      }
    }

    return null;
  }

  String lecturerStatus(LecturerModel lecturer) {
    return lecturerStatuses[lecturer.lecturerCode] ?? 'Đang công tác';
  }

  void assignLecturer(int courseId, String lecturerName) {
    final index = courses.indexWhere((course) => course.id == courseId);

    if (index == -1) {
      return;
    }

    final course = courses[index];

    courses[index] = CourseModel(
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
    for (var index = 0; index < courses.length; index++) {
      final course = courses[index];
      if (course.lecturer != previous) continue;
      courses[index] = CourseModel(
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

  void addCourses(Iterable<CourseModel> rows) {
    courses.addAll(rows);
    notifyListeners();
  }

  void recordImport(TrainingImportRecordModel record) {
    importHistory.insert(0, record);
    notifyListeners();
  }
}
