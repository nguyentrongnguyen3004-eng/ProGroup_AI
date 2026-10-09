import '../../models/group_invitation_model.dart';

class MockGroupInvitations {
  static final List<GroupInvitationModel> invitations = [
    GroupInvitationModel(
      id: 1,
      groupId: 1,
      groupName: 'Nhóm ProGroup',
      inviter: 'Nguyễn Văn An',
      inviteeName: 'Đỗ Minh Khang',
      inviteeMssv: '22110005',
      status: 'Chờ xử lý',
      createdAt: DateTime(2026, 9, 20, 9, 30),
    ),
    GroupInvitationModel(
      id: 2,
      groupId: 1,
      groupName: 'Nhóm ProGroup',
      inviter: 'Nguyễn Văn An',
      inviteeName: 'Lê Quốc Bảo',
      inviteeMssv: '22110006',
      status: 'Đã chấp nhận',
      createdAt: DateTime(2026, 9, 18, 14, 20),
    ),
  ];

  static int generateId() {
    if (invitations.isEmpty) {
      return 1;
    }

    return invitations.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  static void add(GroupInvitationModel invitation) {
    invitations.add(invitation);
  }
}
