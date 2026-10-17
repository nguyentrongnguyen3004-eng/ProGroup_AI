import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/lecturer_api_service.dart';

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
  List<LecturerCourseModel> _assignedCourses = [];

  List<LecturerCourseModel> get _availableCourses {
    if (widget.lecturerCourseId != null) {
      return _assignedCourses
          .where((course) => course.courseId == widget.lecturerCourseId)
          .toList();
    }
    if (widget.course == null) return _assignedCourses;

    return _assignedCourses
        .where((course) => course.courseId == widget.course!.id)
        .toList();
  }

  List<String> get _statusOptions => const [
    'Đang hoạt động',
    'Chờ duyệt',
    'Tạm khóa',
  ];

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

    _assignedCourses = LecturerApiService.instance.cachedCourses;
    final requestedCourseId = widget.lecturerCourseId ?? widget.course?.id;

    if (requestedCourseId != null &&
        _assignedCourses.any((course) => course.courseId == requestedCourseId)) {
      _selectedCourseId = requestedCourseId;
    } else if (_assignedCourses.isNotEmpty) {
      _selectedCourseId = _assignedCourses.first.courseId;
    }

    _status = 'Đang hoạt động';

    if (_assignedCourses.isEmpty) {
      LecturerApiService.instance.fetchCourses().then((courses) {
        if (mounted) {
          setState(() {
            _assignedCourses = courses;
            if (_selectedCourseId == null && courses.isNotEmpty) {
              _selectedCourseId = courses.first.courseId;
            }
          });
        }
      });
    }
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

  Future<void> _save() async {
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

    try {
      await LecturerApiService.instance.createTopic(
        tenDeTai: _titleController.text.trim(),
        moTa: _descriptionController.text.trim(),
        mucTieu: _objectiveController.text.trim(),
        phamVi: _scopeController.text.trim(),
        congNghe: _technologyController.text.trim(),
        dotDangKyId: selectedCourse.courseId,
      );

      final topic = TopicModel(
        id: DateTime.now().millisecondsSinceEpoch,
        courseId: selectedCourse.courseId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        objective: _objectiveController.text.trim(),
        scope: _scopeController.text.trim(),
        technology: _technologyController.text.trim(),
        source: _sourceController.text.trim(),
        status: _status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo đề tài "${topic.title}" thành công.'),
          ),
        );
        Navigator.pop(context, topic);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo đề tài: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final courses = _availableCourses;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Thêm đề tài mới', en: 'Add new topic'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: courses.isEmpty ? null : _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.check_rounded, size: 20),
          label: Text(
            AppLocalizations.text('Tạo đề tài', en: 'Create topic'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // Card 1: Course & Title
              _FormCard(
                title: AppLocalizations.text('Thông tin học phần & Tiêu đề', en: 'Course & Title'),
                icon: Icons.school_rounded,
                iconColor: const Color(0xFF6366F1),
                children: [
                  if (courses.isEmpty)
                    Text(
                      AppLocalizations.text(
                        'Không có lớp học phần được phân công để tạo đề tài.',
                        en: 'No assigned course is available for a new topic.',
                      ),
                      style: TextStyle(color: colors.error),
                    )
                  else
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCourseId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.text(
                          'Lớp học phần',
                          en: 'Course class',
                        ),
                        prefixIcon: const Icon(Icons.school_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: courses
                          .map(
                            (course) => DropdownMenuItem<int>(
                              value: course.courseId,
                              child: Text(
                                '${course.name} • ${course.classCode}',
                                maxLines: 1,
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
                  const SizedBox(height: 14),
                  _Field(
                    controller: _titleController,
                    label: AppLocalizations.text('Tên đề tài', en: 'Topic title'),
                    icon: Icons.title_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Card 2: Details & Scope
              _FormCard(
                title: AppLocalizations.text('Nội dung & Phạm vi', en: 'Content & Scope'),
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF0284C7),
                children: [
                  _Field(
                    controller: _descriptionController,
                    label: AppLocalizations.text('Mô tả chi tiết', en: 'Description'),
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                  _Field(
                    controller: _objectiveController,
                    label: AppLocalizations.text('Mục tiêu cần đạt', en: 'Objectives'),
                    icon: Icons.track_changes_rounded,
                    maxLines: 3,
                  ),
                  _Field(
                    controller: _scopeController,
                    label: AppLocalizations.text('Phạm vi thực hiện', en: 'Scope'),
                    icon: Icons.crop_free_rounded,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Card 3: Tech & Metadata
              _FormCard(
                title: AppLocalizations.text('Công nghệ & Trạng thái', en: 'Tech & Status'),
                icon: Icons.settings_suggest_rounded,
                iconColor: const Color(0xFFF59E0B),
                children: [
                  _Field(
                    controller: _technologyController,
                    label: AppLocalizations.text('Công nghệ (phân cách bằng dấu phẩy)', en: 'Technologies (comma-separated)'),
                    icon: Icons.code_rounded,
                  ),
                  _Field(
                    controller: _sourceController,
                    label: AppLocalizations.text('Nguồn đề tài', en: 'Source'),
                    icon: Icons.source_rounded,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.text('Trạng thái', en: 'Status'),
                      prefixIcon: const Icon(Icons.sync_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _FormCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
