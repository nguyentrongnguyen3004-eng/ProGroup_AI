import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/app_update_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/server_config_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  final authService = AuthService();

  bool obscurePassword = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.instance.autoCheckAndPrompt(context);
      }
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;

    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage(
        AppLocalizations.text(
          'Vui lòng nhập đầy đủ thông tin.',
          en: 'Please enter all required information.',
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = await authService.login(
        usernameController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      setState(() => loading = false);

      if (user == null) {
        showMessage(
          AppLocalizations.text(
            'Tên đăng nhập hoặc mật khẩu không đúng.',
            en: 'Incorrect username or password.',
          ),
        );
        return;
      }

      final destination = switch (user.role) {
        'LECTURER' || 'GIANGVIEN' => AppRoutes.lecturerMain,
        'SINHVIEN' => AppRoutes.home,
        'GIAOVU' || 'GIAOVUKHOA' => AppRoutes.governanceMain,
        'PHONG_DAO_TAO' || 'PHONGDAOTAO' => AppRoutes.trainingMain,
        'ADMIN' => AppRoutes.adminMain,
        _ => null,
      };
      if (destination == null) {
        showMessage(
          AppLocalizations.text(
            'Tài khoản này chưa được cấp giao diện ứng dụng.',
            en: 'This account does not have an application role.',
          ),
        );
        return;
      }
      Navigator.pushReplacementNamed(context, destination, arguments: user);
    } catch (_) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(
        AppLocalizations.text(
          'Không thể đăng nhập lúc này. Vui lòng thử lại.',
          en: 'Unable to sign in right now. Please try again.',
        ),
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton.filledTonal(
                  tooltip: 'Cấu hình Máy chủ Backend',
                  icon: const Icon(Icons.dns_rounded, size: 20),
                  onPressed: () => ServerConfigDialog.show(context),
                ),
              ),
              const SizedBox(height: 5),

              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.groups, color: Colors.white, size: 42),
              ),

              const SizedBox(height: 16),

              Text(
                AppConstants.appName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                AppConstants.appSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.grayColor),
              ),

              const SizedBox(height: 25),

              AppTextField(
                controller: usernameController,
                label: AppLocalizations.text('Tên đăng nhập', en: 'Username'),
                hint: AppLocalizations.text(
                  'Nhập tên đăng nhập',
                  en: 'Enter username',
                ),
                prefixIcon: Icons.person_outline,
              ),

              SizedBox(height: 20),

              AppTextField(
                controller: passwordController,
                label: AppLocalizations.text('Mật khẩu', en: 'Password'),
                hint: AppLocalizations.text(
                  'Nhập mật khẩu',
                  en: 'Enter password',
                ),
                prefixIcon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),

              SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: Text(
                    AppLocalizations.text(
                      'Quên mật khẩu?',
                      en: 'Forgot password?',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              AppButton(
                text: 'ĐĂNG NHẬP',
                loading: loading,
                icon: Icons.login,
                onPressed: login,
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.text(
                        'Tài khoản đăng nhập hệ thống (API)',
                        en: 'System Login Accounts (API)',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    _buildAccountRow('Sinh viên', 'sv001', '123456', Icons.school),
                    _buildAccountRow('Giảng viên', 'gv001', '123456', Icons.person_outline),
                    _buildAccountRow('Giáo vụ khoa', 'gvk.demo', '123456', Icons.admin_panel_settings_outlined),
                    _buildAccountRow('Phòng đào tạo', 'pdt.demo', '123456', Icons.domain),
                    _buildAccountRow('Admin hệ thống', 'admin.demo', '123456', Icons.security),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountRow(String roleLabel, String user, String pass, IconData icon) {
    return InkWell(
      onTap: () {
        usernameController.text = user;
        passwordController.text = pass;
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.blue.shade700),
            const SizedBox(width: 6),
            Text('$roleLabel: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            Expanded(
              child: Text(
                '$user / $pass',
                style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.touch_app_outlined, size: 13, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
