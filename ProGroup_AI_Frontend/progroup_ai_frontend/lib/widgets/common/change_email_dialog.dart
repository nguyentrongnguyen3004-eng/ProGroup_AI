import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

/// Modal bottom sheet đẹp mắt, hiện đại phục vụ việc đổi địa chỉ email cho tất cả các role.
class ChangeEmailDialog extends StatefulWidget {
  final String currentEmail;
  final Future<void> Function(String newEmail)? onConfirm;

  const ChangeEmailDialog({
    super.key,
    required this.currentEmail,
    this.onConfirm,
  });

  /// Phương thức static tiện lợi để hiển thị modal đổi email trên mọi màn hình.
  static Future<String?> show(
    BuildContext context, {
    required String currentEmail,
    Future<void> Function(String newEmail)? onConfirm,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeEmailDialog(
        currentEmail: currentEmail,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  int _step = 0; // 0: Nhập email, 1: Xác thực OTP
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailController.text = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendTimer = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _submitEmail() {
    final newEmail = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (newEmail.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Vui lòng nhập địa chỉ email mới.',
          en: 'Please enter a new email address.',
        );
      });
      return;
    }

    if (!emailRegex.hasMatch(newEmail)) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Email chưa đúng định dạng (vd: user@example.com).',
          en: 'Invalid email format (e.g. user@example.com).',
        );
      });
      return;
    }

    if (newEmail.toLowerCase() == widget.currentEmail.trim().toLowerCase()) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Email mới phải khác với email hiện tại.',
          en: 'New email must be different from current email.',
        );
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _step = 1;
    });
    _startResendCountdown();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Mã OTP phải gồm 6 chữ số.',
          en: 'OTP must be 6 digits.',
        );
      });
      return;
    }

    // Demo OTP chấp nhận 123456 hoặc bất kỳ 6 số hợp lệ
    if (otp != '123456') {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Mã OTP không chính xác. Thử lại với mã thử nghiệm: 123456',
          en: 'Incorrect OTP. Try again with demo code: 123456',
        );
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newEmail = _emailController.text.trim();
      if (widget.onConfirm != null) {
        await widget.onConfirm!(newEmail);
      }
      if (mounted) {
        Navigator.of(context).pop(newEmail);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh kéo drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.outlineVariant.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Nội dung theo từng bước
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _step == 0 ? _buildEmailStep(colors) : _buildOtpStep(colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(ColorScheme colors) {
    return Column(
      key: const ValueKey('email_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Biểu tượng & Tiêu đề
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.alternate_email_rounded, color: colors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.text('Đổi địa chỉ email', en: 'Change Email Address'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.text(
                      'Cập nhật email nhận thông báo & bảo mật',
                      en: 'Update email for notifications & security',
                    ),
                    style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Thẻ hiển thị Email hiện tại
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: colors.onSurfaceVariant),
              const SizedBox(width: 10),
              Text(
                '${AppLocalizations.text('Email hiện tại', en: 'Current email')}: ',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              Expanded(
                child: Text(
                  widget.currentEmail,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Ô nhập email mới
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.text('Email mới', en: 'New Email'),
            hintText: 'name@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: _emailController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _emailController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
          onChanged: (_) => setState(() => _errorMessage = null),
          onSubmitted: (_) => _submitEmail(),
        ),

        // Banner thông báo lỗi nếu có
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 18, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 13, color: colors.error),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Hướng dẫn bảo mật
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.text(
                    'Hệ thống sẽ gửi mã OTP gồm 6 chữ số đến địa chỉ email mới này để xác thực quyền sở hữu.',
                    en: 'A 6-digit OTP code will be sent to this new email to verify ownership.',
                  ),
                  style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant, height: 1.35),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Hàng nút điều khiển
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _submitEmail,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(
                  AppLocalizations.text('Gửi mã OTP', en: 'Send OTP Code'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpStep(ColorScheme colors) {
    return Column(
      key: const ValueKey('otp_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mark_email_read_outlined, color: colors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.text('Xác thực email mới', en: 'Verify New Email'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _emailController.text.trim(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Nhập mã OTP
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 10,
          ),
          decoration: InputDecoration(
            counterText: '',
            labelText: AppLocalizations.text('Mã xác thực OTP (6 số)', en: 'OTP Code (6 digits)'),
            hintText: '123456',
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
          onChanged: (val) {
            setState(() => _errorMessage = null);
            if (val.trim().length == 6) {
              _verifyOtp();
            }
          },
        ),

        // Hint Demo OTP
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_outlined, size: 15, color: colors.onSecondaryContainer),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    AppLocalizations.text('Mã thử nghiệm: 123456', en: 'Demo OTP: 123456'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 18, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 13, color: colors.error),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        // Hàng gửi lại mã
        Center(
          child: _resendTimer > 0
              ? Text(
                  '${AppLocalizations.text('Gửi lại sau', en: 'Resend code in')} ${_resendTimer}s',
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                )
              : TextButton.icon(
                  onPressed: _startResendCountdown,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    AppLocalizations.text('Gửi lại mã OTP', en: 'Resend OTP Code'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
        ),

        const SizedBox(height: 20),

        // Hàng nút điều khiển
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _step = 0;
                    _errorMessage = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(AppLocalizations.text('Quay lại', en: 'Back')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _verifyOtp,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  AppLocalizations.text('Xác nhận & Lưu', en: 'Confirm & Save'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
