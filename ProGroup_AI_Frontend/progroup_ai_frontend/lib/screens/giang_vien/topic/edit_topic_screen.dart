import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/lecturer_api_service.dart';

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

  bool get _isAssigned =>
      widget.topic.status.trim().toLowerCase() == 'đã đăng ký' ||
      widget.topic.status.trim().toLowerCase().contains('nhóm');

  List<String> _availableStatuses() {
    final values = ['Đang hoạt động', 'Chưa sử dụng', 'Tạm khóa'];
    if (!values.contains(widget.topic.status)) values.add(widget.topic.status);
    return values;
  }

  LecturerCourseModel? _courseForTopic() {
    for (final course in LecturerApiService.instance.cachedCourses) {
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isAssigned ? const Color(0xFFFEF2F2) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isAssigned ? const Color(0xFFFECACA) : const Color(0xFFC7D2FE),
                ),
              ),
              child: Icon(
                _isAssigned ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
                color: _isAssigned ? const Color(0xFFDC2626) : const Color(0xFF4F46E5),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isAssigned
                    ? AppLocalizations.text('Cảnh báo xác nhận', en: 'Confirmation Warning')
                    : AppLocalizations.text('Xác nhận lưu thay đổi', en: 'Confirm Changes'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isAssigned) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  AppLocalizations.text(
                    'Đề tài này đã có nhóm sinh viên đăng ký được duyệt chính thức. Tên đề tài đã được khóa để đảm bảo tính nhất quán của hội đồng. Các thông tin nội dung khác sau khi sửa sẽ được cập nhật trực tiếp tới nhóm sinh viên.',
                    en: 'This topic has been officially assigned to a student group. The topic title is locked. Any content updates will directly affect the student group.',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              _isAssigned
                  ? AppLocalizations.text(
                      'Bạn có chắc chắn muốn lưu các cập nhật cho đề tài này không?',
                      en: 'Are you sure you want to save the updates for this topic?',
                    )
                  : AppLocalizations.text(
                      'Bạn có chắc chắn muốn cập nhật thông tin cho đề tài này không?',
                      en: 'Are you sure you want to save the changes for this topic?',
                    ),
              style: const TextStyle(fontSize: 14.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(AppLocalizations.text('Hủy bỏ', en: 'Cancel')),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: _isAssigned ? const Color(0xFFDC2626) : const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(
              _isAssigned
                  ? AppLocalizations.text('Xác nhận lưu', en: 'Confirm & Save')
                  : AppLocalizations.text('Xác nhận', en: 'Confirm'),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await LecturerApiService.instance.updateTopic(
        widget.topic.id,
        tenDeTai: _titleController.text.trim(),
        moTa: _descriptionController.text.trim(),
        mucTieu: _objectiveController.text.trim(),
        phamVi: _scopeController.text.trim(),
        congNghe: _technologyController.text.trim(),
        status: _status,
      );

      final updatedTopic = widget.topic.copyWith(
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
            content: Text(
              AppLocalizations.text(
                'Đã cập nhật đề tài thành công.',
                en: 'Topic updated successfully.',
              ),
            ),
          ),
        );
        Navigator.pop(context, updatedTopic);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật đề tài: $e')),
        );
      }
    }
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.save_rounded, size: 20),
          label: Text(
            AppLocalizations.text('Lưu thay đổi', en: 'Save changes'),
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
              if (_isAssigned)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cảnh báo: Đề tài này đã có nhóm sinh viên đăng ký được duyệt chính thức. Tên đề tài đã được khóa để đảm bảo tính nhất quán của hội đồng/đồ án.',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Card 1: Course Info & Title
              _FormCard(
                title: AppLocalizations.text('Học phần & Tên đề tài', en: 'Course & Title'),
                icon: Icons.school_rounded,
                iconColor: const Color(0xFF6366F1),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
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
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _titleController,
                    label: AppLocalizations.text('Tên đề tài', en: 'Topic title'),
                    icon: Icons.title_rounded,
                    readOnly: _isAssigned,
                    helperText: _isAssigned
                        ? 'Tên đề tài đã khóa do đã có nhóm được duyệt chính thức'
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Card 2: Details & Scope
              _FormCard(
                title: AppLocalizations.text('Nội dung & Mục tiêu', en: 'Content & Scope'),
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
                title: AppLocalizations.text('Công nghệ & Quản lý', en: 'Tech & Management'),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.text('Trạng thái', en: 'Status'),
                      prefixIcon: const Icon(Icons.sync_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
  final bool readOnly;
  final String? helperText;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.readOnly = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          helperText: helperText,
          helperMaxLines: 2,
          alignLabelWithHint: maxLines > 1,
          filled: readOnly,
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
