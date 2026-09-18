class GroupModel {
  final int id;
  final String name;
  final String leader;
  final int memberCount;
  final int maxMembers;
  final String status;
  final List<String> members;

  const GroupModel({
    required this.id,
    required this.name,
    required this.leader,
    required this.memberCount,
    required this.maxMembers,
    required this.status,
    required this.members,
  });
}