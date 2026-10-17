import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/settings/app_settings.dart';
<<<<<<< HEAD
=======
import '../../../services/admin_data_service.dart';
import '../../../models/admin_account_model.dart';
>>>>>>> origin/Frontend
import '../../../models/user_model.dart';
import '../../../services/admin_api_service.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import 'dart:convert';
import '../../../widgets/common/change_email_dialog.dart';
import '../../../widgets/common/change_password_dialog.dart';
import '../../../widgets/common/profile_avatar_picker_helper.dart';
import '../../admin/admin_helpers.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key, this.user});
  final UserModel? user;

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
<<<<<<< HEAD
  late UserModel _user;
  String _customAvatar = '';
  final String _department = 'Ban Quản trị Hệ thống ProGroup AI';
  final String _office = 'Trung tâm Dữ liệu & CNTT - Tầng 5';
  bool _isLoading = false;

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user ?? AuthService.currentUser;
    _fetchProfile();
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
          );
        });
      }
    } catch (_) {}
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AD';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;

=======
  AdminAccountModel? get _account =>
      AdminDataService.instance.accountById(widget.user.id);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([AdminDataService.instance, AppSettings.instance]),
    builder: (context, _) {
      final account = _account;
      if (account == null) {
>>>>>>> origin/Frontend
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
                        title: adminText('Thông tin Quản trị viên', 'Admin Information'),
                        icon: Icons.security_rounded,
                        iconColor: const Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(),

                      const SizedBox(height: 18),

                      // Account Security Section
                      _SectionTitle(
                        title: adminText('Bảo mật & Tài khoản', 'Security & Account'),
                        icon: Icons.shield_rounded,
                        iconColor: const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 8),
                      _buildAccountCard(),

                      const SizedBox(height: 18),

                      // System Settings Section
                      _SectionTitle(
                        title: adminText('Cài đặt hệ thống', 'System Settings'),
                        icon: Icons.tune_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 8),
                      _buildSettingsCard(settings),

                      const SizedBox(height: 18),

                      // About Section
                      _SectionTitle(
                        title: adminText('Thông tin ứng dụng', 'Application Info'),
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
                          adminText('Đăng xuất', 'Log Out'),
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
                    color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
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
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              _user.roleName.isNotEmpty ? _user.roleName : 'Quản trị viên Hệ thống',
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
<<<<<<< HEAD
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
            title: adminText('Tài khoản Quản trị', 'Username'),
            subtitle: _user.username,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFFEC4899),
            title: adminText('Email liên hệ', 'Email'),
            subtitle: _user.email.isNotEmpty ? _user.email : 'Chưa cập nhật',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _changeEmail(_user.email),
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.admin_panel_settings_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: adminText('Đơn vị Quản trị', 'Department'),
            subtitle: _department,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: adminText('Địa điểm làm việc', 'Office Location'),
            subtitle: _office,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF10B981),
            title: adminText('Cấp quyền tài khoản', 'Role & Privilege'),
            subtitle: _user.roleName.isNotEmpty ? _user.roleName : 'Root Administrator',
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
            title: adminText('Đổi mật khẩu', 'Change Password'),
            subtitle: adminText(
              'Cập nhật mật khẩu đăng nhập bảo vệ tài khoản Quản trị',
              'Update login password for security',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changePassword,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.security_rounded,
            iconColor: const Color(0xFF10B981),
            title: adminText('Bảo mật tài khoản', 'Account Security'),
            subtitle: adminText(
              'Quyền tối cao trên toàn bộ hệ sinh thái ProGroup AI',
              'Root access on ProGroup AI system',
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
            title: adminText('Giao diện hiển thị', 'Theme Mode'),
            subtitle: _themeName(settings.themeMode),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changeTheme,
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: adminText('Ngôn ngữ', 'Language'),
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
            title: adminText('Phiên bản', 'Version'),
            subtitle: 'ProGroup AI v1.0.0 (Admin Edition)',
          ),
          const Divider(height: 1, indent: 64),
          _ListRow(
            icon: Icons.help_rounded,
            iconColor: const Color(0xFF0EA5E9),
            title: adminText('Tài liệu Quản trị viên', 'Admin Documentation'),
            subtitle: adminText('Trung tâm hỗ trợ ProGroup AI', 'ProGroup AI Support Center'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(adminText('Trung tâm hỗ trợ Quản trị viên ProGroup AI.', 'ProGroup AI Admin Support Center.')),
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
        return adminText('Theo hệ thống', 'System');
      case ThemeMode.light:
        return adminText('Sáng', 'Light');
      case ThemeMode.dark:
        return adminText('Tối', 'Dark');
=======
    if (!mounted || action == null) return;
    if (action == 'remove') {
      AdminDataService.instance.updateAccount(account.copyWith(avatar: ''));
      showAdminMessage(
        context,
        'Đã xóa ảnh đại diện.',
        'Profile picture removed.',
      );
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      final extension = file.extension?.toLowerCase() ?? '';
      if (bytes == null || bytes.isEmpty) {
        showAdminMessage(
          context,
          'Không đọc được ảnh đã chọn.',
          'Could not read the selected image.',
        );
        return;
      }
      if (!const {'png', 'jpg', 'jpeg', 'webp'}.contains(extension)) {
        showAdminMessage(
          context,
          'Chỉ hỗ trợ PNG, JPG, JPEG hoặc WEBP.',
          'Only PNG, JPG, JPEG, or WEBP are supported.',
        );
        return;
      }
      if (bytes.length > 5 * 1024 * 1024) {
        showAdminMessage(
          context,
          'Ảnh phải nhỏ hơn 5 MB.',
          'The image must be smaller than 5 MB.',
        );
        return;
      }
      final mime = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final preview = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(adminText('Xem trước ảnh', 'Preview image')),
          content: SizedBox(
            width: 170,
            height: 170,
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(adminText('Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(adminText('Dùng ảnh này', 'Use this photo')),
            ),
          ],
        ),
      );
      if (preview != true || !mounted) return;
      AdminDataService.instance.updateAccount(
        account.copyWith(avatar: 'data:$mime;base64,${base64Encode(bytes)}'),
      );
      showAdminMessage(
        context,
        'Đã cập nhật ảnh đại diện.',
        'Profile picture updated.',
      );
    } catch (_) {
      if (mounted) {
        showAdminMessage(
          context,
          'Không thể chọn ảnh lúc này.',
          'Unable to choose an image right now.',
        );
      }
>>>>>>> origin/Frontend
    }
  }

  Future<void> _changeEmail(String current) async {
    final newEmail = await ChangeEmailDialog.show(
      context,
      currentEmail: current,
      onConfirm: (email) async {
        await AdminApiService.instance.changeEmail(email);
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
<<<<<<< HEAD
      });
      _showMessage(AppLocalizations.text('Đổi email thành công.', en: 'Email changed successfully.'));
    }
  }

  Future<void> _changePassword() async {
    final success = await ChangePasswordDialog.show(
      context,
      onConfirm: (current, newPass) async {
        await AdminApiService.instance.changePassword(current, newPass);
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
=======
        return;
      }
      final duplicate = AdminDataService.instance.accounts.any(
        (item) =>
            item.id != account.id &&
            item.email.toLowerCase() == email.toLowerCase(),
      );
      if (duplicate) {
        showAdminMessage(
          context,
          'Email đã được sử dụng.',
          'This email is already in use.',
        );
        return;
      }
      final otpController = TextEditingController();
      String? otp;
      try {
        otp = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(adminText('Xác thực email', 'Verify email')),
            content: Column(
>>>>>>> origin/Frontend
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    adminText('Chọn giao diện', 'Choose Theme'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: current,
                  title: Text(adminText('Sáng', 'Light')),
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
                  title: Text(adminText('Tối', 'Dark')),
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
                  title: Text(adminText('Theo hệ thống', 'System')),
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
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          );
        } catch (_) {}
      }
    }
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFEF4444),
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
            adminText('Đăng xuất', 'Log Out'),
          ),
          content: Text(
            adminText(
              'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
              'Are you sure you want to log out?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                adminText('Hủy', 'Cancel'),
              ),
            ),
            FilledButton(
<<<<<<< HEAD
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
=======
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(adminText('Xác nhận', 'Confirm')),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        AdminDataService.instance.updateAccount(account.copyWith(email: email));
        showAdminMessage(context, 'Đã cập nhật email.', 'Email updated.');
      }
    } finally {
      emailController.dispose();
    }
  }

  Future<void> _changePassword(AdminAccountModel account) async {
    final current = TextEditingController();
    final password = TextEditingController();
    final confirm = TextEditingController();
    try {
      final result = await showDialog<(String, String, String)?>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(adminText('Đổi mật khẩu', 'Change password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: current,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: adminText('Mật khẩu hiện tại', 'Current password'),
>>>>>>> origin/Frontend
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
<<<<<<< HEAD
              child: Text(
                adminText('Đăng xuất', 'Log Out'),
              ),
            ),
          ],
        );
      },
