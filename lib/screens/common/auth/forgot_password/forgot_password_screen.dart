import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../services/mock_service.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  final service = MockService();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    if (loading) return;

    final email = emailController.text.trim();
    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!validEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Nhập địa chỉ email hợp lệ.',
              en: 'Enter a valid email address.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final sent = await service.sendOtp(email);
      if (!mounted) return;

      setState(() => loading = false);
      if (!sent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.text(
                'Chưa thể gửi mã OTP. Vui lòng thử lại.',
                en: 'The OTP could not be sent. Please try again.',
              ),
            ),
          ),
        );
        return;
      }

      Navigator.pushNamed(context, AppRoutes.otp, arguments: email);
    } catch (_) {
      if (!mounted) return;

      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Chưa thể gửi mã OTP. Vui lòng thử lại.',
              en: 'The OTP could not be sent. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Quên mật khẩu', en: 'Forgot Password'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_reset, size: 55),

              const SizedBox(height: 20),

              Text(
                AppLocalizations.text(
                  'Khôi phục mật khẩu',
                  en: 'Recover Password',
                ),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                AppLocalizations.text(
                  'Nhập email tài khoản. '
                  'Mã OTP sẽ được gửi đến email của bạn.',
                  en:
                      'Enter your account email. '
                      'An OTP code will be sent to your email.',
                ),
              ),

              const SizedBox(height: 30),

              AppTextField(
                controller: emailController,
                label: AppLocalizations.text('Email', en: 'Email'),
                hint: 'example@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 25),

              AppButton(
                text: AppLocalizations.text('GỬI MÃ OTP', en: 'SEND OTP'),
                loading: loading,
                icon: Icons.send,
                onPressed: sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
