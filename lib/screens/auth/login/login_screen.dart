import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final usernameController =
      TextEditingController();

  final passwordController =
      TextEditingController();

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
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage(
        'Vui lòng nhập đầy đủ thông tin.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final user = await authService.login(
      usernameController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (user == null) {
      showMessage(
        'Tên đăng nhập hoặc mật khẩu không đúng.',
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 45),

              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.groups,
                  color: Colors.white,
                  size: 45,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                AppConstants.appSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.grayColor,
                ),
              ),

              const SizedBox(height: 45),

              AppTextField(
                controller: usernameController,
                label: 'Tên đăng nhập',
                hint: 'Nhập tên đăng nhập',
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              AppTextField(
                controller: passwordController,
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu',
                prefixIcon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons
                            .visibility_off_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.forgotPassword,
                    );
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              AppButton(
                text: 'ĐĂNG NHẬP',
                loading: loading,
                icon: Icons.login,
                onPressed: login,
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(
                    alpha: 0.06,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Tài khoản demo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Sinh viên: sv001 / 123456',
                    ),
                    Text(
                      'Admin: admin / Admin@123',
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