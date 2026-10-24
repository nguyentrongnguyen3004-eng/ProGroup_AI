class GroupModel {
  final int id;
  final int courseId;
  final String name;
  final String leader;
  final int memberCount;
  final int maxMembers;
  final String status;
  final List<String> members;

  const GroupModel({
    required this.id,
    required this.courseId,
    required this.name,
    required this.leader,
    required this.memberCount,
    required this.maxMembers,
    required this.status,
    required this.members,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? json['nhomId'] as int? ?? 0;
    final courseId = json['courseId'] as int? ??
        json['lopHocPhanId'] as int? ??
        json['dotDangKyId'] as int? ??
        0;
    final name = json['name'] as String? ??
        json['tenNhom'] as String? ??
        'Nhóm $id';
    final leader = json['leader'] as String? ??
        json['truongNhom'] as String? ??
        '';
    final maxMembers = json['maxMembers'] as int? ?? 5;
    final status = json['status'] as String? ??
        json['trangThai'] as String? ??
        'Đang hoạt động';

    List<String> memberNames = [];
    if (json['members'] is List) {
      memberNames = (json['members'] as List)
          .map((m) {
            if (m is Map) {
              return (m['hoTen'] ?? m['name'] ?? m['fullName'] ?? '').toString();
            }
            return m.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (json['thanhViens'] is List) {
      memberNames = (json['thanhViens'] as List)
          .map((m) {
            if (m is Map) {
              return (m['hoTen'] ?? m['name'] ?? m['fullName'] ?? '').toString();
            }
            return m.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    if (memberNames.isEmpty && leader.isNotEmpty) {
      memberNames = [leader];
    }

    final memberCount = json['memberCount'] as int? ?? memberNames.length;

    return GroupModel(
      id: id,
      courseId: courseId,
      name: name,
      leader: leader,
      memberCount: memberCount,
      maxMembers: maxMembers,
      status: status,
      members: memberNames,
    );
  }

  GroupModel copyWith({
    int? id,
    int? courseId,
    String? name,
    String? leader,
    int? memberCount,
    int? maxMembers,
    String? status,
    List<String>? members,
  }) {
    return GroupModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      leader: leader ?? this.leader,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      status: status ?? this.status,
      members: members ?? this.members,
    );
  }
}
