class GroupJoinRequestModel {
  final int id;
  final int groupId;
  final String groupName;
  final String studentName;
  final String studentMssv;
  final String studentEmail;
  String status;
  final String message;
  final DateTime createdAt;

  GroupJoinRequestModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.studentName,
    required this.studentMssv,
    required this.studentEmail,
    required this.status,
    this.message = '',
    required this.createdAt,
  });
}
