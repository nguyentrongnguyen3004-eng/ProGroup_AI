import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../models/lecturer_course_model.dart';
import '../models/lecturer_model.dart';
import '../models/lecturer_topic_proposal_model.dart';
import '../models/topic_model.dart';
import 'api_service.dart';

class LecturerApiService {
  LecturerApiService._();
  static final LecturerApiService instance = LecturerApiService._();

  // Cache in-memory to speed up screens if desired
  List<LecturerCourseModel> _cachedCourses = [];
  List<GroupModel> _cachedGroups = [];
  List<TopicModel> _cachedTopics = [];
  List<Map<String, dynamic>> _cachedNotifications = [];

  List<LecturerCourseModel> get cachedCourses => List.unmodifiable(_cachedCourses);
  List<GroupModel> get cachedGroups => List.unmodifiable(_cachedGroups);
  List<TopicModel> get cachedTopics => List.unmodifiable(_cachedTopics);
  List<Map<String, dynamic>> get cachedNotifications => List.unmodifiable(_cachedNotifications);

  /// 1. Lấy danh sách lớp học phần của giảng viên
  /// GET /api/lecturer/courses (hoặc fallback /api/lop-hoc-phan/me, /api/lop-hoc-phan)
  Future<List<LecturerCourseModel>> fetchCourses() async {
    dynamic res;
    try {
      res = await ApiService.instance.get('/api/lecturer/courses');
    } catch (_) {
      try {
        res = await ApiService.instance.get('/api/lop-hoc-phan/me');
      } catch (_) {
        res = await ApiService.instance.get('/api/lop-hoc-phan');
      }
    }

    if (res is List) {
      final List<LecturerCourseModel> list = [];
      for (final item in res) {
        if (item is Map<String, dynamic>) {
          list.add(LecturerCourseModel.fromJson(item));
        }
      }
      _cachedCourses = list;
      return list;
    }
    return _cachedCourses;
  }

  /// 2. Lấy danh sách nhóm đồ án
  /// GET /api/groups hoặc GET /api/lecturer/courses/{id}/groups
  Future<List<GroupModel>> fetchGroups([int? lopHocPhanId]) async {
    dynamic res;
    if (lopHocPhanId != null) {
      try {
        res = await ApiService.instance.get('/api/lecturer/courses/$lopHocPhanId/groups');
      } catch (_) {
        try {
          res = await ApiService.instance.get('/api/groups/course/$lopHocPhanId');
        } catch (_) {
          try {
            res = await ApiService.instance.get('/api/groups?lopHocPhanId=$lopHocPhanId');
          } catch (_) {}
        }
      }
    } else {
      try {
        res = await ApiService.instance.get('/api/groups');
      } catch (_) {
        // Nếu không có API lấy toàn bộ nhóm, duyệt qua các lớp đã cache
        final allGroups = <GroupModel>[];
        for (final c in _cachedCourses) {
          try {
            final grps = await fetchGroups(c.courseId);
            allGroups.addAll(grps);
          } catch (_) {}
        }
        if (allGroups.isNotEmpty) {
          _cachedGroups = allGroups;
          return allGroups;
        }
      }
    }

    if (res is List) {
      final List<GroupModel> list = [];
      for (final item in res) {
        if (item is Map<String, dynamic>) {
          list.add(GroupModel.fromJson(item));
        }
      }
      if (lopHocPhanId == null) {
        _cachedGroups = list;
      }
      return list;
    }
    return lopHocPhanId != null
        ? _cachedGroups.where((g) => g.courseId == lopHocPhanId).toList()
        : _cachedGroups;
  }

