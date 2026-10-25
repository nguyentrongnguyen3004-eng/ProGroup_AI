import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AvatarService {
  AvatarService._();
  static final AvatarService instance = AvatarService._();

  static const String _prefPrefix = 'user_avatar_';

  /// ValueNotifier để toàn bộ widget lắng nghe sự thay đổi avatar theo thời gian thực
  final ValueNotifier<String> avatarNotifier = ValueNotifier<String>('');

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
        avatarNotifier.value = local;
        return local;
      }
    } catch (_) {}

    final remote = AuthService.currentUser.avatarUrl;
    if (remote != null && remote.isNotEmpty) {
      avatarNotifier.value = remote;
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

    // Cập nhật ngay ValueNotifier để toàn bộ giao diện đổi avatar tức thì
    avatarNotifier.value = cleanData;

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
        avatarNotifier.value = serverUrl;
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
    avatarNotifier.value = '';
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

  /// Vẽ nội dung bên trong hình tròn avatar (Ảnh Base64 / Ảnh mạng / Chữ viết tắt)
  static Widget buildAvatarContent({
    required String avatar,
    required String initials,
    double size = 48,
    double fontSize = 16,
    Color textColor = Colors.white,
  }) {
    final clean = avatar.trim();
    if (clean.startsWith('data:image/')) {
      final separator = clean.indexOf(',');
      if (separator != -1) {
        try {
          final bytes = base64Decode(clean.substring(separator + 1));
          return ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: fontSize,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        } catch (_) {}
      }
    }

    final resolved = resolveDisplayUrl(clean);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          resolved,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Text(
              initials,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Widget hiển thị Avatar người dùng có khả năng tự động lắng nghe và cập nhật tức thì
class UserAvatarView extends StatelessWidget {
  final String initials;
  final double size;
  final double fontSize;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const UserAvatarView({
    super.key,
    required this.initials,
    this.size = 48,
    this.fontSize = 16,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const defaultGradients = [Color(0xFF1E3A5F), Color(0xFF2563EB)];
    final colors = gradientColors ?? defaultGradients;

    final childWidget = ValueListenableBuilder<String>(
      valueListenable: AvatarService.instance.avatarNotifier,
      builder: (context, avatar, _) {
        final currentAvatar = avatar.isNotEmpty
            ? avatar
            : (AuthService.currentUser.avatarUrl ?? '');

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AvatarService.buildAvatarContent(
            avatar: currentAvatar,
            initials: initials,
            size: size,
            fontSize: fontSize,
          ),
        );
      },
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: childWidget,
      );
    }

    return childWidget;
  }
}
