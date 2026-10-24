import '../../models/course_model.dart';

class MockCourses {
  static const List<CourseModel> courses = [
    CourseModel(
      id: 1,
      code: 'LTDD',
      name: 'Lập trình di động',
      classCode: 'LTDD-01',
      semester: 'HK7 - 2026',
      lecturer: 'Nguyễn Văn Bình',
      status: 'Đang đăng ký',
    ),
    CourseModel(
      id: 2,
      code: 'BDL',
      name: 'Nhập môn Big Data',
      classCode: 'BDL-02',
      semester: 'HK7 - 2026',
      lecturer: 'Trần Thị Lan',
      status: 'Chưa mở',
    ),
    CourseModel(
      id: 3,
      code: 'IOT',
      name: 'Internet of Things',
      classCode: 'IOT-01',
      semester: 'HK7 - 2026',
      lecturer: 'Lê Minh Tuấn',
      status: 'Đang đăng ký',
    ),
  ];
}
