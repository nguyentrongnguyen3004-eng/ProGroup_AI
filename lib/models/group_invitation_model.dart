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
}
