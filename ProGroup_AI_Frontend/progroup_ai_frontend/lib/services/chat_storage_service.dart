import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dịch vụ lưu trữ tin nhắn chat cục bộ trên thiết bị
/// Đảm bảo tin nhắn không bao giờ bị mất khi người dùng thoát màn hình hoặc khởi động lại ứng dụng
class ChatStorageService {
  ChatStorageService._();
  static final ChatStorageService instance = ChatStorageService._();

  static const String _prefix = 'chat_messages_cache_v2_';

  /// Tải danh sách tin nhắn đã lưu cho một phòng chat (theo roomId)
  Future<List<Map<String, dynamic>>> loadMessages(
    String roomId, {
    String? currentUserId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefix$roomId';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonStr);
      final List<Map<String, dynamic>> results = [];

      for (final item in decoded) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          // Cập nhật thuộc tính 'me' theo currentUserId của phiên đăng nhập hiện tại
          if (currentUserId != null && map.containsKey('senderId')) {
            map['me'] = (map['senderId'].toString() == currentUserId);
          }
          results.add(map);
        }
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('[ChatStorageService] Lỗi đọc tin nhắn ($roomId): $e');
      }
      return [];
    }
  }

  /// Lưu danh sách tin nhắn vào SharedPreferences
  Future<void> saveMessages(
    String roomId,
    List<Map<String, dynamic>> messages,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefix$roomId';

      // Chuyển đổi dữ liệu sang định dạng JSON an toàn
      final serializableList = messages.map((m) {
        final copy = Map<String, dynamic>.from(m);
        final created = copy['createdAt'];
        if (created is DateTime) {
          copy['createdAt'] = created.toIso8601String();
        } else if (created != null && created is! String && created is! int) {
          try {
            copy['createdAt'] = (created as dynamic).toDate().toIso8601String();
          } catch (_) {
            copy['createdAt'] = created.toString();
          }
        }
        return copy;
      }).toList();

      await prefs.setString(key, jsonEncode(serializableList));
    } catch (e) {
      if (kDebugMode) {
        print('[ChatStorageService] Lỗi lưu tin nhắn ($roomId): $e');
      }
    }
  }

  /// Thêm 1 tin nhắn vào bộ nhớ cục bộ
  Future<void> appendMessage(
    String roomId,
    Map<String, dynamic> message,
  ) async {
    final current = await loadMessages(roomId);
    current.add(message);
    await saveMessages(roomId, current);
  }

  /// Xóa sạch lịch sử chat của một phòng
  Future<void> clearRoom(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$roomId');
    } catch (e) {
      if (kDebugMode) {
        print('[ChatStorageService] Lỗi xóa phòng ($roomId): $e');
      }
    }
  }
}
