import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../services/governance_api_service.dart';

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
  final _phoneController = TextEditingController();
  final _classController = TextEditingController();
  final _facultyController = TextEditingController(text: 'CNTT');
  final _specializationController = TextEditingController();
  String _degree = 'ThS.';
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

  static const List<String> _degreeOptions = [
    'Cử nhân',
    'Kỹ sư',
    'ThS.',
    'TS.',
    'PGS.TS.',
    'GS.TS.',
  ];

  @override
  void initState() {
    super.initState();
    if (_isStudent) {
      final existing = _existingStudent;
      _codeController.text = existing?.studentCode ?? '';
      _nameController.text = existing?.fullName ?? '';
      _emailController.text = existing?.email ?? '';
      _phoneController.text = existing?.phone ?? '';
      _classController.text = existing?.classCode ?? '';
      _status = existing?.status ?? 'Đang học';
    } else {
      final existing = _existingLecturer;
      _codeController.text = existing?.lecturerCode ?? '';
      _nameController.text = existing?.fullName ?? '';
      _emailController.text = existing?.email ?? '';
      _phoneController.text = existing?.phoneNumber ?? '';
      _facultyController.text =
          (existing?.faculty.isNotEmpty == true) ? existing!.faculty : 'CNTT';
      _specializationController.text = existing?.chuyenMon ?? '';
      if (existing != null && _degreeOptions.contains(existing.hocVi)) {
        _degree = existing.hocVi;
      }
      _status = 'Đang công tác';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _classController.dispose();
    _facultyController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final faculty = _facultyController.text.trim();
    final classCode = _classController.text.trim();
    final spec = _specializationController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _isStudent
              ? _text('Xác nhận thêm sinh viên', 'Confirm add student')
              : _text('Xác nhận thêm giảng viên', 'Confirm add lecturer'),
        ),
        content: Text(
          '${_isStudent ? "MSSV" : "Mã GV"}: $code\n'
          'Họ tên: $name\n'
          'Email: $email'
          '${phone.isNotEmpty ? '\nSĐT: $phone' : ''}'
          '${!_isStudent && spec.isNotEmpty ? '\nHướng NC: $spec' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_text('Hủy', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_text('Xác nhận', 'Confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final active = _isStudent ? (_status == 'Đang học') : (_status == 'Đang công tác');
      if (_isStudent) {
        await GovernanceApiService.instance.createStudent({
          'mssv': code,
          'hoTen': name,
          'email': email,
          'soDienThoai': phone,
          'khoa': faculty,
          'maLopHocPhan': classCode,
          'trangThai': active,
        });
      } else {
        await GovernanceApiService.instance.createLecturer({
          'maGiangVien': code,
          'hoTen': name,
          'email': email,
          'soDienThoai': phone,
          'khoa': faculty,
          'hocVi': _degree,
          'chuyenMon': spec,
          'trangThai': active,
        });
      }

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
                    _textField(
                      controller: _phoneController,
                      label: _text('Số điện thoại', 'Phone number'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      required: false,
                      validator: _validatePhone,
                    ),
                    _textField(
                      controller: _facultyController,
                      label: _text('Khoa', 'Faculty'),
                      icon: Icons.account_balance_outlined,
                    ),
                    if (_isStudent)
                      _textField(
                        controller: _classController,
                        label: _text('Mã lớp học phần (nếu có)', 'Course Class Code (optional)'),
                        icon: Icons.school_outlined,
                        required: false,
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: DropdownButtonFormField<String>(
                          initialValue: _degree,
                          decoration: InputDecoration(
                            labelText: _text('Học vị', 'Degree'),
                            prefixIcon: const Icon(Icons.workspace_premium_outlined),
                          ),
                          items: _degreeOptions
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _degree = v);
                          },
                        ),
                      ),
                      _textField(
                        controller: _specializationController,
                        label: _text('Hướng nghiên cứu / Chuyên môn', 'Research Direction'),
                        icon: Icons.science_outlined,
                        required: false,
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
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
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
    bool required = true,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon),
      ),
      validator:
          validator ??
          (required
              ? (value) => value == null || value.trim().isEmpty
                    ? _text('Vui lòng nhập $label.', 'Enter $label.')
                    : null
              : null),
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

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(phone)) {
      return _text('Số điện thoại phải gồm 10-11 chữ số.', 'Phone must be 10-11 digits.');
    }
    return null;
  }

  String _text(String vi, String en) => AppLocalizations.text(vi, en: en);
}
