import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_notifications.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';

class AddTopicScreen extends StatefulWidget {
  final CourseModel? course;
  final int? lecturerCourseId;
  final Map<String, String>? initialValues;

  const AddTopicScreen({
    super.key,
    this.course,
    this.lecturerCourseId,
    this.initialValues,
  });

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _scopeController = TextEditingController();
  final _technologyController = TextEditingController();
  final _sourceController = TextEditingController(text: 'Giảng viên');

  int? _selectedCourseId;
  late String _status;

  List<LecturerCourseModel> get _availableCourses {
    final assignedCourses = MockLecturerCourses.courses;
    if (widget.lecturerCourseId != null) {
      return assignedCourses
          .where((course) => course.courseId == widget.lecturerCourseId)
          .toList();
    }
    if (widget.course == null) return assignedCourses;

    return assignedCourses
        .where((course) => course.courseId == widget.course!.id)
        .toList();
  }

  List<String> _availableStatuses() {
    final values = MockLecturerTopics.topics
        .map((topic) => topic.status.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    if (values.isEmpty) values.add('Đang hoạt động');
    return values;
  }

  List<String> get _statusOptions {
    final values = _availableStatuses();
    if (!values.contains(_status)) values.insert(0, _status);
    return values;
  }

  @override
  void initState() {
    super.initState();
    final values = widget.initialValues;
    _titleController.text = values?['title'] ?? '';
    _descriptionController.text = values?['description'] ?? '';
    _objectiveController.text = values?['objective'] ?? '';
    _scopeController.text = values?['scope'] ?? '';
    _technologyController.text = values?['technology'] ?? '';
    _sourceController.text = values?['source'] ?? 'Giảng viên';

    final courses = _availableCourses;
    final requestedCourseId = widget.lecturerCourseId ?? widget.course?.id;

    if (requestedCourseId != null &&
        courses.any((course) => course.courseId == requestedCourseId)) {
      _selectedCourseId = requestedCourseId;
    } else if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.courseId;
    }

    final statuses = _availableStatuses();
    _status = statuses.contains('Đang hoạt động')
        ? 'Đang hoạt động'
        : statuses.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectiveController.dispose();
    _scopeController.dispose();
    _technologyController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    LecturerCourseModel? selectedCourse;
    for (final course in _availableCourses) {
      if (course.courseId == _selectedCourseId) {
        selectedCourse = course;
        break;
      }
    }

    if (selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Hãy chọn lớp học phần được phân công.',
              en: 'Select an assigned course.',
            ),
          ),
        ),
      );
      return;
    }

    final nextId =
        MockLecturerTopics.topics.fold<int>(
          0,
          (maximum, topic) => topic.id > maximum ? topic.id : maximum,
        ) +
        1;

    final topic = TopicModel(
      id: nextId,
      courseId: selectedCourse.courseId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      objective: _objectiveController.text.trim(),
      scope: _scopeController.text.trim(),
      technology: _technologyController.text.trim(),
      source: _sourceController.text.trim(),
      status: _status,
    );

    MockLecturerTopics.add(topic);
    MockLecturerNotifications.instance.addNotification(
      type: 'Đề tài',
      icon: Icons.lightbulb_outline,
      title: 'Đã thêm đề tài',
      content:
          'Đề tài "' +
          topic.title +
          '" đã được thêm vào ' +
          selectedCourse.name +
          '.',
    );
    Navigator.pop(context, topic);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final courses = _availableCourses;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Thêm đề tài', en: 'Add topic')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (courses.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.text(
                      'Không có lớp học phần được phân công để tạo đề tài.',
                      en: 'No assigned course is available for a new topic.',
                    ),
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              )
            else
              DropdownButtonFormField<int>(
                initialValue: _selectedCourseId,
                decoration: InputDecoration(
                  labelText: AppLocalizations.text(
                    'Lớp học phần',
                    en: 'Course',
                  ),
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
                items: courses
                    .map(
                      (course) => DropdownMenuItem(
                        value: course.courseId,
                        child: Text(
                          '${course.name} • ${course.classCode}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged:
                    widget.course != null || widget.lecturerCourseId != null
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _selectedCourseId = value);
                      },
                validator: (value) => value == null
                    ? AppLocalizations.text(
                        'Hãy chọn lớp học phần.',
                        en: 'Select a course.',
                      )
                    : null,
              ),
            const SizedBox(height: 16),
            _Field(
              controller: _titleController,
              label: AppLocalizations.text('Tên đề tài', en: 'Topic title'),
              icon: Icons.title,
            ),
            _Field(
              controller: _descriptionController,
              label: AppLocalizations.text('Mô tả', en: 'Description'),
              icon: Icons.description_outlined,
              maxLines: 4,
            ),
            _Field(
              controller: _objectiveController,
              label: AppLocalizations.text('Mục tiêu', en: 'Objective'),
              icon: Icons.flag_outlined,
              maxLines: 3,
            ),
            _Field(
              controller: _scopeController,
              label: AppLocalizations.text('Phạm vi', en: 'Scope'),
              icon: Icons.crop_free_outlined,
              maxLines: 3,
            ),
            _Field(
              controller: _technologyController,
              label: AppLocalizations.text('Công nghệ', en: 'Technology'),
              icon: Icons.code_outlined,
            ),
            _Field(
              controller: _sourceController,
              label: AppLocalizations.text('Nguồn đề tài', en: 'Source'),
              icon: Icons.source_outlined,
            ),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(
                labelText: AppLocalizations.text('Trạng thái', en: 'Status'),
                prefixIcon: const Icon(Icons.sync_outlined),
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
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: courses.isEmpty ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                AppLocalizations.text('Tạo đề tài', en: 'Create topic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppLocalizations.text(
              'Vui lòng nhập $label.',
              en: 'Please enter $label.',
            );
          }
          return null;
        },
      ),
    );
  }
}
