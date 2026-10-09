import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/settings/app_settings.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../models/governance_profile_model.dart';

class GovernanceProfileScreen extends StatefulWidget {
  const GovernanceProfileScreen({super.key});

  @override
  State<GovernanceProfileScreen> createState() =>
      _GovernanceProfileScreenState();
}

class _GovernanceProfileScreenState extends State<GovernanceProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppSettings.instance,
        MockGovernanceData.instance,
      ]),
      builder: (context, _) {
        final governance = MockGovernanceData.current;
        final settings = AppSettings.instance;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.text('Cá nhân', en: 'Profile'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              _buildProfileHeader(governance),

              const SizedBox(height: 25),

              _buildInfoCard(governance),

              const SizedBox(height: 15),

              _buildAccountCard(),

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
                label: Text(AppLocalizations.text('Đăng xuất', en: 'Log Out')),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(GovernanceProfileModel governance) {
    final initials = _getInitials(governance.fullName);

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: _buildAvatar(
                governance.avatarBase64,
                initials.isEmpty ? 'GV' : initials,
              ),
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: _changeAvatar,
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
          governance.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text(
          'Mã cán bộ: ${governance.staffCode}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
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
          final bytes = base64Decode(avatar.substring(separator + 1));

          return ClipOval(
            child: Image.memory(
              bytes,
              width: 104,
              height: 104,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
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
          width: 104,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
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
        fontSize: 34,
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

  Widget _buildInfoCard(GovernanceProfileModel governance) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(AppLocalizations.text('Họ và tên', en: 'Full Name')),
            subtitle: Text(governance.fullName),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: Text(AppLocalizations.text('Mã cán bộ', en: 'Staff ID')),
            subtitle: Text(governance.staffCode),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(AppLocalizations.text('Email', en: 'Email')),
            subtitle: Text(governance.email),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changeEmail(governance.email),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(AppLocalizations.text('Điện thoại', en: 'Phone')),
            subtitle: Text(governance.phone),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: Text(AppLocalizations.text('Khoa', en: 'Faculty')),
            subtitle: Text(governance.faculty),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.work_outline),
            title: Text(AppLocalizations.text('Chức vụ', en: 'Position')),
            subtitle: Text(governance.position),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(AppLocalizations.text('Vai trò', en: 'Role')),
            subtitle: Text(
              AppLocalizations.text(
                'Giáo vụ khoa',
                en: 'Faculty Academic Affairs Officer',
              ),
            ),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(AppLocalizations.text('Trạng thái', en: 'Status')),
            subtitle: Text(
              governance.isActive
                  ? AppLocalizations.text('Đang hoạt động', en: 'Active')
                  : AppLocalizations.text('Không hoạt động', en: 'Inactive'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT
  // ============================================================

  Widget _buildAccountCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(
              AppLocalizations.text('Đổi mật khẩu', en: 'Change Password'),
            ),
            subtitle: Text(
              AppLocalizations.text(
                'Cập nhật mật khẩu đăng nhập',
                en: 'Update your login password',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changePassword,
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(
              AppLocalizations.text(
                'Bảo mật tài khoản',
                en: 'Account Security',
              ),
            ),
            subtitle: Text(
              AppLocalizations.text(
                'OTP và xác thực email',
                en: 'OTP and email verification',
              ),
            ),
            trailing: const Icon(Icons.check_circle_outline),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Widget _buildSettingsCard(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(AppLocalizations.text('Giao diện', en: 'Theme')),
            subtitle: Text(_themeName(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeTheme,
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(AppLocalizations.text('Ngôn ngữ', en: 'Language')),
            subtitle: Text(
              settings.language == 'vi' ? 'Tiếng Việt' : 'English',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeLanguage,
          ),

          const Divider(height: 1),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(
              AppLocalizations.text('Thông báo', en: 'Notifications'),
            ),
            subtitle: Text(
              AppLocalizations.text(
                'Nhận thông báo từ hệ thống',
                en: 'Receive notifications from the system',
              ),
            ),
            value: settings.notificationsEnabled,
            onChanged: settings.setNotifications,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAboutCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.text('Phiên bản', en: 'Version')),
            subtitle: const Text('ProGroup AI v1.0.0'),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(AppLocalizations.text('Trợ giúp', en: 'Help')),
            trailing: const Icon(Icons.chevron_right),
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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  AppLocalizations.text('Ảnh đại diện', en: 'Profile Picture'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(
                  AppLocalizations.text('Chụp ảnh', en: 'Take Photo'),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _showMessage(
                    AppLocalizations.text(
                      'Chức năng chụp ảnh sẽ được tích hợp khi kết nối camera.',
                      en: 'Camera capture will be integrated when camera support is connected.',
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  AppLocalizations.text(
                    'Chọn từ thư viện',
                    en: 'Choose from Gallery',
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAvatarFromGallery();
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(
                  AppLocalizations.text('Xóa ảnh', en: 'Remove Photo'),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  MockGovernanceData.updateAvatar('');

                  _showMessage(
                    AppLocalizations.text(
                      'Đã xóa ảnh đại diện.',
                      en: 'Profile picture removed.',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAvatarFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        _showMessage(
          AppLocalizations.text(
            'Không đọc được ảnh đã chọn.',
            en: 'Unable to read the selected image.',
          ),
        );
        return;
      }

      final extension = file.extension?.toLowerCase() ?? '';

      if (!const {'png', 'jpg', 'jpeg', 'webp', 'gif'}.contains(extension)) {
        _showMessage(
          AppLocalizations.text(
            'Chỉ hỗ trợ PNG, JPG, JPEG, WEBP hoặc GIF.',
            en: 'Only PNG, JPG, JPEG, WEBP or GIF are supported.',
          ),
        );
        return;
      }

      if (bytes.length > 5 * 1024 * 1024) {
        _showMessage(
          AppLocalizations.text(
            'Ảnh đại diện phải nhỏ hơn 5 MB.',
            en: 'Profile picture must be smaller than 5 MB.',
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
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              AppLocalizations.text(
                'Xem trước ảnh đại diện',
                en: 'Preview Profile Picture',
              ),
            ),
            content: Center(
              child: CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(bytes),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: Text(
                  AppLocalizations.text('Dùng ảnh này', en: 'Use This Photo'),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !mounted) {
        return;
      }

      MockGovernanceData.updateAvatar(
        'data:$mime;base64,${base64Encode(bytes)}',
      );

      _showMessage(
        AppLocalizations.text(
          'Đã cập nhật ảnh đại diện.',
          en: 'Profile picture updated.',
        ),
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        AppLocalizations.text(
          'Không thể mở hoặc đọc ảnh này.',
          en: 'Unable to open or read this image.',
        ),
      );
    }
  }

  // ============================================================
  // CHANGE EMAIL
  // ============================================================

  Future<void> _changeEmail(String currentEmail) async {
    final controller = TextEditingController(text: currentEmail);

    final newEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.text('Đổi email', en: 'Change Email')),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.text('Email mới', en: 'New Email'),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  _showDialogMessage(
                    AppLocalizations.text(
                      'Email chưa đúng định dạng.',
                      en: 'Invalid email format.',
                    ),
                  );
                  return;
                }

                if (value == currentEmail) {
                  _showDialogMessage(
                    AppLocalizations.text(
                      'Email mới phải khác email hiện tại.',
                      en: 'New email must be different from the current email.',
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: Text(AppLocalizations.text('Gửi OTP', en: 'Send OTP')),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newEmail == null || !mounted) {
      return;
    }

    await _verifyNewEmail(newEmail);
  }

  Future<void> _verifyNewEmail(String newEmail) async {
    final otpController = TextEditingController();

    final verified = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.text('Xác thực email', en: 'Verify Email'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.text(
                  'Mã OTP đã được gửi đến email mới.',
                  en: 'An OTP has been sent to the new email.',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: AppLocalizations.text('Mã OTP', en: 'OTP Code'),
                  hintText: '123456',
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.text(
                  'Demo OTP: 123456',
                  en: 'Demo OTP: 123456',
                ),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                final otp = otpController.text.trim();

                if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
                  _showDialogMessage(
                    AppLocalizations.text(
                      'OTP phải gồm đúng 6 chữ số.',
                      en: 'OTP must contain exactly 6 digits.',
                    ),
                  );
                  return;
                }

                if (otp != '123456') {
                  _showDialogMessage(
                    AppLocalizations.text(
                      'OTP không đúng.',
                      en: 'Incorrect OTP.',
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: Text(AppLocalizations.text('Xác nhận', en: 'Confirm')),
            ),
          ],
        );
      },
    );

    otpController.dispose();

    if (verified != true || !mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.text(
              'Xác nhận email mới',
              en: 'Confirm New Email',
            ),
          ),
          content: Text(
            '${AppLocalizations.text('Bạn có muốn sử dụng email', en: 'Do you want to use the email')} $newEmail?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(AppLocalizations.text('Xác nhận', en: 'Confirm')),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    MockGovernanceData.updateEmail(newEmail);

    _showMessage(
      AppLocalizations.text(
        'Đổi email thành công.',
        en: 'Email changed successfully.',
      ),
    );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  void _changePassword() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.text('Đổi mật khẩu', en: 'Change Password'),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.text(
                      'Mật khẩu hiện tại',
                      en: 'Current Password',
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.text(
                      'Mật khẩu mới',
                      en: 'New Password',
                    ),
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.text(
                      'Xác nhận mật khẩu',
                      en: 'Confirm Password',
                    ),
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                final currentPassword = currentController.text.trim();

                final newPassword = newController.text;

                final confirmPassword = confirmController.text;

                if (currentPassword.isEmpty) {
                  _showDialogMessage(
                    AppLocalizations.text(
                      'Vui lòng nhập mật khẩu hiện tại.',
                      en: 'Please enter your current password.',
                    ),
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  _showDialogMessage(
                    AppLocalizations.text(
                      'Mật khẩu mới phải có ít nhất 6 ký tự.',
                      en: 'New password must contain at least 6 characters.',
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  _showDialogMessage(
                    AppLocalizations.text(
                      'Mật khẩu xác nhận không khớp.',
                      en: 'Password confirmation does not match.',
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                _showMessage(
                  AppLocalizations.text(
                    'Đổi mật khẩu thành công.',
                    en: 'Password changed successfully.',
                  ),
                );
              },
              child: Text(AppLocalizations.text('Lưu', en: 'Save')),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // THEME
  // ============================================================

  void _changeTheme() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final current = AppSettings.instance.themeMode;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  AppLocalizations.text('Chọn giao diện', en: 'Choose Theme'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: current,
                title: Text(AppLocalizations.text('Sáng', en: 'Light')),
                secondary: const Icon(Icons.light_mode_outlined),
                onChanged: (value) {
                  if (value == null) return;

                  AppSettings.instance.setThemeMode(value);

                  Navigator.pop(sheetContext);
                },
              ),

              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: current,
                title: Text(AppLocalizations.text('Tối', en: 'Dark')),
                secondary: const Icon(Icons.dark_mode_outlined),
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
                  AppLocalizations.text('Theo hệ thống', en: 'System'),
                ),
                secondary: const Icon(Icons.settings_outlined),
                onChanged: (value) {
                  if (value == null) return;

                  AppSettings.instance.setThemeMode(value);

                  Navigator.pop(sheetContext);
                },
              ),
            ],
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
      showDragHandle: true,
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: AppSettings.instance,
          builder: (context, _) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      AppLocalizations.text('Ngôn ngữ', en: 'Language'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Text('🇻🇳', style: TextStyle(fontSize: 25)),
                    title: Text(
                      AppLocalizations.text('Tiếng Việt', en: 'Vietnamese'),
                    ),
                    onTap: () {
                      AppSettings.instance.setLanguage('vi');

                      Navigator.pop(sheetContext);
                    },
                  ),

                  ListTile(
                    leading: const Text('🇬🇧', style: TextStyle(fontSize: 25)),
                    title: const Text('English'),
                    onTap: () {
                      AppSettings.instance.setLanguage('en');

                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
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
          title: Text(AppLocalizations.text('Đăng xuất', en: 'Log Out')),
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
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
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
              child: Text(AppLocalizations.text('Đăng xuất', en: 'Log Out')),
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
        return AppLocalizations.text('Sáng', en: 'Light');

      case ThemeMode.dark:
        return AppLocalizations.text('Tối', en: 'Dark');

      case ThemeMode.system:
        return AppLocalizations.text('Theo hệ thống', en: 'System');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDialogMessage(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.text('Đóng', en: 'Close')),
            ),
          ],
        );
      },
    );
  }
}
