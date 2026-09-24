import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/services/mock_service.dart';
import 'package:progroup_ai_frontend/widgets/app_button.dart';
import 'package:progroup_ai_frontend/widgets/app_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();

  final confirmController = TextEditingController();

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
    if (loading) return;

    final password = passwordController.text;

    final confirm = confirmController.text;

    if (password.length < 6) {
      showMessage(
        AppLocalizations.text(
          'Mật khẩu phải có ít nhất 6 ký tự.',
          en: 'Password must contain at least 6 characters.',
        ),
      );
      return;
    }

    if (password != confirm) {
      showMessage(
        AppLocalizations.text(
          'Mật khẩu xác nhận không khớp.',
          en: 'Password confirmation does not match.',
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await service.resetPassword(password);

      if (!mounted) return;

      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Đặt lại mật khẩu thành công.',
              en: 'Password reset successfully.',
            ),
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(
        AppLocalizations.text(
          'Không thể đặt lại mật khẩu lúc này. Vui lòng thử lại.',
          en: 'The password could not be reset right now. Please try again.',
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
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Đặt lại mật khẩu', en: 'Reset Password'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.password, size: 60),

            SizedBox(height: 20),

            Text(
              AppLocalizations.text(
                'Tạo mật khẩu mới',
                en: 'Create New Password',
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            AppTextField(
              controller: passwordController,
              label: AppLocalizations.text('Mật khẩu mới', en: 'New Password'),
              hint: AppLocalizations.text(
                'Nhập mật khẩu mới',
                en: 'Enter new password',
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
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),

            SizedBox(height: 20),

            AppTextField(
              controller: confirmController,
              label: AppLocalizations.text(
                'Xác nhận mật khẩu',
                en: 'Confirm Password',
              ),
              hint: AppLocalizations.text(
                'Nhập lại mật khẩu',
                en: 'Enter password again',
              ),
              prefixIcon: Icons.lock_reset,
              obscureText: obscureConfirm,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscureConfirm = !obscureConfirm;
                  });
                },
                icon: Icon(
                  obscureConfirm ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),

            SizedBox(height: 30),

            AppButton(
              text: AppLocalizations.text(
                'ĐẶT LẠI MẬT KHẨU',
                en: 'RESET PASSWORD',
              ),
              loading: loading,
              onPressed: resetPassword,
            ),
          ],
        ),
      ),
    );
  }
}
