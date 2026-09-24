import 'package:flutter/material.dart';

class MockLecturerNotifications extends ChangeNotifier {
  MockLecturerNotifications._();

  static final MockLecturerNotifications instance =
      MockLecturerNotifications._();

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'type': 'Đề tài',
      'icon': Icons.lightbulb_outline,
      'title': 'Sinh viên đề xuất đề tài mới',
      'content': 'Nhóm sinh viên vừa gửi một đề tài mới cần bạn duyệt.',
      'time': '10 phút trước',
      'isRead': false,
    },
    {
      'id': 2,
      'type': 'Đăng ký',
      'icon': Icons.assignment_outlined,
      'title': 'Có đăng ký đề tài mới',
      'content': 'Nhóm ProGroup đã đăng ký đề tài và đang chờ duyệt.',
      'time': '1 giờ trước',
      'isRead': false,
    },
    {
      'id': 3,
      'type': 'Nhóm',
      'icon': Icons.groups_outlined,
      'title': 'Có nhóm mới',
      'content': 'Một nhóm mới đã được tạo trong lớp LTDD-01.',
      'time': 'Hôm qua',
      'isRead': true,
    },
  ];

  List<Map<String, dynamic>> get notifications => List.unmodifiable(
    _notifications.map((item) => Map<String, dynamic>.unmodifiable(item)),
  );

  int get unreadCount =>
      _notifications.where((item) => item['isRead'] == false).length;

  void markAsRead(int id) {
    final index = _notifications.indexWhere((item) => item['id'] == id);

    if (index == -1 || _notifications[index]['isRead'] == true) return;

    _notifications[index]['isRead'] = true;
    notifyListeners();
  }

  void markAllAsRead() {
    bool changed = false;

    for (final item in _notifications) {
      if (item['isRead'] == false) {
        item['isRead'] = true;
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
  }) {
    final nextId = _notifications.isEmpty
        ? 1
        : _notifications
                  .map((item) => item['id'] as int)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    _notifications.insert(0, {
      'id': nextId,
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
