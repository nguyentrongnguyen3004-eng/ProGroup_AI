import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/core/settings/app_settings.dart';
import 'package:progroup_ai_frontend/data/mock/mock_user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = MockUser.student;

  late String email;
  String avatarMode = 'default';

  @override
  void initState() {
    super.initState();
    email = user.email;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
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
              _buildProfileHeader(),

              const SizedBox(height: 25),

              _buildInfoCard(),

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
                label: Text(AppLocalizations.text('Đăng xuất', en: 'Log out')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: avatarMode == 'default'
                  ? Text(
                      user.fullName.substring(0, 1),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.person, size: 48),
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

        SizedBox(height: 14),

        Text(
          user.fullName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 4),

        Text(
          'MSSV: ${user.mssv ?? user.username}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.badge_outlined),
            title: Text(AppLocalizations.text('Họ và tên', en: 'Full Name')),
            subtitle: Text('Nguyễn Văn An'),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: Text(AppLocalizations.text('MSSV', en: 'Student ID')),
            subtitle: Text(user.mssv ?? user.username),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(AppLocalizations.text('Email', en: 'Email')),
            subtitle: Text(email),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeEmail,
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(AppLocalizations.text('Vai trò', en: 'Role')),
            subtitle: Text(user.roleName),
          ),
        ],
      ),
    );
  }

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
            subtitle: Text(settings.language),
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

  Widget _buildAboutCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppLocalizations.text('Phiên bản', en: 'Version')),
            subtitle: Text('ProGroup AI v1.0.0'),
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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  AppLocalizations.text('Ảnh đại diện', en: 'Profile Picture'),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(
                  AppLocalizations.text('Chụp ảnh', en: 'Take Photo'),
                ),
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    avatarMode = 'camera';
                  });

                  _showMessage(
                    'Demo UI: camera sẽ được tích hợp ở bước tiếp theo.',
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
                  Navigator.pop(context);

                  setState(() {
                    avatarMode = 'gallery';
                  });

                  _showMessage(
                    'Demo UI: thư viện ảnh sẽ được tích hợp ở bước tiếp theo.',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text('Xóa ảnh'),
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    avatarMode = 'default';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeEmail() {
    final controller = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.text('Đổi email', en: 'Change Email')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: AppLocalizations.text(
                    'Email mới',
                    en: 'New Email',
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(height: 12),
              Text(
                AppLocalizations.text(
                  'Sau khi nhập email, hệ thống sẽ gửi OTP để xác thực.',
                  en: 'After entering your email, the system will send an OTP for verification.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (!value.contains('@')) {
                  return;
                }

                Navigator.pop(context);
                _verifyNewEmail(value);
              },
              child: Text(AppLocalizations.text('Gửi OTP', en: 'Send OTP')),
            ),
          ],
        );
      },
    );
  }

  void _verifyNewEmail(String newEmail) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.text('Xác thực email', en: 'Verify Email'),
          ),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: AppLocalizations.text('Mã OTP', en: 'OTP Code'),
              hintText: '123456',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (otpController.text.trim() != '123456') {
                  _showMessage(
                    AppLocalizations.text(
                      'OTP không đúng. Demo OTP: 123456',
                      en: 'Incorrect OTP. Demo OTP: 123456',
                    ),
                  );
                  return;
                }

                setState(() {
                  email = newEmail;
                });

                Navigator.pop(context);

                _showMessage(
                  AppLocalizations.text(
                    'Đổi email thành công.',
                    en: 'Email changed successfully.',
                  ),
                );
              },
              child: Text(AppLocalizations.text('Xác nhận', en: 'Confirm')),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    final currentController = TextEditingController();

    final newController = TextEditingController();

    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
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
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.text(
                      'Mật khẩu mới',
                      en: 'New Password',
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.text(
                      'Xác nhận mật khẩu',
                      en: 'Confirm Password',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final newPassword = newController.text;

                if (newPassword.length < 6) {
                  _showMessage(
                    AppLocalizations.text(
                      'Mật khẩu mới phải có ít nhất 6 ký tự.',
                      en: 'New password must contain at least 6 characters.',
                    ),
                  );
                  return;
                }

                if (newPassword != confirmController.text) {
                  _showMessage(
                    AppLocalizations.text(
                      'Mật khẩu xác nhận không khớp.',
                      en: 'Password confirmation does not match.',
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

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

  void _changeTheme() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final current = AppSettings.instance.themeMode;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  AppLocalizations.text('Chọn giao diện', en: 'Choose Theme'),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
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

                  Navigator.pop(context);
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

                  Navigator.pop(context);
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

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
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
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    leading: const Text('🇬🇧', style: TextStyle(fontSize: 25)),
                    title: const Text('English'),
                    onTap: () {
                      AppSettings.instance.setLanguage('en');
                      Navigator.pop(context);
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
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
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
