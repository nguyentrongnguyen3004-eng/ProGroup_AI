import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/topic_registration_model.dart';
import '../../../services/lecturer_api_service.dart';

class TopicRegistrationDetailScreen extends StatefulWidget {
  final TopicRegistrationModel registration;

  const TopicRegistrationDetailScreen({super.key, required this.registration});

  @override
  State<TopicRegistrationDetailScreen> createState() =>
      _TopicRegistrationDetailScreenState();
}

class _TopicRegistrationDetailScreenState
    extends State<TopicRegistrationDetailScreen> {
  late TopicRegistrationModel _current;
  bool _isLoading = true;
  bool _isUpdating = false;

  GroupModel? _group;
  TopicModel? _topic;
  LecturerCourseModel? _course;

  @override
  void initState() {
    super.initState();
    _current = widget.registration;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        LecturerApiService.instance.fetchGroups(),
        LecturerApiService.instance.fetchTopics(),
        LecturerApiService.instance.fetchCourses(),
      ]);

      final groups = results[0] as List<GroupModel>;
      final topics = results[1] as List<TopicModel>;
      final courses = results[2] as List<LecturerCourseModel>;

      GroupModel? grp;
      for (final g in groups) {
        if (g.id == _current.groupId) {
          grp = g;
          break;
        }
      }

      TopicModel? tpc;
      for (final t in topics) {
        if (t.id == _current.topicId) {
          tpc = t;
          break;
        }
      }

      LecturerCourseModel? crs;
      final targetCourseId = grp?.courseId ?? tpc?.courseId;
      if (targetCourseId != null) {
        for (final c in courses) {
          if (c.courseId == targetCourseId) {
            crs = c;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _group = grp;
          _topic = tpc;
          _course = crs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final registration = _current;
    final isPending = registration.status.trim() == 'Chờ duyệt';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text(
            'Chi tiết đăng ký đề tài',
            en: 'Topic Registration Details',
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: isPending
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUpdating ? null : _reject,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(
                        AppLocalizations.text('Từ chối', en: 'Reject'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.dangerColor,
                        side: const BorderSide(color: AppTheme.dangerColor),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isUpdating ? null : _approve,
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        AppLocalizations.text(
                          'Duyệt đăng ký',
                          en: 'Approve Registration',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                children: [
                  _RegistrationCard(registration: registration),
                  const SizedBox(height: 12),
                  _GroupCard(group: _group, registration: registration, course: _course),
                  const SizedBox(height: 12),
                  _TopicCard(
                    topic: _topic,
                    registration: registration,
                    group: _group,
                  ),
                  const SizedBox(height: 12),
                  _CourseCard(
                    course: _course,
                    group: _group,
                    topic: _topic,
                  ),
                  if (!isPending) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                AppLocalizations.text(
                                  'Đăng ký này đã được hoàn tất xử lý.',
                                  en: 'This registration has been fully processed.',
                                ),
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.text(
            'Duyệt đăng ký đề tài?',
            en: 'Approve Topic Registration?',
          ),
        ),
        content: Text(
          AppLocalizations.text(
            'Đăng ký sẽ chuyển sang trạng thái “Đã duyệt”.',
            en: 'Registration status will change to "Approved".',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              AppLocalizations.text(
                'Xác nhận duyệt',
                en: 'Confirm Approval',
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _isUpdating = true);
    try {
      await LecturerApiService.instance.approveTopicRegistration(_current.id, true);
      if (!mounted) return;
      setState(() {
        _current = _current.copyWith(status: 'Đã duyệt');
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Đã duyệt đăng ký đề tài.',
              en: 'Topic registration approved.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RegistrationRejectionDialog(),
    );

    if (!mounted || reason == null) return;

    setState(() => _isUpdating = true);
    try {
      await LecturerApiService.instance.approveTopicRegistration(
        _current.id,
        false,
        ghiChu: reason,
      );
      if (!mounted) return;
      setState(() {
        _current = _current.copyWith(status: 'Từ chối', rejectionReason: reason);
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              'Đã từ chối đăng ký đề tài.',
              en: 'Topic registration rejected.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _RegistrationRejectionDialog extends StatefulWidget {
  const _RegistrationRejectionDialog();

  @override
  State<_RegistrationRejectionDialog> createState() =>
      _RegistrationRejectionDialogState();
}

class _RegistrationRejectionDialogState
    extends State<_RegistrationRejectionDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppLocalizations.text('Từ chối đăng ký', en: 'Reject Registration'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.text(
              'Nhập lý do để nhóm có thể điều chỉnh đăng ký.',
              en: 'Enter reason so the group can adjust registration.',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: AppLocalizations.text(
                'Lý do từ chối',
                en: 'Rejection reason',
              ),
              errorText: _error,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(
                () => _error = AppLocalizations.text(
                  'Vui lòng nhập lý do từ chối.',
                  en: 'Please enter rejection reason.',
                ),
              );
            } else {
              Navigator.pop(context, reason);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.dangerColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            AppLocalizations.text(
              'Xác nhận từ chối',
              en: 'Confirm Rejection',
            ),
          ),
        ),
      ],
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final TopicRegistrationModel registration;

  const _RegistrationCard({required this.registration});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = _statusColor(registration.status);

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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${AppLocalizations.text('Đơn đăng ký', en: 'Registration')} #${registration.id}',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusBadge(
                label: AppLocalizations.status(registration.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xFF0284C7),
            label: AppLocalizations.text(
              'Thời gian đăng ký',
              en: 'Registration time',
            ),
            value: _formatDateTime(registration.registeredAt),
          ),
          if (registration.status.trim() == 'Từ chối' &&
              (registration.rejectionReason?.trim().isNotEmpty ?? false)) ...[
            const Divider(height: 20),
            Text(
              AppLocalizations.text('Lý do từ chối', en: 'Rejection reason'),
              style: const TextStyle(
                color: AppTheme.dangerColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              registration.rejectionReason!,
              style: TextStyle(color: colors.onSurface, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel? group;
  final TopicRegistrationModel registration;
  final LecturerCourseModel? course;

  const _GroupCard({
    required this.group,
    required this.registration,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (group == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Text(
          'Nhóm #${registration.groupId}',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.text('Nhóm sinh viên', en: 'Student Group'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.groupName(group!.name),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (group!.leader.isNotEmpty)
            _InfoRow(
              icon: Icons.stars_rounded,
              iconColor: const Color(0xFFF59E0B),
              label: AppLocalizations.text('Trưởng nhóm', en: 'Leader'),
              value: group!.leader,
            ),
          _InfoRow(
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFF6366F1),
            label: AppLocalizations.text('Số thành viên', en: 'Members'),
            value:
                '${group!.memberCount}/${course?.maxMembers ?? group!.maxMembers} ${AppLocalizations.text('sinh viên', en: 'students')}',
          ),
          if (course != null)
            _InfoRow(
              icon: Icons.tune_rounded,
              iconColor: const Color(0xFF0284C7),
              label: AppLocalizations.text(
                'Quy mô nhóm',
                en: 'Group size rule',
              ),
              value:
                  '${course!.minMembers} - ${course!.maxMembers} ${AppLocalizations.text('sinh viên/nhóm', en: 'students/group')}',
            ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicModel? topic;
  final TopicRegistrationModel registration;
  final GroupModel? group;

  const _TopicCard({
    required this.topic,
    required this.registration,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (topic == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Text(
          'Đề tài #${registration.topicId}',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.text('Đề tài đăng ký', en: 'Registered Topic'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.topicText(topic!.title),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          if (topic!.description.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.topicText(topic!.description),
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.45, fontSize: 13.5),
            ),
          ],
          const SizedBox(height: 12),
          if (topic!.objective.isNotEmpty)
            _InfoRow(
              icon: Icons.track_changes_rounded,
              iconColor: const Color(0xFF10B981),
              label: AppLocalizations.text('Mục tiêu', en: 'Objective'),
              value: AppLocalizations.topicText(topic!.objective),
            ),
          if (topic!.scope.isNotEmpty)
            _InfoRow(
              icon: Icons.crop_free_rounded,
              iconColor: const Color(0xFF8B5CF6),
              label: AppLocalizations.text('Phạm vi', en: 'Scope'),
              value: AppLocalizations.topicText(topic!.scope),
            ),
          if (topic!.technology.isNotEmpty)
            _InfoRow(
              icon: Icons.code_rounded,
              iconColor: const Color(0xFF0284C7),
              label: AppLocalizations.text('Công nghệ', en: 'Technology'),
              value: topic!.technology,
            ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final LecturerCourseModel? course;
  final GroupModel? group;
  final TopicModel? topic;

  const _CourseCard({
    required this.course,
    required this.group,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (course == null) return const SizedBox.shrink();

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
                width: 34,
                height: 34,
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.text('Lớp học phần', en: 'Course Class'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.courseName(course!.name),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.tag_rounded,
            iconColor: const Color(0xFF6366F1),
            label: AppLocalizations.text('Mã học phần', en: 'Course code'),
            value: course!.code,
          ),
          _InfoRow(
            icon: Icons.meeting_room_rounded,
            iconColor: const Color(0xFF0284C7),
            label: AppLocalizations.text('Mã lớp HP', en: 'Class code'),
            value: course!.classCode,
          ),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF10B981),
            label: AppLocalizations.text('Học kỳ', en: 'Semester'),
            value: course!.semester,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.trim()) {
    case 'Chờ duyệt':
      return AppTheme.warningColor;
    case 'Đã duyệt':
      return AppTheme.successColor;
    case 'Từ chối':
      return AppTheme.dangerColor;
    default:
      return AppTheme.grayColor;
  }
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} • $hour:$minute';
}
