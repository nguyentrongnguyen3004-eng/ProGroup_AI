import '../../models/group_model.dart';

class MockLecturerGroups {
  static final List<GroupModel> groups = [
    GroupModel(
      id: 101,
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
      id: 102,
      courseId: 1,
      name: 'Mobile Team',
      leader: 'Nguyễn Thị Mai',
      memberCount: 5,
      maxMembers: 5,
      status: 'Đã đủ thành viên',
      members: [
        'Nguyễn Thị Mai',
        'Lê Văn Phúc',
        'Trần Minh Đức',
        'Phạm Văn Long',
        'Hoàng Anh Tuấn',
      ],
    ),
    GroupModel(
      id: 103,
      courseId: 1,
      name: 'Nhóm Chưa Chọn Đề Tài',
      leader: 'Phạm Minh Đức',
      memberCount: 3,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: ['Phạm Minh Đức', 'Đỗ Minh Khang', 'Lê Quốc Bảo'],
    ),
    GroupModel(
      id: 104,
      courseId: 1,
      name: 'Smart Attendance',
      leader: 'Hoàng Anh Tuấn',
      memberCount: 4,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: [
        'Hoàng Anh Tuấn',
        'Nguyễn Hoàng Long',
        'Trần Quốc Huy',
        'Võ Thành Đạt',
      ],
    ),
    GroupModel(
      id: 105,
      courseId: 3,
      name: 'Nhóm IoT Team',
      leader: 'Trần Văn Minh',
      memberCount: 3,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: ['Trần Văn Minh', 'Nguyễn Thị Mai', 'Lê Văn Phúc'],
    ),
  ];

  static List<GroupModel> getByCourse(int courseId) {
    return groups.where((group) => group.courseId == courseId).toList();
  }

  static GroupModel? getById(int id) {
    try {
      return groups.firstWhere((group) => group.id == id);
    } catch (_) {
      return null;
    }
  }
}
