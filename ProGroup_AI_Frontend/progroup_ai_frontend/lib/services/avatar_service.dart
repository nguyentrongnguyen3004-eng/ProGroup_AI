import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AvatarService {
  AvatarService._();
  static final AvatarService instance = AvatarService._();

  static const String _prefPrefix = 'user_avatar_';

  String _getKey(String? username) {
    final name = (username != null && username.isNotEmpty)
        ? username
        : AuthService.currentUser.username;
    return '$_prefPrefix${name.toLowerCase()}';
  }

  /// Lấy avatar hiện tại: ưu tiên SharedPreferences (local cache), nếu chưa có thì lấy từ currentUser.avatarUrl
  Future<String> getAvatar([String? username]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString(_getKey(username))?.trim();
      if (local != null && local.isNotEmpty) {
        return local;
      }
    } catch (_) {}

    final remote = AuthService.currentUser.avatarUrl;
    if (remote != null && remote.isNotEmpty) {
      return remote;
    }
    return '';
  }

  /// Lưu avatar mới (gọi API Backend + lưu vào SharedPreferences + cập nhật AuthService.currentUser)
  Future<String?> saveAvatar(String avatarData, [String? username]) async {
    final cleanData = avatarData.trim();
    final uname = (username != null && username.isNotEmpty)
        ? username
        : AuthService.currentUser.username;

    // 1. Lưu local cache ngay lập tức để không bao giờ bị mất
    try {
      final prefs = await SharedPreferences.getInstance();
      if (cleanData.isEmpty) {
        await prefs.remove(_getKey(uname));
      } else {
        await prefs.setString(_getKey(uname), cleanData);
      }
    } catch (e) {
      debugPrint('[AvatarService] Error saving to SharedPreferences: $e');
    }

    // 2. Cập nhật model currentUser trong bộ nhớ
    AuthService.currentUser = AuthService.currentUser.copyWith(
      avatarUrl: cleanData.isEmpty ? null : cleanData,
    );

    // 3. Đẩy lên Backend API để lưu vào database & server disk
    try {
      final res = await ApiService.instance.post('/api/profile/avatar', {
        'avatarData': cleanData.isEmpty ? null : cleanData,
      });

      if (res is Map && res['avatarUrl'] != null) {
        final serverUrl = res['avatarUrl'].toString();
        AuthService.currentUser = AuthService.currentUser.copyWith(
          avatarUrl: serverUrl,
        );
        return serverUrl;
      }
    } catch (e) {
      debugPrint('[AvatarService] Error uploading avatar to backend: $e');
    }

    return cleanData;
  }

  /// Xóa avatar
  Future<void> removeAvatar([String? username]) async {
    await saveAvatar('', username);
  }

  /// Chuẩn hóa URL hiển thị của avatar:
  /// - Base64 Data URI: giữ nguyên
  /// - Full HTTP URL: giữ nguyên
  /// - Relative URL (/uploads/...): ghép nối với apiBaseUrl
  static String resolveDisplayUrl(String avatar) {
    final clean = avatar.trim();
    if (clean.isEmpty) return '';
    if (clean.startsWith('data:image/') ||
        clean.startsWith('http://') ||
        clean.startsWith('https://')) {
      return clean;
    }
    if (clean.startsWith('/')) {
      return '${AppConstants.apiBaseUrl}$clean';
    }
    return clean;
  }
}
