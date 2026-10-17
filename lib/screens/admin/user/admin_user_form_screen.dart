import 'package:flutter/material.dart';

import '../../../models/admin_account_model.dart';
import '../../../services/admin_api_service.dart';
import '../../admin/admin_helpers.dart';

class AdminUserFormScreen extends StatefulWidget {
  const AdminUserFormScreen({super.key, this.account, this.currentAdminId});

  final AdminAccountModel? account;
  final int? currentAdminId;

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  late String _role;
  late String _status;
  bool _isSubmitting = false;

  bool get _editing => widget.account != null;

  final List<Map<String, String>> _roleOptions = [
    {'code': 'SINHVIEN', 'label': 'Sinh viên'},
    {'code': 'GIANGVIEN', 'label': 'Giảng viên'},
    {'code': 'GIAOVUKHOA', 'label': 'Giáo vụ khoa'},
    {'code': 'PHONGDAOTAO', 'label': 'Phòng Đào tạo'},
    {'code': 'ADMIN', 'label': 'Quản trị viên'},
  ];

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _name = TextEditingController(text: account?.fullName ?? '');
    _username = TextEditingController(text: account?.username ?? '');
    _email = TextEditingController(text: account?.email ?? '');
    _phone = TextEditingController(text: account?.phone ?? '');
    _role = account?.role ?? 'SINHVIEN';
    _status = account?.status ?? 'Đang hoạt động';
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_editing && _password.text != _confirmPassword.text) {
      showAdminMessage(context, 'Mật khẩu xác nhận không khớp.', 'Password confirmation does not match.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'tenDangNhap': _username.text.trim(),
        'matKhau': _password.text.trim(),
        'hoTen': _name.text.trim(),
        'email': _email.text.trim(),
        'soDienThoai': _phone.text.trim(),
        'maVaiTro': _role,
        'trangThai': _status == 'Đang hoạt động',
      };

      await AdminApiService.instance.createUser(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editing ? 'Cập nhật tài khoản thành công.' : 'Tạo tài khoản thành công.'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editing
              ? adminText('Chỉnh sửa người dùng', 'Edit User')
              : adminText('Thêm người dùng mới', 'Add New User'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              Card(
                elevation: 0,
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminText('Thông tin cơ bản', 'Basic Information'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.onSurface),
                      ),
                      const SizedBox(height: 16),
                      _inputField(
                        controller: _name,
                        label: adminText('Họ và tên', 'Full Name'),
                        icon: Icons.person_outline,
                        colors: colors,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập họ và tên' : null,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: _username,
                        label: adminText('Tên đăng nhập', 'Username'),
                        icon: Icons.account_circle_outlined,
                        colors: colors,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: _email,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        colors: colors,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: _phone,
                        label: adminText('Số điện thoại', 'Phone Number'),
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminText('Phân quyền & Trạng thái', 'Role & Status'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.onSurface),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _roleOptions.any((r) => r['code'] == _role) ? _role : _roleOptions.first['code'],
                        decoration: InputDecoration(
                          labelText: adminText('Vai trò', 'Role'),
                          prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF2563EB)),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                        ),
                        items: _roleOptions.map((r) {
                          return DropdownMenuItem<String>(
                            value: r['code'],
                            child: Text(r['label']!),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _role = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: InputDecoration(
                          labelText: adminText('Trạng thái', 'Status'),
                          prefixIcon: const Icon(Icons.toggle_on_outlined, color: Color(0xFF059669)),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Đang hoạt động', child: Text('Đang hoạt động')),
                          DropdownMenuItem(value: 'Đã khóa', child: Text('Đã khóa')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (!_editing) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminText('Mật khẩu', 'Password'),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.onSurface),
                        ),
                        const SizedBox(height: 16),
                        _inputField(
                          controller: _password,
                          label: adminText('Mật khẩu', 'Password'),
                          icon: Icons.lock_outline,
                          obscureText: true,
                          colors: colors,
                          validator: (v) => v == null || v.length < 6 ? 'Mật khẩu phải tối thiểu 6 ký tự' : null,
                        ),
                        const SizedBox(height: 14),
                        _inputField(
                          controller: _confirmPassword,
                          label: adminText('Xác nhận mật khẩu', 'Confirm Password'),
                          icon: Icons.lock_reset_outlined,
                          obscureText: true,
                          colors: colors,
                          validator: (v) => v != _password.text ? 'Mật khẩu không khớp' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _save,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSubmitting
                        ? 'Đang lưu...'
                        : (_editing ? 'Cập nhật tài khoản' : 'Tạo tài khoản'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colors,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}
