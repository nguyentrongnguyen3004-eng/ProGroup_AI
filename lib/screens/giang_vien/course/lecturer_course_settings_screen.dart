import 'package:flutter/material.dart';

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
    final current = widget.course;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cấu hình lớp học phần',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 80),
          children: [
            // Course Info Pill Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Color(0xFF4F46E5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.name,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${current.classCode} • ${current.semester}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Card 1: Deadlines
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.date_range_rounded,
                          size: 18,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Thời gian đăng ký',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DateField(
                    label: 'Bắt đầu lập nhóm',
                    value: _format(_groupStart),
                    iconColor: const Color(0xFF2563EB),
                    onTap: () => _chooseDate((v) => _groupStart = v, _groupStart),
                  ),
                  _DateField(
                    label: 'Kết thúc lập nhóm',
                    value: _format(_groupEnd),
                    iconColor: const Color(0xFF2563EB),
                    onTap: () => _chooseDate((v) => _groupEnd = v, _groupEnd),
                  ),
                  const SizedBox(height: 6),
                  _DateField(
                    label: 'Bắt đầu đăng ký đề tài',
                    value: _format(_topicStart),
                    iconColor: const Color(0xFF8B5CF6),
                    onTap: () => _chooseDate((v) => _topicStart = v, _topicStart),
                  ),
                  _DateField(
                    label: 'Kết thúc đăng ký đề tài',
                    value: _format(_topicEnd),
                    iconColor: const Color(0xFF8B5CF6),
                    onTap: () => _chooseDate((v) => _topicEnd = v, _topicEnd),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Card 2: Group Limits
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          size: 18,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Quy mô nhóm',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số thành viên tối thiểu',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF10B981)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed < 1) {
                        return 'Số thành viên tối thiểu phải từ 1.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số thành viên tối đa',
                      prefixIcon: const Icon(Icons.people_alt_rounded, color: Color(0xFFF59E0B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                ],
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: ElevatedButton.icon(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.check_circle_rounded, size: 20),
          label: const Text(
            'Lưu cấu hình',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final Color iconColor;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
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

String _format(DateTime value) {
  final d = value.day.toString().padLeft(2, '0');
  final m = value.month.toString().padLeft(2, '0');
  return '$d/$m/${value.year}';
}
