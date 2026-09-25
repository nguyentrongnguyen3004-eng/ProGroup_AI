import 'package:flutter/material.dart';

class MockGovernanceNotifications extends ChangeNotifier {
  MockGovernanceNotifications._();
  static final instance = MockGovernanceNotifications._();
  final List<Map<String, dynamic>> _items = [
    {
      'id': 1,
      'type': 'Import dữ liệu',
      'icon': Icons.file_download_done_outlined,
      'title': 'Đã cập nhật dữ liệu sinh viên',
      'content':
          'Danh sách sinh viên đã được rà soát và đồng bộ trong dữ liệu Giáo vụ khoa.',
      'time': '10 phút trước',
      'isRead': false,
    },
    {
      'id': 2,
      'type': 'Phân công',
      'icon': Icons.assignment_ind_outlined,
      'title': 'Có thay đổi phân công giảng viên',
      'content': 'Phân công giảng viên cho một lớp học phần vừa được cập nhật.',
      'time': '1 giờ trước',
      'isRead': false,
    },
    {
      'id': 3,
      'type': 'Kiểm tra dữ liệu',
      'icon': Icons.fact_check_outlined,
      'title': 'Có dữ liệu cần kiểm tra',
      'content':
          'Một số dòng import chưa hợp lệ. Hãy mở màn hình import để xem lỗi theo dòng.',
      'time': 'Hôm qua',
      'isRead': true,
    },
    {
      'id': 4,
      'type': 'Lớp học phần',
      'icon': Icons.school_outlined,
      'title': 'Danh sách lớp học phần đã sẵn sàng',
      'content':
          'Dữ liệu lớp học phần hiện có thể được tìm kiếm và xem chi tiết.',
      'time': '2 ngày trước',
      'isRead': true,
    },
  ];
  List<Map<String, dynamic>> get notifications => List.unmodifiable(
    _items.map((item) => Map<String, dynamic>.unmodifiable(item)),
  );
  int get unreadCount => _items.where((item) => item['isRead'] == false).length;
  void markAsRead(int id) {
    final i = _items.indexWhere((item) => item['id'] == id);
    if (i < 0 || _items[i]['isRead'] == true) return;
    _items[i]['isRead'] = true;
    notifyListeners();
  }

  void markAllAsRead() {
    var changed = false;
    for (final item in _items) {
      if (item['isRead'] == false) {
        item['isRead'] = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void addNotification({
    required String type,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final id = _items.isEmpty
        ? 1
        : _items.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    _items.insert(0, {
      'id': id,
      'type': type,
      'icon': icon,
      'title': title,
      'content': content,
      'time': 'Vừa xong',
      'isRead': false,
    });
    notifyListeners();
  }
}
