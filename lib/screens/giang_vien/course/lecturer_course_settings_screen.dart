import 'package:flutter/material.dart';

import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_notifications.dart';
import '../../../models/lecturer_course_model.dart';

class LecturerCourseSettingsScreen extends StatefulWidget {
  final LecturerCourseModel course;

  const LecturerCourseSettingsScreen({super.key, required this.course});

  @override
  State<LecturerCourseSettingsScreen> createState() =>
      _LecturerCourseSettingsScreenState();
}

class _LecturerCourseSettingsScreenState
    extends State<LecturerCourseSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late DateTime _groupStart;
  late DateTime _groupEnd;
  late DateTime _topicStart;
  late DateTime _topicEnd;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.course.minMembers.toString(),
    );
    _maxController = TextEditingController(
      text: widget.course.maxMembers.toString(),
    );
    _groupStart = _parse(widget.course.groupRegistrationStart);
    _groupEnd = _parse(widget.course.groupRegistrationEnd);
    _topicStart = _parse(widget.course.topicRegistrationStart);
    _topicEnd = _parse(widget.course.topicRegistrationEnd);
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime current) => showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  Future<void> _chooseDate(
    ValueChanged<DateTime> save,
    DateTime current,
  ) async {
    final selected = await _pickDate(current);
    if (selected != null && mounted) setState(() => save(selected));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (!_groupStart.isBefore(_groupEnd)) {
      _message('Ngày bắt đầu lập nhóm phải trước ngày kết thúc.');
      return;
    }
    if (!_topicStart.isBefore(_topicEnd)) {
      _message('Ngày bắt đầu đăng ký đề tài phải trước ngày kết thúc.');
      return;
    }
    final updated = widget.course.copyWith(
      groupRegistrationStart: _format(_groupStart),
      groupRegistrationEnd: _format(_groupEnd),
      topicRegistrationStart: _format(_topicStart),
      topicRegistrationEnd: _format(_topicEnd),
      minMembers: int.parse(_minController.text.trim()),
      maxMembers: int.parse(_maxController.text.trim()),
    );
    MockLecturerCourses.update(updated);
    MockLecturerNotifications.instance.addNotification(
      type: 'Cấu hình',
      icon: Icons.settings_outlined,
      title: 'Đã cập nhật cấu hình học phần',
      content:
          'Lịch đăng ký và quy mô nhóm của ' + updated.classCode + ' đã đổi.',
    );
    _message('Đã lưu cấu hình lớp học phần.');
    Navigator.of(context).pop(updated);
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final current =
        MockLecturerCourses.getByCourseId(widget.course.courseId) ??
        widget.course;
    return Scaffold(
      appBar: AppBar(title: const Text('Cấu hình lớp học phần')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(current.name),
                subtitle: Text(current.classCode + ' • ' + current.semester),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thời gian đăng ký',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _DateField(
              label: 'Bắt đầu lập nhóm',
              value: _format(_groupStart),
              onTap: () =>
                  _chooseDate((value) => _groupStart = value, _groupStart),
            ),
            _DateField(
              label: 'Kết thúc lập nhóm',
              value: _format(_groupEnd),
              onTap: () => _chooseDate((value) => _groupEnd = value, _groupEnd),
            ),
            _DateField(
              label: 'Bắt đầu đăng ký đề tài',
              value: _format(_topicStart),
              onTap: () =>
                  _chooseDate((value) => _topicStart = value, _topicStart),
            ),
            _DateField(
              label: 'Kết thúc đăng ký đề tài',
              value: _format(_topicEnd),
              onTap: () => _chooseDate((value) => _topicEnd = value, _topicEnd),
            ),
            const SizedBox(height: 12),
            Text('Quy mô nhóm', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số thành viên tối thiểu',
                prefixIcon: Icon(Icons.group_outlined),
              ),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed < 1) {
                  return 'Số thành viên tối thiểu phải từ 1.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số thành viên tối đa',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                final minimum = int.tryParse(_minController.text.trim());
                if (parsed == null || parsed < 1) {
                  return 'Số thành viên tối đa phải từ 1.';
                }
                if (minimum != null && parsed < minimum) {
                  return 'Số tối đa phải lớn hơn hoặc bằng số tối thiểu.';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Lưu cấu hình'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(value),
      ),
    ),
  );
}

DateTime _parse(String value) {
  final parts = value.split('/');
  if (parts.length == 3) {
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2].split(' ').first);
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }
  return DateTime.tryParse(value) ?? DateTime.now();
}

String _format(DateTime value) =>
    value.day.toString().padLeft(2, '0') +
    '/' +
    value.month.toString().padLeft(2, '0') +
    '/' +
    value.year.toString();
