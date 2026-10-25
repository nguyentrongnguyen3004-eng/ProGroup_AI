import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/settings/app_settings.dart';
import '../../../models/user_model.dart';
import '../../../models/user_profile_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/student_api_service.dart';
import '../../../services/avatar_service.dart';
import '../../../services/app_update_service.dart';
import '../../../widgets/common/change_email_dialog.dart';
import '../../../widgets/common/change_password_dialog.dart';
import '../../../widgets/common/profile_avatar_picker_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel user;
  UserProfileModel? _profile;
  late String email;
  String avatarData = '';

  @override
  void initState() {
    super.initState();
    user = AuthService.currentUser;
    email = user.email;
    _loadAvatar();
    _loadProfile();
  }

  Future<void> _loadAvatar() async {
    final avatar = await AvatarService.instance.getAvatar(user.username);
    if (mounted && avatar.isNotEmpty) {
      setState(() => avatarData = avatar);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await StudentApiService.instance.fetchProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        if (profile.avatarUrl.isNotEmpty) {
          avatarData = profile.avatarUrl;
          AvatarService.instance.syncFromServer(user.username, profile.avatarUrl);
        }
        if (profile.email.isNotEmpty) {
          email = profile.email;
        }
      });
    } catch (_) {
      // Giữ thông tin cơ bản từ AuthService.currentUser
    }
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 76),
              children: [
                // Profile Avatar Hero
                _buildProfileHeader(),

                const SizedBox(height: 20),

                // Info Section
                _SectionTitle(
                  title: AppLocalizations.text('Thông tin sinh viên', en: 'Student Information'),
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

  Widget _buildProfileHeader() {
    final colors = Theme.of(context).colorScheme;
    final displayName = _profile?.fullName.isNotEmpty == true
        ? _profile!.fullName
        : user.fullName;
    final displayMssv = _profile?.mssv.isNotEmpty == true
        ? _profile!.mssv
        : (user.mssv ?? user.username);
    final initials = _getInitials(displayName);

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
                    avatarData,
                    initials.isEmpty ? 'SV' : initials,
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
            displayName,
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
              '${AppLocalizations.text('MSSV', en: 'Student ID')}: $displayMssv',
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
  // AVATAR HELPERS
  // ============================================================

  Widget _buildAvatar(String avatar, String initials) {
    if (avatar.startsWith('data:image/')) {
      final separator = avatar.indexOf(',');
      if (separator != -1) {
        try {
          final bytes = base64Decode(avatar.substring(separator + 1));
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitialAvatar(initials),
            ),
          );
        } catch (_) {
    final resolved = AvatarService.resolveDisplayUrl(avatar);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          resolved,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialAvatar(initials),
        ),
      );
    }

          return _buildInitialAvatar(initials);
        }
      }
    }

    final resolved = AvatarService.resolveDisplayUrl(avatar);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          resolved,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialAvatar(initials),
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

    if (parts.isEmpty) return 'SV';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ============================================================
  // SECTIONS
  // ============================================================

  Widget _buildInfoCard() {
    final colors = Theme.of(context).colorScheme;
    final fullName = _profile?.fullName.isNotEmpty == true
        ? _profile!.fullName
        : user.fullName;
    final mssv = _profile?.mssv.isNotEmpty == true
        ? _profile!.mssv
        : (user.mssv ?? user.username);
    final faculty = _profile?.faculty.isNotEmpty == true
        ? _profile!.faculty
        : 'Khoa Công nghệ thông tin';
    final dob = _profile?.dateOfBirth.isNotEmpty == true
        ? _profile!.dateOfBirth
        : 'Chưa cập nhật';
    final gender = _profile?.gender.isNotEmpty == true
        ? _profile!.gender
        : 'Chưa cập nhật';

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
            subtitle: fullName,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF6366F1),
            title: AppLocalizations.text('Mã số sinh viên', en: 'Student ID'),
            subtitle: mssv,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFFEC4899),
            title: AppLocalizations.text('Email liên hệ', en: 'Email'),
            subtitle: email,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changeEmail,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: AppLocalizations.text('Ngày sinh', en: 'Date of Birth'),
            subtitle: dob,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.transgender_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: AppLocalizations.text('Giới tính', en: 'Gender'),
            subtitle: gender,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: AppLocalizations.text('Khoa', en: 'Faculty'),
            subtitle: faculty,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF10B981),
            title: AppLocalizations.text('Vai trò tài khoản', en: 'Role'),
            subtitle: user.roleName.isNotEmpty ? user.roleName : 'Sinh viên',
          ),
        ],
      ),
    );
  }

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
            iconColor: const Color(0xFF0EA5E9),
            title: AppLocalizations.text('Ngôn ngữ', en: 'Language'),
            subtitle: settings.language == 'vi' ? 'Tiếng Việt' : 'English',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changeLanguage,
          ),
          const Divider(height: 1, indent: 64),
          SwitchListTile(
            secondary: const _SquircleIcon(
              icon: Icons.notifications_rounded,
              color: Color(0xFFEC4899),
            ),
            title: Text(
              AppLocalizations.text('Thông báo hệ thống', en: 'Notifications'),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              AppLocalizations.text(
                'Nhận thông báo lịch bảo vệ và đề tài',
                en: 'Receive notifications on schedules & topics',
              ),
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),
            value: settings.notificationsEnabled,
            onChanged: settings.setNotifications,
          ),
        ],
      ),
    );
  }

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
            icon: Icons.system_update_rounded,
            iconColor: const Color(0xFF2563EB),
            title: AppLocalizations.text('Kiểm tra bản cập nhật', en: 'Check for Updates'),
            subtitle: AppLocalizations.text(
              'Nhấn để tìm phiên bản mới nhất',
              en: 'Tap to check for latest version',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => AppUpdateService.instance.manualCheckAndPrompt(context),
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.info_rounded,
            iconColor: const Color(0xFF64748B),
            title: AppLocalizations.text('Phiên bản', en: 'Version'),
            subtitle: 'ProGroup AI v${AppUpdateService.currentVersion}',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => AppUpdateService.instance.manualCheckAndPrompt(context),
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.help_rounded,
            iconColor: const Color(0xFF0EA5E9),
            title: AppLocalizations.text('Trợ giúp & Hướng dẫn', en: 'Help & FAQ'),
            subtitle: AppLocalizations.text(
              'Trung tâm hỗ trợ ProGroup AI',
              en: 'ProGroup AI Support Center',
            ),
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
  // ACTIONS & DIALOGS
  // ============================================================

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppLocalizations.text('Sáng', en: 'Light');
      case ThemeMode.dark:
        return AppLocalizations.text('Tối', en: 'Dark');
      case ThemeMode.system:
        return AppLocalizations.text('Theo hệ thống', en: 'System');
    }
  }

  void _changeAvatar() {
    ProfileAvatarPickerHelper.show(
      context: context,
      onAvatarSelected: (newAvatar) {
        setState(() {
          avatarData = newAvatar;
        });
      },
      onAvatarRemoved: () {
        setState(() {
          avatarData = '';
        });
      },
    );
  }

  Future<void> _changeEmail() async {
    final newEmail = await ChangeEmailDialog.show(
      context,
      currentEmail: email,
    );
    if (newEmail != null && mounted) {
      setState(() {
        email = newEmail;
      });
      _showMessage(
        AppLocalizations.text('Đổi email thành công.', en: 'Email changed successfully.'),
      );
    }
  }

  Future<void> _changePassword() async {
    final success = await ChangePasswordDialog.show(context);
    if (success == true && mounted) {
      _showMessage(
        AppLocalizations.text('Đổi mật khẩu thành công.', en: 'Password changed successfully.'),
      );
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
                    AppLocalizations.text('Chọn giao diện', en: 'Choose Theme'),
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                // ignore: deprecated_member_use
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  // ignore: deprecated_member_use
                  groupValue: current,
                  title: Text(AppLocalizations.text('Sáng', en: 'Light')),
                  secondary: const _SquircleIcon(
                    icon: Icons.light_mode_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value == null) return;
                    AppSettings.instance.setThemeMode(value);
                    Navigator.pop(sheetContext);
                  },
                ),
                // ignore: deprecated_member_use
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  // ignore: deprecated_member_use
                  groupValue: current,
                  title: Text(AppLocalizations.text('Tối', en: 'Dark')),
                  secondary: const _SquircleIcon(
                    icon: Icons.dark_mode_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value == null) return;
                    AppSettings.instance.setThemeMode(value);
                    Navigator.pop(sheetContext);
                  },
                ),
                // ignore: deprecated_member_use
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  // ignore: deprecated_member_use
                  groupValue: current,
                  title: Text(AppLocalizations.text('Theo hệ thống', en: 'System')),
                  secondary: const _SquircleIcon(
                    icon: Icons.settings_brightness_rounded,
                    color: Color(0xFF8B5CF6),
                  ),
                  // ignore: deprecated_member_use
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
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: AppSettings.instance,
          builder: (context, _) {
            final current = AppSettings.instance.language;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        AppLocalizations.text('Ngôn ngữ', en: 'Language'),
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
                      title: Text(AppLocalizations.text('Tiếng Việt', en: 'Vietnamese')),
                      trailing: current == 'vi'
                          ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB))
                          : null,
                      onTap: () {
                        AppSettings.instance.setLanguage('vi');
                        Navigator.pop(sheetContext);
                      },
                    ),
                    ListTile(
                      leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                      title: const Text('English'),
                      trailing: current == 'en'
                          ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB))
                          : null,
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

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLocalizations.text('Đăng xuất', en: 'Log Out')),
          content: Text(
            AppLocalizations.text(
              'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
              en: 'Are you sure you want to log out?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: Text(AppLocalizations.text('Đăng xuất', en: 'Log Out')),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ============================================================
// REUSABLE HELPER WIDGETS (SQUIRCLE & LIST ROW)
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
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
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
