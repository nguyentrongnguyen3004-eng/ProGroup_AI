import '../../models/group_model.dart';

class MockGroups {
  static List<GroupModel> groups = [
    GroupModel(
      id: 1,
      courseId: 1,
      name: 'Nhóm ProGroup',
      leader: 'Nguyễn Văn An',
      memberCount: 4,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: [
        'Nguyễn Văn An',
        'Trần Văn Minh',
        'Lê Hoàng Nam',
        'Phạm Quốc Huy',
      ],
    ),

    GroupModel(
      id: 2,
      courseId: 3,
      name: 'Nhóm IoT Team',
      leader: 'Trần Văn Minh',
      memberCount: 3,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: ['Trần Văn Minh', 'Nguyễn Thị Mai', 'Lê Văn Phúc'],
    ),
  ];

  static void addGroup(GroupModel group) {
    groups.add(group);
  }
}
