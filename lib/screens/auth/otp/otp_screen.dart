import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../services/mock_service.dart';
import '../../../widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpScreen> createState() =>
      _OtpScreenState();
}

class _OtpScreenState
    extends State<OtpScreen> {
  final otpController =
      TextEditingController();

  final service = MockService();

  bool loading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      showMessage(
        'OTP phải gồm 6 chữ số.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final result = await service.verifyOtp(
      otpController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (!result) {
      showMessage('Mã OTP không đúng.');
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.resetPassword,
      arguments: widget.email,
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
        title: const Text('Xác thực OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 55,
            ),

            const SizedBox(height: 20),

            const Text(
              'Nhập mã OTP',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Mã OTP đã được gửi đến ${widget.email}',
            ),

            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              keyboardType:
                  TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '000000',
              ),
            ),

            const SizedBox(height: 20),

            AppButton(
              text: 'XÁC NHẬN',
              loading: loading,
              icon: Icons.check,
              onPressed: verifyOtp,
            ),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                'Demo OTP: 123456',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}