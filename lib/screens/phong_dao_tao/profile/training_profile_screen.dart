import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/settings/app_settings.dart';
import '../../../data/mock/mock_training_data.dart';
import '../../../models/training_profile_model.dart';

class TrainingProfileScreen extends StatefulWidget {
  const TrainingProfileScreen({super.key});

  @override
  State<TrainingProfileScreen> createState() => _TrainingProfileScreenState();
}

class _TrainingProfileScreenState extends State<TrainingProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final data = MockTrainingData.instance;
    final settings = AppSettings.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([data, settings]),
      builder: (context, _) {
        final profile = data.profile;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _text(context, 'Cá nhân', 'Profile'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              _buildProfileHeader(profile),
              const SizedBox(height: 25),
              _buildInfoCard(profile),
              const SizedBox(height: 15),
              _buildAccountCard(profile),
              const SizedBox(height: 15),
              _buildSettingsCard(settings),
              const SizedBox(height: 15),
              _buildAboutCard(),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade200),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: Text(_text(context, 'Đăng xuất', 'Log out')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(TrainingProfileModel profile) {
    final initials = _initials(profile.fullName);
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: _buildAvatar(profile.avatar, initials),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: () => _changeAvatar(profile.avatar),
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${_text(context, 'Mã cán bộ', 'Staff ID')}: ${profile.staffCode}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String avatar, String initials) {
    if (avatar.startsWith('data:image/')) {
      final separator = avatar.indexOf(',');
      if (separator >= 0) {
        try {
          return ClipOval(
            child: Image.memory(
              base64Decode(avatar.substring(separator + 1)),
              width: 104,
              height: 104,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitialAvatar(initials),
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
          width: 104,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialAvatar(initials),
        ),
      );
    }
    return _buildInitialAvatar(initials);
  }

  Widget _buildInitialAvatar(String initials) => Text(
    initials,
    style: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    ),
  );

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'PĐ';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildInfoCard(TrainingProfileModel profile) => Card(
    child: Column(
      children: [
        _infoTile(
          Icons.person_outline,
          _text(context, 'Họ và tên', 'Full name'),
          profile.fullName,
        ),
        const Divider(height: 1),
        _infoTile(
          Icons.badge_outlined,
          _text(context, 'Mã cán bộ', 'Staff ID'),
          profile.staffCode,
        ),
        const Divider(height: 1),
        _infoTile(
          Icons.alternate_email,
          _text(context, 'Email', 'Email'),
          profile.email,
        ),
        const Divider(height: 1),
        _infoTile(
          Icons.phone_outlined,
          _text(context, 'Số điện thoại', 'Phone'),
          profile.phone,
        ),
        const Divider(height: 1),
        _infoTile(
          Icons.apartment_outlined,
          _text(context, 'Đơn vị', 'Unit'),
          profile.unit,
        ),
        const Divider(height: 1),
        _infoTile(
          Icons.work_outline,
          _text(context, 'Chức vụ', 'Position'),
          profile.position,
        ),
        const Divider(height: 1),
        _infoTile(
          Icons.assignment_ind_outlined,
          _text(context, 'Vai trò', 'Role'),
          profile.roleName,
        ),
        const Divider(height: 1),
        _infoTile(
          Icons.verified_user_outlined,
          _text(context, 'Trạng thái', 'Status'),
          profile.accountStatus,
        ),
      ],
    ),
  );

  Widget _infoTile(IconData icon, String title, String value) =>
      ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value));

  Widget _buildAccountCard(TrainingProfileModel profile) => Card(
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: Text(_text(context, 'Đổi email', 'Change email')),
          subtitle: Text(profile.email),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _changeEmail(profile.email),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(_text(context, 'Đổi mật khẩu', 'Change password')),
          trailing: const Icon(Icons.chevron_right),
          onTap: _changePassword,
        ),
      ],
    ),
  );

  Widget _buildSettingsCard(AppSettings settings) => Card(
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(_text(context, 'Giao diện', 'Theme')),
          subtitle: Text(_themeName(settings.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _changeTheme,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(_text(context, 'Ngôn ngữ', 'Language')),
          subtitle: Text(settings.language == 'en' ? 'English' : 'Tiếng Việt'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _changeLanguage,
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: Text(_text(context, 'Thông báo', 'Notifications')),
          value: settings.notificationsEnabled,
          onChanged: settings.setNotifications,
        ),
      ],
    ),
  );

  Widget _buildAboutCard() => Card(
    child: ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(_text(context, 'Giới thiệu', 'About')),
      subtitle: const Text('ProGroup AI · 1.0.0'),
    ),
  );

  Future<void> _changeAvatar(String currentAvatar) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(_text(context, 'Chọn ảnh', 'Choose image')),
              onTap: () => Navigator.pop(context, 'choose'),
            ),
            if (currentAvatar.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(_text(context, 'Xóa ảnh', 'Remove image')),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'remove') {
      MockTrainingData.instance.updateAvatar('');
      _showMessage(
        _text(context, 'Đã xóa ảnh đại diện.', 'Profile image removed.'),
      );
    } else if (action == 'choose') {
      await _pickAvatar();
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.single.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showMessage(
          _text(
            context,
            'Không đọc được tệp ảnh đã chọn.',
            'Could not read the selected image.',
          ),
        );
        return;
      }
      final extension = result.files.single.extension?.toLowerCase() ?? '';
      if (!const {'png', 'jpg', 'jpeg', 'webp', 'gif'}.contains(extension)) {
        _showMessage(
          _text(
            context,
            'Chỉ hỗ trợ PNG, JPG, JPEG, WEBP hoặc GIF.',
            'Only PNG, JPG, JPEG, WEBP, or GIF are supported.',
          ),
        );
        return;
      }
      if (bytes.length > 5 * 1024 * 1024) {
        _showMessage(
          _text(
            context,
            'Ảnh đại diện phải nhỏ hơn 5 MB.',
            'Profile pictures must be smaller than 5 MB.',
          ),
        );
        return;
      }
      final mime = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            _text(context, 'Xem trước ảnh đại diện', 'Preview profile picture'),
          ),
          content: Center(
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: 128,
                height: 128,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  width: 128,
                  height: 128,
                  child: Icon(Icons.broken_image_outlined, size: 42),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(_text(context, 'Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(_text(context, 'Dùng ảnh này', 'Use this photo')),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      MockTrainingData.instance.updateAvatar(
        'data:$mime;base64,${base64Encode(bytes)}',
      );
      _showMessage(
        _text(context, 'Đã cập nhật ảnh đại diện.', 'Profile image updated.'),
      );
    } catch (_) {
      if (mounted) {
        _showMessage(
          _text(
            context,
            'Không thể chọn ảnh lúc này.',
            'Unable to choose an image right now.',
          ),
        );
      }
    }
  }

  Future<void> _changeEmail(String currentEmail) async {
    final controller = TextEditingController(text: currentEmail);
    try {
      final email = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_text(context, 'Đổi email', 'Change email')),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _text(context, 'Email mới', 'New email'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_text(context, 'Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(_text(context, 'Tiếp tục', 'Continue')),
            ),
          ],
        ),
      );
      if (!mounted || email == null) return;
      if (email.toLowerCase() == currentEmail.trim().toLowerCase()) {
        _showMessage(
          _text(
            context,
            'Email mới phải khác email hiện tại.',
            'The new email must differ from the current email.',
          ),
        );
        return;
      }
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        _showMessage(
          _text(context, 'Email không hợp lệ.', 'Enter a valid email address.'),
        );
        return;
      }
      final verified = await _verifyNewEmail(email);
      if (verified == true && mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              _text(context, 'Xác nhận email mới', 'Confirm new email'),
            ),
            content: Text(
              '${_text(context, 'Bạn có muốn sử dụng email', 'Use this email address?')} $email',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(_text(context, 'Hủy', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(_text(context, 'Xác nhận', 'Confirm')),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
        MockTrainingData.instance.updateEmail(email);
        _showMessage(_text(context, 'Đã cập nhật email.', 'Email updated.'));
      } else if (verified == false && mounted) {
        _showMessage(
          _text(context, 'Mã OTP không đúng.', 'The OTP code is incorrect.'),
        );
      }
    } finally {
      controller.dispose();
    }
  }

  Future<bool?> _verifyNewEmail(String email) async {
    final controller = TextEditingController();
    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_text(context, 'Xác nhận email', 'Verify email')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_text(context, 'Nhập mã OTP gửi đến', 'Enter the OTP sent to')} $email',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  helperText: _text(
                    context,
                    'Mã demo: 123456',
                    'Demo code: 123456',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_text(context, 'Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                controller.text.trim() == '123456',
              ),
              child: Text(_text(context, 'Xác nhận', 'Verify')),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _changePassword() async {
    final formKey = GlobalKey<FormState>();
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    try {
      final changed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_text(context, 'Đổi mật khẩu', 'Change password')),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _passwordField(
                  current,
                  _text(context, 'Mật khẩu hiện tại', 'Current password'),
                ),
                const SizedBox(height: 12),
                _passwordField(
                  next,
                  _text(context, 'Mật khẩu mới', 'New password'),
                  validator: (value) => (value ?? '').length < 6
                      ? _text(
                          context,
                          'Mật khẩu cần ít nhất 6 ký tự.',
                          'Use at least 6 characters.',
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                _passwordField(
                  confirm,
                  _text(context, 'Xác nhận mật khẩu', 'Confirm password'),
                  validator: (value) => value != next.text
                      ? _text(
                          context,
                          'Mật khẩu xác nhận không khớp.',
                          'Passwords do not match.',
                        )
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(_text(context, 'Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (current.text.isEmpty) {
                  _showMessage(
                    _text(
                      context,
                      'Vui lòng nhập mật khẩu hiện tại.',
                      'Enter your current password.',
                    ),
                  );
                  return;
                }
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(_text(context, 'Cập nhật', 'Update')),
            ),
          ],
        ),
      );
      if (changed == true && mounted) {
        _showMessage(
          _text(
            context,
            'Đã cập nhật mật khẩu demo.',
            'Demo password updated.',
          ),
        );
      }
    } finally {
      current.dispose();
      next.dispose();
      confirm.dispose();
    }
  }

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    obscureText: true,
    validator:
        validator ??
        (value) => (value ?? '').isEmpty
            ? _text(context, 'Không được để trống.', 'This field is required.')
            : null,
    decoration: InputDecoration(labelText: label),
  );

  Future<void> _changeTheme() async {
    final current = AppSettings.instance.themeMode;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_text(context, 'Chọn giao diện', 'Choose theme')),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (value) => Navigator.pop(dialogContext, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ThemeMode.values
                  .map(
                    (mode) => RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(_themeName(mode)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
    if (selected != null) AppSettings.instance.setThemeMode(selected);
  }

  Future<void> _changeLanguage() async {
    final current = AppSettings.instance.language;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_text(context, 'Chọn ngôn ngữ', 'Choose language')),
        children: [
          RadioGroup<String>(
            groupValue: current,
            onChanged: (value) => Navigator.pop(dialogContext, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final language in ['vi', 'en'])
                  RadioListTile<String>(
                    value: language,
                    title: Text(language == 'vi' ? 'Tiếng Việt' : 'English'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) AppSettings.instance.setLanguage(selected);
  }

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.system => _text(context, 'Theo hệ thống', 'System default'),
    ThemeMode.light => _text(context, 'Sáng', 'Light'),
    ThemeMode.dark => _text(context, 'Tối', 'Dark'),
  };

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text(context, 'Đăng xuất', 'Log out')),
        content: Text(
          _text(
            context,
            'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
            'Are you sure you want to log out?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_text(context, 'Hủy', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_text(context, 'Đăng xuất', 'Log out')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

String _text(BuildContext context, String vi, String en) =>
    AppLocalizations.text(vi, en: en);
