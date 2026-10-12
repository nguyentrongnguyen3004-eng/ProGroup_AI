import '../core/network/api_client.dart';
import '../models/group_model.dart';

class GroupService {
  static final List<GroupModel> groups = [
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

  Future<List<GroupModel>> getGroupsByCourse(int courseId) async {
    try {
      final response = await ApiClient.get('/groups/course/$courseId');
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      return data.map((json) => GroupModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách nhóm của lớp: $e');
    }
  }

  Future<List<GroupModel>> getMyGroups() async {
    try {
      final response = await ApiClient.get('/groups/mine');
      return _parseGroupList(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<GroupModel> getGroupById(int id) async {
    try {
      final response = await ApiClient.get('/Groups/$id');
      final data = _extractData(response);
      return _parseSingleGroup(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createGroup(int dotDangKyId, String tenNhom) async {
    try {
      await ApiClient.post('/groups', {
        'DotDangKyId': dotDangKyId,
        'TenNhom': tenNhom,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addMember(int groupId, int sinhVienId) async {
    try {
      await ApiClient.post('/Groups/$groupId/members', {
        'SinhVienId': sinhVienId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMember(int groupId, int sinhVienId) async {
    try {
      await ApiClient.delete('/Groups/$groupId/members/$sinhVienId');
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to parse lists properly
  List<GroupModel> _parseGroupList(dynamic response) {
    List<dynamic> list = [];
    if (response is List) {
      list = response;
    } else if (response is Map && response.containsKey('data')) {
      list = response['data'] ?? [];
    } else if (response is Map && response.containsKey('items')) {
      list = response['items'] ?? [];
    }

    return list.map((json) => _parseSingleGroup(json)).toList();
  }

  dynamic _extractData(dynamic response) {
    if (response is Map && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  GroupModel _parseSingleGroup(dynamic json) {
    List<dynamic> thanhViens = json['thanhViens'] ?? [];
    List<String> memberNames = thanhViens
        .map((m) => (m['hoTen'] as String?) ?? 'Unknown')
        .toList();

    return GroupModel(
      id: json['nhomId'] ?? 0,
      courseId: json['lopHocPhanId'] ?? json['dotDangKyId'] ?? 0,
      name: json['tenNhom'] ?? '',
      leader: json['truongNhom'] ?? '',
      memberCount: memberNames.length,
      maxMembers: json['maxMembers'] ?? 5,
      status: json['trangThai'] ?? 'Unknown',
      members: memberNames,
    );
  }
}

