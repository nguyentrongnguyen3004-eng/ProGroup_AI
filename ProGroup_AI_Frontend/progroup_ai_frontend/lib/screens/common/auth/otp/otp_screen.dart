import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/services/password_reset_api_service.dart';
import 'package:progroup_ai_frontend/widgets/app_button.dart';

/// Formatter tự động chuyển đổi ký tự có Shift (!@#$%^&*()) thành số 0-9 nếu bị dính CapsLock / Shift trên máy ảo
class OtpDigitInputFormatter extends TextInputFormatter {
  static const Map<String, String> _shiftedDigits = {
    '!': '1',
    '@': '2',
    '#': '3',
    r'$': '4',
    '%': '5',
    '^': '6',
    '&': '7',
    '*': '8',
    '(': '9',
    ')': '0',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    _shiftedDigits.forEach((key, val) {
      text = text.replaceAll(key, val);
    });
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 6) {
      text = text.substring(0, 6);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  final service = PasswordResetApiService.instance;

  bool loading = false;
  int resendCountdown = 60;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    setState(() => resendCountdown = 60);
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown > 0) {
        setState(() => resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    if (loading) return;

    final otp = otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      showMessage(
        AppLocalizations.text(
          'OTP phải gồm 6 chữ số.',
          en: 'OTP must contain 6 digits.',
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await service.verifyOtp(widget.email, otp);
      if (!mounted) return;

      setState(() => loading = false);
      if (!result) {
        showMessage(
          AppLocalizations.text(
            'Mã OTP không đúng.',
            en: 'Incorrect OTP code.',
          ),
        );
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.resetPassword,
        arguments: {'email': widget.email, 'otp': otp},
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(e.toString());
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
        title: Text(AppLocalizations.text('Xác thực OTP', en: 'Verify OTP')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_outlined, size: 55),

              SizedBox(height: 20),

              Text(
                AppLocalizations.text('Nhập mã OTP', en: 'Enter OTP'),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Text(
                AppLocalizations.text(
                  'Mã OTP đã được gửi đến ${widget.email}',
                  en: 'The OTP code has been sent to ${widget.email}',
                ),
              ),

              SizedBox(height: 30),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                inputFormatters: [OtpDigitInputFormatter()],
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(hintText: '000000'),
              ),

              SizedBox(height: 20),

              AppButton(
                text: AppLocalizations.text('XÁC NHẬN', en: 'CONFIRM'),
                loading: loading,
                icon: Icons.check,
                onPressed: verifyOtp,
              ),

              Center(
                child: TextButton.icon(
                  onPressed: (loading || resendCountdown > 0)
                      ? null
                      : () async {
                          setState(() => loading = true);
                          try {
                            await service.sendOtp(widget.email);
                            startCountdown();
                            showMessage(
                              AppLocalizations.text(
                                'Đã gửi lại mã OTP đến email ${widget.email}.',
                                en: 'OTP has been resent to ${widget.email}.',
                              ),
                            );
                          } catch (e) {
                            showMessage(e.toString());
                          } finally {
                            if (mounted) setState(() => loading = false);
                          }
                        },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    resendCountdown > 0
                        ? '${AppLocalizations.text('Gửi lại sau', en: 'Resend code in')} ${resendCountdown}s'
                        : AppLocalizations.text(
                            'Gửi lại mã OTP qua Email',
                            en: 'Resend OTP via Email',
                          ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
