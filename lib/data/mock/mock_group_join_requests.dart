import '../../models/group_join_request_model.dart';

class MockGroupJoinRequests {
  static final List<GroupJoinRequestModel> requests = [
    GroupJoinRequestModel(
      id: 1,
      groupId: 1,
      groupName: 'Nhóm ProGroup',
      studentName: 'Phạm Minh Đức',
      studentMssv: '22110007',
      studentEmail: 'duc.pham@example.com',
      status: 'Chờ duyệt',
      createdAt: DateTime(2026, 9, 21, 10, 15),
    ),
    GroupJoinRequestModel(
      id: 2,
      groupId: 1,
      groupName: 'Nhóm ProGroup',
      studentName: 'Nguyễn Hoàng Long',
      studentMssv: '22110008',
      studentEmail: 'long.nguyen@example.com',
      status: 'Chờ duyệt',
      createdAt: DateTime(2026, 9, 21, 13, 40),
    ),
    GroupJoinRequestModel(
      id: 3,
      groupId: 1,
      groupName: 'Nhóm ProGroup',
      studentName: 'Trần Quốc Huy',
      studentMssv: '22110009',
      studentEmail: 'huy.tran@example.com',
      status: 'Đã từ chối',
      createdAt: DateTime(2026, 9, 17, 15, 10),
    ),
  ];

  static int generateId() {
    if (requests.isEmpty) {
      return 1;
    }

    return requests.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  static void add(GroupJoinRequestModel request) {
    requests.add(request);
  }
}
