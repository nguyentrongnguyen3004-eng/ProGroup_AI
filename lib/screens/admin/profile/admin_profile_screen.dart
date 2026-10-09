import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/settings/app_settings.dart';
import '../../../data/mock/mock_admin_data.dart';
import '../../../models/admin_account_model.dart';
import '../../../models/user_model.dart';
import '../../admin/admin_helpers.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  AdminAccountModel? get _account =>
      MockAdminData.instance.accountById(widget.user.id);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([MockAdminData.instance, AppSettings.instance]),
    builder: (context, _) {
      final account = _account;
      if (account == null) {
        return Scaffold(
          appBar: AppBar(title: Text(adminText('Cá nhân', 'Profile'))),
          body: adminEmptyState(
            context,
            'Không tìm thấy hồ sơ.',
            'Profile not found.',
          ),
        );
      }
      final settings = AppSettings.instance;
      return Scaffold(
        appBar: AppBar(title: Text(adminText('Cá nhân', 'Profile'))),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _ProfileHeader(
              account: account,
              onAvatar: () => _changeAvatar(account),
            ),
            const SizedBox(height: 18),
            Card(
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.person_outline,
                    title: adminText('Họ và tên', 'Full name'),
                    value: account.fullName,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    title: adminText('Mã cán bộ', 'Staff ID'),
                    value: account.userCode,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.alternate_email,
                    title: adminText('Email', 'Email'),
                    value: account.email,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    title: adminText('Số điện thoại', 'Phone'),
                    value: account.phone.isEmpty ? '—' : account.phone,
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.work_outline,
                    title: adminText('Chức vụ', 'Position'),
                    value: adminText(
                      'Quản trị viên hệ thống',
                      'System administrator',
                    ),
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.assignment_ind_outlined,
                    title: adminText('Vai trò', 'Role'),
                    value: adminText('Admin', 'Admin'),
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: Icons.verified_user_outlined,
                    title: adminText('Trạng thái', 'Status'),
                    value: adminStatusText(account.status),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(adminText('Đổi email', 'Change email')),
                    subtitle: Text(account.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _changeEmail(account),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(adminText('Đổi mật khẩu', 'Change password')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _changePassword(account),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(adminText('Giao diện', 'Theme')),
                    subtitle: Text(_themeName(settings.themeMode)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changeTheme,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(adminText('Ngôn ngữ', 'Language')),
                    subtitle: Text(
                      settings.language == 'en' ? 'English' : 'Tiếng Việt',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changeLanguage,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: Text(adminText('Thông báo', 'Notifications')),
                    value: settings.notificationsEnabled,
                    onChanged: settings.setNotifications,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(adminText('Đăng xuất', 'Log out')),
            ),
          ],
        ),
      );
    },
  );

  Future<void> _changeAvatar(AdminAccountModel account) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(adminText('Chọn ảnh', 'Choose image')),
              onTap: () => Navigator.pop(context, 'choose'),
            ),
            if (account.avatar.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(adminText('Xóa ảnh', 'Remove image')),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'remove') {
      MockAdminData.instance.updateAccount(account.copyWith(avatar: ''));
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
      MockAdminData.instance.updateAccount(
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
    }
  }

  Future<void> _changeEmail(AdminAccountModel account) async {
    final emailController = TextEditingController();
    try {
      final email = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(adminText('Đổi email', 'Change email')),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: adminText('Email mới', 'New email'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(adminText('Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, emailController.text.trim()),
              child: Text(adminText('Gửi OTP', 'Send OTP')),
            ),
          ],
        ),
      );
      if (!mounted || email == null) return;
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        showAdminMessage(
          context,
          'Email không đúng định dạng.',
          'Enter a valid email address.',
        );
        return;
      }
      final duplicate = MockAdminData.instance.accounts.any(
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${adminText('Mã OTP demo đã gửi đến', 'Demo OTP sent to')} $email',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'OTP'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(adminText('Hủy', 'Cancel')),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, otpController.text.trim()),
                child: Text(adminText('Xác nhận', 'Verify')),
              ),
            ],
          ),
        );
      } finally {
        otpController.dispose();
      }
      if (!mounted || otp == null) return;
      if (otp != '123456') {
        showAdminMessage(context, 'OTP không chính xác.', 'Incorrect OTP.');
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(adminText('Xác nhận email mới', 'Confirm new email')),
          content: Text(
            '${adminText('Cập nhật email thành', 'Update the email to')} $email?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(adminText('Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(adminText('Xác nhận', 'Confirm')),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        MockAdminData.instance.updateAccount(account.copyWith(email: email));
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
                ),
              ),
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
        MockAdminData.instance.updateAccount(
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
    MockAdminData.instance.recordActivity(
      action: 'Đăng xuất',
      target: widget.user.username,
      description: 'Tài khoản Admin đăng xuất.',
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.light => adminText('Sáng', 'Light'),
    ThemeMode.dark => adminText('Tối', 'Dark'),
    ThemeMode.system => adminText('Theo hệ thống', 'System default'),
  };
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.account, required this.onAvatar});
  final AdminAccountModel account;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Stack(
        children: [
          adminAvatar(context, account, radius: 52),
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: onAvatar,
              borderRadius: BorderRadius.circular(24),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        account.fullName,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text('${adminText('Mã cán bộ', 'Staff ID')}: ${account.userCode}'),
    ],
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) =>
      ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value));
}
