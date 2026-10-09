import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';

class EditTopicScreen extends StatefulWidget {
  final CourseModel? course;
  final TopicModel topic;

  const EditTopicScreen({super.key, this.course, required this.topic});

  @override
  State<EditTopicScreen> createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _scopeController;
  late final TextEditingController _technologyController;
  late final TextEditingController _sourceController;
  late String _status;

  List<String> _availableStatuses() {
    final values = MockLecturerTopics.topics
        .map((topic) => topic.status.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    if (values.isEmpty) values.add(widget.topic.status);
    if (!values.contains(widget.topic.status)) values.add(widget.topic.status);
    return values;
  }

  LecturerCourseModel? _courseForTopic() {
    for (final course in MockLecturerCourses.courses) {
      if (course.courseId == widget.topic.courseId) return course;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _descriptionController = TextEditingController(
      text: widget.topic.description,
    );
    _objectiveController = TextEditingController(text: widget.topic.objective);
    _scopeController = TextEditingController(text: widget.topic.scope);
    _technologyController = TextEditingController(
      text: widget.topic.technology,
    );
    _sourceController = TextEditingController(text: widget.topic.source);
    _status = widget.topic.status;
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

    if (MockLecturerTopics.getById(widget.topic.id) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Đề tài không còn tồn tại.',
              en: 'This topic is no longer available.',
            ),
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    final updatedTopic = TopicModel(
      id: widget.topic.id,
      courseId: widget.topic.courseId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      objective: _objectiveController.text.trim(),
      scope: _scopeController.text.trim(),
      technology: _technologyController.text.trim(),
      source: _sourceController.text.trim(),
      status: _status,
    );

    MockLecturerTopics.update(updatedTopic);
    final savedTopic = MockLecturerTopics.getById(updatedTopic.id);
    if (savedTopic == null) return;

    Navigator.pop(context, savedTopic);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final course = _courseForTopic();
    final statuses = _availableStatuses();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chỉnh sửa đề tài', en: 'Edit topic'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.school_outlined, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        course == null
                            ? AppLocalizations.text(
                                'Không tìm thấy lớp học phần được phân công.',
                                en: 'The assigned course could not be found.',
                              )
                            : '${course.name}\n${course.code} • ${course.classCode}',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              items: statuses
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
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                AppLocalizations.text('Lưu thay đổi', en: 'Save changes'),
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
