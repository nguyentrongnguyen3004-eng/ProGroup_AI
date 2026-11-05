import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Đặt lại avatar về rỗng khi đăng xuất (tránh rò rỉ avatar giữa các tài khoản/role khác nhau)
  void reset() {
    avatarNotifier.value = '';
  }

  /// Chuyển đổi avatar sang người dùng / role mới khi đăng nhập
  Future<String> switchUser(String username, [String? serverAvatarUrl]) async {
    final cleanUname = username.trim().toLowerCase();

    // 1. Nếu có avatar từ máy chủ, lưu cache và cập nhật ngay
    if (serverAvatarUrl != null && serverAvatarUrl.trim().isNotEmpty) {
      final clean = serverAvatarUrl.trim();
      avatarNotifier.value = clean;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_prefPrefix$cleanUname', clean);
      } catch (_) {}
      return clean;
    }

    // 2. Nếu chưa có từ máy chủ, kiểm tra SharedPreferences của riêng tài khoản này
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString('$_prefPrefix$cleanUname')?.trim();
      if (local != null && local.isNotEmpty) {
        avatarNotifier.value = local;
        AuthService.currentUser = AuthService.currentUser.copyWith(avatarUrl: local);
        return local;
      }
    } catch (_) {}

    // 3. Nếu tài khoản chưa có ảnh đại diện, xóa sạch avatarNotifier để hiển thị initials chuẩn role
    avatarNotifier.value = '';
    return '';
  }

  /// Lấy avatar hiện tại: ưu tiên SharedPreferences (local cache), nếu chưa có thì lấy từ currentUser.avatarUrl
  Future<String> getAvatar([String? username]) async {
    final uname = (username != null && username.isNotEmpty)
        ? username
        : AuthService.currentUser.username;

    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString(_getKey(uname))?.trim();
      if (local != null && local.isNotEmpty) {
        avatarNotifier.value = local;
        return local;
      }
    } catch (_) {}

    final remote = AuthService.currentUser.avatarUrl;
    if (remote != null && remote.trim().isNotEmpty) {
      final clean = remote.trim();
      avatarNotifier.value = clean;
      return clean;
    }

    avatarNotifier.value = '';
    return '';
  }

  /// Đồng bộ avatar từ API máy chủ sau khi tải thông tin hồ sơ cá nhân
  Future<void> syncFromServer(String username, String? serverAvatarUrl) async {
    if (serverAvatarUrl == null || serverAvatarUrl.trim().isEmpty) return;
    final clean = serverAvatarUrl.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString(_getKey(username))?.trim();
      // Nếu local đã lưu ảnh Base64 thì ưu tiên giữ Base64 để hiển thị tức thì không lag mạng
      if (local != null && local.startsWith('data:image/')) {
        avatarNotifier.value = local;
        AuthService.currentUser = AuthService.currentUser.copyWith(avatarUrl: local);
        return;
      }
      await prefs.setString(_getKey(username), clean);
    } catch (_) {}

    if (avatarNotifier.value != clean) {
      avatarNotifier.value = clean;
    }
    AuthService.currentUser = AuthService.currentUser.copyWith(avatarUrl: clean);
  }

  /// Lưu avatar mới (gọi API Backend + lưu vào SharedPreferences + cập nhật AuthService.currentUser)
  Future<String?> saveAvatar(String avatarData, [String? username]) async {
    final cleanData = avatarData.trim();
    final uname = (username != null && username.isNotEmpty)
        ? username
        : AuthService.currentUser.username;

    final previousAvatar = avatarNotifier.value;
    final previousUserAvatar = AuthService.currentUser.avatarUrl;

    // Cập nhật tạm thời ValueNotifier để phản hồi tức thì
    avatarNotifier.value = cleanData;

    try {
      final res = await ApiService.instance.post('/api/profile/avatar', {
        'avatarData': cleanData.isEmpty ? null : cleanData,
      });

      // Lưu local cache sau khi upload thành công lên máy chủ
      final prefs = await SharedPreferences.getInstance();
      if (cleanData.isEmpty) {
        await prefs.remove(_getKey(uname));
      } else {
        await prefs.setString(_getKey(uname), cleanData);
      }

      AuthService.currentUser = AuthService.currentUser.copyWith(
        avatarUrl: cleanData.isEmpty ? null : cleanData,
      );

      if (res is Map && res['avatarUrl'] != null) {
        final serverUrl = res['avatarUrl'].toString();
        AuthService.currentUser = AuthService.currentUser.copyWith(
          avatarUrl: serverUrl,
        );
        if (!cleanData.startsWith('data:image/')) {
          avatarNotifier.value = serverUrl;
        }
        return serverUrl;
      }
      return cleanData;
    } catch (e) {
      // TC_STU_041: Rollback avatar cũ nếu upload thất bại do mất mạng
      avatarNotifier.value = previousAvatar;
      AuthService.currentUser = AuthService.currentUser.copyWith(
        avatarUrl: previousUserAvatar,
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        if (previousAvatar.isEmpty) {
          await prefs.remove(_getKey(uname));
        } else {
          await prefs.setString(_getKey(uname), previousAvatar);
        }
      } catch (_) {}
      debugPrint('[AvatarService] Upload avatar error (offline/failed): $e');
      throw Exception('Tải ảnh thất bại, vui lòng kiểm tra kết nối mạng');
    }
  }

  Future<void> removeAvatar([String? username]) async {
    await saveAvatar('', username);
    avatarNotifier.value = '';
  }

  /// Chuẩn hóa URL hiển thị của avatar:
  /// - Base64 Data URI: giữ nguyên
  /// - Full HTTP URL: giữ nguyên
  /// - Relative URL (/uploads/...): ghép nối với apiBaseUrl / workingBaseUrl
  static String resolveDisplayUrl(String avatar) {
    final clean = avatar.trim();
    if (clean.isEmpty) return '';
    if (clean.startsWith('data:image/') ||
        clean.startsWith('http://') ||
        clean.startsWith('https://')) {
      return clean;
    }
    if (clean.startsWith('/')) {
      final base = ApiService.workingBaseUrl ?? ApiService.currentLanIpUrl;
      return '$base$clean';
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
  final String? username;
  final String? avatarUrl;
  final String initials;
  final double size;
  final double fontSize;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const UserAvatarView({
    super.key,
    this.username,
    this.avatarUrl,
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
      builder: (context, dynamicAvatar, _) {
        // Thứ tự ưu tiên hiển thị avatar:
        // 1. dynamicAvatar từ AvatarService (khi vừa upload/đổi avatar mới)
        // 2. avatarUrl được truyền vào trực tiếp
        // 3. AuthService.currentUser.avatarUrl
        String currentAvatar = '';
        if (dynamicAvatar.trim().isNotEmpty) {
          currentAvatar = dynamicAvatar.trim();
        } else if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
          currentAvatar = avatarUrl!.trim();
        } else if (AuthService.currentUser.avatarUrl != null &&
            AuthService.currentUser.avatarUrl!.trim().isNotEmpty) {
          currentAvatar = AuthService.currentUser.avatarUrl!.trim();
        }

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
