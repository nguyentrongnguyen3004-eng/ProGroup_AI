import 'package:flutter/material.dart';

import '../../models/training_notification_model.dart';

class MockTrainingNotifications extends ChangeNotifier {
  MockTrainingNotifications._();

  static final MockTrainingNotifications instance =
      MockTrainingNotifications._();

  final List<TrainingNotificationModel> _items = [
    TrainingNotificationModel(
      id: 1,
      type: 'Lớp học phần',
      title: 'Đã mở đăng ký lớp LTDD-01',
      content:
          'Lớp Lập trình di động đã sẵn sàng để sinh viên đăng ký trong học kỳ HK7 - 2026.',
      time: '10 phút trước',
      icon: Icons.school_outlined,
    ),
    TrainingNotificationModel(
      id: 2,
      type: 'Phân công giảng viên',
      title: 'Cần rà soát phân công giảng dạy',
      content:
          'Kiểm tra giảng viên phụ trách cho các lớp học phần trước khi chốt thời khóa biểu.',
      time: '1 giờ trước',
      icon: Icons.assignment_ind_outlined,
    ),
    TrainingNotificationModel(
      id: 3,
      type: 'Dữ liệu đào tạo',
      title: 'Danh sách sinh viên đã được cập nhật',
      content:
          'Dữ liệu sinh viên học kỳ hiện tại đã được cập nhật trong hệ thống.',
      time: 'Hôm qua',
      icon: Icons.fact_check_outlined,
      isRead: true,
    ),
  ];

  List<TrainingNotificationModel> get notifications =>
      List.unmodifiable(_items);

  int get unreadCount => _items.where((item) => !item.isRead).length;

  void markAsRead(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0 || _items[index].isRead) return;
    final item = _items[index];
    item.isRead = true;
    notifyListeners();
  }

  void markAllAsRead() {
    var changed = false;
    for (final item in _items) {
      if (!item.isRead) {
        item.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void addNotification({
    required String type,
    required String title,
    required String content,
    IconData icon = Icons.notifications_outlined,
  }) {
    final id = _items.isEmpty
        ? 1
        : _items.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
    _items.insert(
      0,
      TrainingNotificationModel(
        id: id,
        type: type,
        title: title,
        content: content,
        time: 'Vừa xong',
        icon: icon,
      ),
    );
    notifyListeners();
  }
}
