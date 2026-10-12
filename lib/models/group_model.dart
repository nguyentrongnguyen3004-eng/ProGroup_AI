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
    final thanhViens = json['thanhViens'] as List<dynamic>? ?? [];
    final memberNames = thanhViens.map((m) => (m['hoTen'] ?? '').toString()).where((n) => n.isNotEmpty).toList();

    return GroupModel(
      id: json['nhomId'] ?? 0,
      courseId: json['lopHocPhanId'] ?? json['dotDangKyId'] ?? 0,
      name: json['tenNhom'] ?? '',
      leader: json['truongNhom'] ?? json['truongNhomHoTen'] ?? '',
      memberCount: json['soLuongHienTai'] ?? memberNames.length,
      maxMembers: json['soLuongToiDa'] ?? 5,
      status: json['trangThai'] ?? 'Đang mở',
      members: memberNames,
    );
  }
}
