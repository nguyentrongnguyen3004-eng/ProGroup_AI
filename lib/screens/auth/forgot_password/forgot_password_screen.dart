import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../services/mock_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class ForgotPasswordScreen
    extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final emailController =
      TextEditingController();

  final service = MockService();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập email.',
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await service.sendOtp(
      emailController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_reset,
                size: 55,
              ),

              const SizedBox(height: 20),

              const Text(
                'Khôi phục mật khẩu',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Nhập email tài khoản. '
                'Mã OTP sẽ được gửi đến email của bạn.',
              ),

              const SizedBox(height: 30),

              AppTextField(
                controller: emailController,
                label: 'Email',
                hint: 'example@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType:
                    TextInputType.emailAddress,
              ),

              const SizedBox(height: 25),

              AppButton(
                text: 'GỬI MÃ OTP',
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