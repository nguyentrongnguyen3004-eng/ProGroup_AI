class GroupJoinRequestModel {
  final int id;
  final int groupId;
  final String groupName;
  final String studentName;
  final String studentMssv;
  final String studentEmail;
  String status;
  final DateTime createdAt;

  GroupJoinRequestModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.studentName,
    required this.studentMssv,
    required this.studentEmail,
    required this.status,
    required this.createdAt,
  });
}
