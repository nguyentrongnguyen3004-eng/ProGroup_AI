import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/settings/app_settings.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/governance_api_service.dart';
import 'dart:convert';
import '../../../widgets/common/change_email_dialog.dart';
import '../../../widgets/common/change_password_dialog.dart';
import '../../../widgets/common/profile_avatar_picker_helper.dart';
import '../../../services/avatar_service.dart';

class GovernanceProfileScreen extends StatefulWidget {
  const GovernanceProfileScreen({super.key});

  @override
  State<GovernanceProfileScreen> createState() => _GovernanceProfileScreenState();
}

class _GovernanceProfileScreenState extends State<GovernanceProfileScreen> {
  late UserModel _user;
  String _customAvatar = '';
  final String _department = 'Khoa Công nghệ thông tin';
  final String _office = 'Văn phòng Khoa - Nhà B1';
  bool _isLoading = false;

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    _user = AuthService.currentUser;
    _loadAvatar();
    _fetchProfile();
  }

  Future<void> _loadAvatar() async {
    final a = await AvatarService.instance.getAvatar(_user.username);
    if (mounted && a.isNotEmpty) {
      setState(() => _customAvatar = a);
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await ApiService.instance.get('/api/auth/me');
      if (!mounted) return;
      if (res is Map<String, dynamic>) {
        setState(() {
          _user = UserModel(
            id: res['nguoiDungId'] ?? _user.id,
            username: res['tenDangNhap'] ?? _user.username,
            fullName: res['hoTen'] ?? _user.fullName,
            email: res['email'] ?? _user.email,
            role: res['maVaiTro'] ?? _user.role,
            roleName: res['tenVaiTro'] ?? _user.roleName,
            avatarUrl: res['avatarUrl'] as String?,
          );
          if (res['avatarUrl'] != null && (res['avatarUrl'] as String).isNotEmpty) {
            _customAvatar = res['avatarUrl'] as String;
            AvatarService.instance.syncFromServer(_user.username, _customAvatar);
          }
        });
      }
    } catch (_) {}
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'GV';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;

        return Scaffold(
          body: SafeArea(
            bottom: true,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 80),
                    children: [
                      // Profile Avatar Hero
                      _buildProfileHeader(),

                      const SizedBox(height: 20),

                      // Info Section
                      _SectionTitle(
                        title: AppLocalizations.text('Thông tin cán bộ', en: 'Staff Information'),
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(),

                      const SizedBox(height: 18),

                      // Account Security Section
                      _SectionTitle(
                        title: AppLocalizations.text('Bảo mật & Tài khoản', en: 'Security & Account'),
                        icon: Icons.shield_rounded,
                        iconColor: const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 8),
                      _buildAccountCard(),

                      const SizedBox(height: 18),

                      // System Settings Section
                      _SectionTitle(
                        title: AppLocalizations.text('Cài đặt hệ thống', en: 'System Settings'),
                        icon: Icons.tune_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 8),
                      _buildSettingsCard(settings),

                      const SizedBox(height: 18),

                      // About Section
                      _SectionTitle(
                        title: AppLocalizations.text('Thông tin ứng dụng', en: 'Application Info'),
                        icon: Icons.info_rounded,
                        iconColor: const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 8),
                      _buildAboutCard(),

                      const SizedBox(height: 24),

                      // Logout Button
                      OutlinedButton.icon(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade200, width: 1.2),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: Text(
                          AppLocalizations.text('Đăng xuất', en: 'Log Out'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE HEADER (MATCHING LECTURER & STUDENT SPEC)
  // ============================================================
  Widget _buildProfileHeader() {
    final colors = Theme.of(context).colorScheme;
    final initials = _getInitials(_user.fullName);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  child: _buildAvatarImage(initials),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _changeAvatar,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _user.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              _user.roleName.isNotEmpty ? _user.roleName : 'Giáo vụ khoa',
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONAL INFORMATION CARD
  // ============================================================
  Widget _buildInfoCard() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _ListRow(
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: AppLocalizations.text('Tài khoản đăng nhập', en: 'Username'),
            subtitle: _user.username,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFFEC4899),
            title: AppLocalizations.text('Email liên hệ', en: 'Email'),
            subtitle: _user.email.isNotEmpty ? _user.email : 'Chưa cập nhật',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _changeEmail(_user.email),
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.account_balance_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: AppLocalizations.text('Khoa', en: 'Faculty'),
            subtitle: _department,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.business_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: AppLocalizations.text('Văn phòng', en: 'Office'),
            subtitle: _office,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF10B981),
            title: AppLocalizations.text('Vai trò tài khoản', en: 'Role'),
            subtitle: _user.roleName.isNotEmpty ? _user.roleName : 'Giáo vụ khoa',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT SECURITY CARD
  // ============================================================
  Widget _buildAccountCard() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _ListRow(
            icon: Icons.lock_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: AppLocalizations.text('Đổi mật khẩu', en: 'Change Password'),
            subtitle: AppLocalizations.text(
              'Cập nhật mật khẩu đăng nhập bảo vệ tài khoản',
              en: 'Update login password for security',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changePassword,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.security_rounded,
            iconColor: const Color(0xFF10B981),
            title: AppLocalizations.text('Bảo mật tài khoản', en: 'Account Security'),
            subtitle: AppLocalizations.text(
              'Xác thực tài khoản cán bộ khoa',
              en: 'Faculty staff account authentication',
            ),
            trailing: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================
  Widget _buildSettingsCard(AppSettings settings) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _ListRow(
            icon: Icons.palette_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: AppLocalizations.text('Giao diện hiển thị', en: 'Theme Mode'),
            subtitle: _themeName(settings.themeMode),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changeTheme,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: AppLocalizations.text('Ngôn ngữ', en: 'Language'),
            subtitle: settings.language == 'vi' ? 'Tiếng Việt' : 'English',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changeLanguage,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ABOUT CARD
  // ============================================================
  Widget _buildAboutCard() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _ListRow(
            icon: Icons.info_rounded,
            iconColor: const Color(0xFF64748B),
            title: AppLocalizations.text('Phiên bản', en: 'Version'),
            subtitle: 'ProGroup AI v1.0.0',
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.help_rounded,
            iconColor: const Color(0xFF0EA5E9),
            title: AppLocalizations.text('Trợ giúp & Hướng dẫn', en: 'Help & FAQ'),
            subtitle: AppLocalizations.text('Trung tâm hỗ trợ ProGroup AI', en: 'ProGroup AI Support Center'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.text('Trung tâm trợ giúp Giáo vụ khoa ProGroup AI.', en: 'ProGroup AI Faculty Help Center.')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppLocalizations.text('Theo hệ thống', en: 'System');
      case ThemeMode.light:
        return AppLocalizations.text('Sáng', en: 'Light');
      case ThemeMode.dark:
        return AppLocalizations.text('Tối', en: 'Dark');
    }
  }

  Future<void> _changeEmail(String current) async {
    final newEmail = await ChangeEmailDialog.show(
      context,
      currentEmail: current,
      onConfirm: (email) async {
        await GovernanceApiService.instance.changeEmail(email);
      },
    );
    if (newEmail != null && mounted) {
      setState(() {
        _user = UserModel(
          id: _user.id,
          username: _user.username,
          fullName: _user.fullName,
          email: newEmail,
          role: _user.role,
          roleName: _user.roleName,
        );
      });
      _showMessage(AppLocalizations.text('Đổi email thành công.', en: 'Email changed successfully.'));
    }
  }

  Future<void> _changePassword() async {
    final success = await ChangePasswordDialog.show(
      context,
      onConfirm: (current, newPass) async {
        await GovernanceApiService.instance.changePassword(current, newPass);
      },
    );
    if (success == true && mounted) {
      _showMessage(AppLocalizations.text('Đổi mật khẩu thành công.', en: 'Password changed successfully.'));
    }
  }

  void _changeTheme() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final current = AppSettings.instance.themeMode;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    AppLocalizations.text(
                      'Chọn giao diện',
                      en: 'Choose Theme',
                    ),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: current,
                  title: Text(
                    AppLocalizations.text(
                      'Sáng',
                      en: 'Light',
                    ),
                  ),
                  secondary: const _SquircleIcon(
                    icon: Icons.light_mode_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    AppSettings.instance.setThemeMode(value);
                    Navigator.pop(sheetContext);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: current,
                  title: Text(
                    AppLocalizations.text(
                      'Tối',
                      en: 'Dark',
                    ),
                  ),
                  secondary: const _SquircleIcon(
                    icon: Icons.dark_mode_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    AppSettings.instance.setThemeMode(value);
                    Navigator.pop(sheetContext);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: current,
                  title: Text(
                    AppLocalizations.text(
                      'Theo hệ thống',
                      en: 'System',
                    ),
                  ),
                  secondary: const _SquircleIcon(
                    icon: Icons.settings_brightness_rounded,
                    color: Color(0xFF8B5CF6),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    AppSettings.instance.setThemeMode(value);
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeLanguage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final settings = AppSettings.instance;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
                  title: const Text('Tiếng Việt'),
                  trailing: settings.language == 'vi' ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
                  onTap: () {
                    settings.setLanguage('vi');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: const Text('English'),
                  trailing: settings.language == 'en' ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
                  onTap: () {
                    settings.setLanguage('en');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeAvatar() {
    ProfileAvatarPickerHelper.show(
      context: context,
      onAvatarSelected: (newAvatar) {
        setState(() {
          _customAvatar = newAvatar;
        });
      },
      onAvatarRemoved: () {
        setState(() {
          _customAvatar = '';
        });
      },
    );
  }

  Widget _buildAvatarImage(String initials) {
    if (_customAvatar.startsWith('data:image/')) {
      final comma = _customAvatar.indexOf(',');
      if (comma != -1) {
        try {
          final bytes = base64Decode(_customAvatar.substring(comma + 1));
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          );
        } catch (_) {}
      }
    }

    final resolved = AvatarService.resolveDisplayUrl(_customAvatar);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          resolved,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Text(
            initials,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      );
    }

    return Text(
      initials,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2563EB),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            AppLocalizations.text(
              'Đăng xuất',
              en: 'Log Out',
            ),
          ),
          content: Text(
            AppLocalizations.text(
              'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
              en: 'Are you sure you want to log out?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                AppLocalizations.text(
                  'Hủy',
                  en: 'Cancel',
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                AuthService.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: Text(
                AppLocalizations.text(
                  'Đăng xuất',
                  en: 'Log Out',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// REUSABLE HELPER WIDGETS MATCHING LECTURER SPEC
// ============================================================
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SquircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SquircleIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _ListRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ListRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _SquircleIcon(icon: icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
