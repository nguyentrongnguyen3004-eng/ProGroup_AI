import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/auth_service.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_text_field.dart';

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
        'LECTURER' => AppRoutes.lecturerMain,
        'SINHVIEN' => AppRoutes.home,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 45),

              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.groups, color: Colors.white, size: 45),
              ),

              SizedBox(height: 22),

              Text(
                AppConstants.appName,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              Text(
                AppConstants.appSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.grayColor),
              ),

              SizedBox(height: 45),

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

              SizedBox(height: 15),

              AppButton(
                text: 'ĐĂNG NHẬP',
                loading: loading,
                icon: Icons.login,
                onPressed: login,
              ),

              SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.text(
                        'Tài khoản demo',
                        en: 'Demo Account',
                      ),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      AppLocalizations.text(
                        'Sinh viên: sv001 / 123456',
                        en: 'Student: sv001 / 123456',
                      ),
                    ),
                    Text(
                      AppLocalizations.text(
                        'Giảng viên: gv001 / 123456',
                        en: 'Lecturer: gv001 / 123456',
                      ),
                    ),
                    Text(
                      AppLocalizations.text(
                        'Admin: admin / Admin@123',
                        en: 'Admin: admin / Admin@123',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
