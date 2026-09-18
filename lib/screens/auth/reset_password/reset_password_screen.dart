import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../services/mock_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class ResetPasswordScreen
    extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  final service = MockService();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final password =
        passwordController.text;

    final confirm =
        confirmController.text;

    if (password.length < 6) {
      showMessage(
        'Mật khẩu phải có ít nhất 6 ký tự.',
      );
      return;
    }

    if (password != confirm) {
      showMessage(
        'Mật khẩu xác nhận không khớp.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await service.resetPassword(password);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đặt lại mật khẩu thành công.',
        ),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
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
      appBar: AppBar(
        title: const Text(
          'Đặt lại mật khẩu',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.password,
              size: 60,
            ),

            const SizedBox(height: 20),

            Text(
              'Tạo mật khẩu mới',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 30),

            AppTextField(
              controller: passwordController,
              label: 'Mật khẩu mới',
              hint: 'Nhập mật khẩu mới',
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
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),

            const SizedBox(height: 20),

            AppTextField(
              controller: confirmController,
              label: 'Xác nhận mật khẩu',
              hint: 'Nhập lại mật khẩu',
              prefixIcon: Icons.lock_reset,
              obscureText: obscureConfirm,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscureConfirm =
                        !obscureConfirm;
                  });
                },
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),

            const SizedBox(height: 30),

            AppButton(
              text: 'ĐẶT LẠI MẬT KHẨU',
              loading: loading,
              onPressed: resetPassword,
            ),
          ],
        ),
      ),
    );
  }
}