  /// 3. Lấy danh sách đề tài của giảng viên
  /// GET /api/de-tai/cua-toi hoặc GET /api/de-tai/lecturer-topics hoặc GET /api/de-tai
  Future<List<TopicModel>> fetchTopics([int? courseId]) async {
    dynamic res;
    try {
      res = await ApiService.instance.get('/api/de-tai/cua-toi');
    } catch (_) {
      try {
        final query = courseId != null ? '?dotDangKyId=$courseId' : '';
        res = await ApiService.instance.get('/api/de-tai/lecturer-topics$query');
      } catch (_) {
        try {
          final query = courseId != null ? '?lopHocPhanId=$courseId' : '';
          res = await ApiService.instance.get('/api/de-tai$query');
        } catch (_) {}
      }
    }

    if (res is List) {
      final List<TopicModel> list = [];
      for (final item in res) {
        if (item is Map<String, dynamic>) {
          list.add(TopicModel.fromJson(item));
        }
      }
      _cachedTopics = list;
      if (courseId != null) {
        return list.where((t) => t.courseId == courseId).toList();
      }
      return list;
    }

    if (courseId != null) {
      return _cachedTopics.where((t) => t.courseId == courseId).toList();
    }
    return _cachedTopics;
  }

  /// 4. Thống kê số liệu
  /// GET /api/lecturer/statistics
  Future<Map<String, dynamic>> fetchStatistics([int? courseId]) async {
    try {
      final query = courseId != null ? '?lopHocPhanId=$courseId' : '';
      final res = await ApiService.instance.get('/api/lecturer/statistics$query');
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (_) {}

    // Fallback tính toán từ các API thực tế
    final courses = _cachedCourses.isNotEmpty ? _cachedCourses : await fetchCourses();
    final groups = await fetchGroups(courseId);
    final topics = await fetchTopics(courseId);
    final regs = await fetchTopicRegistrations(courseId);

    final selectedCourses = courseId != null
        ? courses.where((c) => c.courseId == courseId).toList()
        : courses;

    final totalStudents = selectedCourses.fold<int>(0, (sum, c) => sum + c.studentCount);
    final approvedRegs = regs.where((r) {
      final st = (r['status'] ?? r['trangThai'] ?? '').toString().toLowerCase();
      return st.contains('đã duyệt') || st.contains('chấp nhận') || st.contains('approved');
    }).toList();

    final pendingRegs = regs.where((r) {
      final st = (r['status'] ?? r['trangThai'] ?? '').toString().toLowerCase();
      return st.contains('chờ duyệt') || st.contains('pending');
    }).toList();

    final rejectedRegs = regs.where((r) {
      final st = (r['status'] ?? r['trangThai'] ?? '').toString().toLowerCase();
      return st.contains('từ chối') || st.contains('rejected');
    }).toList();

    return {
      'totalCourses': selectedCourses.length,
      'totalGroups': groups.length,
      'totalTopics': topics.length,
      'totalStudents': totalStudents,
      'pendingRegistrations': pendingRegs.length,
      'approvedRegistrations': approvedRegs.length,
      'rejectedRegistrations': rejectedRegs.length,
      'groupsWithTopic': approvedRegs.length,
      'groupsWithoutTopic': (groups.length - approvedRegs.length).clamp(0, groups.length),
    };
  }

  /// 5. Lấy danh sách thông báo
  /// GET /api/notifications
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final res = await ApiService.instance.get('/api/notifications');
    if (res is List) {
      final List<Map<String, dynamic>> parsed = [];
      for (final item in res) {
        if (item is Map<String, dynamic>) {
          final type = item['type'] as String? ?? 'Hệ thống';
          final icon = switch (type) {
            'Đề tài' => Icons.lightbulb_outline_rounded,
            'Đăng ký' => Icons.assignment_outlined,
            'Nhóm' => Icons.groups_outlined,
            _ => Icons.notifications_none_rounded,
          };
          parsed.add({
            'id': item['id'] as int? ?? item['thongBaoId'] as int? ?? 0,
            'type': type,
            'icon': icon,
            'title': item['title'] as String? ?? item['tieuDe'] as String? ?? 'Thông báo',
            'content': item['content'] as String? ?? item['noiDung'] as String? ?? '',
            'time': item['time'] as String? ?? item['createdAt'] as String? ?? 'Gần đây',
            'isRead': item['isRead'] as bool? ?? item['daDoc'] as bool? ?? false,
          });
        }
      }
      _cachedNotifications = parsed;
      return parsed;
    }
    return _cachedNotifications;
  }

