import 'package:flutter/material.dart';

import '../../../data/mock/mock_admin_data.dart';
import '../../../models/admin_account_model.dart';
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
  late final TextEditingController _code;
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  late String _role;
  late String _status;

  bool get _editing => widget.account != null;
  bool get _self => widget.account?.id == widget.currentAdminId;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _name = TextEditingController(text: account?.fullName ?? '');
    _code = TextEditingController(text: account?.userCode ?? '');
    _username = TextEditingController(text: account?.username ?? '');
    _email = TextEditingController(text: account?.email ?? '');
    _phone = TextEditingController(text: account?.phone ?? '');
    _role = account?.role ?? MockAdminData.roles.first;
    _status = account?.status ?? MockAdminData.activeStatus;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? adminText('Trường này là bắt buộc.', 'This field is required.')
      : null;

  String? _unique(String? value, String field, String duplicateMessage) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final normalized = value!.trim().toLowerCase();
    final duplicate = MockAdminData.instance.accounts.any((item) {
      if (item.id == widget.account?.id) return false;
      final current = switch (field) {
        'code' => item.userCode,
        'email' => item.email,
        _ => item.username,
      };
      return current.toLowerCase() == normalized;
    });
    return duplicate
        ? adminText(duplicateMessage, switch (field) {
            'code' => 'User code already exists.',
            'email' => 'Email already exists.',
            _ => 'Username already exists.',
          })
        : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = MockAdminData.instance;
    final model = AdminAccountModel(
      id: widget.account?.id ?? 0,
      userCode: _code.text.trim(),
      username: _username.text.trim(),
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      role: _role,
      status: _status,
      password: _editing ? widget.account!.password : _password.text,
      phone: _phone.text.trim(),
      avatar: widget.account?.avatar ?? '',
      createdAt: widget.account?.createdAt ?? DateTime.now(),
    );
    final error = data.validateAccount(
      userCode: model.userCode,
      username: model.username,
      fullName: model.fullName,
      email: model.email,
      role: model.role,
      password: _editing ? 'unchanged' : _password.text,
      confirmPassword: _editing ? 'unchanged' : _confirmPassword.text,
      editingId: widget.account?.id,
      requirePassword: !_editing,
    );
    if (error != null) {
      showAdminMessage(context, error, error);
      return;
    }
    final saved = _editing ? data.updateAccount(model) : data.addAccount(model);
    if (!saved) {
      showAdminMessage(
        context,
        'Không thể lưu tài khoản. Hãy kiểm tra dữ liệu.',
        'Could not save this account. Check the entered data.',
      );
      return;
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        adminText(
          _editing ? 'Sửa người dùng' : 'Thêm người dùng',
          _editing ? 'Edit user' : 'Add user',
        ),
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextFormField(
            controller: _name,
            decoration: InputDecoration(
              labelText: adminText('Họ và tên *', 'Full name *'),
            ),
            validator: _required,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _code,
            readOnly: _editing,
            decoration: InputDecoration(
              labelText: adminText('Mã người dùng *', 'User code *'),
            ),
            validator: (value) => _editing
                ? null
                : _unique(value, 'code', 'Mã người dùng đã tồn tại.'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _username,
            decoration: InputDecoration(
              labelText: adminText('Username *', 'Username *'),
            ),
            validator: (value) =>
                _unique(value, 'username', 'Tên đăng nhập đã tồn tại.'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: adminText('Email *', 'Email *'),
            ),
            validator: (value) {
              final unique = _unique(value, 'email', 'Email đã tồn tại.');
              if (unique != null) return unique;
              if (!RegExp(
                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
              ).hasMatch(value!.trim())) {
                return adminText(
                  'Email không đúng định dạng.',
                  'Enter a valid email address.',
                );
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            decoration: InputDecoration(
              labelText: adminText('Số điện thoại', 'Phone number'),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: InputDecoration(
              labelText: adminText('Vai trò *', 'Role *'),
            ),
            items: [
              for (final role in MockAdminData.roles)
                DropdownMenuItem(value: role, child: Text(adminRoleText(role))),
            ],
            onChanged: _self
                ? null
                : (value) {
                    if (value != null) setState(() => _role = value);
                  },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: InputDecoration(
              labelText: adminText('Trạng thái *', 'Status *'),
            ),
            items: [
              DropdownMenuItem(
                value: MockAdminData.activeStatus,
                child: Text(adminText('Đang hoạt động', 'Active')),
              ),
              DropdownMenuItem(
                value: MockAdminData.lockedStatus,
                child: Text(adminText('Đã khóa', 'Locked')),
              ),
            ],
            onChanged: _self
                ? null
                : (value) {
                    if (value != null) setState(() => _status = value);
                  },
          ),
          if (!_editing) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: adminText('Mật khẩu *', 'Password *'),
              ),
              validator: (value) => value == null || value.length < 6
                  ? adminText(
                      'Mật khẩu phải có ít nhất 6 ký tự.',
                      'Password must be at least 6 characters.',
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: adminText(
                  'Xác nhận mật khẩu *',
                  'Confirm password *',
                ),
              ),
              validator: (value) => value != _password.text
                  ? adminText(
                      'Mật khẩu xác nhận không khớp.',
                      'Passwords do not match.',
                    )
                  : null,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(adminText('Hủy', 'Cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(adminText('Lưu', 'Save')),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
