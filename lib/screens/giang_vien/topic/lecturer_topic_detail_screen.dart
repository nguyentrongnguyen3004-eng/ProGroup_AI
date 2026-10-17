import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
<<<<<<< HEAD
import '../../../core/theme/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../models/lecturer_course_model.dart';
=======
>>>>>>> origin/Frontend
import '../../../models/topic_model.dart';
import '../../../services/lecturer_api_service.dart';
import 'edit_topic_screen.dart';

class LecturerTopicDetailScreen extends StatefulWidget {
  final TopicModel topic;

  const LecturerTopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  State<LecturerTopicDetailScreen> createState() => _LecturerTopicDetailScreenState();
}

class _LecturerTopicDetailScreenState extends State<LecturerTopicDetailScreen> {
<<<<<<< HEAD
  late TopicModel _currentTopic;

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
  }

  LecturerCourseModel? _courseForTopic(TopicModel topic) {
    for (final course in LecturerApiService.instance.cachedCourses) {
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
      setState(() {
        _currentTopic = result;
      });
    }
  }

  Future<void> _changeStatus(int topicId, String status) async {
    try {
      await LecturerApiService.instance.updateTopic(
        topicId,
        tenDeTai: _currentTopic.title,
        moTa: _currentTopic.description,
        mucTieu: _currentTopic.objective,
        phamVi: _currentTopic.scope,
        congNghe: _currentTopic.technology,
      );
      if (mounted) {
        setState(() {
          _currentTopic = _currentTopic.copyWith(status: status);
        });
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
    } catch (_) {}
  }

  List<String> _availableStatuses(TopicModel topic) {
    final statuses = ['Đang hoạt động', 'Chờ duyệt', 'Tạm khóa'];
    if (!statuses.contains(topic.status)) statuses.add(topic.status);
    return statuses;
  }

  void _showStatusOptions(TopicModel topic) {
    final statuses = _availableStatuses(topic);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.text(
                        'Cập nhật trạng thái',
                        en: 'Update status',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                for (final status in statuses)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _statusColor(context, status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _statusIcon(status),
                        color: _statusColor(context, status),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      AppLocalizations.status(status),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: status == topic.status
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: _statusColor(context, status),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _changeStatus(topic.id, status);
                    },
                  ),
              ],
            ),
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
        value.contains('approved') ||
        value.contains('đã duyệt')) {
      return AppTheme.successColor;
    }
    return const Color(0xFF2563EB);
  }

  IconData _statusIcon(String status) {
    final value = status.toLowerCase();
    if (value.contains('chờ') || value.contains('pending')) {
      return Icons.hourglass_top_rounded;
    }
    if (value.contains('khóa') || value.contains('locked')) {
      return Icons.lock_rounded;
    }
    if (value.contains('từ chối') || value.contains('rejected')) {
      return Icons.cancel_rounded;
    }
    return Icons.check_circle_rounded;
=======
  late TopicModel _topic;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
>>>>>>> origin/Frontend
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final topic = _currentTopic;
    final colors = Theme.of(context).colorScheme;

    final course = _courseForTopic(topic);
    final statusColor = _statusColor(context, topic.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Chi tiết đề tài', en: 'Topic details'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _editTopic(topic),
            icon: const Icon(Icons.edit_rounded),
            tooltip: AppLocalizations.text('Chỉnh sửa', en: 'Edit'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          children: [
            // Top Hero Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A5F),
                    Color(0xFF2563EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFFFBBF24),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.topicText(topic.title),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (course != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${course.code} • ${course.classCode}',
                                  style: const TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _statusIcon(topic.status),
                              color: statusColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.status(topic.status),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Source Badge
                      if (topic.source.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF818CF8),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.source_rounded,
                                color: Color(0xFFA5B4FC),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.source(topic.source),
                                style: const TextStyle(
                                  color: Color(0xFFE0E7FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Course Info Card
            _TopicSection(
              title: AppLocalizations.text('Lớp học phần phụ trách', en: 'Assigned Course Class'),
              icon: Icons.school_rounded,
              iconColor: const Color(0xFF6366F1),
              child: course == null
                  ? Text(
                      AppLocalizations.text(
                        'Không tìm thấy lớp học phần được phân công.',
                        en: 'The assigned course could not be found.',
                      ),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.courseName(course.name),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${course.code} • ${course.classCode} • ${course.semester}',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 12),

            // Description Card
            _TopicSection(
              title: AppLocalizations.text('Mô tả chi tiết', en: 'Detailed Description'),
              icon: Icons.description_rounded,
              iconColor: const Color(0xFF0284C7),
              child: _TopicText(
                topic.description,
                emptyLabel: AppLocalizations.text(
                  'Chưa có mô tả chi tiết cho đề tài này.',
                  en: 'No detailed description for this topic.',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Objective Card
            _TopicSection(
              title: AppLocalizations.text('Mục tiêu đề tài', en: 'Topic Objectives'),
              icon: Icons.track_changes_rounded,
              iconColor: const Color(0xFF10B981),
              child: _TopicText(
                topic.objective,
                emptyLabel: AppLocalizations.text(
                  'Chưa có mục tiêu cụ thể.',
                  en: 'No specific objectives specified.',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Scope Card
            _TopicSection(
              title: AppLocalizations.text('Phạm vi thực hiện', en: 'Project Scope'),
              icon: Icons.crop_free_rounded,
              iconColor: const Color(0xFF8B5CF6),
              child: _TopicText(
                topic.scope,
                emptyLabel: AppLocalizations.text(
                  'Chưa có phạm vi thực hiện.',
                  en: 'No scope specified.',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Technology Card
            _TopicSection(
              title: AppLocalizations.text('Công nghệ sử dụng', en: 'Technologies'),
              icon: Icons.code_rounded,
              iconColor: const Color(0xFFF59E0B),
              child: topic.technology.trim().isEmpty
                  ? Text(
                      AppLocalizations.text(
                        'Chưa khai báo công nghệ.',
                        en: 'No technology specified.',
                      ),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: topic.technology
                          .split(RegExp(r'[,;]|\n'))
                          .map((tech) => tech.trim())
                          .where((tech) => tech.isNotEmpty)
                          .map(
                            (tech) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                tech,
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),

            const SizedBox(height: 12),

            // Status Management Card
            _TopicSection(
              title: AppLocalizations.text('Trạng thái hiện tại', en: 'Current Status'),
              icon: Icons.sync_rounded,
              iconColor: statusColor,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.status(topic.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showStatusOptions(topic),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: Text(AppLocalizations.text('Thay đổi', en: 'Change')),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
=======
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.text('Chi Tiết Đề Tài', en: 'Topic Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTopicScreen(topic: _topic),
                ),
              );
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colors),
            const SizedBox(height: 24),
            _buildInfoCard(colors),
            const SizedBox(height: 24),
            _buildStatusCard(colors),
>>>>>>> origin/Frontend
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
class _TopicSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _TopicSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
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
          const SizedBox(height: 12),
          child,
        ],
=======
  Widget _buildHeader(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _topic.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_topic.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(_topic.status),
                ),
              ),
              child: Text(
                _topic.status,
                style: TextStyle(
                  color: _getStatusColor(_topic.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Mã ĐT: ${_topic.id}',
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ColorScheme colors) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              AppLocalizations.text('Mô tả', en: 'Description'),
              _topic.description,
              Icons.description,
              colors,
            ),
            const Divider(height: 32),
            _buildInfoSection(
              AppLocalizations.text('Mục tiêu', en: 'Objectives'),
              _topic.objective,
              Icons.track_changes,
              colors,
            ),
            const Divider(height: 32),
            _buildInfoSection(
              AppLocalizations.text('Phạm vi', en: 'Scope'),
              _topic.scope,
              Icons.center_focus_strong,
              colors,
            ),
            const Divider(height: 32),
            _buildInfoSection(
              AppLocalizations.text('Công nghệ dự kiến', en: 'Expected Technologies'),
              _topic.technology,
              Icons.computer,
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(ColorScheme colors) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: colors.secondary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.text('Thông tin bổ sung', en: 'Additional Information'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              AppLocalizations.text('Nguồn đề tài', en: 'Source'),
              _topic.source,
              colors,
            ),
          ],
        ),
>>>>>>> origin/Frontend
      ),
    );
  }

<<<<<<< HEAD
class _TopicText extends StatelessWidget {
  final String value;
  final String emptyLabel;

  const _TopicText(this.value, {required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isBlank = value.trim().isEmpty;
    return Text(
      isBlank ? emptyLabel : AppLocalizations.topicText(value),
      style: TextStyle(
        color: isBlank ? colors.onSurfaceVariant : colors.onSurface,
        fontSize: 14,
        height: 1.5,
      ),
=======
  Widget _buildDetailRow(String label, String value, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
>>>>>>> origin/Frontend
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
      case 'Đã đăng ký':
        return Colors.green;
      case 'Chờ duyệt':
        return Colors.orange;
      case 'Chưa sử dụng':
        return Colors.blue;
      case 'Từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