  /// Đánh dấu thông báo đã đọc
  Future<void> markNotificationRead(int id) async {
    try {
      await ApiService.instance.put('/api/notifications/$id/read', {});
    } catch (_) {}
    for (var n in _cachedNotifications) {
      if (n['id'] == id) n['isRead'] = true;
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllNotificationsRead() async {
    try {
      await ApiService.instance.put('/api/notifications/read-all', {});
    } catch (_) {}
    for (var n in _cachedNotifications) {
      n['isRead'] = true;
    }
  }

  /// 6. Lấy danh sách đăng ký đề tài
  /// GET /api/dang-ky-de-tai hoặc GET /api/de-tai/registrations
  Future<List<Map<String, dynamic>>> fetchTopicRegistrations([int? courseId]) async {
    dynamic res;
    try {
      res = await ApiService.instance.get('/api/dang-ky-de-tai');
    } catch (_) {
      try {
        res = await ApiService.instance.get('/api/de-tai/registrations');
      } catch (_) {}
    }

    if (res is List) {
      final List<Map<String, dynamic>> list = [];
      for (final item in res) {
        if (item is Map<String, dynamic>) {
          list.add({
            'id': item['id'] as int? ?? item['dangKyDeTaiId'] as int? ?? 0,
            'dangKyDeTaiId': item['dangKyDeTaiId'] as int? ?? item['id'] as int? ?? 0,
            'groupId': item['groupId'] as int? ?? item['nhomId'] as int? ?? 0,
            'nhomId': item['nhomId'] as int? ?? item['groupId'] as int? ?? 0,
            'groupName': item['groupName'] as String? ?? item['nhomTen'] as String? ?? 'Nhóm',
            'leaderName': item['leaderName'] as String? ?? item['truongNhomTen'] as String? ?? 'Trưởng nhóm',
            'courseName': item['courseName'] as String? ?? item['lopHocPhanTen'] as String? ?? '',
            'topicId': item['topicId'] as int? ?? item['deTaiId'] as int? ?? 0,
            'deTaiId': item['deTaiId'] as int? ?? item['topicId'] as int? ?? 0,
            'topicTitle': item['topicTitle'] as String? ?? item['deTaiTen'] as String? ?? 'Đề tài',
            'status': item['status'] as String? ?? item['trangThai'] as String? ?? 'Chờ duyệt',
            'registeredAt': item['registeredAt'] ?? item['ngayDangKy'] ?? DateTime.now().toIso8601String(),
            'note': item['note'] as String? ?? item['ghiChu'] as String?,
          });
        }
      }
      return list;
    }
    return [];
  }

  /// 7. Duyệt / Từ chối đăng ký đề tài
  /// PUT /api/dang-ky-de-tai/{id}/duyet hoặc PUT /api/de-tai/registrations/{id}/decide
  Future<void> approveTopicRegistration(int id, bool chapNhan, {String? ghiChu}) async {
    try {
      await ApiService.instance.put('/api/dang-ky-de-tai/$id/duyet', {
        'chapNhan': chapNhan,
        'ghiChu': ghiChu,
      });
    } catch (_) {
      await ApiService.instance.put('/api/de-tai/registrations/$id/decide', {
        'dongY': chapNhan,
        'ghiChu': ghiChu,
      });
    }
  }

  /// 8. Tạo đề tài mới
  /// POST /api/de-tai
  Future<void> createTopic({
    required String tenDeTai,
    String? moTa,
    String? mucTieu,
    String? phamVi,
    String? congNghe,
    required int dotDangKyId,
  }) async {
    await ApiService.instance.post('/api/de-tai', {
      'tenDeTai': tenDeTai,
      'moTa': moTa ?? '',
      'mucTieu': mucTieu ?? '',
      'phamVi': phamVi ?? '',
      'congNgheDuKien': congNghe ?? '',
      'dotDangKyId': dotDangKyId,
    });
    await fetchTopics();
  }

  /// 9. Cập nhật đề tài
  /// PUT /api/de-tai/{id}
  Future<void> updateTopic(
    int id, {
    required String tenDeTai,
    String? moTa,
    String? mucTieu,
    String? phamVi,
    String? congNghe,
  }) async {
    await ApiService.instance.put('/api/de-tai/$id', {
      'tenDeTai': tenDeTai,
      'moTa': moTa ?? '',
      'mucTieu': mucTieu ?? '',
      'phamVi': phamVi ?? '',
      'congNgheDuKien': congNghe ?? '',
    });
    await fetchTopics();
  }

  /// 10. Xóa đề tài
  /// DELETE /api/de-tai/{id}
  Future<void> deleteTopic(int id) async {
    await ApiService.instance.delete('/api/de-tai/$id');
    await fetchTopics();
  }

  /// 11. Lấy danh sách đề xuất đề tài từ sinh viên
  /// GET /api/de-tai?nguonDeTai=Sinh viên đề xuất&trangThaiDuyet=Chờ duyệt
  Future<List<LecturerTopicProposalModel>> fetchTopicProposals([int? courseId]) async {
    dynamic res;
    try {
      res = await ApiService.instance.get(
        '/api/de-tai?nguonDeTai=Sinh%20vi%C3%AAn%20%C4%91%E1%BB%81%20xu%E1%BA%A5t',
      );
    } catch (_) {
      try {
        res = await ApiService.instance.get('/api/de-tai/proposals');
      } catch (_) {
        res = await ApiService.instance.get('/api/de-tai');
      }
    }

    if (res is List) {
      final List<LecturerTopicProposalModel> list = [];
      for (final item in res) {
        if (item is Map<String, dynamic>) {
          final source = item['source'] as String? ?? item['nguonDeTai'] as String? ?? '';
          if (source.toLowerCase().contains('sinh viên') || item['sinhVienDeXuatId'] != null) {
            list.add(LecturerTopicProposalModel.fromJson(item));
          }
        }
      }
      return list;
    }
    return [];
  }

  /// 12. Duyệt đề xuất từ sinh viên
  /// PUT /api/de-tai/{id}/duyet
  Future<void> approveTopicProposal(int id, bool chapNhan, {String? lyDo}) async {
    try {
      await ApiService.instance.put('/api/de-tai/$id/duyet', {
        'chapNhan': chapNhan,
        'lyDo': lyDo,
      });
    } catch (_) {
      await ApiService.instance.put('/api/de-tai/$id', {
        'trangThaiDuyet': chapNhan ? 'Đã duyệt' : 'Từ chối',
        'lyDo': lyDo,
      });
    }
  }

  /// 13. Tải hồ sơ giảng viên
  /// GET /api/auth/me
  Future<LecturerModel?> fetchProfile() async {
    try {
      final res = await ApiService.instance.get('/api/auth/me');
      if (res is Map<String, dynamic>) {
        return LecturerModel(
          id: res['giangVienId'] as int? ?? res['nguoiDungId'] as int? ?? 1,
          lecturerCode: res['maGiangVien'] as String? ?? res['tenDangNhap'] as String? ?? 'GV001',
          fullName: res['hoTen'] as String? ?? 'Giảng viên',
          email: res['email'] as String? ?? '',
          faculty: 'Khoa Công nghệ thông tin',
          department: 'Bộ môn Công nghệ phần mềm',
          avatar: '',
        );
      }
    } catch (_) {}
    return null;
  }

  /// 14. Đổi mật khẩu
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      await ApiService.instance.post('/api/auth/change-password', {
        'oldPassword': currentPassword,
        'newPassword': newPassword,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 15. Đổi email
  Future<bool> changeEmail(String newEmail) async {
    try {
      await ApiService.instance.put('/api/auth/change-email', {'email': newEmail});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Đồng bộ toàn bộ dữ liệu từ Backend API
  Future<void> syncAllData() async {
    try {
      await Future.wait([
        fetchProfile(),
        fetchCourses(),
        fetchTopics(),
        fetchNotifications(),
      ]);
    } catch (_) {}
  }
}
