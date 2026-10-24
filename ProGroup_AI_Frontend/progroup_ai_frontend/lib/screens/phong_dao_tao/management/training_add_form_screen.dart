import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_training_data.dart';
import '../../../models/course_model.dart';
import '../../../models/governance_student_model.dart';
import '../../../models/lecturer_model.dart';
import '../../../models/training_subject_model.dart';
import 'training_data_management_screen.dart';

class TrainingAddFormScreen extends StatefulWidget {
  final TrainingDataKind kind;
  final Object? existingData;

  const TrainingAddFormScreen({
    super.key,
    required this.kind,
    this.existingData,
  });

  @override
  State<TrainingAddFormScreen> createState() => _TrainingAddFormScreenState();
}

class _TrainingAddFormScreenState extends State<TrainingAddFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _classController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  final _semesterController = TextEditingController();

  late String _status;
  String? _selectedSubjectCode;
  String _selectedLecturerCode = '';

  bool get _isStudent => widget.kind == TrainingDataKind.students;
  bool get _isLecturer => widget.kind == TrainingDataKind.lecturers;
  bool get _isCourseClass => widget.kind == TrainingDataKind.courseClasses;
  bool get _isSubject => widget.kind == TrainingDataKind.subjects;
  bool get _isEdit => widget.existingData != null;
  GovernanceStudentModel? get _existingStudent =>
      widget.existingData is GovernanceStudentModel
      ? widget.existingData as GovernanceStudentModel
      : null;
  LecturerModel? get _existingLecturer => widget.existingData is LecturerModel
      ? widget.existingData as LecturerModel
      : null;
  CourseModel? get _existingCourseClass => widget.existingData is CourseModel
      ? widget.existingData as CourseModel
      : null;
  TrainingSubjectModel? get _existingSubject =>
      widget.existingData is TrainingSubjectModel
      ? widget.existingData as TrainingSubjectModel
      : null;

  List<String> get _statusOptions {
    final data = MockTrainingData.instance;
    final Iterable<String> values = switch (widget.kind) {
      TrainingDataKind.students => data.students.map((item) => item.status),
      TrainingDataKind.lecturers => data.lecturerStatuses.values,
      TrainingDataKind.courseClasses => data.courseClasses.map(
        (item) => item.status,
      ),
      TrainingDataKind.subjects => data.subjects.map((item) => item.status),
    };
    final options = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final uniqueOptions = options.toSet().toList();
    if (uniqueOptions.isEmpty) uniqueOptions.add(_defaultStatus);
    if (!uniqueOptions.contains(_status)) uniqueOptions.insert(0, _status);
    return uniqueOptions;
  }

  String get _defaultStatus => switch (widget.kind) {
    TrainingDataKind.students => 'Đang học',
    TrainingDataKind.lecturers => 'Đang công tác',
    TrainingDataKind.courseClasses => 'Đang đăng ký',
    TrainingDataKind.subjects => 'Đang giảng dạy',
  };

  String _text(String vi, String en) => AppLocalizations.text(vi, en: en);

  @override
  void initState() {
    super.initState();
    final data = MockTrainingData.instance;
    final existingStatus = switch (widget.kind) {
      TrainingDataKind.students => _existingStudent?.status,
      TrainingDataKind.lecturers =>
        _existingLecturer == null
            ? null
            : data.lecturerStatus(_existingLecturer!),
      TrainingDataKind.courseClasses => _existingCourseClass?.status,
      TrainingDataKind.subjects => _existingSubject?.status,
    };
    _status = existingStatus ?? _initialStatus(data);
    if (_isStudent && _existingStudent != null) {
      _codeController.text = _existingStudent!.studentCode;
      _nameController.text = _existingStudent!.fullName;
      _emailController.text = _existingStudent!.email;
      _classController.text = _existingStudent!.classCode;
    } else if (_isLecturer && _existingLecturer != null) {
      _codeController.text = _existingLecturer!.lecturerCode;
      _nameController.text = _existingLecturer!.fullName;
      _emailController.text = _existingLecturer!.email;
      _facultyController.text = _existingLecturer!.faculty;
      _departmentController.text = _existingLecturer!.department;
    } else if (_isSubject && _existingSubject != null) {
      _codeController.text = _existingSubject!.code;
      _nameController.text = _existingSubject!.name;
      _creditsController.text = '${_existingSubject!.credits}';
      _departmentController.text = _existingSubject!.department;
    } else if (_isCourseClass) {
      final existing = _existingCourseClass;
      if (existing != null) {
        _codeController.text = existing.classCode;
        _selectedSubjectCode = existing.code;
        _semesterController.text = existing.semester;
        final assignedLecturers = data.lecturers
            .where((item) => item.fullName == existing.lecturer)
            .toList();
        _selectedLecturerCode = assignedLecturers.isEmpty
            ? ''
            : assignedLecturers.first.lecturerCode;
      } else {
        if (data.subjects.isNotEmpty) {
          _selectedSubjectCode = data.subjects.first.code;
        }
        final semesters = data.courseClasses
            .map((item) => item.semester.trim())
            .where((value) => value.isNotEmpty);
        if (semesters.isNotEmpty) _semesterController.text = semesters.first;
      }
    }
  }

  String _initialStatus(MockTrainingData data) {
    final statuses = switch (widget.kind) {
      TrainingDataKind.students => data.students.map((item) => item.status),
      TrainingDataKind.lecturers => data.lecturerStatuses.values,
      TrainingDataKind.courseClasses => data.courseClasses.map(
        (item) => item.status,
      ),
      TrainingDataKind.subjects => data.subjects.map((item) => item.status),
    };
    return statuses.isEmpty ? _defaultStatus : statuses.first;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _classController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    _creditsController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final data = MockTrainingData.instance;
    final code = _codeController.text.trim();
    final duplicateMessage = _duplicateMessage(data, code);
    if (duplicateMessage != null) {
      _showMessage(duplicateMessage, error: true);
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
    } else if (_isLecturer) {
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
    } else if (_isSubject) {
      final existing = _existingSubject;
      final subject = TrainingSubjectModel(
        code: code,
        name: _nameController.text.trim(),
        credits: int.parse(_creditsController.text.trim()),
        department: _departmentController.text.trim(),
        status: _status,
      );
      if (existing == null) {
        data.addSubjects([subject]);
      } else {
        data.updateSubject(existing.code, subject);
      }
    } else {
      final subjectIndex = data.subjects.indexWhere(
        (item) => item.code == _selectedSubjectCode,
      );
      if (subjectIndex < 0) {
        _showMessage(
          _text(
            'Hãy chọn học phần đang tồn tại.',
            'Select an available course.',
          ),
          error: true,
        );
        return;
      }
      final subject = data.subjects[subjectIndex];
      final lecturer = data.lecturers.where(
        (item) => item.lecturerCode == _selectedLecturerCode,
      );
      final existing = _existingCourseClass;
      final courseClass = CourseModel(
        id: existing?.id ?? data.nextCourseClassId,
        code: subject.code,
        name: subject.name,
        classCode: code,
        semester: _semesterController.text.trim(),
        lecturer: lecturer.isEmpty ? '' : lecturer.first.fullName,
        status: _status,
      );
      if (existing == null) {
        data.addCourseClasses([courseClass]);
      } else {
        data.updateCourseClass(courseClass);
      }
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(_successMessage)));
  }

  String? _duplicateMessage(MockTrainingData data, String code) {
    final normalized = code.toLowerCase();
    if (_isStudent &&
        data.students.any(
          (item) =>
              item.id != _existingStudent?.id &&
              item.studentCode.toLowerCase() == normalized,
        )) {
      return _text('Mã sinh viên đã tồn tại.', 'Student ID already exists.');
    }
    if (_isLecturer &&
        data.lecturers.any(
          (item) =>
              item.id != _existingLecturer?.id &&
              item.lecturerCode.toLowerCase() == normalized,
        )) {
      return _text('Mã giảng viên đã tồn tại.', 'Lecturer ID already exists.');
    }
    if (_isSubject &&
        data.subjects.any(
          (item) =>
              item.code != _existingSubject?.code &&
              item.code.toLowerCase() == normalized,
        )) {
      return _text('Mã học phần đã tồn tại.', 'Course code already exists.');
    }
    if (_isCourseClass &&
        data.courseClasses.any(
          (item) =>
              item.id != _existingCourseClass?.id &&
              item.classCode.toLowerCase() == normalized,
        )) {
      return _text(
        'Mã lớp học phần đã tồn tại.',
        'Course class code already exists.',
      );
    }
    final email = _emailController.text.trim().toLowerCase();
    if (_isStudent &&
        data.students.any(
          (item) =>
              item.id != _existingStudent?.id &&
              item.email.toLowerCase() == email,
        )) {
      return _text('Email đã tồn tại.', 'Email already exists.');
    }
    if (_isLecturer &&
        data.lecturers.any(
          (item) =>
              item.id != _existingLecturer?.id &&
              item.email.toLowerCase() == email,
        )) {
      return _text('Email đã tồn tại.', 'Email already exists.');
    }
    return null;
  }

  String get _title => switch (widget.kind) {
    TrainingDataKind.students =>
      _isEdit
          ? _text('Chỉnh sửa sinh viên', 'Edit student')
          : _text('Thêm sinh viên', 'Add student'),
    TrainingDataKind.lecturers =>
      _isEdit
          ? _text('Chỉnh sửa giảng viên', 'Edit lecturer')
          : _text('Thêm giảng viên', 'Add lecturer'),
    TrainingDataKind.courseClasses => _text(
      _isEdit ? 'Chỉnh sửa lớp học phần' : 'Thêm lớp học phần',
      _isEdit ? 'Edit course class' : 'Add course class',
    ),
    TrainingDataKind.subjects =>
      _isEdit
          ? _text('Chỉnh sửa học phần', 'Edit course')
          : _text('Thêm học phần', 'Add course'),
  };

  String get _successMessage => switch (widget.kind) {
    TrainingDataKind.students => _text(
      _isEdit ? 'Cập nhật sinh viên thành công.' : 'Thêm sinh viên thành công.',
      _isEdit ? 'Student updated successfully.' : 'Student added successfully.',
    ),
    TrainingDataKind.lecturers => _text(
      _isEdit
          ? 'Cập nhật giảng viên thành công.'
          : 'Thêm giảng viên thành công.',
      _isEdit
          ? 'Lecturer updated successfully.'
          : 'Lecturer added successfully.',
    ),
    TrainingDataKind.courseClasses => _text(
      _isEdit
          ? 'Cập nhật lớp học phần thành công.'
          : 'Thêm lớp học phần thành công.',
      _isEdit
          ? 'Course class updated successfully.'
          : 'Course class added successfully.',
    ),
    TrainingDataKind.subjects => _text(
      _isEdit ? 'Cập nhật học phần thành công.' : 'Thêm học phần thành công.',
      _isEdit ? 'Course updated successfully.' : 'Course added successfully.',
    ),
  };

  String get _codeLabel => switch (widget.kind) {
    TrainingDataKind.students => _text('Mã sinh viên', 'Student ID'),
    TrainingDataKind.lecturers => _text('Mã giảng viên', 'Lecturer ID'),
    TrainingDataKind.courseClasses => _text(
      'Mã lớp học phần',
      'Course class ID',
    ),
    TrainingDataKind.subjects => _text('Mã học phần', 'Course code'),
  };

  String? _validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return _text('Vui lòng nhập $_codeLabel.', 'Enter $_codeLabel.');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return _text('Vui lòng nhập Email.', 'Enter an email.');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return _text('Email không đúng định dạng.', 'Email format is invalid.');
    }
    return null;
  }

  String? _validateCredits(String? value) {
    final credits = int.tryParse(value?.trim() ?? '');
    if (credits == null || credits <= 0) {
      return _text('Số tín chỉ phải lớn hơn 0.', 'Enter positive credits.');
    }
    return null;
  }

  String? _validateSemester(String? value) {
    final semester = value?.trim() ?? '';
    if (semester.isEmpty) {
      return _text('Vui lòng nhập học kỳ.', 'Enter a semester.');
    }
    if (!RegExp(
      r'^HK\s*\d+\s*-\s*\d{4}$',
      caseSensitive: false,
    ).hasMatch(semester)) {
      return _text(
        'Học kỳ phải theo dạng HK7 - 2026.',
        'Use the semester format HK7 - 2026.',
      );
    }
    return null;
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
    final data = MockTrainingData.instance;
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
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
                    if (_isStudent) ...[
                      _textField(
                        controller: _codeController,
                        label: _codeLabel,
                        icon: Icons.badge_outlined,
                        validator: _validateCode,
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
                        controller: _classController,
                        label: _text('Lớp', 'Class'),
                        icon: Icons.school_outlined,
                      ),
                    ] else if (_isLecturer) ...[
                      _textField(
                        controller: _codeController,
                        label: _codeLabel,
                        icon: Icons.badge_outlined,
                        validator: _validateCode,
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
                        controller: _facultyController,
                        label: _text('Khoa', 'Faculty'),
                        icon: Icons.account_balance_outlined,
                      ),
                      _textField(
                        controller: _departmentController,
                        label: _text('Bộ môn', 'Department'),
                        icon: Icons.apartment_outlined,
                      ),
                    ] else if (_isSubject) ...[
                      _textField(
                        controller: _codeController,
                        label: _codeLabel,
                        icon: Icons.menu_book_outlined,
                        validator: _validateCode,
                      ),
                      _textField(
                        controller: _nameController,
                        label: _text('Tên học phần', 'Course name'),
                        icon: Icons.title,
                      ),
                      _textField(
                        controller: _creditsController,
                        label: _text('Số tín chỉ', 'Credits'),
                        icon: Icons.numbers_outlined,
                        keyboardType: TextInputType.number,
                        validator: _validateCredits,
                      ),
                      _textField(
                        controller: _departmentController,
                        label: _text('Bộ môn', 'Department'),
                        icon: Icons.apartment_outlined,
                      ),
                    ] else ...[
                      _textField(
                        controller: _codeController,
                        label: _codeLabel,
                        icon: Icons.class_outlined,
                        validator: _validateCode,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSubjectCode,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _text('Học phần', 'Course'),
                          prefixIcon: const Icon(Icons.menu_book_outlined),
                        ),
                        items: data.subjects
                            .map(
                              (subject) => DropdownMenuItem(
                                value: subject.code,
                                child: Text(
                                  '${subject.code} · ${subject.name}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedSubjectCode = value),
                        validator: (value) => value == null || value.isEmpty
                            ? _text('Hãy chọn học phần.', 'Select a course.')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _textField(
                        controller: _semesterController,
                        label: _text('Học kỳ', 'Semester'),
                        icon: Icons.calendar_month_outlined,
                        validator: _validateSemester,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLecturerCode,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _text(
                            'Giảng viên (không bắt buộc)',
                            'Lecturer (optional)',
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text(_text('Chưa phân công', 'Unassigned')),
                          ),
                          ...data.lecturers.map(
                            (lecturer) => DropdownMenuItem(
                              value: lecturer.lecturerCode,
                              child: Text(
                                '${lecturer.fullName} · ${lecturer.lecturerCode}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedLecturerCode = value ?? ''),
                      ),
                    ],
                    const SizedBox(height: 2),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      isExpanded: true,
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
                          ? _text('Hãy chọn trạng thái.', 'Select a status.')
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
                    label: Text(_text('Lưu', 'Save')),
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
}
