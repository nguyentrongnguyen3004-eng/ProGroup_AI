import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_lecturer_courses.dart';
import '../../../data/mock/mock_lecturer_topics.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import 'edit_topic_screen.dart';

class LecturerTopicDetailScreen extends StatefulWidget {
  final CourseModel? course;
  final TopicModel topic;

  const LecturerTopicDetailScreen({
    super.key,
    this.course,
    required this.topic,
  });

  @override
  State<LecturerTopicDetailScreen> createState() =>
      _LecturerTopicDetailScreenState();
}

class _LecturerTopicDetailScreenState extends State<LecturerTopicDetailScreen> {
  LecturerCourseModel? _courseForTopic(TopicModel topic) {
    for (final course in MockLecturerCourses.courses) {
      if (course.courseId == topic.courseId) return course;
    }
    return null;
  }

  Future<void> _editTopic(TopicModel topic) async {
    final result = await Navigator.push<TopicModel>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTopicScreen(course: widget.course, topic: topic),
      ),
    );

    if (result != null && mounted) {
      setState(() {});
    }
  }

  Future<void> _changeStatus(int topicId, String status) async {
    if (MockLecturerTopics.getById(topicId) == null) return;

    MockLecturerTopics.updateStatus(topicId, status);
    final updated = MockLecturerTopics.getById(topicId);
    if (updated == null) return;

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.text(
            'Đã cập nhật trạng thái đề tài.',
            en: 'Topic status updated.',
          ),
        ),
      ),
    );
  }

  List<String> _availableStatuses(TopicModel topic) {
    final statuses = MockLecturerTopics.topics
        .map((item) => item.status.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    if (!statuses.contains(topic.status)) statuses.add(topic.status);
    return statuses;
  }

  void _showStatusOptions(TopicModel topic) {
    final statuses = _availableStatuses(topic);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final status in statuses)
                ListTile(
                  leading: Icon(
                    _statusIcon(status),
                    color: _statusColor(context, status),
                  ),
                  title: Text(AppLocalizations.status(status)),
                  trailing: status == topic.status
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _changeStatus(topic.id, status);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(BuildContext context, String status) {
    final value = status.trim().toLowerCase();
    if (value.contains('chờ') || value.contains('pending')) {
      return AppTheme.warningColor;
    }
    if (value.contains('khóa') ||
        value.contains('từ chối') ||
        value.contains('locked') ||
        value.contains('rejected')) {
      return AppTheme.dangerColor;
    }
    if (value.contains('hoạt động') ||
        value.contains('active') ||
        value.contains('approved')) {
      return AppTheme.successColor;
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _statusIcon(String status) {
    final value = status.toLowerCase();
    if (value.contains('chờ') || value.contains('pending')) {
      return Icons.hourglass_empty;
    }
    if (value.contains('khóa') || value.contains('locked')) {
      return Icons.lock_outline;
    }
    if (value.contains('từ chối') || value.contains('rejected')) {
      return Icons.cancel_outlined;
    }
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final topic = MockLecturerTopics.getById(widget.topic.id);
    final colors = Theme.of(context).colorScheme;

    if (topic == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.text('Chi tiết đề tài', en: 'Topic details'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.text(
                'Đề tài không còn tồn tại.',
                en: 'This topic is no longer available.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    final course = _courseForTopic(topic);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết đề tài', en: 'Topic details'),
        ),
        actions: [
          IconButton(
            onPressed: () => _editTopic(topic),
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppLocalizations.text('Chỉnh sửa', en: 'Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TopicHeader(
            topic: topic,
            statusColor: _statusColor(context, topic.status),
          ),
          const SizedBox(height: 16),
          _TopicSection(
            title: AppLocalizations.text('Lớp học phần', en: 'Course'),
            icon: Icons.school_outlined,
            child: course == null
                ? Text(
                    AppLocalizations.text(
                      'Không tìm thấy lớp học phần được phân công.',
                      en: 'The assigned course could not be found.',
                    ),
                    style: TextStyle(color: colors.onSurfaceVariant),
                  )
                : Text(
                    '${course.name}\n${course.code} • ${course.classCode} • ${course.semester}',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _TopicSection(
            title: AppLocalizations.text('Mô tả', en: 'Description'),
            icon: Icons.description_outlined,
            child: _TopicText(topic.description, emptyLabel: 'Chưa có mô tả.'),
          ),
          const SizedBox(height: 16),
          _TopicSection(
            title: AppLocalizations.text('Mục tiêu', en: 'Objective'),
            icon: Icons.flag_outlined,
            child: _TopicText(topic.objective, emptyLabel: 'Chưa có mục tiêu.'),
          ),
          const SizedBox(height: 16),
          _TopicSection(
            title: AppLocalizations.text('Phạm vi', en: 'Scope'),
            icon: Icons.crop_free_outlined,
            child: _TopicText(topic.scope, emptyLabel: 'Chưa có phạm vi.'),
          ),
          const SizedBox(height: 16),
          _TopicSection(
            title: AppLocalizations.text('Công nghệ', en: 'Technology'),
            icon: Icons.code_outlined,
            child: _TopicText(
              topic.technology,
              emptyLabel: 'Chưa khai báo công nghệ.',
            ),
          ),
          const SizedBox(height: 16),
          _TopicSection(
            title: AppLocalizations.text('Nguồn đề tài', en: 'Source'),
            icon: Icons.source_outlined,
            child: Text(
              topic.source.trim().isEmpty
                  ? AppLocalizations.text('Chưa có nguồn.', en: 'No source.')
                  : AppLocalizations.source(topic.source),
            ),
          ),
          const SizedBox(height: 16),
          _TopicSection(
            title: AppLocalizations.text('Trạng thái', en: 'Status'),
            icon: Icons.sync_outlined,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.status(topic.status),
                    style: TextStyle(
                      color: _statusColor(context, topic.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showStatusOptions(topic),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(AppLocalizations.text('Thay đổi', en: 'Change')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicHeader extends StatelessWidget {
  final TopicModel topic;
  final Color statusColor;

  const _TopicHeader({required this.topic, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderTag(
                text: AppLocalizations.status(topic.status),
                accentColor: statusColor,
              ),
              if (topic.technology.trim().isNotEmpty)
                _HeaderTag(text: topic.technology),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  final String text;
  final Color? accentColor;

  const _HeaderTag({required this.text, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: accentColor == null
            ? null
            : Border.all(color: accentColor!, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TopicSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _TopicSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _TopicText extends StatelessWidget {
  final String value;
  final String emptyLabel;

  const _TopicText(this.value, {required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    return Text(
      value.trim().isEmpty
          ? AppLocalizations.text(emptyLabel, en: emptyLabel)
          : value,
      style: const TextStyle(height: 1.5),
    );
  }
}
