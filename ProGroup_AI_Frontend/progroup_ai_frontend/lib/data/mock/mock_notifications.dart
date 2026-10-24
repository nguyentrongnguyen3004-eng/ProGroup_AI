import 'package:flutter/material.dart';

class MockNotifications extends ChangeNotifier {
  MockNotifications._();

  static final MockNotifications instance = MockNotifications._();

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'type': 'Nhóm',
      'icon': Icons.groups,
      'title': 'Bạn được mời vào nhóm',
      'content': 'Nhóm ProGroup đã gửi lời mời tham gia nhóm.',
      'time': '10 phút trước',
      'unread': true,
    },
    {
      'id': 2,
      'type': 'Đề tài',
      'icon': Icons.lightbulb_outline,
      'title': 'Đăng ký đề tài đã được mở',
      'content': 'Giảng viên đã mở thời gian đăng ký đề tài cho lớp LTDD-01.',
      'time': '1 giờ trước',
      'unread': true,
    },
    {
      'id': 3,
      'type': 'Đề tài',
      'icon': Icons.check_circle_outline,
      'title': 'Đề tài đã được duyệt',
      'content': 'Đề tài "Hệ thống gợi ý đề tài bằng AI" đã được duyệt.',
      'time': 'Hôm qua',
      'unread': false,
    },
    {
      'id': 4,
      'type': 'Hệ thống',
      'icon': Icons.security_outlined,
      'title': 'Đăng nhập thành công',
      'content': 'Tài khoản của bạn vừa đăng nhập trên thiết bị hiện tại.',
      'time': 'Hôm qua',
      'unread': false,
    },
  ];

  List<Map<String, dynamic>> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount {
    return _notifications.where((item) => item['unread'] == true).length;
  }

  void markAsRead(int id) {
    final index = _notifications.indexWhere((item) => item['id'] == id);

    if (index == -1) {
      return;
    }

    if (_notifications[index]['unread'] != true) {
      return;
    }

    _notifications[index]['unread'] = false;
    notifyListeners();
  }

  void markAllAsRead() {
    bool changed = false;

    for (final item in _notifications) {
      if (item['unread'] == true) {
        item['unread'] = false;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void addNotification({
    required String type,
    required IconData icon,
    required String title,
    required String content,
    required String time,
  }) {
    final nextId = _notifications.isEmpty
        ? 1
        : (_notifications
                  .map((item) => item['id'] as int)
                  .reduce((a, b) => a > b ? a : b) +
              1);

    _notifications.insert(0, {
      'id': nextId,
      'type': type,
      'icon': icon,
      'title': title,
      'content': content,
      'time': time,
      'unread': true,
    });

    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}
