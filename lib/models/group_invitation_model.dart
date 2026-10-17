class GroupInvitationModel {
  final int id;
  final int groupId;
  final String groupName;
  final String inviter;
  final String inviteeName;
  final String inviteeMssv;
  String status;
  final DateTime createdAt;

  GroupInvitationModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.inviter,
    required this.inviteeName,
    required this.inviteeMssv,
    required this.status,
    required this.createdAt,
  });

  factory GroupInvitationModel.fromJson(Map<String, dynamic> json) {
    return GroupInvitationModel(
      id: json['id'] as int? ?? 0,
      groupId: json['groupId'] as int? ?? 0,
      groupName: json['groupName'] as String? ?? '',
      inviter: json['inviter'] as String? ?? '',
      inviteeName: json['inviteeName'] as String? ?? '',
      inviteeMssv: json['inviteeMssv'] as String? ?? '',
      status: json['status'] as String? ?? 'Chờ xử lý',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