=======
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: adminText('Mật khẩu mới', 'New password'),
                ),
              ),
              TextField(
                controller: confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: adminText('Xác nhận mật khẩu', 'Confirm password'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(adminText('Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, (
                current.text,
                password.text,
                confirm.text,
              )),
              child: Text(adminText('Lưu', 'Save')),
            ),
          ],
        ),
      );
      if (!mounted || result == null) return;
      if (result.$1 != account.password) {
        showAdminMessage(
          context,
          'Mật khẩu hiện tại không đúng.',
          'The current password is incorrect.',
        );
      } else if (result.$2.length < 6) {
        showAdminMessage(
          context,
          'Mật khẩu mới phải có ít nhất 6 ký tự.',
          'New password must be at least 6 characters.',
        );
      } else if (result.$2 != result.$3) {
        showAdminMessage(
          context,
          'Mật khẩu xác nhận không khớp.',
          'Passwords do not match.',
        );
      } else {
        AdminDataService.instance.updateAccount(
          account.copyWith(password: result.$2),
        );
        showAdminMessage(context, 'Đã đổi mật khẩu.', 'Password changed.');
      }
    } finally {
      current.dispose();
      password.dispose();
      confirm.dispose();
    }
  }

  Future<void> _changeTheme() async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<ThemeMode>(
              groupValue: AppSettings.instance.themeMode,
              onChanged: (value) => Navigator.pop(context, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final mode in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(_themeName(mode)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) AppSettings.instance.setThemeMode(selected);
  }

  Future<void> _changeLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<String>(
              groupValue: AppSettings.instance.language,
              onChanged: (value) => Navigator.pop(context, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final option in [
                    ('vi', 'Tiếng Việt'),
                    ('en', 'English'),
                  ])
                    RadioListTile<String>(
                      value: option.$1,
                      title: Text(option.$2),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) AppSettings.instance.setLanguage(selected);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(adminText('Đăng xuất', 'Log out')),
        content: Text(
          adminText(
            'Bạn có chắc muốn đăng xuất?',
            'Are you sure you want to log out?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(adminText('Hủy', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(adminText('Đăng xuất', 'Log out')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    AdminDataService.instance.recordActivity(
      action: 'Đăng xuất',
      target: widget.user.username,
      description: 'Tài khoản Admin đăng xuất.',
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
>>>>>>> origin/Frontend
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
