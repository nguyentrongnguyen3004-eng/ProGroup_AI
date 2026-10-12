import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => n['isRead'] == false || n['read'] == false).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiClient.get('/notifications');
      if (res is List) {
        _notifications = res.cast<Map<String, dynamic>>();
      } else if (res is Map && res['data'] is List) {
        _notifications = (res['data'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Keep empty if API does not return data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addNotification({
    required String title,
    required String message,
    String type = 'Hệ thống',
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'content': message,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
      'isRead': false,
      'read': false,
    });
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    for (var n in _notifications) {
      n['isRead'] = true;
      n['read'] = true;
    }
    notifyListeners();
    try {
      await ApiClient.put('/notifications/read-all', {});
    } catch (_) {}
  }

  Future<void> markAsRead(dynamic id) async {
    for (var n in _notifications) {
      if (n['id'] == id) {
        n['isRead'] = true;
        n['read'] = true;
      }
    }
    notifyListeners();
    try {
      await ApiClient.put('/notifications/$id/read', {});
    } catch (_) {}
  }
}
