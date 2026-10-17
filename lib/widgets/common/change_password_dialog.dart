import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

/// Modal bottom sheet đẹp mắt, hiện đại phục vụ việc đổi mật khẩu cho tất cả các role.
class ChangePasswordDialog extends StatefulWidget {
  final Future<void> Function(String currentPassword, String newPassword)? onConfirm;

  const ChangePasswordDialog({
    super.key,
    this.onConfirm,
  });

  /// Phương thức static tiện lợi để hiển thị modal đổi mật khẩu trên mọi màn hình.
  static Future<bool?> show(
    BuildContext context, {
    Future<void> Function(String currentPassword, String newPassword)? onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangePasswordDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  int _calculateStrength(String pass) {
    if (pass.isEmpty) return 0;
    int score = 0;
    if (pass.length >= 6) score++;
    if (pass.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(pass) && RegExp(r'[a-zA-Z]').hasMatch(pass)) score++;
    return score; // 0, 1, 2, 3
  }

  Future<void> _submit() async {
    final currentPass = _currentPassController.text.trim();
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    if (currentPass.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Vui lòng nhập mật khẩu hiện tại.',
          en: 'Please enter your current password.',
        );
      });
      return;
    }

    if (newPass.length < 6) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Mật khẩu mới phải có ít nhất 6 ký tự.',
          en: 'New password must have at least 6 characters.',
        );
      });
      return;
    }

    if (newPass == currentPass) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Mật khẩu mới phải khác với mật khẩu hiện tại.',
          en: 'New password must be different from current password.',
        );
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _errorMessage = AppLocalizations.text(
          'Mật khẩu xác nhận không trùng khớp.',
          en: 'Password confirmation does not match.',
        );
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.onConfirm != null) {
        await widget.onConfirm!(currentPass, newPass);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
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
    final strength = _calculateStrength(_newPassController.text);

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

              // Header tiêu đề & icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_reset_rounded, color: colors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.text('Đổi mật khẩu', en: 'Change Password'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.text(
                            'Cập nhật mật khẩu để bảo vệ tài khoản',
                            en: 'Update password to secure your account',
                          ),
                          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Ô 1: Mật khẩu hiện tại
              TextField(
                controller: _currentPassController,
                obscureText: _obscureCurrent,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.text('Mật khẩu hiện tại', en: 'Current Password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),

              const SizedBox(height: 14),

              // Ô 2: Mật khẩu mới
              TextField(
                controller: _newPassController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.text('Mật khẩu mới', en: 'New Password'),
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),

              // Thanh đo độ mạnh mật khẩu
              if (_newPassController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: strength >= 1 ? Colors.red : colors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: strength >= 2 ? Colors.amber : colors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: strength >= 3 ? Colors.green : colors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      strength == 0
                          ? ''
                          : strength == 1
                              ? AppLocalizations.text('Yếu', en: 'Weak')
                              : strength == 2
                                  ? AppLocalizations.text('Trung bình', en: 'Medium')
                                  : AppLocalizations.text('Mạnh', en: 'Strong'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: strength == 1
                            ? Colors.red
                            : strength == 2
                                ? Colors.amber.shade700
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Ô 3: Xác nhận mật khẩu mới
              TextField(
                controller: _confirmPassController,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: AppLocalizations.text('Xác nhận mật khẩu mới', en: 'Confirm New Password'),
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
                onSubmitted: (_) => _submit(),
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

              // Lời khuyên bảo mật
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.security_rounded, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.text(
                          'Mật khẩu nên chứa từ 6 ký tự trở lên, kết hợp chữ cái và số để đảm bảo tính an toàn cao nhất.',
                          en: 'Password should contain at least 6 characters, combining letters and numbers for highest security.',
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
                      onPressed: () => Navigator.of(context).pop(false),
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
                      onPressed: _isLoading ? null : _submit,
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
                          : const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        AppLocalizations.text('Lưu mật khẩu', en: 'Save Password'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
