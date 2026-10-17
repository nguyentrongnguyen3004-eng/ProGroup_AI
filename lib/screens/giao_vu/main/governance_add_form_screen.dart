import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../services/admin_api_service.dart';

enum GovernanceAddKind { student, lecturer }

class GovernanceAddFormScreen extends StatefulWidget {
  final GovernanceAddKind kind;
  final Object? existingData;

  const GovernanceAddFormScreen({
    super.key,
    required this.kind,
    this.existingData,
  });

  @override
  State<GovernanceAddFormScreen> createState() =>
      _GovernanceAddFormScreenState();
}

class _GovernanceAddFormScreenState extends State<GovernanceAddFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _classController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  late String _status;
  bool _isSaving = false;

  bool get _isStudent => widget.kind == GovernanceAddKind.student;
  GovernanceStudentModel? get _existingStudent =>
      widget.existingData is GovernanceStudentModel
      ? widget.existingData as GovernanceStudentModel
      : null;
  LecturerModel? get _existingLecturer => widget.existingData is LecturerModel
      ? widget.existingData as LecturerModel
      : null;
  bool get _isEdit => widget.existingData != null;

  List<String> get _statusOptions {
    return _isStudent
        ? ['Đang học', 'Bảo lưu', 'Đã tốt nghiệp']
        : ['Đang công tác', 'Nghỉ phép', 'Đã nghỉ việc'];
  }

  @override
  void initState() {
    super.initState();
    if (_isStudent) {
      final existing = _existingStudent;
      _codeController.text = existing?.studentCode ?? '';
      _nameController.text = existing?.fullName ?? '';
      _emailController.text = existing?.email ?? '';
      _classController.text = existing?.classCode ?? '';
      _status = existing?.status ?? 'Đang học';
    } else {
      final existing = _existingLecturer;
      _codeController.text = existing?.lecturerCode ?? '';
      _nameController.text = existing?.fullName ?? '';
      _emailController.text = existing?.email ?? '';
      _facultyController.text = existing?.faculty ?? '';
      _departmentController.text = existing?.department ?? '';
      _status = 'Đang công tác';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _classController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    try {
      await AdminApiService.instance.createUser({
        'tenDangNhap': code,
        'matKhau': '123456',
        'hoTen': name,
        'email': email,
        'soDienThoai': '',
        'maVaiTro': _isStudent ? 'SINHVIEN' : 'GIANGVIEN',
        'trangThai': true,
      });

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isStudent
                ? _text('Thêm sinh viên thành công.', 'Student added successfully.')
                : _text('Thêm giảng viên thành công.', 'Lecturer added successfully.'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isStudent
        ? (_isEdit
              ? _text('Chỉnh sửa sinh viên', 'Edit student')
              : _text('Thêm sinh viên', 'Add student'))
        : (_isEdit
              ? _text('Chỉnh sửa giảng viên', 'Edit lecturer')
              : _text('Thêm giảng viên', 'Add lecturer'));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _textField(
                      controller: _codeController,
                      label: _isStudent
                          ? _text('Mã sinh viên', 'Student ID')
                          : _text('Mã giảng viên', 'Lecturer ID'),
                      icon: Icons.badge_outlined,
                    ),
                    _textField(
                      controller: _nameController,
                      label: _text('Họ và tên', 'Full name'),
                      icon: Icons.person_outline,
                    ),
                    _textField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    if (_isStudent)
                      _textField(
                        controller: _classController,
                        label: _text('Lớp', 'Class'),
                        icon: Icons.school_outlined,
                      )
                    else ...[
                      _textField(
                        controller: _facultyController,
                        label: _text('Khoa', 'Faculty'),
                        icon: Icons.account_balance_outlined,
                      ),
                      _textField(
                        controller: _departmentController,
                        label: _text('Bộ môn', 'Department'),
                        icon: Icons.apartment_outlined,
                      ),
                    ],
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: InputDecoration(
                        labelText: _text('Trạng thái', 'Status'),
                        prefixIcon: const Icon(Icons.verified_outlined),
                      ),
                      items: _statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(AppLocalizations.status(status)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? _text(
                              'Vui lòng chọn trạng thái.',
                              'Select a status.',
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_text('Hủy', 'Cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _isEdit
                          ? _text('Cập nhật', 'Update')
                          : _text('Lưu', 'Save'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: '$label *',
        prefixIcon: Icon(icon),
      ),
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty
              ? _text('Vui lòng nhập $label.', 'Enter $label.')
              : null,
    ),
  );

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return _text('Vui lòng nhập Email.', 'Enter an email.');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return _text('Email không đúng định dạng.', 'Email format is invalid.');
    }
    return null;
  }

  String _text(String vi, String en) => AppLocalizations.text(vi, en: en);
}
