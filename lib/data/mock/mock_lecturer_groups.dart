import 'package:flutter/foundation.dart';
import '../../models/group_model.dart';

class MockLecturerGroups extends ChangeNotifier {
  MockLecturerGroups._();
  static final MockLecturerGroups instance = MockLecturerGroups._();

  static List<GroupModel> _groups = [
    const GroupModel(
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
    const GroupModel(
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
    const GroupModel(
      id: 103,
      courseId: 1,
      name: 'Nhóm Chưa Chọn Đề Tài',
      leader: 'Phạm Minh Đức',
      memberCount: 3,
      maxMembers: 5,
      status: 'Đang hoạt động',
      members: ['Phạm Minh Đức', 'Đỗ Minh Khang', 'Lê Quốc Bảo'],
    ),
    const GroupModel(
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
    const GroupModel(
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

  static List<GroupModel> get groups => _groups;

  static void setGroups(List<GroupModel> newGroups) {
    _groups = List.from(newGroups);
    instance.notifyListeners();
  }

  static List<GroupModel> getByCourse(int courseId) {
    return _groups.where((group) => group.courseId == courseId).toList();
  }

  static GroupModel? getById(int id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (_) {
      return null;
    }
  }
}
