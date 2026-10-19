import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/settings/app_settings.dart';
import '../../../models/lecturer_model.dart';
import '../../../services/lecturer_api_service.dart';
import '../../../widgets/common/change_email_dialog.dart';
import '../../../widgets/common/change_password_dialog.dart';
import '../../../widgets/common/profile_avatar_picker_helper.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  LecturerModel? _lecturer;
  String _customAvatar = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await LecturerApiService.instance.fetchProfile();
      if (mounted) {
        setState(() {
          _lecturer = p;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final defaultLecturer = const LecturerModel(
          id: 1,
          lecturerCode: 'GV001',
          fullName: 'Nguyễn Văn Bình',
          email: 'binh.nv@example.edu.vn',
          faculty: 'Khoa Công nghệ thông tin',
          department: 'Bộ môn Công nghệ phần mềm',
          avatar: '',
        );
        final lecturer = (_lecturer ?? defaultLecturer).copyWith(
          avatar: _customAvatar.isNotEmpty ? _customAvatar : null,
        );
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
                _buildProfileHeader(lecturer),

                const SizedBox(height: 20),

                // Info Section
                _SectionTitle(
                  title: AppLocalizations.text('Thông tin cá nhân', en: 'Personal Information'),
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 8),
                _buildInfoCard(lecturer),

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
                    AppLocalizations.text(
                      'Đăng xuất',
                      en: 'Log Out',
                    ),
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
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(dynamic lecturer) {
    final colors = Theme.of(context).colorScheme;
    final initials = _getInitials(lecturer.fullName);

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
                  backgroundColor: colors.primary.withValues(alpha: 0.1),
                  child: _buildAvatar(
                    lecturer.avatar,
                    initials.isEmpty ? 'GV' : initials,
                  ),
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
            lecturer.fullName,
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
              '${AppLocalizations.text('Mã GV', en: 'Lecturer ID')}: ${lecturer.lecturerCode}',
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
  // AVATAR
  // ============================================================

  Widget _buildAvatar(String avatar, String initials) {
    if (avatar.startsWith('data:image/')) {
      final separator = avatar.indexOf(',');

      if (separator != -1) {
        try {
          final bytes = base64Decode(
            avatar.substring(separator + 1),
          );

          return ClipOval(
            child: Image.memory(
              bytes,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildInitialAvatar(initials);
              },
            ),
          );
        } catch (_) {
          return _buildInitialAvatar(initials);
        }
      }
    }

    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          avatar,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return _buildInitialAvatar(initials);
          },
        ),
      );
    }

    return _buildInitialAvatar(initials);
  }

  Widget _buildInitialAvatar(String initials) {
    return Text(
      initials,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'GV';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildInfoCard(dynamic lecturer) {
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
            icon: Icons.badge_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: AppLocalizations.text('Họ và tên', en: 'Full Name'),
            subtitle: lecturer.fullName,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF6366F1),
            title: AppLocalizations.text('Mã giảng viên', en: 'Lecturer ID'),
            subtitle: lecturer.lecturerCode,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFFEC4899),
            title: AppLocalizations.text('Email liên hệ', en: 'Email'),
            subtitle: lecturer.email,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _changeEmail(lecturer.email),
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.account_balance_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: AppLocalizations.text('Khoa', en: 'Faculty'),
            subtitle: AppLocalizations.tr(lecturer.faculty),
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.business_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: AppLocalizations.text('Bộ môn', en: 'Department'),
            subtitle: AppLocalizations.tr(lecturer.department),
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF10B981),
            title: AppLocalizations.text('Vai trò tài khoản', en: 'Role'),
            subtitle: AppLocalizations.text('Giảng viên', en: 'Lecturer'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT SECURITY
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
              'Xác thực email và mã xác nhận',
              en: 'Email verification and code validation',
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
  // SETTINGS
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
          const Divider(height: 1, indent: 64),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: _SquircleIcon(
              icon: Icons.notifications_rounded,
              color: const Color(0xFFEF4444),
            ),
            title: Text(
              AppLocalizations.text('Thông báo', en: 'Notifications'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
            ),
            subtitle: Text(
              AppLocalizations.text(
                'Nhận thông báo cập nhật từ hệ thống',
                en: 'Receive updates from the system',
              ),
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),
            trailing: Switch.adaptive(
              value: settings.notificationsEnabled,
              onChanged: settings.setNotifications,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ABOUT
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
              _showMessage(
                AppLocalizations.text(
                  'Trung tâm trợ giúp ProGroup AI.',
                  en: 'ProGroup AI Help Center.',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHANGE AVATAR
  // ============================================================

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

  // ============================================================
  // CHANGE EMAIL
  // ============================================================

  Future<void> _changeEmail(String currentEmail) async {
    final newEmail = await ChangeEmailDialog.show(
      context,
      currentEmail: currentEmail,
      onConfirm: (email) async {
        await LecturerApiService.instance.changeEmail(email);
      },
    );
    if (newEmail != null && mounted) {
      _showMessage(
        AppLocalizations.text(
          'Đổi email thành công.',
          en: 'Email changed successfully.',
        ),
      );
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword() async {
    final success = await ChangePasswordDialog.show(
      context,
      onConfirm: (current, newPass) async {
        await LecturerApiService.instance.changePassword(current, newPass);
      },
    );
    if (success == true && mounted) {
      _showMessage(
        AppLocalizations.text(
          'Đổi mật khẩu thành công.',
          en: 'Password changed successfully.',
        ),
      );
    }
  }

  // ============================================================
  // THEME
  // ============================================================

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
                  secondary: _SquircleIcon(
                    icon: Icons.light_mode_rounded,
                    color: const Color(0xFFF59E0B),
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
                  secondary: _SquircleIcon(
                    icon: Icons.dark_mode_rounded,
                    color: const Color(0xFF6366F1),
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
                  secondary: _SquircleIcon(
                    icon: Icons.settings_brightness_rounded,
                    color: const Color(0xFF8B5CF6),
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

  // ============================================================
  // LANGUAGE
  // ============================================================

  void _changeLanguage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: AppSettings.instance,
          builder: (context, _) {
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
                        'Ngôn ngữ',
                        en: 'Language',
                      ),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Text(
                      '🇻🇳',
                      style: TextStyle(fontSize: 25),
                    ),
                    title: Text(
                      AppLocalizations.text(
                        'Tiếng Việt',
                        en: 'Vietnamese',
                      ),
                    ),
                    onTap: () {
                      AppSettings.instance.setLanguage('vi');
                      Navigator.pop(sheetContext);
                    },
                  ),

                  ListTile(
                    leading: const Text(
                      '🇬🇧',
                      style: TextStyle(fontSize: 25),
                    ),
                    title: const Text('English'),
                    onTap: () {
                      AppSettings.instance.setLanguage('en');
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
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

  // ============================================================
  // HELPERS
  // ============================================================

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppLocalizations.text(
          'Sáng',
          en: 'Light',
        );

      case ThemeMode.dark:
        return AppLocalizations.text(
          'Tối',
          en: 'Dark',
        );

      case ThemeMode.system:
        return AppLocalizations.text(
          'Theo hệ thống',
          en: 'System',
        );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

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
        Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
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
