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

  factory GroupJoinRequestModel.fromJson(Map<String, dynamic> json) {
    return GroupJoinRequestModel(
      id: json['id'] as int? ?? 0,
      groupId: json['groupId'] as int? ?? 0,
      groupName: json['groupName'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      studentMssv: json['studentMssv'] as String? ?? '',
      studentEmail: json['studentEmail'] as String? ?? '',
      status: json['status'] as String? ?? 'Chờ duyệt',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
