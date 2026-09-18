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
}