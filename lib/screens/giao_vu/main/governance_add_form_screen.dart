import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_governance_data.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';

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
    final data = MockGovernanceData.instance;
    final values = _isStudent
        ? data.students.map((item) => item.status)
        : data.lecturerStatuses.values;
    final options = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final selectedStatus = _status;
    options.removeWhere((value) => value.trim().isEmpty);
    final uniqueOptions = options.toSet().toList();
    if (selectedStatus.trim().isNotEmpty &&
        !uniqueOptions.contains(selectedStatus)) {
      uniqueOptions.insert(0, selectedStatus);
    }
    return uniqueOptions;
  }

  @override
  void initState() {
    super.initState();
    final data = MockGovernanceData.instance;
    if (_isStudent) {
      final existing = _existingStudent;
      _codeController.text = existing?.studentCode ?? '';
      _nameController.text = existing?.fullName ?? '';
      _emailController.text = existing?.email ?? '';
      _classController.text = existing?.classCode ?? '';
      _status =
          existing?.status ??
          (data.students.isEmpty ? 'Đang học' : data.students.first.status);
    } else {
      final existing = _existingLecturer;
      _codeController.text = existing?.lecturerCode ?? '';
      _nameController.text = existing?.fullName ?? '';
      _emailController.text = existing?.email ?? '';
      _facultyController.text =
          existing?.faculty ??
          (data.lecturers.isEmpty ? '' : data.lecturers.first.faculty);
      _departmentController.text = existing?.department ?? '';
      _status = existing != null
          ? data.lecturerStatus(existing)
          : (data.lecturers.isEmpty
                ? 'Đang công tác'
                : data.lecturerStatus(data.lecturers.first));
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = MockGovernanceData.instance;
    final code = _codeController.text.trim();
    final duplicate = _isStudent
        ? data.students.any(
            (student) =>
                student.id != _existingStudent?.id &&
                student.studentCode.toLowerCase() == code.toLowerCase(),
          )
        : data.lecturers.any(
            (lecturer) =>
                lecturer.id != _existingLecturer?.id &&
                lecturer.lecturerCode.toLowerCase() == code.toLowerCase(),
          );
    if (duplicate) {
      _showMessage(
        _isStudent
            ? _text('Mã sinh viên đã tồn tại.', 'Student ID already exists.')
            : _text('Mã giảng viên đã tồn tại.', 'Lecturer ID already exists.'),
        error: true,
      );
      return;
    }
    final email = _emailController.text.trim().toLowerCase();
    final duplicateEmail = _isStudent
        ? data.students.any(
            (student) =>
                student.id != _existingStudent?.id &&
                student.email.toLowerCase() == email,
          )
        : data.lecturers.any(
            (lecturer) =>
                lecturer.id != _existingLecturer?.id &&
                lecturer.email.toLowerCase() == email,
          );
    if (duplicateEmail) {
      _showMessage(
        _text('Email đã tồn tại.', 'Email already exists.'),
        error: true,
      );
      return;
    }

    if (_isStudent) {
      final existing = _existingStudent;
      final student = GovernanceStudentModel(
        id: existing?.id ?? data.nextStudentId,
        studentCode: code,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        classCode: _classController.text.trim(),
        status: _status,
      );
      if (existing == null) {
        data.addStudents([student]);
      } else {
        data.updateStudent(student);
      }
    } else {
      final existing = _existingLecturer;
      final lecturer = LecturerModel(
        id: existing?.id ?? data.nextLecturerId,
        lecturerCode: code,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        faculty: _facultyController.text.trim(),
        department: _departmentController.text.trim(),
        avatar: existing?.avatar ?? '',
      );
      if (existing == null) {
        data.addLecturers([lecturer], statuses: {code: _status});
      } else {
        data.updateLecturer(lecturer, status: _status);
      }
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    navigator.pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isStudent
              ? (_isEdit
                    ? _text(
                        'Cập nhật sinh viên thành công.',
                        'Student updated successfully.',
                      )
                    : _text(
                        'Thêm sinh viên thành công.',
                        'Student added successfully.',
                      ))
              : (_isEdit
                    ? _text(
                        'Cập nhật giảng viên thành công.',
                        'Lecturer updated successfully.',
                      )
                    : _text(
                        'Thêm giảng viên thành công.',
                        'Lecturer added successfully.',
                      )),
        ),
      ),
    );
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
