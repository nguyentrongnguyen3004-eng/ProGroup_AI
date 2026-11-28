import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../models/lecturer_course_model.dart';
import '../models/lecturer_model.dart';
import '../models/lecturer_topic_proposal_model.dart';
import '../models/topic_model.dart';
import 'api_service.dart';
import 'data_cache_service.dart';

class LecturerApiService {
  LecturerApiService._();
  static final LecturerApiService instance = LecturerApiService._();

  // Cache in-memory to speed up screens if desired
  List<LecturerCourseModel> _cachedCourses = [];
  List<GroupModel> _cachedGroups = [];
  List<TopicModel> _cachedTopics = [];
  List<Map<String, dynamic>> _cachedNotifications = [];

  void clearCache() {
    _cachedCourses = [];
    _cachedGroups = [];
    _cachedTopics = [];
    _cachedNotifications = [];
  }

  List<LecturerCourseModel> get cachedCourses => List.unmodifiable(_cachedCourses);
  List<GroupModel> get cachedGroups => List.unmodifiable(_cachedGroups);
  List<TopicModel> get cachedTopics => List.unmodifiable(_cachedTopics);
  List<Map<String, dynamic>> get cachedNotifications => List.unmodifiable(_cachedNotifications);

  /// 1. Lấy danh sách lớp học phần của giảng viên
  /// GET /api/lecturer/courses (hoặc fallback /api/lop-hoc-phan/me, /api/lop-hoc-phan)
  Future<List<LecturerCourseModel>> fetchCourses({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<LecturerCourseModel>>(
      'lecturer_courses',
      () async {
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
      },
      forceRefresh: forceRefresh,
    );
  }

  /// Cập nhật cấu hình lớp học phần (số lượng SV/nhóm, thời gian đăng ký...)
  /// PUT /api/lop-hoc-phan/{id}/cau-hinh
  Future<void> updateCourseSettings(int courseId, Map<String, dynamic> settings) async {
    await ApiService.instance.put('/api/lop-hoc-phan/$courseId/cau-hinh', settings);
    try {
      await fetchCourses();
    } catch (_) {}
  }

  /// 2. Lấy danh sách nhóm đồ án
  /// GET /api/groups?lopHocPhanId={id} hoặc GET /api/groups
  Future<List<GroupModel>> fetchGroups([int? lopHocPhanId, bool forceRefresh = false]) async {
    return DataCacheService.instance.getOrFetch<List<GroupModel>>(
      'lecturer_groups_${lopHocPhanId ?? 'all'}',
      () async {
        dynamic res;
        if (lopHocPhanId != null) {
          try {
            res = await ApiService.instance.get('/api/groups?lopHocPhanId=$lopHocPhanId');
          } catch (_) {
            try {
              res = await ApiService.instance.get('/api/groups/course/$lopHocPhanId');
            } catch (_) {}
          }
        } else {
          try {
            res = await ApiService.instance.get('/api/groups');
          } catch (_) {
            final allGroups = <GroupModel>[];
            for (final c in _cachedCourses) {
              try {
                final grps = await fetchGroups(c.id);
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
      },
      forceRefresh: forceRefresh,
    );
  }

  /// 3. Lấy danh sách đề tài của giảng viên
  /// GET /api/de-tai/lecturer-topics hoặc GET /api/de-tai/cua-toi
  Future<List<TopicModel>> fetchTopics([int? courseId, bool forceRefresh = false]) async {
    return DataCacheService.instance.getOrFetch<List<TopicModel>>(
      'lecturer_topics_${courseId ?? 'all'}',
      () async {
        dynamic res;
        if (courseId != null) {
          try {
            res = await ApiService.instance.get('/api/de-tai/lecturer-topics?lopHocPhanId=$courseId');
          } catch (_) {
            try {
              res = await ApiService.instance.get('/api/de-tai?lopHocPhanId=$courseId');
            } catch (_) {
              try {
                res = await ApiService.instance.get('/api/de-tai/cua-toi');
              } catch (_) {}
            }
          }
        } else {
          try {
            res = await ApiService.instance.get('/api/de-tai/cua-toi');
          } catch (_) {
            try {
              res = await ApiService.instance.get('/api/de-tai/lecturer-topics');
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
            return list
                .where((t) =>
                    t.courseId == courseId ||
                    t.lopHocPhanId == courseId ||
                    t.dotDangKyId == courseId)
                .toList();
          }
          return list;
        }

        if (courseId != null) {
          return _cachedTopics
              .where((t) =>
                  t.courseId == courseId ||
                  t.lopHocPhanId == courseId ||
                  t.dotDangKyId == courseId)
              .toList();
        }
        return _cachedTopics;
      },
      forceRefresh: forceRefresh,
    );
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
  Future<List<Map<String, dynamic>>> fetchNotifications({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'lecturer_notifications',
      () async {
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
      },
      ttl: const Duration(seconds: 15),
      forceRefresh: forceRefresh,
    );
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
  Future<List<Map<String, dynamic>>> fetchTopicRegistrations([int? courseId, bool forceRefresh = false]) async {
    return DataCacheService.instance.getOrFetch<List<Map<String, dynamic>>>(
      'lecturer_topic_regs_${courseId ?? 'all'}',
      () async {
        dynamic res;
        try {
          final query = courseId != null ? '?lopHocPhanId=$courseId' : '';
          res = await ApiService.instance.get('/api/dang-ky-de-tai$query');
        } catch (_) {
          try {
            res = await ApiService.instance.get('/api/dang-ky-de-tai');
          } catch (_) {
            try {
              res = await ApiService.instance.get('/api/de-tai/registrations');
            } catch (_) {}
          }
        }

        if (res is List) {
          final List<Map<String, dynamic>> list = [];
          for (final item in res) {
            if (item is Map<String, dynamic>) {
              final regLopId = item['lopHocPhanId'] as int? ?? item['courseId'] as int?;
              final regDotId = item['dotDangKyId'] as int?;
              if (courseId != null && regLopId != null && regLopId != courseId && regDotId != courseId) {
                continue;
              }
              list.add({
                'id': item['id'] as int? ?? item['dangKyDeTaiId'] as int? ?? 0,
                'dangKyDeTaiId': item['dangKyDeTaiId'] as int? ?? item['id'] as int? ?? 0,
                'groupId': item['groupId'] as int? ?? item['nhomId'] as int? ?? 0,
                'nhomId': item['nhomId'] as int? ?? item['groupId'] as int? ?? 0,
                'courseId': regLopId ?? 0,
                'lopHocPhanId': regLopId ?? 0,
                'dotDangKyId': regDotId ?? 0,
                'groupName': item['groupName'] as String? ?? item['tenNhom'] as String? ?? item['nhomTen'] as String? ?? 'Nhóm',
                'leaderName': item['leaderName'] as String? ?? item['tenTruongNhom'] as String? ?? item['truongNhomTen'] as String? ?? 'Trưởng nhóm',
                'courseName': item['courseName'] as String? ?? item['tenLopHocPhan'] as String? ?? item['lopHocPhanTen'] as String? ?? '',
                'topicId': item['topicId'] as int? ?? item['deTaiId'] as int? ?? 0,
                'deTaiId': item['deTaiId'] as int? ?? item['topicId'] as int? ?? 0,
                'topicTitle': item['topicTitle'] as String? ?? item['tenDeTai'] as String? ?? item['deTaiTen'] as String? ?? 'Đề tài',
                'status': item['status'] as String? ?? item['trangThai'] as String? ?? 'Chờ duyệt',
                'registeredAt': item['registeredAt'] ?? item['ngayDangKy'] ?? DateTime.now().toIso8601String(),
                'note': item['note'] as String? ?? item['ghiChu'] as String?,
              });
            }
          }
          return list;
        }
        return [];
      },
      ttl: const Duration(seconds: 15),
      forceRefresh: forceRefresh,
    );
  }

  /// 6.1 Lấy đăng ký đề tài của nhóm cụ thể
  /// GET /api/dang-ky-de-tai/cua-nhom/{groupId}
  Future<Map<String, dynamic>?> fetchGroupTopicRegistration(int groupId, {bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<Map<String, dynamic>?>(
      'lecturer_group_topic_reg_$groupId',
      () async {
        try {
          final res = await ApiService.instance.get('/api/dang-ky-de-tai/cua-nhom/$groupId');
          if (res is Map<String, dynamic>) return res;
          return null;
        } catch (_) {
          return null;
        }
      },
      ttl: const Duration(seconds: 15),
      forceRefresh: forceRefresh,
    );
  }

  /// 6.2 Lấy thông tin chi tiết đề tài theo ID
  /// GET /api/de-tai/{topicId}
  Future<TopicModel?> fetchTopicById(int topicId, {bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<TopicModel?>(
      'lecturer_topic_detail_$topicId',
      () async {
        try {
          final res = await ApiService.instance.get('/api/de-tai/$topicId');
          if (res is Map<String, dynamic>) {
            return TopicModel.fromJson(res);
          }
          return null;
        } catch (_) {
          return null;
        }
      },
      ttl: const Duration(seconds: 30),
      forceRefresh: forceRefresh,
    );
  }

  /// 7. Duyệt / Từ chối đăng ký đề tài
  /// PUT /api/dang-ky-de-tai/{id}/duyet hoặc PUT /api/de-tai/registrations/{id}/decide
  Future<void> approveTopicRegistration(int id, bool chapNhan, {String? ghiChu}) async {
    try {
      await ApiService.instance.put('/api/dang-ky-de-tai/$id/duyet', {
        'chapNhan': chapNhan,
        'ghiChu': ghiChu,
        'lyDo': ghiChu,
        'lyDoTuChoi': ghiChu,
        'reason': ghiChu,
      });
    } catch (_) {
      await ApiService.instance.put('/api/de-tai/registrations/$id/decide', {
        'dongY': chapNhan,
        'ghiChu': ghiChu,
      });
    } finally {
      DataCacheService.instance.invalidatePrefix('lecturer_');
      DataCacheService.instance.invalidatePrefix('student_');
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
    int? lopHocPhanId,
    String? status,
    String? nguonDeTai,
  }) async {
    final body = <String, dynamic>{
      'tenDeTai': tenDeTai,
      'moTa': moTa ?? '',
      'mucTieu': mucTieu ?? '',
      'phamVi': phamVi ?? '',
      'congNgheDuKien': congNghe ?? '',
      'dotDangKyId': dotDangKyId,
    };
    if (lopHocPhanId != null) body['lopHocPhanId'] = lopHocPhanId;
    if (status != null && status.isNotEmpty) body['trangThai'] = status;
    if (nguonDeTai != null && nguonDeTai.isNotEmpty) {
      body['nguonDeTai'] = nguonDeTai;
      body['source'] = nguonDeTai;
    }
    await ApiService.instance.post('/api/de-tai', body);
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
    String? status,
  }) async {
    await ApiService.instance.put('/api/de-tai/$id', {
      'tenDeTai': tenDeTai,
      'moTa': moTa ?? '',
      'mucTieu': mucTieu ?? '',
      'phamVi': phamVi ?? '',
      'congNgheDuKien': congNghe ?? '',
      if (status != null && status.isNotEmpty) 'trangThai': status,
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
  /// GET /api/de-tai/proposals (tối ưu sẵn lọc ở Backend)
  Future<List<LecturerTopicProposalModel>> fetchTopicProposals([int? courseId]) async {
    dynamic res;
    try {
      final query = courseId != null ? '?courseId=$courseId' : '';
      res = await ApiService.instance.get('/api/de-tai/proposals$query');
    } catch (_) {
      try {
        res = await ApiService.instance.get(
          '/api/de-tai?nguonDeTai=Sinh%20vi%C3%AAn%20%C4%91%E1%BB%81%20xu%E1%BA%A5t',
        );
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
    // Backend trả lỗi nghiệp vụ (403/409/400...) -> hiển thị đúng cho giảng viên, không fallback.
    await ApiService.instance.put('/api/de-tai/$id/duyet', {
      'chapNhan': chapNhan,
      'lyDo': lyDo,
      'lyDoTuChoi': lyDo,
      'ghiChu': lyDo,
      'reason': lyDo,
      'feedback': lyDo,
    });
    DataCacheService.instance.invalidatePrefix('lecturer_topics');
  }

  /// 13. Tải hồ sơ giảng viên
  /// GET /api/profile hoặc /api/auth/me
  Future<LecturerModel?> fetchProfile({bool forceRefresh = false}) async {
    return DataCacheService.instance.getOrFetch<LecturerModel?>(
      'lecturer_profile',
      () async {
        try {
          dynamic res;
          try {
            res = await ApiService.instance.get('/api/profile');
          } catch (_) {
            res = await ApiService.instance.get('/api/auth/me');
          }
          if (res is Map<String, dynamic>) {
            final avatar = (res['avatarUrl'] ?? res['avatar'] ?? '').toString();
            final gvInfo = res['giangVien'] as Map<String, dynamic>?;
            final hocVi = (gvInfo?['hocVi'] ?? res['hocVi'] ?? 'ThS.').toString();
            final chuyenMon = (gvInfo?['chuyenMon'] ?? res['chuyenMon'] ?? 'Công nghệ phần mềm & Di động').toString();
            final faculty = (gvInfo?['tenKhoa'] ?? res['tenKhoa'] ?? 'Khoa Công nghệ thông tin').toString();
            return LecturerModel(
              id: gvInfo?['giangVienId'] as int? ?? res['nguoiDungId'] as int? ?? 1,
              lecturerCode: gvInfo?['maGiangVien'] as String? ?? res['tenDangNhap'] as String? ?? 'GV001',
              fullName: res['hoTen'] as String? ?? 'Giảng viên',
              email: res['email'] as String? ?? '',
              phoneNumber: (res['soDienThoai'] ?? res['phoneNumber'] ?? '').toString(),
              faculty: faculty,
              department: 'Bộ môn Công nghệ phần mềm',
              avatar: avatar,
              hocVi: hocVi,
              chuyenMon: chuyenMon,
            );
          }
        } catch (_) {}
        return null;
      },
      forceRefresh: forceRefresh,
    );
  }

    /// Cập nhật thông tin giảng viên (Họ tên, SĐT, Học vị, Chuyên môn)
  Future<bool> updateProfile({String? fullName, String? phoneNumber, String? hocVi, String? chuyenMon}) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['hoTen'] = fullName;
      if (phoneNumber != null) body['soDienThoai'] = phoneNumber;
      if (hocVi != null) body['hocVi'] = hocVi;
      if (chuyenMon != null) body['chuyenMon'] = chuyenMon;
      await ApiService.instance.put('/api/profile', body);
      return true;
    } catch (_) {
      return false;
    }
  }

/// 14. Đổi mật khẩu
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    await ApiService.instance.put('/api/auth/change-password', {
      'currentPassword': currentPassword,
      'oldPassword': currentPassword,
      'newPassword': newPassword,
    });
    return true;
  }

  /// 15. Đổi email
  Future<bool> changeEmail(String newEmail, [String? otp]) async {
    await ApiService.instance.put('/api/auth/change-email', {
      'email': newEmail,
      if (otp != null && otp.isNotEmpty) 'otp': otp,
    });
    return true;
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

  /// 16. Cập nhật trạng thái đợt đăng ký (Đang mở / Đã đóng / Chưa mở)
  Future<void> updatePeriodStatus(int periodId, String newStatus) async {
    await ApiService.instance.put('/api/dot-dang-ky/$periodId/trang-thai', {
      'trangThai': newStatus,
    });
  }

  /// Lấy danh sách đợt đăng ký của lớp học phần

  /// Tạo đợt đăng ký mới cho lớp học phần (TC_LEC_027)
  Future<Map<String, dynamic>> createRegistrationPeriod({
    required String tenDot,
    required int lopHocPhanId,
    required DateTime ngayBatDau,
    required DateTime ngayKetThuc,
    DateTime? ngayKetThucLapNhom,
    DateTime? ngayBatDauDangKyDeTai,
    int minMembers = 1,
    int maxMembers = 5,
  }) async {
    final res = await ApiService.instance.post('/api/dot-dang-ky', {
      'tenDot': tenDot,
      'lopHocPhanId': lopHocPhanId,
      'ngayBatDau': ngayBatDau.toIso8601String(),
      'ngayKetThuc': ngayKetThuc.toIso8601String(),
      if (ngayKetThucLapNhom != null)
        'ngayKetThucLapNhom': ngayKetThucLapNhom.toIso8601String(),
      if (ngayBatDauDangKyDeTai != null)
        'ngayBatDauDangKyDeTai': ngayBatDauDangKyDeTai.toIso8601String(),
      'minMembers': minMembers,
      'maxMembers': maxMembers,
    });
    return (res is Map) ? res.cast<String, dynamic>() : {};
  }

  Future<List<Map<String, dynamic>>> fetchCourseRegistrationPeriods(int lopHocPhanId) async {
    try {
      final res = await ApiService.instance.get('/api/dot-dang-ky?lopHocPhanId=$lopHocPhanId');
      if (res is List) return res.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  /// 17. Giảng viên lấy danh sách báo cáo tiến độ các nhóm
  Future<List<Map<String, dynamic>>> fetchLecturerReports() async {
    try {
      final res = await ApiService.instance.get('/api/bao-cao/giang-vien');
      if (res is List) return res.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  /// 18. Giảng viên chấm điểm và nhận xét báo cáo
  Future<void> gradeReport(int reportId, {double? diem, String? nhanXet, String trangThai = 'Đạt'}) async {
    await ApiService.instance.put('/api/bao-cao/$reportId/cham-diem', {
      'diem': diem,
      'nhanXetGiangVien': nhanXet,
      'trangThai': trangThai,
    });
  }
}
