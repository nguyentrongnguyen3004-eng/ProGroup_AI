class GovernanceStudentModel {
  final int id;
  final String studentCode;
  final String fullName;
  final String email;
  final String phone;
  final String classCode;
  final String status;
  final String cohort;

  const GovernanceStudentModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.email,
    this.phone = '0909123456',
    required this.classCode,
    required this.status,
    this.cohort = 'K21',
  });
}
